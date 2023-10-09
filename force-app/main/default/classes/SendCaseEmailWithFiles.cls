/*
Created By: Neha Agrawal
Created Date: 19th July 2022
Description: Created to send email for Accounting ACH Cases with files.
Changelog 

Author--             Date--                       Purpose--

*/

public class SendCaseEmailWithFiles {
    @InvocableMethod(label='Send Case Email' description='Send Case Email With Files for ACCT ACH Cases' category='Case')
    public static void sendCaseEmail(List<Id> caseIds) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
            String tempToUse=Send_Email_Info__c.getInstance('ACCTACHDetails').Email_template_to_use__c;
        String replyToEmail=Send_Email_Info__c.getInstance('ACCTACHDetails').Email_Service_Address__c;
        List<String> toAddressList=New List<String>();
        toAddressList=Send_Email_Info__c.getInstance('ACCTACHDetails').To_Addresses__c.Split(';');
        Case achCase=[SELECT id, createdby.ContactId, CreatedById  FROM Case 
                      WHERE id=:caseIds.get(0) LIMIT 1];
        if(achCase!=null){
            Set<Id> contentDocIds = new Set<Id>();
            list<contentDocumentLink> contentDocLink=[SELECT LinkedEntityId,ContentDocumentId
                                                      FROM ContentDocumentLink WHERE LinkedEntityId=: caseIds.get(0)];
            if(!contentDocLink.isEmpty()){
                for(ContentDocumentLink link:contentDocLink){
                    contentDocIds.add(link.ContentDocumentId);
                }
                    
                    List<ContentVersion> documents= new List<ContentVersion>{};
                        documents.addAll([
                            SELECT Id, Title, FileType, VersionData, isLatest, PathOnClient, ContentDocumentId
                            FROM ContentVersion
                            WHERE isLatest = true AND ContentDocumentId in: contentDocIds
                        ]);
                    
                    for (ContentVersion document: documents) {
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        blob WOCFbody = document.versiondata;
                        attachment.setBody(WOCFbody);
                        attachment.setFileName(document.PathOnClient);
                        
                        attachments.add(attachment);
                    }
                
                if(!attachments.isEmpty()){
                    mail.setFileAttachments(attachments);
                }
                
            }
            EmailTemplate emailtemp = [SELECT Id, Subject, HTMLValue FROM EmailTemplate 
                                       WHERE DeveloperName  =:tempToUse];
            //Apex Single email message
            System.Debug('============='+UserInfo.getUserId());
            mail.setUseSignature(false);
            mail.setTargetObjectId(achCase.createdby.ContactId);
            mail.setWhatId(caseIds.get(0));
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setToAddresses(toAddressList);//Set To Email Address
            //Set File Attachment
            mail.setTemplateId(emailtemp.Id);
            mail.setSaveAsActivity(false); 
            mail.setReplyTo(replyToEmail);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
            
        }
    }
}