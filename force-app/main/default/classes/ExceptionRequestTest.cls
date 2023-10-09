@isTest
private class ExceptionRequestTest {
    
    @testSetup 
    static void setupmethod() {
        
        Exception_Request__c newEr=TestClientUtils.createExceptionRequest('New',
                                                                          'New Car Incentive Exception Request',
                                                                          12000, 12000,'test@test.com');
        insert newEr;
        ContentVersion conVer=TestClientUtils.createCV('Test Doc', 'TestDocument.pdf', 'Test Content');
        insert conVer;
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE id=:conVer.id].ContentDocumentId;
        ContentDocumentLink conDocLink= TestClientUtils.createCDL(newEr.Id, 'V', conDocId);
        insert conDocLink;
        
        Exception_Request__c newTcuv=TestClientUtils.createExceptionRequest('New',
                                                                          'TCUV Incentive Exception Request',
                                                                          60000, 60000,'test@test.com');
        insert newTcuv;
        
        List<Incentive_Exception_Email__c> customSettingtoInsert=New List<Incentive_Exception_Email__c>();
        Incentive_Exception_Email__c newCarInitial = new Incentive_Exception_Email__c();
        newCarInitial.Name = 'NewCarInitialApprover';
        newCarInitial.New_Car_Email_Address__c = 'newTest@test.com';
        newCarInitial.TCUV_Email_Address__c='tcuvTest@test.com';
        newCarInitial.To_Addresses__c='Test@test.com';
        customSettingtoInsert.add(newCarInitial);
        
        Incentive_Exception_Email__c newCarAdditional = new Incentive_Exception_Email__c();
        newCarAdditional.Name='NewCarAdditionalApprover';
        newCarAdditional.New_Car_Email_Address__c='newTest@test.com';
        newCarAdditional.TCUV_Email_Address__c='tcuvTest@test.com';
        newCarAdditional.Over_10k_To_Emails__c='Test@test.com';
        newCarAdditional.Over_50k_To_Emails__c='Test@test.com';
        customSettingtoInsert.add(newCarAdditional);
        
        Incentive_Exception_Email__c tcuvInitial = new Incentive_Exception_Email__c();
        tcuvInitial.Name = 'TCUVInitialApprover';
        tcuvInitial.New_Car_Email_Address__c = 'newTest@test.com';
        tcuvInitial.TCUV_Email_Address__c='tcuvTest@test.com';
        tcuvInitial.To_Addresses__c='Test@test.com';
        customSettingtoInsert.add(tcuvInitial);
        
        Incentive_Exception_Email__c tcuvAdditional = new Incentive_Exception_Email__c();
        tcuvAdditional.Name='TCUVAdditionalApprover';
        tcuvAdditional.New_Car_Email_Address__c = 'newTest@test.com';
        tcuvAdditional.TCUV_Email_Address__c='tcuvTest@test.com';
        tcuvAdditional.Over_10k_To_Emails__c='Test@test.com';
        tcuvAdditional.Over_50k_To_Emails__c='Test@test.com';
        customSettingtoInsert.add(tcuvAdditional);
        
        Incentive_Exception_Email__c otherEmails = new Incentive_Exception_Email__c();
        otherEmails.Name='OtherExceptionEmails';
        otherEmails.New_Car_Email_Address__c = 'newTest@test.com';
        otherEmails.TCUV_Email_Address__c='tcuvTest@test.com';
        otherEmails.New_Car_Incentive_Team__c='Test@test.com';
        otherEmails.TCUV_Incentive_Team__c='Test@test.com';
        otherEmails.Accounting_Email__c='Test@test.com';
        otherEmails.PAL_Email__c='Test@test.com';
        otherEmails.Other_than_PAL_Email__c='Test@test.com';
        customSettingtoInsert.add(otherEmails);
        
        insert customSettingtoInsert;
    }
    
    static testMethod void testNewCarExceptionCreate() 
    {
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments =
            new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
                // Test with the subject that matches with email service.
                email.subject = 'Testing New Car Exception Process';
        email.plainTextBody = 'Testing\r\n This e-mail transmission contains';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'newTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
    }
    static testMethod void testTCUVExceptionCreate() 
    {
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Test with the subject that matches with email service.
        email.subject = 'Testing TCUV Exception Process';
        email.plainTextBody = 'Testing\r\n This e-mail transmission contains';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'tcuvTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
    }
    static testMethod void testNewCarInitialApproval() 
    {
        Exception_Request__c existingReq=[SELECT Id, CreatedById, Name, Status__c, Approval_History__c,
                                          Exception_Request_Type__c, Total_VIN_Amount__c,
                                          Manual_Total_VIN_Amount__c,Final_Approver__c,Requester_Email__c
                                          FROM Exception_Request__c WHERE Exception_Request_Type__c=
                                          'New Car Incentive Exception Request' LIMIT 1];
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Test with the subject that matches with email service.
        email.subject = 'New Car Exception Incentive Request Submitted [Request # '+existingReq.Name+']';
        email.plainTextBody = 'Approved';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'newTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
    }
    static testMethod void testNewCarAdditionalApproveReject() 
    {
        Exception_Request__c existingReq=[SELECT Id, CreatedById, Name, Status__c, Approval_History__c,
                                          Exception_Request_Type__c, Total_VIN_Amount__c,
                                          Manual_Total_VIN_Amount__c,Final_Approver__c,Requester_Email__c
                                          FROM Exception_Request__c WHERE Exception_Request_Type__c=
                                          'New Car Incentive Exception Request' LIMIT 1];
        existingReq.Status__c='Additional Approval required';
        Update existingReq;
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Test with the subject that matches with email service.
        email.subject = 'Additional approval is required on request '+existingReq.Name;
        email.plainTextBody = 'Approved';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'newTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
        
        existingReq.Status__c='Additional Approval required';
        existingReq.Manual_Total_VIN_Amount__c=60000;
        existingReq.VIN_1_Amount__c=60000;
        Update existingReq;
         email.plainTextBody = 'Rejected';
        AcctIncExceptionEmailService acct1= new AcctIncExceptionEmailService();
        acct1.handleInboundEmail(email, env);
    }
    static testMethod void testTCUVInitialApproval() 
    {
        Exception_Request__c existingReq=[SELECT Id, CreatedById, Name, Status__c, Approval_History__c,
                                          Exception_Request_Type__c, Total_VIN_Amount__c,
                                          Manual_Total_VIN_Amount__c,Final_Approver__c,Requester_Email__c
                                          FROM Exception_Request__c WHERE Exception_Request_Type__c=
                                          'TCUV Incentive Exception Request' LIMIT 1];
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Test with the subject that matches with email service.
        email.subject = 'New TCUV Exception Incentive Request Submitted [Request # '+existingReq.Name+']';
        email.plainTextBody = 'Approved';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'newTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
    }
     static testMethod void testTCUVAdditionalApproveReject() 
    {
        Exception_Request__c existingReq=[SELECT Id, CreatedById, Name, Status__c, Approval_History__c,
                                          Exception_Request_Type__c, Total_VIN_Amount__c,
                                          Manual_Total_VIN_Amount__c,Final_Approver__c,Requester_Email__c
                                          FROM Exception_Request__c WHERE Exception_Request_Type__c=
                                          'TCUV Incentive Exception Request' LIMIT 1];
        existingReq.Status__c='Additional Approval required';
        Update existingReq;
        // Create a new email and envelope object.    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Test with the subject that matches with email service.
        email.subject = 'Additional approval is required on request '+existingReq.Name;
        email.plainTextBody = 'Rejected';
        
        env.fromAddress = 'Test@test.com';
        email.fromAddress='Test@test.com';
        email.toAddresses= new List<String>{'newTest@test.com'};
            email.fromName='Test';
        AcctIncExceptionEmailService acct= new AcctIncExceptionEmailService();
        acct.handleInboundEmail(email, env);
        
        existingReq.Status__c='Additional Approval required';
        existingReq.Manual_Total_VIN_Amount__c=14000;
        existingReq.VIN_1_Amount__c=14000;
        Update existingReq;
         email.plainTextBody = 'Approved';
        AcctIncExceptionEmailService acct1= new AcctIncExceptionEmailService();
        acct1.handleInboundEmail(email, env);

        
    }
}