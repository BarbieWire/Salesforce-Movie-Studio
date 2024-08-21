public with sharing class TMBDIntegrationController {
    public class MovieResponseFromClient {
        @AuraEnabled
        public List<Integer> genre_ids { get; set; }
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
    public static String getTitleOfExistingRecord(Id recordId) {
        Movie__c movie = [SELECT Title__c FROM Movie__c WHERE Id = :recordId LIMIT 1];
        return movie.Title__c;
    }

    private static Map<Integer, String> getOfficialGenres() {
        Map<Integer, String> result = new Map<Integer, String>();

        tmdb requestHandler = new tmdb();
        tmdbGenreListResponse response = requestHandler.genreList();

        for (tmdbGenre genre : response.genres) {
            result.put(genre.id, genre.name);
        }

        return result;
    }

    private static String processMovieGenre(Map<Integer, String> genres, MovieResponseFromClient movieNewData) {
        try {
            // Convert genre IDs to genre names
            List<String> genreNames = new List<String>();
            if (movieNewData.genre_ids != null) {
                for (Integer genreId : movieNewData.genre_ids) {
                    if (genres.containsKey(genreId)) {
                        String genreName = genres.get(genreId);
                        if (genreName.split(' ').size() > 1) {
                            genreName = genreName.replace(' ', '_');
                        }
                        genreNames.add(genreName);
                    }
                }
            }
            // Convert the List<String> genreNames to a single String for the multi-picklist
            if (genreNames != null && !genreNames.isEmpty()) {
                return String.join(genreNames, ';');
            } 
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateMovieRecord(MovieResponseFromClient movieNewData, Id recordId) {
        Movie__c movie = [SELECT Id, TMDBId__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :recordId LIMIT 1];

        movie.TMDBId__c = movieNewData.record_id;
        movie.TMDBSyncDate__c = Date.today();
        movie.Description__c = movieNewData.overview;
        movie.Rating__c = movieNewData.rating;

        Map<Integer, String> genres = getOfficialGenres();
        String processedGenres = processMovieGenre(genres, movieNewData);
        movie.Genre__c = processedGenres;
        
        update movie;
    }

    @AuraEnabled
    public static List<Review__c> getReviewsByMovieId(Id movieId) {
        List<Review__c> reviews = [
            SELECT Id, Author__c, Comment__c, Rating__c, CreatedDate, Avatar__c
            FROM Review__c 
            WHERE Movie__c = :movieId
            ORDER BY CreatedDate DESC
        ];

        return reviews;
    }
}