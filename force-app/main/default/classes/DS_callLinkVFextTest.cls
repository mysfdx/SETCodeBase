@isTest
private class DS_callLinkVFextTest {

    static testMethod void DSCallTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;      
        DS_callLinkVFext obj = new DS_callLinkVFext(new ApexPages.StandardController(newAccount));
        obj.callVFPg();
    }
    
}