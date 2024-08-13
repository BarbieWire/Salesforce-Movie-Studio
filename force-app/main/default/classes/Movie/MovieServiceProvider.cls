public with sharing class MovieServiceProvider {
    @future(callout=true)
    public static void updateMovieRecord(String tmdbId, String movieId) {
        try {
            tmdb tmdbClient = new tmdb();
            tmdMovieDetailResponse result = tmdbClient.movieDetailResponse(tmdbId);
                
            Movie__c movie = [SELECT Id, Description__c, Title__c, Revenue__c, 
            Rating__c, Poster__c, Budget__c
            FROM Movie__c WHERE Id = :movieId LIMIT 1];

            movie.Description__c = result.overview;
            movie.Title__c = result.original_title;
            movie.Revenue__c = result.revenue;
            movie.Rating__c = result.vote_average;
            movie.Poster__c = result.poster_path;
            movie.Budget__c = result.budget;
            update movie;

        } catch (Exception e) {
            System.debug('Error in future method: ' + e.getMessage());
        }
    }
}