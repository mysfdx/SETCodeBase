@isTest
private Class DS_CasePages_Test {
    
    private static TestMethod void casExtTest() {
        SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
        setDistInfo.ISDM_User__c = UserInfo.getUserId();
        insert setDistInfo;
        List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
        listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
        listAccounts.get(0).District__c = '100';
        insert  listAccounts;
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subcategory;
        Case cs = TestClientUtils.createCases(listAccounts, 1, false).get(0);
        List < Contact > listContacts = TestClientUtils.createContacts(listAccounts, 2, false);      
        listContacts.get(0).Role__c = 'IT Contact';
        listContacts.get(1).Role__c = 'DD System Admin';
        insert listContacts;
        DS_Product__c prod = TestClientUtils.getProduct('Dealer Daily', 'Apps Services', 'CRM');
        insert prod;
        listCases.get(0).DS_Vendor_Product_cust__c = product.Id;
        listCases.get(0).DS_Subproduct__c = subcategory.Id;
        insert listCases.get(0);
        Test.startTest();
        DS_CaseExtension ext = new DS_CaseExtension(new ApexPages.StandardController(cs));
        ext.caseTypeSel();
        ext.cas.DS_Vendor_Product_cust__c = product.Id;
        ext.cas.DS_Subproduct__c = subcategory.Id;
        ext.cas.DS_Customer_Name__c = listAccounts.get(0).Id;
        ext.cas.DS_Username__c = 'Test';
        ext.cas.DS_Customer_Name_cust__c = 'Test';
        ext.cas.Subject = 'Test Subject';
        ext.cas.DS_App_Function__c = 'VSP';
        ext.cas.DS_Requester_Type__c = 'Associate';
        ext.newCase();
        ext.fetchRecentCases();
        ext.caseTypeSel();   
        Test.stopTest();        
    }   
    
    private static TestMethod void casWebServcTest() {
        SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
        setDistInfo.ISDM_User__c = UserInfo.getUserId();
        insert setDistInfo;
        List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
        listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
        listAccounts.get(0).District__c = '100';
        listAccounts.get(0).Dealer_Code__c = '55555';
        insert  listAccounts;
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subcategory;
        Case cs = TestClientUtils.createCases(listAccounts, 1, false).get(0);
        List < Contact > listContacts = TestClientUtils.createContacts(listAccounts, 2, false);      
        listContacts.get(0).Role__c = 'IT Contact';
        listContacts.get(1).Role__c = 'DD System Admin';
        listContacts.get(0).RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer Community Contact').getRecordTypeId();
        listContacts.get(1).RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer Community Contact').getRecordTypeId();
        listContacts.get(0).Current_SPIN__c = '1042';
        listContacts.get(1).Current_SPIN__c = '1042';
        insert listContacts;
        DS_Product__c prod = TestClientUtils.getProduct('Dealer Daily', 'Apps Services', 'CRM');
        insert prod;
        listCases.get(0).DS_Vendor_Product_cust__c = product.Id;
        listCases.get(0).DS_Subproduct__c = subcategory.Id;
        insert listCases.get(0);
        DS_CaseExtension ext = new DS_CaseExtension(new ApexPages.StandardController(cs));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DS_DealerDailyWebServiceMock());
        ext.fetchCustomerDetails();
        ext.newCase();
        ext.applyDefaultValues();   
        Test.stopTest();
    }
    
    private static TestMethod void casOvrTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, true);
       
        DS_CaseoverridePage ext= new DS_CaseoverridePage(new ApexPages.StandardController(listCases.get(0)));
        Test.setCurrentPage(Page.DS_CaseRedirect);
        ext.redirectToPage();
        
    }   
    private static TestMethod void casOvrJMSCDSTest() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='JMSC - Dealer Services'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        system.runAs(u){
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SET SmartPath').getRecordTypeId();
        
        Case newCase = new Case();
        newCase.RecordTypeId = caseRecordTypeId;
        newCase.JMA_Business_Unit__c = 'Dealer Services';
        newCase.DS_Time_Spent_In_Minutes__c = 5;
        newCase.DS_Time_Entry_Mins__c = '5';
        newCase.DS_Time__c = '2';
        newCase.AccountId = listAccounts.get(0).Id;
        insert newCase;
        DS_CaseoverridePage ext1= new DS_CaseoverridePage(new ApexPages.StandardController(newCase));
        Test.setCurrentPage(Page.DS_CaseRedirect);
        ext1.redirectToPage();
        }
        
        
    }   
    
    private static TestMethod void casEdtTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, true);
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subcategory;
        Test.startTest();
        Case cs = listCases.get(0);
        cs.DS_Vendor_Product_cust__c = product.Id;
        cs.DS_Subproduct__c = subcategory.Id;
        cs.DS_Customer_Name__c = listAccounts.get(0).Id;
        DS_CaseEditController ext = new DS_CaseEditController(new ApexPages.StandardController(cs));
        /*Attachment attach = new Attachment();
        ext.CreatedByUser = 'TestUser';
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        ext.file = attach.body;
        ext.myDoc = attach;*/
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        ext.fn='Test.pdf';
        ext.file=bodyBlob;
        ext.mySave();
        ext.Cancel();
        Test.stopTest();
    }
    
    private static TestMethod void casRecTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        DS_RecentCases RC = new DS_RecentCases();
        Apexpages.currentpage().getParameters().put('id', listAccounts.get(0).Id);
        Test.startTest();
        RC.CustomerDetails();
        RC.ProductLinks();
        RC.subProduct();
        RC.subProdCustDetails();
        RC.SubProductLinks();
        RC.productCseDetails();
        Test.stopTest();
    }   
    
}