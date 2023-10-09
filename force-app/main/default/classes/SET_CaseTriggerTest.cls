@isTest
public with sharing class SET_CaseTriggerTest {

    static TestMethod void DStestCas() {
        Id DSProfileId = [ SELECT Name FROM Profile WHERE Name = 'JMSC - Dealer Services' ][0].Id;
        User objUser = TestClientUtils.createUser(DSProfileId, 'Test First' , 'Test Last', 'testfirst.testlast@infojm.com', 'testfirst.testlast@infojm.com');   
        insert objUser;     
        Test.startTest();
        system.runAs(objUser) {
            SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
            setDistInfo.ISDM_User__c = UserInfo.getUserId();
            insert setDistInfo;
            List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
            listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
            listAccounts.get(0).District__c = '100';
            insert  listAccounts;
            List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
            DS_Product__c objProduct = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
            insert objProduct;
            DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
            insert subcategory;
            listCases.get(0).DS_Vendor_Product_cust__c = objProduct.Id;
            listCases.get(0).DS_Subproduct__c = subcategory.Id;
            insert listCases;
            List < DS_Customer_Details__c > listCustDetails = TestClientUtils.createCustomerDetails(listCases, 1, true) ;
            listCases.get(0).Status = 'Closed';
            update listCases;
        }
        Test.stopTest();
    }   
    
    static TestMethod void SETtestCas() {
        Test.startTest();
        SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
        setDistInfo.ISDM_User__c = UserInfo.getUserId();
        insert setDistInfo;
        List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
        listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
        listAccounts.get(0).District__c = '100';
        insert  listAccounts;
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);      
        insert listCases;
        listCases.get(0).SET_Follow_Up_Results__c = 'Confirmed Fix';
        update listCases;
        Test.stopTest();
    }
     
   static TestMethod void SETPartstestCas() {
        Id DSProfileId = [ SELECT Name FROM Profile WHERE Name =  'SET- Parts Technical'][0].Id;
        User objUser = TestClientUtils.createUser(DSProfileId, 'Part First' , 'Part Last', 'partfirst.testlast@infojm.com', 'partfirst.testlast@infojm.com');   
        insert objUser;     
        Test.startTest();
        system.runAs(objUser) {
            SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
            setDistInfo.ISDM_User__c = UserInfo.getUserId();
            insert setDistInfo;
            List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
            listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
            listAccounts.get(0).District__c = '100';
            insert  listAccounts;
            List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
            DS_Product__c objProduct = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
            insert objProduct;
            listCases.get(0).DS_Vendor_Product_cust__c = objProduct.Id;
            insert listCases;
            listCases.get(0).DS_Support_Team__c = 'SET Parts Support';
            listCases.get(0).DS_Knowledge__c = 'Yes';
            List < DS_Customer_Details__c > listCustDetails = TestClientUtils.createCustomerDetails(listCases, 1, true) ;
            listCases.get(0).Status = 'Closed';
            update listCases;
        }
        Test.stopTest();
    }   
   
}