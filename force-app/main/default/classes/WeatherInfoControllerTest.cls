@isTest
private class WeatherInfoControllerTest {
    @isTest
    static void requestAndValuesTest() {
        Account acc = new Account(Name = 'Account', ShippingCity = 'Funchal');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new WeatherHttpCalloutMock()); 
        PageReference testPage = Page.WeatherInfo; 
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        Test.startTest();
        WeatherInfoController weatherInfo = new WeatherInfoController(sc);
        Test.stopTest();
        System.assertEquals('few clouds', weatherInfo.acc.Weather_Description__c);
        System.assertEquals(295.34, weatherInfo.acc.Temperature__c);
        System.assertEquals('https://openweathermap.org/img/wn/02n.png', weatherInfo.acc.Weather_Icon__c);
    }
}
