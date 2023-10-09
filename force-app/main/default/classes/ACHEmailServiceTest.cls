@isTest
private class ACHEmailServiceTest {
    
    static testMethod void testACHEmailServiceMethod() 
    {
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Create Test record.
       List<Account> actList= TestClientUtils.createAccounts(1,True);
       List <Case> caseList=TestClientUtils.createCases(actList,1,True);
        Case caseRecord = [SELECT CaseNumber,Id FROM Case WHERE Id = :caseList.get(0).Id LIMIT 1];
        System.debug('caseRecord.CaseNumber '+caseRecord.CaseNumber+' caseRecord.Id '+caseRecord.Id);
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'ACH Parts Program Elec. Transf. Authorization';
        email.plainTextBody = 'AP Validation Completed \n Case Number: '+caseRecord.CaseNumber;
        
        env.fromAddress = 'test@test.com';
        ACHEmailService obj= new ACHEmailService();
        obj.handleInboundEmail(email, env );
        
    }
}