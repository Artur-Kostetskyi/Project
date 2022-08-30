/**************************************************************************************
 * @Name         : WeatherInfoController
 * @Description  : Class makes get request to OpenWeatherMap and sets values on the WeatherInfo page
 * @Created By   : Artur Kostetskyi
 * @Created Date : Aug 25, 2022
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
public with sharing class WeatherInfoController {
    public Account acc { get; set; } 
    
    public WeatherInfoController(ApexPages.StandardController stdController) {
        System.debug(ApexPages.currentPage().getParameters().get('Id'));
        try {
            acc = [Select Id, Weather_Description__c, Temperature__c, Weather_Icon__c, ShippingCity, BillingCity
            FROM Account
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        setWeatherInfo();
    }

    private WeatherWrapper makeRequest() {
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String city = acc.ShippingCity != null ? acc.ShippingCity : acc.BillingCity;
        String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid=a944543861634ed950896a39a09ab211';
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        if (response.getStatus().equals('OK')) {
            return WeatherWrapper.parse(response.getBody());
        } else {
            return null;
        }
    }

    private void setWeatherInfo() {
        WeatherWrapper weatherWrap = makeRequest();
        System.debug(weatherWrap);
        if (weatherWrap != null) {
            List<WeatherWrapper.Weather> weatherList = weatherWrap.weather;
            acc.Weather_Description__c = weatherList.get(0).description;
            acc.Temperature__c = weatherWrap.main.temp;
            acc.Weather_Icon__c = 'https://openweathermap.org/img/wn/' + weatherList.get(0).icon + '.png';
        }
    }
}
