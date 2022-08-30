@isTest
global class WeatherHttpCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"coord":{"lon":-16.9,"lat":32.6333},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02n"}],"base":"stations","main":{"temp":295.34,"feels_like":295.78,"temp_min":294.33,"temp_max":295.77,"pressure":1019,"humidity":83},"visibility":10000,"wind":{"speed":2.57,"deg":330},"clouds":{"all":20},"dt":1661809122,"sys":{"type":2,"id":2009137,"country":"PT","sunrise":1661755233,"sunset":1661801824},"timezone":3600,"id":2267827,"name":"Funchal","cod":200}');
        return response; 
    }
}