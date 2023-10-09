@isTest
private Class SET_Parts_CasePages_Test {
    
    private static TestMethod void casExtTest() {
        SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(false);
        setDistInfo.ISDM_User__c = UserInfo.getUserId();
        insert setDistInfo;
        List < Account > listAccounts = TestClientUtils.createAccounts(1, false);
        listAccounts.get(0).SET_DISTRICT_INFO__c = setDistInfo.Id;     
        listAccounts.get(0).District__c = '100';
        listAccounts.get(0).Dealer_Code__c = '55555';
        insert  listAccounts;
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
        DS_Product__c product = TestClientUtils.getProduct('PDC-VIN Restricted TEST1', 'Apps Services', 'CRM');
        insert product;
        Case cs = TestClientUtils.createCases(listAccounts, 1, false).get(0);
        List < Contact > listContacts = TestClientUtils.createContacts(listAccounts, 2, false);      
        listContacts.get(0).Role__c = 'IT Contact';
        listContacts.get(1).Role__c = 'DD System Admin';
        insert listContacts;
        DS_Product__c prod = TestClientUtils.getProduct('PDC-VIN Restricted TEST2', 'Apps Services', 'CRM');
        insert prod;
        listCases.get(0).DS_Vendor_Product_cust__c = prod.Id;
        listCases.get(0).Subject = 'Test Subject';
        insert listCases.get(0);
        Test.startTest();
        SET_Parts_CaseExtension ext = new SET_Parts_CaseExtension(new ApexPages.StandardController(cs));
        ext.caseTypeSel();
        ext.accountId=listAccounts.get(0).Id;
        ext.cas.DS_Vendor_Product_cust__c =  prod.Id;
         ext.cas.DS_Customer_Name__c = listAccounts.get(0).Id;
        ext.cas.DS_Username__c = 'Test';
        ext.cas.DS_Customer_Name_cust__c = 'Test';
        ext.cas.Subject = 'Test Subject';
        ext.cas.DS_App_Function__c = 'VSP';
        ext.cas.DS_Requester_Type__c = 'Associate';
        ext.cas.DS_Notes__c = 'Test Notes';
        ext.cas.Business_Unit__c = 'SET';
        ext.cas.DS_LOB__c = 'SET';  
        ext.cas.DS_Resolution__c = 'Resolved';  
        ext.cas.Status = 'Closed';
        ext.cas.DS_Support_Team__c = 'SET Parts Support';
        ext.cas.Priority = 'Normal';  
        ext.cas.Origin='Web';
        ext.cas.DS_Username__c ='Test';
        ext.cas.DS_Resolution_Category__c = 'Request for Help';
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
        DS_Product__c product = TestClientUtils.getProduct('PDC-VIN Restricted TEST3', 'Apps Services', 'CRM');
        insert product;
         Case cs = TestClientUtils.createCases(listAccounts, 1, false).get(0);
        List < Contact > listContacts = TestClientUtils.createContacts(listAccounts, 2, false);      
        listContacts.get(0).Role__c = 'IT Contact';
        listContacts.get(1).Role__c = 'DD System Admin';
        insert listContacts;
        DS_Product__c prod = TestClientUtils.getProduct('PDC-VIN Restricted TEST4', 'Apps Services', 'CRM');
        insert prod;
        listCases.get(0).DS_Vendor_Product_cust__c = product.Id;
        insert listCases.get(0);
        SET_Parts_CaseExtension ext = new SET_Parts_CaseExtension(new ApexPages.StandardController(cs));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DS_DealerDailyWebServiceMock());
        ext.fetchCustomerDetails();
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