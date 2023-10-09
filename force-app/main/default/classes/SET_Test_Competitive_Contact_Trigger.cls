/************************************************************************************************************
Intital Creation History
Created By: Jay B
Created On: 5/19/2014
Purpose: this is used as Test class for Competitive Contact Trigger.
        
       
**************************************************************************************************************/  
@isTest
private class SET_Test_Competitive_Contact_Trigger {

    static testMethod void TestCompetitiveContact() {
        Competitive_Contact__c cmptRec=new Competitive_Contact__c();
        cmptRec.First_Name__c='TestFirst';
        cmptRec.Last_Name__c='TestLast';
       
        test.startTest();
        
        
        PageReference pageRef = Page.Competitive_Contact_Page;
        Test.setCurrentPage(pageRef);
        Apexpages.Standardcontroller stdcontroller=new Apexpages.Standardcontroller(cmptRec);
        Competitive_Contact_Controller cmpCtrl=new Competitive_Contact_Controller(stdcontroller);
        cmpCtrl.showStandardPage();
        
        
        insert cmptRec;
        Competitive_Contact__c cmptRecRd=[Select Name from Competitive_Contact__c where id=:cmptRec.id];
        test.stopTest();
    }
}