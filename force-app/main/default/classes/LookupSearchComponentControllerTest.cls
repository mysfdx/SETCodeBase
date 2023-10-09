@isTest
private class LookupSearchComponentControllerTest {
    
    private static testMethod void testGetResultWithSearch() {
        Account a=TestClientUtils.getAccount('Test');
        a.Active_Dealer__c=true;
        insert a;
        LookupSearchComponentController.getResults('Account','Name','');
    }
    
    private static testMethod void testGetResultWithoutSearch() {
        Account a=TestClientUtils.getAccount('Test');
        a.Active_Dealer__c=true;
        insert a;
        LookupSearchComponentController.getResults('Account','Name','Test');
    }
    
}