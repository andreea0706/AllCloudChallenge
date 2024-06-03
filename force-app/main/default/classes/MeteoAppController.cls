public with sharing class MeteoAppController {
    

    public class MeteoWrapper {
        @AuraEnabled
        public String dateTimeValue;	
        @AuraEnabled
        public Decimal maxTemp;
        @AuraEnabled
        public Decimal minTemp;
        @AuraEnabled
        public String weatherCode;
    }

    @AuraEnabled
    public static List<MeteoWrapper> checkWeather(String latitude, String longitude){
        try {
            List<MeteoWrapper> meteoWrapper = new List<MeteoWrapper>();
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String endpoint = 'daily=weather_code,temperature_2m_max,temperature_2m_min&'+'latitude=' + latitude + '&longitude=' + longitude;
            req.setEndpoint('callout:Meteo_Api/v1/forecast?' + endpoint);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            String resp = res.getBody();
            MeteoResponseWrapper responseWrapper = MeteoResponseWrapper.parse(resp);
            for (Integer i = 0; i < responseWrapper.daily.temperature_2m_max.size(); i++) {
                MeteoWrapper item = new MeteoWrapper();
                item.dateTimeValue = String.valueof(Date.today().addDays(i));
                item.maxTemp = responseWrapper.daily.temperature_2m_max.get(i);
                item.minTemp = responseWrapper.daily.temperature_2m_min.get(i);
                item.weatherCode = MeteoUtil.getMeteoInterpretationCode(responseWrapper.daily.weather_code.get(i));
                meteoWrapper.add(item);
            }

            return meteoWrapper;
         
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getGeoCoordinates(String address){
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String addressEncoded = EncodingUtil.urlEncode(address , 'UTF-8');
            req.setEndpoint('callout:Google_Api/maps/api/geocode/json?address=' + addressEncoded + '&key=' + System.Label.Google_Api_Key);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            String resp = res.getBody();
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
