@isTest
global class CalloutMockforPDF implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    string s1='test1';
    
    res.setStatusCode(200);
    res.setBody(s1);
    System.assertEquals('https://api.linkedin.com/uas/oauth/requestToken', 'https://api.linkedin.com/uas/oauth/requestToken');
    return res;
  }
 global class CalloutMockforPDFError implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('failed');
    res.setStatusCode(401);
    res.setBody('error');
        System.assertEquals('https://api.linkedin.com/uas/oauth/requestToken', 'https://api.linkedin.com/uas/oauth/requestToken');

    return res;
  }  
  }
}