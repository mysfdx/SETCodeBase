@isTest
public class SalesforceRequestEmailServiceTest {
    
    @testSetup
    static void dataSetup(){
        Salesforce_Request__c newsr=New Salesforce_Request__c();
        newsr.Subject__c='New Salesforce Request created';
        //newsr.OwnerId=[SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Salesforce_Product_Team'].Id;
        newsr.Requester_Email__c='Test@email.com';
        newsr.Brief_Description__c='New Salesforce Request created';
        newsr.Requester_Name__c='Tester';
        newsr.Status__c='New';
        insert newsr;
        
    }
    
    @isTest
    static void testSFReqExisting(){
        String srName= [SELECT Id,Name FROM Salesforce_Request__c LIMIT 1].Name;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment attach = new Messaging.InboundEmail.BinaryAttachment() ;
        email.subject = 'New Salesforce Request Submitted [Request # '+srName+']';
        email.fromName = 'TestTest';
        email.plainTextBody = 'Test email body';
        env.fromAddress = 'Test@email.com';
        email.fromAddress='Test@email.com';
        List<string> emails = new List<string>{'salesforcerequests@jmfamily.com'};
            email.toAddresses= emails;
        List<string> ccEmails = new List<string>{'Test@test.com'};
            email.ccAddresses= ccEmails;
        
        attach.body = blob.valueOf('my attachment text');
        attach.fileName = 'textfileone.txt';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attach };
            
            SalesforceRequestEmailService emailProcess1 = new SalesforceRequestEmailService();
        
        
        emailProcess1.handleInboundEmail(email, env);
        
    }
    
    @isTest
    static void testSFReqNew(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment attach = new Messaging.InboundEmail.BinaryAttachment() ;
        
        email.subject = 'Test';
        email.fromName = 'TestTest';
        email.plainTextBody = 'Test email body This e-mail transmission contains';
        env.fromAddress = 'Test@email.com';
        email.fromAddress='Test@email.com';
        List<string> emails = new List<string>{'salesforcerequests@jmfamily.com'};
            email.toAddresses= emails;
        List<string> ccEmails = new List<string>{'Test@test.com'};
            email.ccAddresses= ccEmails;
        
        attach.body = blob.valueOf('my attachment text');
        attach.fileName = 'textfileone.txt';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attach };
            
            SalesforceRequestEmailService emailProcess = new SalesforceRequestEmailService();
        
        emailProcess.handleInboundEmail(email, env);
    }
    
    
}