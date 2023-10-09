@isTest
private class DS_callProdVFextTest {

    static testMethod void DSCallTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;      
        DS_callProdVFext obj = new DS_callProdVFext(new ApexPages.StandardController(newAccount));
        obj.callVFPg();
    }
    
}