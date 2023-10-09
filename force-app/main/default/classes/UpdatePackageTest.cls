/**
 * UpdatePackageTest.cls
 * Description  : Test Class to check the Update package Functionality.
 * @Author      : Vijay Mittal
 * @version     : 1.0
 * @CreatedDate : May 26, 2012
************************Version Updates***********************************************************************
 Updated Date             Updated By                  Update Comments 
**************************************************************************************************************/

@isTest(SeeAllData=false)
private class UpdatePackageTest {

    static testMethod void testUpdatePackage() {        
        Account acc = TestClientUtils.createAccount();
        Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
        Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
        acc.RecordTypeId=rtByName.getRecordTypeId();
        Insert acc;
        List<Packages__c> packList = new List<Packages__c>();
        List<Package_Action__c> packAction = new List<Package_Action__c>();
        
        Toyota_Dealer_Agreements__c tda = TestClientUtils.createToyotaDealerAgreements(acc.Id);
        tda.Expiration_Date__c = System.today().addDays(5);
        tda.Extended_To__c = System.today().addDays(25);
        
        insert tda;
        packList.add(TestClientUtils.createPackages( acc.Id, tda.Id) ); 
        packList.add(TestClientUtils.createPackages(acc.Id, tda.Id) );
        
        insert packList;
        
        packAction.add(new Package_Action__c(Package__c = packList[0].Id, Action__c = 'GM Change'));
        packAction.add(new Package_Action__c(Package__c = packList[0].Id, Action__c = 'Land Purchase'));
        packAction.add(new Package_Action__c(Package__c = packList[1].Id, Action__c = 'Site Request'));
        packAction.add(new Package_Action__c(Package__c = packList[1].Id, Action__c = '6 - 12 Letter'));
        
        Insert packAction;        
        //System.assertEquals('GM Change; Land Purchase' ,[SELECT Package_Actions__c FROM Packages__c WHERE Id =: packList[0].Id limit 1].Package_Actions__c );
        
        packAction[0].Action__c = 'Relocation';
        
        update packAction[0];        
        // System.assertEquals('Land Purchase; Relocation' ,[SELECT Package_Actions__c FROM Packages__c WHERE Id =: packList[0].Id limit 1].Package_Actions__c );
        
        delete packAction[0];        
        // System.assertEquals('Land Purchase' ,[SELECT Package_Actions__c FROM Packages__c WHERE Id =: packList[0].Id limit 1].Package_Actions__c );
        
        delete packAction[1]; 
        // System.assertEquals(null ,[SELECT Package_Actions__c FROM Packages__c WHERE Id =: packList[0].Id limit 1].Package_Actions__c );
        
        undelete packAction[0];
        //  System.assertEquals('Relocation' ,[SELECT Package_Actions__c FROM Packages__c WHERE Id =: packList[0].Id limit 1].Package_Actions__c );        
    }
    
}