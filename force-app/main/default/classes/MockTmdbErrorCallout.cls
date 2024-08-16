@isTest
public class MockTmdbErrorCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(404);
        res.setBody('{"success": false, "status_code": 34, "status_message": "The resource you requested could not be found."}');
        return res;
    }
}
