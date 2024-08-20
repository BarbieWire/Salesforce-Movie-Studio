public class MovieBatchProcessor implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private Set<Id> movieIds;

    public MovieBatchProcessor(Set<Id> movieIds) {
        this.movieIds = movieIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, TMDBid__c FROM Movie__c WHERE Id IN :movieIds]);
    }

    public void execute(Database.BatchableContext bc, List<Movie__c> scope) {
        List<Movie__c> moviesToUpdate = new List<Movie__c>();
        TMDBSettings__c settings = TMDBSettings__c.getOrgDefaults();

        tmdb tmdbClient = new tmdb();

        Integer calloutCount = 0;
        Integer maxCalloutsPerBatch = 50;

        for (Movie__c movie : scope) {
            if (movie.TMDBid__c != null) {
                if (calloutCount >= maxCalloutsPerBatch) break;
                
                try {
                    tmdMovieDetailResponse result = tmdbClient.movieDetailResponse(movie.TMDBid__c);

                    movie.Description__c = result.overview;
                    movie.Title__c = result.original_title;
                    movie.Revenue__c = result.revenue;
                    movie.Rating__c = result.vote_average;
    
                    if (settings != null && settings.TMDBBasePosterURL__c != null) {
                        String baseUrl = settings.TMDBBasePosterURL__c;
                        movie.Poster__c = baseUrl + result.poster_path;
                    }
                    
                    movie.Budget__c = result.budget;
                    movie.TMDBSyncDate__c = Date.today();
    
                    moviesToUpdate.add(movie);
                    calloutCount++;
                } catch (Exception e) {
                    System.debug('Error processing movie ID ' + movie.TMDBid__c + ': ' + e.getMessage());
                }
            }
        }

        if (!moviesToUpdate.isEmpty()) {
            update moviesToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: Any post-processing after batch completion
    }
}
