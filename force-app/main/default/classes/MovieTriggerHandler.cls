public with sharing class MovieTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Movie__c> movies = (List<Movie__c>)Trigger.new;


        System.debug(movies);
        for (Movie__c movie : movies) {
            if (movie.TMDBid__c != null) {
                try {
                    tmdb.movieDetailResponseFuture(movie.TMDBid__c, movie.Id);
                } catch (Exception e) {
                    System.debug('Error queuing future method for TMDB_id ' + movie.TMDBid__c + ': ' + e.getMessage());
                }
            }
        }
    }
}
