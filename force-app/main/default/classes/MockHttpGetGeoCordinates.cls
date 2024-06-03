@IsTest
global class MockHttpGetGeoCordinates implements HttpCalloutMock{
   
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"results": [{ "geometry":{"location": {"lat": 44.4358321, "lng": 26.0500975}}} ], "status": "OK"}');
        res.setStatusCode(200);
        return res;
    }
}
