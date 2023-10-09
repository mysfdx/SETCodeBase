@isTest
public with sharing class SET_Parts_KnowledgeSearchControllerTest {
    static testMethod void knowldgTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(1, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 1, false);
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        List < Contact > listContacts = TestClientUtils.createContacts(listAccounts, 2, false);      
        listContacts.get(0).Role__c = 'IT Contact';
        listContacts.get(1).Role__c = 'DD System Admin';
        insert listContacts;
        DS_Product__c prod = TestClientUtils.getProduct('SET Parts Warehouse', 'Apps Services', 'CRM');
        insert prod;        
        insert listCases.get(0);
        Case cs = TestClientUtils.createCases(listAccounts, 1, false).get(0);
        cs.DS_Vendor_Product_cust__c = product.Id;
        cs.Subject = 'Testing';
        insert cs;
        List<DS_Customer_Details__c> listCustDetails = TestClientUtils.createCustomerDetails(new List < Case > {cs}, 1, true);
        apexpages.currentpage().getparameters().put('CaseId' , cs.Id);
        Knowledge__kav objKnow = new Knowledge__kav(URLName = 'SampleTest', Title = 'SampleTest', Summary = 'Testing', DS_Product__c = product.Id);
        insert objKnow;
        objKnow = [ SELECT KnowledgeArticleId, Title, Summary, DS_Product__c FROM Knowledge__kav WHERE Id =: objKnow.Id ];
        KbManagement.PublishingService.publishArticle(objKnow.KnowledgeArticleId, true);
        Test.startTest();
        SET_Parts_KnowledgeSearchController obj = new SET_Parts_KnowledgeSearchController();
        obj.selectedKnow = objKnow.KnowledgeArticleId;
        obj.Cas = cs;
        obj.fetchArticles();   
        obj.backToCase();
        obj.redirectToArticleCreate();
        Test.stopTest();        
    }    
}