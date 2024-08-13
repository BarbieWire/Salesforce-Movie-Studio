global class TMDBSyncBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, tmdbId__c, Revenue__c, Rating__c, TMDBSyncDate__c FROM Movie__c ' +
                       'WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c < LAST_N_DAYS:30) ' +
                       'AND tmdbId__c != NULL';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Movie__c> scope) {
        List<Movie__c> moviesToUpdate = new List<Movie__c>();
        
        for (Movie__c movie : scope) {
            // Call the method to get the data from the TMDB API
            MovieServiceProvider.updateMovieRecord(newMovie.TMDBid__c, newMovie.Id);
            
            if (tmdbData != null) {
                movie.Revenue__c = tmdbData.Revenue;
                movie.Rating__c = tmdbData.Rating;
                movie.TMDBSyncDate__c = Date.today();
                
                moviesToUpdate.add(movie);
            }
        }
        
        if (!moviesToUpdate.isEmpty()) {
            update moviesToUpdate;
        }
    }
}
