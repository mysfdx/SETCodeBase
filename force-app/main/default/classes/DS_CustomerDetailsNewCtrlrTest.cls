@isTest
public with sharing class DS_CustomerDetailsNewCtrlrTest {
    
    @TestSetup static void dataSetup() {
        DS_AD_Lookup_Config__c objConfig = new DS_AD_Lookup_Config__c(Name = 'ADLookup', DS_API_URL__c = 'www.test.com', DS_Certification_URL__c = 'www.test.com', DS_Refresh_Token__c = 'Test');
        objConfig.DS_Authorization_Header__c = 'Test';
        insert objConfig;
    }
    
    private static testMethod void testWebServ() {        
        DS_Customer_Details__c custDetails = new DS_Customer_Details__c();
        DS_CustomerDetailsNewCtrlr obj = new DS_CustomerDetailsNewCtrlr(new ApexPages.StandardController(custDetails));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DS_DealerDailyWebServiceMock());
        obj.fetchCustomerDetails();
        Test.stopTest();
    }   
    
    static testMethod void testCustNew() {
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, true);
        List<DS_Customer_Details__c> listCustDetails = TestClientUtils.createCustomerDetails(listCases, 1, true);
        apexpages.currentpage().getparameters().put('retURL' , listCases.get(0).Id);
        Test.startTest();
        DS_CustomerDetailsNewCtrlr obj = new DS_CustomerDetailsNewCtrlr(new ApexPages.StandardController(listCustDetails.get(0)));
        obj.inserCust();
        obj.applyDefaultValues();
        Test.stopTest();
    }
    
}