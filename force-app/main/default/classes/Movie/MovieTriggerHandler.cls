public with sharing class MovieTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Movie__c> movies = (List<Movie__c>)Trigger.new;

        for (Movie__c movie : movies) {
            if (movie.TMDBid__c != null) {
                try {
                    MovieServiceProvider.updateMovieRecord(movie.TMDBid__c, movie.Id);
                } catch (Exception e) {
                    System.debug('Error queuing future method for TMDB_id ' + movie.TMDBid__c + ': ' + e.getMessage());
                }
            }
        }
    }

    public override void afterUpdate() {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Movie__c newMovie = (Movie__c)Trigger.new[i];
            Movie__c oldMovie = (Movie__c)Trigger.old[i];
            
            if ((newMovie.TMDBid__c != null) && (newMovie.TMDBid__c != oldMovie.TMDBid__c)) {
                MovieServiceProvider.updateMovieRecord(newMovie.TMDBid__c, newMovie.Id);
            }
        }
    }
    
}
