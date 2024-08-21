public with sharing class ReviewBatchProcessor implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private Set<Id> movieIds;

    public ReviewBatchProcessor(Set<Id> movieIds) {
        this.movieIds = movieIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, TMDBId__c 
            FROM Movie__c 
            WHERE Id IN :movieIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Movie__c> scope) {
        List<Review__c> reviewsToInsert = new List<Review__c>();
        Set<Id> movieIdsInScope = new Set<Id>();

        TMDBSettings__c settings = TMDBSettings__c.getOrgDefaults();

        for (Movie__c movie : scope) {
            movieIdsInScope.add(movie.Id);
        }

        Map<Id, List<Review__c>> existingReviewsMap = new Map<Id, List<Review__c>>();
        for (Review__c review : [SELECT Id, Movie__c FROM Review__c WHERE Movie__c IN :movieIdsInScope]) {
            if (!existingReviewsMap.containsKey(review.Movie__c)) {
                existingReviewsMap.put(review.Movie__c, new List<Review__c>());
            }
            existingReviewsMap.get(review.Movie__c).add(review);
        }

        tmdb tmdbClient = new tmdb();
        Integer calloutCount = 0;
        Integer maxCalloutsPerBatch = 50;

        for (Movie__c movie : scope) {
            if (calloutCount >= maxCalloutsPerBatch) break;
            
            if (!existingReviewsMap.containsKey(movie.Id) || existingReviewsMap.get(movie.Id).isEmpty()) {
                String tmdbId = movie.TMDBId__c;

                if (tmdbId != null) {
                    tmdMovieReviewsResponse fetchedReviews = tmdbClient.getReviewsByTMDBId(tmdbId);
                    if (fetchedReviews.results != null && !fetchedReviews.results.isEmpty()) {

                        for (tmdMovieReviewsResponse.Review review : fetchedReviews.results) {
                            Review__c newReview = new Review__c();
                            newReview.Author__c = review.author;
                            newReview.Comment__c = review.content;
                            newReview.Movie__c = movie.Id;
                            newReview.Rating__c = review.author_details.rating;

                            if (settings != null && settings.TMDBBasePosterURL__c != null && review.author_details.avatar_path != null) {
                                String baseUrl = settings.TMDBBasePosterURL__c;
                                newReview.Avatar__c = baseUrl + review.author_details.avatar_path;
                            }

                            reviewsToInsert.add(newReview);
                        }
                    }
                    calloutCount++;
                }
            }
        }

        if (!reviewsToInsert.isEmpty()) {
            insert reviewsToInsert;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: Any post-processing after batch completion
    }
}