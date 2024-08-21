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
        result.request_success = response.getStatusCode();
        return result;
    }

    public tmdMovieReviewsResponse getReviewsByTMDBId(String movieId) {
        String resourceName = '/movie/' + movieId + '/reviews';
        String endpoint = buildResourceUrl(resourceName);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);

        Http http = new Http();
        HttpResponse response = http.send(request);

        tmdMovieReviewsResponse result = (tmdMovieReviewsResponse) JSON.deserialize(response.getBody(), tmdMovieReviewsResponse.class);

        return result;
    }
}
