public with sharing class MovieTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Movie__c> movies = (List<Movie__c>)Trigger.new;
        Set<Id> movieIds = new Set<Id>();

        for (Movie__c movie : movies) {
            system.debug(movie.TMDBid__c);
            if (movie.TMDBid__c != null) {
                movieIds.add(movie.Id);
            }
        }

        try {
            system.debug(movieIds);
            if (!movieIds.isEmpty()){
                 MovieServiceProvider.updateMovieRecords(movieIds);
            }
        } catch (Exception e) {
            System.debug('Error queuing future method in after insert' + ': ' + e.getMessage());
        }
    }

    public override void afterUpdate() {
        Set<Id> movieIds = new Set<Id>();

        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Movie__c newMovie = (Movie__c)Trigger.new[i];
            Movie__c oldMovie = (Movie__c)Trigger.old[i];
            
            if ((newMovie.TMDBid__c != null) && (newMovie.TMDBid__c != oldMovie.TMDBid__c)) {
                movieIds.add(newMovie.Id);
            }
        }
        // invoke async update method 
        if (!movieIds.isEmpty()) {
            MovieServiceProvider.updateMovieRecords(movieIds);
        }
    }
}
