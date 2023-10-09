/*
Name: IncentiveBatchTest
Purpose: Test class for code coverage of IncentiveCaseUpdateBatch.
Author: Neha Agrawal
Date: 9/25/2020

ChangeLog

Author--             Date--                       Purpose--
Neha Agrawal        6/16/2021          to cover the IncentiveActionRequiredCaseBatch as well
*/


@istest
Private class IncentiveBatchTest {
    
    @testSetup 
    static void setup(){
        List<Case> caseList=new List<case>();
        case c =new case(Form_name__c='Incentives Challenge',status='Approved - Validation Pending',
                         Challenge__c='CH_SET_CHALLENGE',
                        Retail_Date__c=system.Today());
        Account a=TestClientUtils.createAccount();
        a.Email_list__c='Test@email.com';
        insert a;
        case c1 =new case(Form_name__c='Incentives Challenge',status='Document Upload Required',
                          Challenge__c='CH_SET_CHALLENGE',
                         AccountId=a.Id,
                         Retail_Date__c=system.Today());
        caseList.add(c);
        caseList.add(c1);
        Insert caseList;
        MuleTokenRequest__c m=new MuleTokenRequest__c();
        m.name='MuleToken';
        m.RetryCriteria__c='null;1';
        m.TokenURL__c='Test';
        m.GrantType__c='Test';
        m.Scope__c='Test';
        m.ActionRequiredBatchCriteria__c='Challenge__c not in (\'NO_MATCH\',\'EXPORT\') ';
        m.IncentiveEmailListSeparator__c=';';
        m.Inc_Team_Email_Address__c='Test@email.com';
        m.Current_Salesforce_Admin__c='Test@email.com';
        insert m;
    }
    static testmethod void testIncentiveActionRequireBatch() {
        Test.startTest();
        IncentiveActionRequiredCaseBatch batch = new IncentiveActionRequiredCaseBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
    
    static testmethod void testSuccessIncentiveBatch() { 
        Test.setMock(HttpCalloutMock.class, new IncentiveBatchSuccessMock());
        Test.startTest();
        IncentiveCaseUpdateBatch uca = new IncentiveCaseUpdateBatch();
        //uca.expiresinsec=system.Now();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
     static testmethod void testErrorIncentiveBatch() { 
        Test.setMock(HttpCalloutMock.class, new IncentiveBatchErrorMock());
        Test.startTest();
        IncentiveCaseUpdateBatch uca = new IncentiveCaseUpdateBatch();
        //uca.expiresinsec=system.Now();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
    public class IncentiveBatchSuccessMock implements HttpCalloutMock {
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
        public class IncentiveBatchErrorMock implements HttpCalloutMock {
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