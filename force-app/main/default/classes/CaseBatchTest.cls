@isTest
private class CaseBatchTest {
    
     static testMethod void setup() {
        
       Account a = new Account(Name='Acme', Dealer_Code__c='01234');
        insert a;
         Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SET DS Case').getRecordTypeId();
        Case newCase = new Case();
            newCase.RecordTypeId = caseRecordTypeId;
            newCase.JMA_Business_Unit__c = 'Dealer Services';
            newCase.DS_Time_Spent_In_Minutes__c = 5;
            newCase.DS_Time_Entry_Mins__c = '5';
            newCase.DS_Time__c = '2';
          newCase.AccountId =a.id;
          newCase.status ='Closed';
         insert newCase;
         Test.startTest();
         CaseBatch c=new CaseBatch();
         database.executeBatch(c);
         Test.stopTest();
    }
    
    
}