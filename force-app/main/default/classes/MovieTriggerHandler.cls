public with sharing class MovieTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        Set<Id> movieIds = new Set<Id>();

        for (Movie__c movie : (List<Movie__c>) Trigger.new) {
            if (movie.TMDBid__c != null) {
                movieIds.add(movie.Id);
            }
        }

        if (!movieIds.isEmpty()) {
            MovieServiceProvider.processMovies(movieIds);
        }
    }

    public override void afterUpdate() {
        Set<Id> movieIds = new Set<Id>();

        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Movie__c newMovie = (Movie__c) Trigger.new[i];
            Movie__c oldMovie = (Movie__c) Trigger.old[i];
            
            if ((newMovie.TMDBid__c != null) && (newMovie.TMDBid__c != oldMovie.TMDBid__c)) {
                movieIds.add(newMovie.Id);
            }
        }

        if (!movieIds.isEmpty()) {
            MovieServiceProvider.processMovies(movieIds);
        }
    }
}
