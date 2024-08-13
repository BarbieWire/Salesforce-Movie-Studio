public with sharing class MovieServiceProvider {
    @future(callout=true)
    public static void updateMovieRecords(Set<Id> movieIds) {
        List<Movie__c> moviesToUpdate = new List<Movie__c>();
        
        for (String movieId : movieIds) {
            Movie__c movie = [SELECT Id, TMDBid__c, Description__c, Title__c, Revenue__c, 
                  Rating__c, Poster__c, Budget__c
                  FROM Movie__c WHERE Id = :movieId LIMIT 1];


            tmdb tmdbClient = new tmdb();
            tmdMovieDetailResponse result = tmdbClient.movieDetailResponse(movie.TMDBid__c);

            movie.Description__c = result.overview;
            movie.Title__c = result.original_title;
            movie.Revenue__c = result.revenue;
            movie.Rating__c = result.vote_average;
            movie.Poster__c = result.poster_path;
            movie.Budget__c = result.budget;

            moviesToUpdate.add(movie);
        }

        update moviesToUpdate;
    }
}