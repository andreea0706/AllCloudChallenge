    public class MeteoResponseWrapper {
        public Daily daily {get;set;}
        public class Daily {
            public List<Integer> weather_code {get;set;}
            public List<Decimal> temperature_2m_min {get;set;}
            public List<Decimal> temperature_2m_max {get;set;}
        }
        
        public static MeteoResponseWrapper parse(String json) {
		    return (MeteoResponseWrapper) System.JSON.deserialize(json, MeteoResponseWrapper.class);
        }
    }