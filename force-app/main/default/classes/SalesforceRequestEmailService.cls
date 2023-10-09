/*
Created By: Neha Agrawal
Created Date: 28th September 2022
Description: SalesforceRequestEmailService: Created to handle email responses for 
non Salesforce users for Accounting ACH Cases.
Changelog 

Author--             Date--                       Purpose--

*/
global class SalesforceRequestEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            If(email.plainTextBody<>Null){
                String emailPlainBody=email.plainTextBody;
                String searchText='This e-mail transmission contains';
                If(emailPlainBody.containsIgnoreCase(searchText)){
                    String afterSecText = emailPlainBody.substringAfter(searchText);              
                    emailPlainBody=emailPlainBody.remove(afterSecText);
                    emailPlainBody=emailPlainBody.remove(searchText);
                    System.debug('emailPlainBody is '+emailPlainBody);
                    system.debug('email.fromName is '+email.fromName);
                }
                String reqNum;
                Pattern p = Pattern.compile('SR-\\d{8}+');
                Matcher m = p.matcher(email.Subject);
                while(m.find()){
                    reqNum = m.group();
                }
                system.debug('reqNum '+reqNum);
                if(reqNum == null) {
                    try{
                        List<String> ccAddList =New List<String>();
                        For(string s: email.toAddresses){
                            if(s<>'salesforcerequests@jmfamily.com'){
                                ccAddList.add(s); 
                            }
                        }
                        If(email.ccAddresses<>Null && !(email.ccAddresses).isEmpty()){
                            ccAddList.addAll(email.ccAddresses);
                        }
                        
                        Salesforce_Request__c sr=New Salesforce_Request__c();
                        sr.Subject__c=email.subject;
                        If(!test.isRunningTest()){
                         sr.OwnerId=[SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Salesforce_Product_Team'].Id;   
                        }
                        sr.Requester_Email__c=email.fromAddress;
                        sr.Brief_Description__c=emailPlainBody;
                        sr.Requester_Name__c=email.fromName;
                        sr.Status__c='New';
                        insert sr;
                        if( email.binaryAttachments <>null){
                            if(!email.binaryAttachments.isEmpty()){
                                 addEmailAttachments(email.binaryAttachments,sr.Id,null);
                                /*List<ContentVersion> contentVersionList=new List<ContentVersion>();
                                For(Messaging.Inboundemail.BinaryAttachment file : 
                                    email.binaryAttachments){
                                        Messaging.EmailFileAttachment singleAttach = 
                                            New Messaging.EmailFileAttachment();
                                        ContentVersion cv = new ContentVersion();
                                        cv.Title = file.fileName;
                                        cv.PathOnClient = file.fileName;
                                        cv.VersionData = file.body;
                                        singleAttach.setBody(file.body);
                                        singleAttach.setFileName(file.fileName);
                                        cv.IsMajorVersion = true;
                                        contentVersionList.add(cv);
                                        //emailAttach.add(singleAttach);
                                    } 
                                Database.insert(contentVersionList, False);
                                //Get Content Documents
                                List<ContentVersion> contentDocIdList=New List<ContentVersion>();
                                contentDocIdList = [SELECT ContentDocumentId FROM ContentVersion 
                                                    WHERE Id IN: contentVersionList];
                                //Create ContentDocumentLink 
                                List<ContentDocumentLink> conDocLinkList=New List<ContentDocumentLink>();
                                For(ContentVersion ver:contentDocIdList){
                                    ContentDocumentLink cdl = New ContentDocumentLink();
                                    cdl.LinkedEntityId = sr.Id;
                                    cdl.ContentDocumentId = ver.ContentDocumentId;
                                    cdl.shareType = 'V';
                                    conDocLinkList.add(cdl);
                                }
                                Database.insert(conDocLinkList, False);*/
                            }
                        }
                        EmailTemplate emailtemp = [SELECT Id, Subject, HTMLValue, Body FROM 
                                                   EmailTemplate WHERE DeveloperName  
                                                   ='Salesforce_Request_Submission_Template'];
                        Messaging.SingleEmailMessage mail = 
                            Messaging.renderStoredEmailTemplate(emailtemp.Id, sr.CreatedById, sr.Id);
                        String emailSubject = mail.getSubject();
                        String emailTextBody = mail.getPlainTextBody();
                        mail.setSubject(emailSubject);
                        mail.setPlainTextBody(emailTextBody);
                        mail.setUseSignature(false);
                        mail.setTargetObjectId(sr.CreatedById);
                        mail.setTreatTargetObjectAsRecipient(false);
                        If(!ccAddList.isEmpty()){
                            mail.setCCAddresses(ccAddList);
                        }
                        
                        mail.setToAddresses(New List<String>{envelope.fromAddress});//Set To Email Address
                        mail.setSaveAsActivity(true); 
                        mail.setReplyTo('salesforcerequests@jmfamily.com');  
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
                    }
                    Catch(exception e){
                        system.debug('Exception Occured '+e.getMessage()+' '+e.getStackTraceString());
                    }
                }
                else{
                    Salesforce_Request__c existingSR=[SELECT Id, Name
                                                      FROM Salesforce_Request__c WHERE Name=:reqNum LIMIT 1];
                    try{
                        EmailMessage emailMessage = new EmailMessage();  
                        emailMessage.Status = '0';
                        emailMessage.FromAddress = email.FromAddress;
                        if(email.toAddresses.size() > 0){
                            emailMessage.ToAddress = String.join( email.toAddresses, ';' );
                        }
                        
                        if(email.ccAddresses != null && email.ccAddresses.size() > 0){
                            emailMessage.CcAddress = String.join( email.ccAddresses, ';' );
                        }
                        emailMessage.FromName = email.FromName; // from name  
                        emailMessage.Subject = email.Subject; // email subject  
                        emailMessage.TextBody = email.plainTextBody; // email body  
                        emailMessage.RelatedToId = existingSR.Id;
                        insert emailMessage; 
                        if( email.binaryAttachments <>null){
                            if(!email.binaryAttachments.isEmpty()){
                                addEmailAttachments(email.binaryAttachments,existingSR.Id,emailMessage.Id);
                                /*List<ContentVersion> contentVersionList=new List<ContentVersion>();
                                For(Messaging.Inboundemail.BinaryAttachment file : 
                                    email.binaryAttachments){
                                        Messaging.EmailFileAttachment singleAttach = 
                                            New Messaging.EmailFileAttachment();
                                        ContentVersion cv = new ContentVersion();
                                        cv.Title = file.fileName;
                                        cv.PathOnClient = file.fileName;
                                        cv.VersionData = file.body;
                                        singleAttach.setBody(file.body);
                                        singleAttach.setFileName(file.fileName);
                                        cv.IsMajorVersion = true;
                                        contentVersionList.add(cv);
                                        //emailAttach.add(singleAttach);
                                    } 
                                Database.insert(contentVersionList, False);
                                //Get Content Documents
                                List<ContentVersion> contentDocIdList=New List<ContentVersion>();
                                contentDocIdList = [SELECT ContentDocumentId FROM ContentVersion 
                                                    WHERE Id IN: contentVersionList];
                                List<Id> contentDocIds=New List<Id>();
                                
                                //Create ContentDocumentLink 
                                List<ContentDocumentLink> conDocLinkList=New List<ContentDocumentLink>();
                                For(ContentVersion ver:contentDocIdList){
                                    ContentDocumentLink cdl = New ContentDocumentLink();
                                    cdl.LinkedEntityId = emailMessage.Id;
                                    cdl.ContentDocumentId = ver.ContentDocumentId;
                                    cdl.shareType = 'V';
                                    contentDocIds.add(ver.ContentDocumentId);
                                    //emailMessage.ContentDocumentIds.add(ver.ContentDocumentId);
                                    conDocLinkList.add(cdl);
                                }
                                Database.insert(conDocLinkList, False);*/
                                    
                            }
                        }
                    }
                    catch(Exception e){
                        system.debug('Exception Occured '+e.getMessage()+' '+e.getStackTraceString());  
                    }
                }
            } 
            return result;
        }  
    private void addEmailAttachments(List<Messaging.InboundEmail.BinaryAttachment> emailAttachments, Id SRId, Id msgId){
        List<ContentVersion> contentVersionList=new List<ContentVersion>();
                                For(Messaging.Inboundemail.BinaryAttachment file : 
                                    emailAttachments){
                                        Messaging.EmailFileAttachment singleAttach = 
                                            New Messaging.EmailFileAttachment();
                                        ContentVersion cv = new ContentVersion();
                                        cv.Title = file.fileName;
                                        cv.PathOnClient = file.fileName;
                                        cv.VersionData = file.body;
                                        singleAttach.setBody(file.body);
                                        singleAttach.setFileName(file.fileName);
                                        cv.IsMajorVersion = true;
                                        contentVersionList.add(cv);
                                        //emailAttach.add(singleAttach);
                                    } 
                                Database.insert(contentVersionList, False);
                                //Get Content Documents
                                List<ContentVersion> contentDocIdList=New List<ContentVersion>();
                                contentDocIdList = [SELECT ContentDocumentId FROM ContentVersion 
                                                    WHERE Id IN: contentVersionList];
                                //Create ContentDocumentLink 
                                List<ContentDocumentLink> conDocLinkList=New List<ContentDocumentLink>();
                                For(ContentVersion ver:contentDocIdList){
                                    ContentDocumentLink cdl = New ContentDocumentLink();
                                    cdl.LinkedEntityId = SRId;
                                    cdl.ContentDocumentId = ver.ContentDocumentId;
                                    cdl.shareType = 'V';
                                    conDocLinkList.add(cdl);
                                    if(msgId<>null){
                                     ContentDocumentLink cdl2 = New ContentDocumentLink();
                                    cdl2.LinkedEntityId = msgId;
                                    cdl2.ContentDocumentId = ver.ContentDocumentId;
                                    cdl2.shareType = 'V';
                                    conDocLinkList.add(cdl2);   
                                    }
                                }
                                Database.insert(conDocLinkList, False);
    }
}