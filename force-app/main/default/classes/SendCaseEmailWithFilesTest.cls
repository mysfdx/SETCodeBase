@isTest
private class SendCaseEmailWithFilesTest {
    @TestSetup
    private static void setupTestData(){
        Send_Email_Info__c emailInfo= new Send_Email_Info__c();
        emailInfo.Name = 'ACCTACHDetails';
        emailInfo.Email_template_to_use__c = 'ACCT_ACH_PTS_AUTHORIZE';
        emailInfo.Email_Service_Address__c = 'Test1@jm.com';
        emailInfo.To_Addresses__c='Test@jm.com';
        insert emailInfo;
        
        Account a = new Account(Name='AcmeTest', Dealer_Code__c='01664');
        insert a;
        
        Contact con = new Contact(
            AccountId = a.Id,
            LastName = 'portalUserTest',
            email='Test2@email.com'
            
        );
        insert con;
        
        Profile p = [select Id,name from Profile where Name = 'Dealer User Community Profile 1' Limit 1];
        User newUser = new User(
            profileId = p.Id,
            username = 'testuser2@setdjithandler.com',
            email = 'testuser2@setdjithandler.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='sjusert',
            lastname='portalUserTest',
            contactId = con.id
        );
        insert newUser;
        
    }
    
    @isTest
    private static void doTest() {
        String exceptionCaught;
        user u=[Select id, username, name, contactId from user where username = 'testuser2@setdjithandler.com' limit 1];
        System.runAs(u) {
            setd_CaseInfo.CaseInfo caseInfo;
            
            try {
                caseInfo = setd_AcctAchPtsAuthorizeController.getCaseInfo();
                insert caseInfo.caseObject;
            } catch(Exception e) {
                exceptionCaught = e.getTypeName();
            }
        }
        Case c=[Select id from Case where Form_Name__c='ACCT ACH PTS AUTHORIZE' limit 1];
        //insert content Version
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink for Case
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'I';
        cdl.Visibility='AllUsers';
        Insert cdl;
        
        SendCaseEmailWithFiles.sendCaseEmail(New List<Id>{c.Id});
        
    }
    
}