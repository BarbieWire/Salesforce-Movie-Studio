global class TMDBSyncBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, tmdbId__c, Revenue__c, Rating__c, TMDBSyncDate__c
            FROM Movie__c
            WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c <= LAST_N_DAYS:30)
            AND tmdbId__c != NULL
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Movie__c> scope) {
        tmdb tmdbClient = new tmdb();
        List<Movie__c> moviesToUpdate = new List<Movie__c>();
        
        for (Movie__c movie : scope) {
            tmdMovieDetailResponse response = tmdbClient.movieDetailResponse(movie.TMDBid__c);
            movie.Revenue__c = response.revenue;
            movie.Rating__c = response.vote_average;
            movie.TMDBSyncDate__c = Date.today();

            moviesToUpdate.add(movie);
        }
        
        if (!moviesToUpdate.isEmpty()) {
            update moviesToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job finished');
    }

}
