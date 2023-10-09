@isTest
private class SET_TestFacilityTrigger {

    static testMethod void testFacilityTrigger() {
        // Dualed__c,Other_Manufacturer__c,Account__c
        
        Account setAccount=new Account();
        
        setAccount.Name='Test SET Account';
        string dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        setAccount.Dealer_Code__c='1234';
        setAccount.RecordTypeId=dealerRecordTypeId;
        insert setAccount;
        
        Facility__c facRec=new Facility__c();
        facRec.Name='Test Facility';
        facRec.Account__c=setAccount.ID;
        facRec.Dualed__c=true;
        facRec.Other_Manufacturer__c='Test Mfc1;Test Mfc2;Test Mfc3';
        insert facRec;
        
        Account acctRec=[Select SET_Other_Manufacturer__c from Account where id=:setAccount.ID];
        
        Facility__c facRec2=new Facility__c();
        facRec2.Name='Test Facility2';
        facRec2.Account__c=setAccount.ID;
        facRec2.Dualed__c=true;
        facRec2.Other_Manufacturer__c='Test Mfc2;Test Mfc4';
        insert facRec2;
        
        acctRec=[Select SET_Other_Manufacturer__c from Account where id=:setAccount.ID];
        facRec2.Dualed__c=false;
        update facRec2;
        
        
    }
}