@isTest
public class MockTmdbCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTPResponse object
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);

        // Create mock TMDB API JSON response
        String jsonResponse = '{"overview": "Test Description", "original_title": "Test Title", "revenue": 500000, "vote_average": 7.5, "poster_path": "/testposter.jpg", "budget": 200000}';
        res.setBody(jsonResponse);
        return res;
    }
}