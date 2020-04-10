@IsTest
global class HttpMockResponseGenerator implements HttpCalloutMock
{
    // Set the response in your test class so this just passes it back
    public HttpResponse response = new HttpResponse();
    
    global HTTPResponse respond(HTTPRequest request) {
        return response;
    }
}