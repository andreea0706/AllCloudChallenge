public with sharing class MeteoUtil {
   
    public static String getMeteoInterpretationCode(Integer code) {
    
        switch on code {
            when 0  {
                return 'Clear sky';
            }
            when 1, 2, 3  {
                return 'Mainly clear, partly cloudy, and overcast';
            }
            when 45, 48 {
                return 'Fog and depositing rime fog';
            }
            when 51, 53, 55 {
                return 'Drizzle: Light, moderate, and dense intensity';
            }
            when 56, 57 {
                return 'Freezing Drizzle: Light and dense intensity';
            }
            when 61, 63, 65 {
                return 'Rain: Slight, moderate and heavy intensity';
            }
            when 66, 67 {
                return 'Freezing Rain: Light and heavy intensity';
            }
            when 71, 73, 75 {
                return 'Snow fall: Slight, moderate, and heavy intensity';
            }
            when 77 {
                return 'Snow grains';
            }
            when 80, 81, 82 {
                return 'Rain showers: Slight, moderate, and violent';
            }
            when 85, 86 {
                return 'Snow showers slight and heavy';
            }
            when 95 {
                return 'Thunderstorm: Slight or moderate';
            }
            when 96, 99  {
                return 'Thunderstorm with slight and heavy hail';
            }
            when else {
                return 'Weather code cannot be found';
            }
        } 
    }
}
