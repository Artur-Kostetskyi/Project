/**************************************************************************************
 * @Name         : WeatherWrapper
 * @Description  : Wrapper class for Weather Information from API request
 * @Created By   : Artur Kostetskyi
 * @Created Date : Aug 28, 2022
 * @Modification Log:
 * ************************************************************************************
 * Version          Developer                    Date               Description
 * ------------------------------------------------------------------------------------
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 **************************************************************************************/
public with sharing class WeatherWrapper {

	public class Weather {
		public Integer id;
		public String description;
		public String icon;
	}

	public List<Weather> weather;
	public Main main;

	public class Main {
		public Double temp;
	}

	public static WeatherWrapper parse(String json) {
		return (WeatherWrapper) System.JSON.deserialize(json, WeatherWrapper.class);
	}
}