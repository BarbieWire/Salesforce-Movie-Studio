public with sharing class tmdb {
    private static final String API_KEY = '824604f5e10070e0ec4a47a306b846a9';
    private static final String API_KEY_PARAM_NAME = 'api_key';
    private static final String API_VERSION = '3';

    private String authQueryParameter {
        get {
            return API_KEY_PARAM_NAME + '=' + API_KEY;
        }
    }

    private static final String BASE_URL = 'https://api.themoviedb.org/';

    private string buildResourceUrl(String resourceName) {
        return BASE_URL + API_VERSION + resourceName;
    }

    private HttpRequest authenticateRequest(HttpRequest request) {
        String endpoint = request.getEndpoint();
        if (endpoint.contains('?')) {
            endpoint += '&' + authQueryParameter;
        } else {
            endpoint += '?' + authQueryParameter;
        }
        request.setEndpoint(endpoint);

        return request;
    }

    public tmdbGenreListResponse genreList() {
        String resourceName = '/genre/movie/list';
        String endpoint = buildResourceUrl(resourceName);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);
        Http http = new Http();
        HttpResponse response = http.send(request);

        tmdbGenreListResponse tmdbResponse = (tmdbGenreListResponse) JSON.deserialize(response.getBody(), tmdbGenreListResponse.class);
        return tmdbResponse;
    }

    public tmdbSearchMovieResponse searchMovie(String title) {
        String resourceName = '/search/movie';
        String endpoint = buildResourceUrl(resourceName);
        endpoint += '?query=' + EncodingUtil.urlEncode(title, 'UTF-8');
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);

        request = authenticateRequest(request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response.getBody());

        tmdbSearchMovieResponse result = (tmdbSearchMovieResponse) JSON.deserialize(response.getBody(), tmdbSearchMovieResponse.class);
        return result;
    }

    public tmdMovieDetailResponse movieDetailResponse(String movieId) {
        String resourceName = '/movie/';
        String endpoint = buildResourceUrl(resourceName);
        endpoint += movieId;

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);

        Http http = new Http();
        HttpResponse response = http.send(request);

        tmdMovieDetailResponse result = (tmdMovieDetailResponse) JSON.deserialize(response.getBody(), tmdMovieDetailResponse.class);
        return result;
    }

        @future(callout=true)
        public static void movieDetailResponseFuture(String tmdbId, String movieId) {
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

                // Update the Movie__c record with the new data
                update movie;

            } catch (Exception e) {
                System.debug('Error in future method: ' + e.getMessage());
            }
        }

}
