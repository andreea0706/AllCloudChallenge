@IsTest
global class MockHttpGetMeteoConditions implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"daily":{"time":["2024-06-02", "2024-06-03"], "weather_code":[3, 71, 95], "temperature_2m_max":[ 30.5, 32.5, 30.9], "temperature_2m_min":[19.7, 19.7, 20.0]}}');
        res.setStatusCode(200);
        return res;
    }
}
