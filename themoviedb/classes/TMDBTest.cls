@isTest
class TMDBTest {
    @isTest
    static void requestGenreList() {
        StaticResourceCalloutMock mock = getTMDBMockFromStaticResource('TMDBApiResponseGenreListMock');
        Test.setMock(HttpCalloutMock.class, mock);

        tmdb tmdbClient = new tmdb();
        tmdbGenreListResponse response = tmdbClient.genreList();
        System.assert(response.genres.size() > 0, 'List of genres must be returned');
    }

    @isTest
    static void searchMovie() {
        StaticResourceCalloutMock mock = getTMDBMockFromStaticResource('TMDBApiResponseSearchMovieMock');
        Test.setMock(HttpCalloutMock.class, mock);

        tmdb tmdbClient = new tmdb();
        tmdbSearchMovieResponse response = tmdbClient.searchMovie('saw');
        System.assert(response.results.size() > 0, 'List of movies must be returned');
    }

    static StaticResourceCalloutMock getTMDBMockFromStaticResource(String mockStaticResourceName) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(mockStaticResourceName);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        return mock;
    }
}
