@isTest
private class COE_Code_Library_Test {
    
    static testMethod void testAuditTracker() {
        Account acct = TestClientUtils.createAccount();     
        insert acct;       
        String objName = COE_CodeLibrary.getObjectName(acct.Id);
        COE_CodeLibrary.getsObjectNameFieldValue(new List < Id > {acct.Id}); 
        COE_CodeLibrary.getSobjectTypeByPrefix('001');
    }
    
}