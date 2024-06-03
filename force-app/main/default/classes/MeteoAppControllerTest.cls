@IsTest
public class MeteoAppControllerTest {
    

    @IsTest
    public static void getGeoCoordinatesTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpGetGeoCordinates());
        String address = 'Bulevardul Iuliu Maniu 6R + Bucuresti + 061103 + Romania';
        String jsonResponse = MeteoAppController.getGeoCoordinates(address);
        Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Assert.areEqual('OK', (String) mapResponse.get('status'), 'Status response is wrong ' + mapResponse.get('status')); 

        List<Object> mapResults = (List<Object>) mapResponse.get('results');
        Map<String, Object> results = (Map<String, Object>) mapResults.get(0);
        Map<String, Object> geometry = (Map<String, Object>) results.get('geometry');
        Map<String, Object> location = (Map<String, Object>) geometry.get('location');
        Assert.areEqual(44.4358321, (Decimal) location.get('lat'), 'Latitude response is wrong ' + mapResponse.get('lat')); 
        Assert.areEqual(26.0500975, (Decimal) location.get('lng'), 'Longitude response is wrong ' + mapResponse.get('lng')); 

    }


    @IsTest
    public static void checkWeatherTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpGetMeteoConditions());
        List<MeteoAppController.MeteoWrapper> wrapper = MeteoAppController.checkWeather('44.4358321','26.0500975');
        System.debug(wrapper);
        Assert.areEqual('2024-06-03', wrapper.get(0).dateTimeValue, 'wrong date ' + wrapper.get(0).dateTimeValue); 
        Assert.areEqual(30.5,  wrapper.get(0).maxTemp, 'wrong max Temp ' + wrapper.get(0).maxTemp); 
        Assert.areEqual(19.7, wrapper.get(0).minTemp, 'wrong max Temp ' + wrapper.get(0).minTemp); 
        Assert.areEqual('Mainly clear, partly cloudy, and overcast', wrapper.get(0).weatherCode, 'wrong weather code ' + wrapper.get(0).weatherCode); 
        Assert.areEqual(3, wrapper.size(), 'Wrong number of items ' + wrapper.size()); 

        
    }

}
