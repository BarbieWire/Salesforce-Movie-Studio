public with sharing class TMDBIntegration {
    public class MovieResponseFromClient {
        @AuraEnabled
        public List<Integer> genre_ids { get; set; }
        @AuraEnabled
        public List<String> genres { get; set; }
        @AuraEnabled
        public String overview { get; set; }
        @AuraEnabled
        public Decimal rating { get; set; }
        @AuraEnabled
        public String record_id { get; set; }
        @AuraEnabled
        public String title { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchMovie(String title) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        tmdb requestHandler = new tmdb();
        tmdbSearchMovieResponse response = requestHandler.searchMovie(title);
        List<tmdbSearchMovieResult> movies = response.results;

        for (tmdbSearchMovieResult movie : movies) {
            Map<String, Object> result = new Map<String, Object>();
            result.put('title', movie.original_title);
            result.put('rating', movie.vote_average);
            result.put('overview', movie.overview);
            result.put('record_id', movie.id);
            result.put('genre_ids', movie.genre_ids);

            results.add(result);
        }
        
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Integer, String> getOfficialGenres() {
        Map<Integer, String> result = new Map<Integer, String>();

        tmdb requestHandler = new tmdb();
        tmdbGenreListResponse response = requestHandler.genreList();

        for (tmdbGenre genre : response.genres) {
            result.put(genre.id, genre.name);
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getMovieTitle(Id recordId) {
        Movie__c movie = [SELECT Title__c FROM Movie__c WHERE Id = :recordId LIMIT 1];
        return movie.Title__c;
    }

    @AuraEnabled
    public static void updateMovieRecord(MovieResponseFromClient movieNewData, Id recordId) {
        Movie__c movie = [SELECT Id, TMDBId__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :recordId LIMIT 1];

        movie.TMDBId__c = movieNewData.record_id;
        movie.TMDBSyncDate__c = Date.today();
        movie.Description__c = movieNewData.overview;
        movie.Rating__c = movieNewData.rating;

        // Convert the List<String> genres to a single String for the multi-picklist
        if (movieNewData.genres != null && !movieNewData.genres.isEmpty()) {
            movie.Genre__c = String.join(movieNewData.genres, ';');
        } else {
            movie.Genre__c = null;
        }
        
        update movie;
    }
}