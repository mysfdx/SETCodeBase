/*Name:backhaulFormControllerTest
Purpose:Test Class for backhaulFormController
Author:Neha Agrawal
Date:3/10/2023

Change Log
Date - Changed by - Change Description
*/

@IsTest
public class backhaulFormControllerTest {
    
    @TestSetup
    private static void buildTestData(){
        List<Backhaul_Mule_API__c> muleApis=New List<Backhaul_Mule_API__c>();
        Backhaul_Mule_API__c muleApi1=New Backhaul_Mule_API__c();
        muleApi1.Name='BackhaulCostAPI';
        muleApi1.client_id__c='client-id';
        muleApi1.event_id__c='VEHBKHAULCST';
        muleApi1.transaction_id__c='123456';
        muleApi1.event_seq__c='120';
        muleApi1.last_in_seq_flag__c='Y';
        muleApi1.API_URL__c='Test';
        muleApis.add(muleApi1);
        Backhaul_Mule_API__c muleApi2=New Backhaul_Mule_API__c();
        muleApi2.Name='BackhaulRequestAPI';
        muleApi2.client_id__c='client-id';
        muleApi2.event_id__c='VEHBKHAULREQ';
        muleApi2.transaction_id__c='123456';
        muleApi2.event_seq__c='120';
        muleApi2.last_in_seq_flag__c='Y';
        muleApi2.API_URL__c='Test';
        muleApis.add(muleApi2);
        Insert muleApis;
        MuleTokenRequest__c mt=new MuleTokenRequest__c();
        mt.Name='BackhaulMuleToken';
        mt.client_id__c='123456';
        mt.client_secret__c='123456';
        mt.TokenURL__c='https://login.microsoftonline.com/';
        mt.Scope__c='scope';
        mt.Email_Addresses__c='SETDLR_[FromDlrCd]_NEW_VEHICLE_SALES_MANAGER@SETDEALERDAILY.COM;'+
             'SETDLR_[FromDlrCd]_INVENTORY_MANAGER@SETDEALERDAILY.COM';
        mt.GrantType__c='client_credentials';
        insert mt;
        
    }
    
    @IsTest
    private static void caseInfoTest(){
        backhaulFormController.getCaseInfo();
    }
    
    @IsTest
    private static void backhaulCostTestSuccess(){
         Test.setMock(HttpCalloutMock.class, new backhaulSuccessMock());
        Test.startTest();
        backhaulFormController.returnBackhaulCost('12345','12345','12345');
         Test.stopTest();
    }
    
    
    @IsTest
    private static void backhaulCostTestFailure(){
         Test.setMock(HttpCalloutMock.class, new backhaulErrorMock());
        Test.startTest();
        backhaulFormController.returnBackhaulCost('12345','12345','12345');
         Test.stopTest();
    }
    
    @IsTest
    private static void backhaulReqTestSuccess(){
         Test.setMock(HttpCalloutMock.class, new backhaulSuccessMock());
        Test.startTest();
        Case backhaulCase= New Case();
        backhaulFormController.backhaulRequestSubmission('12345','12345','12345','Test','Test','Test',
                                                         backhaulCase,'850');
         Test.stopTest();
    }
    
    
    @IsTest
    private static void backhaulReqTestFailure(){
         Test.setMock(HttpCalloutMock.class, new backhaulErrorMock());
        Test.startTest();
        Case backhaulCase= New Case();
        backhaulFormController.backhaulRequestSubmission('12345','12345','12345','Test','Test','Test',
                                                         backhaulCase,'850');
         Test.stopTest();
    }
    
     @IsTest
    private static void testBackhaulEmail(){
         Test.startTest();
        Account backhaulAccount= TestClientUtils.createAccount();
        insert backhaulAccount;
        Account a=[SELECT Dealer_Code__c, Id FROM Account WHERE Id=:backhaulAccount.Id LIMIT 1];
        backhaulFormController.sentBackhaulEmail(a.Dealer_Code__c,a.Dealer_Code__c,'Test','Test',
                                                 '850','12345','Test','Test');
         Test.stopTest();
        
    }
    public class backhaulSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            String strJSON = '{"access_token" : "Test", "expires_in" : 355.0}';
            //'{"client_id" : "Test", "client_secret" : "Test", "grant_type" : "Test", "scope" : "Test"}';
            //strJSON += '"PrimaryDealership" : true, "SETNumber" : "55555", "SPIN" : "2", "UserName " : "Test"}';
            //'client_id=' + Clientid + '&client_secret=' + Clientsec + '&grant_type=client_credentials&scope=api://jmfamily.com/set/dealerincentivesdashboard-qa/.default';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(strJSON);
            response.setStatusCode(200);
            return response; 
        }
    }
        public class backhaulErrorMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest request) {
                String strJSON = '{"access_token" : "Test", "expires_in" : 355.0}';
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(strJSON);
                response.setStatusCode(404);
                return response; 
            }
        }

}