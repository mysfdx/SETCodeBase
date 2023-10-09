@isTest
global class DS_DealerDailyWebServiceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String strJSON = '{"LegalFirstName" : "Test", "LegalLastName" : "Test", "DPUserId" : "Test", "CellPhone" : "9999999999", "Email" : "Test@test.com", ';
        strJSON += '"PrimaryDealership" : true, "SETNumber" : "55555", "SPIN" : "2", "UserName " : "Test"}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(strJSON);
        response.setStatusCode(200);
        return response; 
    }
}