/*Name:TranportationClaimController
Purpose: Controller for transportClaimForm aura component and used to display existing contact information 
on Transport Claim form, used to save new records and to fetch picklist values, ENHC0012574
Author:Neha Agrawal
Date:2/3/2021

Change Log
Date - Changed by - Change Description
04/22/2021 - Neha Agrawal -  added the one more email for carriers within sendEmail method.
03/27/2023 - Neha Agrawal - added new carriers.
*/

public without sharing class TranportationClaimController {
    
    /*
Used to fetch all Active Dealer codes
*/
    @AuraEnabled
    public static Account[] getDealerCodeOptions(){
        return [
            SELECT Id, Name, Dealer_code__c
            FROM Account
            WHERE Active_Dealer__c=true
            ORDER BY Dealer_code__c
        ];
    }
    /*
Used to fetch Dealers's contact information and Dealer Code
*/
    @AuraEnabled
    public static transportClaimInfo.claimInfo getTransportClaimInfo() {
        transportClaimInfo claimInfoInstance=new transportClaimInfo();
        transportClaimInfo.claimInfo claimInfoObject=claimInfoInstance.createTransportClaim();
        return claimInfoObject;
    }
    
    /*
Used to save new Transporation Claim record
*/
    @AuraEnabled
    public static string getInsertedClaim(Transportation_claim__c claim) {
        insert claim;
        return claim.Id;
    }
    /*
Used to fetch all picklist values of Carrier Name field
*/
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getCarrierNameOptions() {
        avs_PicklistUtil utilities = new avs_PicklistUtil();
        return utilities.getPicklistValues('Transportation_Claim__c', 'Carrier_Name__c');
    }
    /*
Used to fetch all picklist values of Delivery Type field
*/
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getDeliveryTypeOptions() {
        avs_PicklistUtil utilities = new avs_PicklistUtil();
        return utilities.getPicklistValues('Transportation_Claim__c', 'Delivery_Type__c');
    }
    /*
Used to fetch all picklist values of Vehicle Type field
*/
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getVehicleTypeOptions() {
        avs_PicklistUtil utilities = new avs_PicklistUtil();
        return utilities.getPicklistValues('Transportation_Claim__c', 'Vehicle_Type__c');
    }
    /*
Used to send email to form submission confirmation email to Dealers
*/
    @AuraEnabled
    public static void sendEmail(id claimId){
        Messaging.SingleEmailMessage dealerMail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage carrierMail = new Messaging.SingleEmailMessage();
        //id claimContactId=[Select id, createdby.ContactId from Transportation_Claim__c where id=:claimId limit 1].createdby.ContactId;
        Transportation_Claim__c tranClaim=[Select id, createdby.ContactId,Contact_Email__c,Carrier_Name__c from Transportation_Claim__c 
                                           where id=:claimId limit 1];
        if(tranClaim!=null){
            Set<Id> contentDocIds = new Set<Id>();
            list<contentDocumentLink> contentDocLink=[SELECT LinkedEntityId,ContentDocumentId
                                                      FROM ContentDocumentLink
                                                      WHERE LinkedEntityId=: claimId];
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
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
                    for (ContentVersion document: documents) {
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        blob WOCFbody = document.versiondata;
                        attachment.setBody(WOCFbody);
                        attachment.setFileName(document.PathOnClient);
                        
                        attachments.add(attachment);
                    }
                dealerMail.setFileAttachments(attachments);
                carrierMail.setFileAttachments(attachments);
            }
            List<EmailTemplate> emailtempList = [SELECT Id, Subject, HTMLValue,Name FROM EmailTemplate WHERE Name in ('TrasnportClaimInfo',
                                                                                                                      'Carrier BOL Upload Template')];
            for(EmailTemplate et: emailtempList){
                if(et.name=='TrasnportClaimInfo'){
                    dealerMail.setTemplateId(et.id);
                }
                if(et.name=='Carrier BOL Upload Template'){
                    carrierMail.setTemplateId(et.id);
                }
            }
            //Apex Single email message
            System.Debug('============='+UserInfo.getUserId());
            dealerMail.setUseSignature(false);
            carrierMail.setUseSignature(false);
            dealerMail.setTargetObjectId(tranClaim.createdby.ContactId); 
            carrierMail.setTargetObjectId(tranClaim.createdby.ContactId); 
            TransportClaimCarrierMails__c mails=TransportClaimCarrierMails__c.getInstance('CarrierEmails');
            system.debug('mails is '+mails);
            List<string> Longhorn=mails.Longhorn__c.split(';');
            List<string> ACE=mails.ACE__c.split(';');
            List<string> Centurion=mails.Centurion__c.split(';');
            List<string> STSOTHER=mails.STS_and_Other__c.split(';');
            List<string> AMJ=mails.AMJ__c.split(';');
            List<string> DMX=mails.DMX__c.split(';');
            List<string> NorthBeach=mails.NorthBeach__c.split(';');
            List<string> Runbuggy=mails.Runbuggy__c.split(';');
            List<string> Hicks=mails.HICKS__c.split(';');
            List<string> Masney=mails.Masney__c.split(';');
            
            dealerMail.setToAddresses(new String[] {tranClaim.Contact_Email__c});//Set To Email Address
            //dealerMail.setToAddresses(new String[] {'neha.agrawal_contractor@jmfamily.com'});
            if(tranClaim.Carrier_Name__c=='Auto Carrier Express'){
                carrierMail.setToAddresses(ACE);
            }
            else if(tranClaim.Carrier_Name__c=='Southeast Transportation System' || tranClaim.Carrier_Name__c=='Other'){
                carrierMail.setToAddresses(STSOTHER);
            }
            else if(tranClaim.Carrier_Name__c=='Centurion Auto Transport'){
                carrierMail.setToAddresses(Centurion);
            }else if(tranClaim.Carrier_Name__c=='Longhorn'){
                carrierMail.setToAddresses(Longhorn);
            }
            else if(tranClaim.Carrier_Name__c=='AMJ Auto Transport'){
                carrierMail.setToAddresses(AMJ);
            }
            else if(tranClaim.Carrier_Name__c=='Masney Auto Transport'){
                carrierMail.setToAddresses(Masney);
            }
            else if(tranClaim.Carrier_Name__c=='North Beach Auto Transport Inc'){
                carrierMail.setToAddresses(NorthBeach);
            }
            else if(tranClaim.Carrier_Name__c=='Hicks Auto Transport'){
                carrierMail.setToAddresses(Hicks);
            }
            else if(tranClaim.Carrier_Name__c=='Runbuggy OMI, LLC'){
                carrierMail.setToAddresses(Runbuggy);
            }
            else if(tranClaim.Carrier_Name__c=='DMX'){
                carrierMail.setToAddresses(DMX);
            }
            //Set File Attachment
            //mail.setSenderDisplayName(userinfo.getname());
            //dealerMail.setTemplateId(emailtemp.Id);
            dealerMail.setWhatId(claimId);
            carrierMail.setWhatId(claimId);    
            dealerMail.setSaveAsActivity(false);
            carrierMail.setSaveAsActivity(false);
            carrierMail.setReplyTo('Transportdamage@setoyota.com');    
            try { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dealerMail,carrierMail});//Send Email
            }
            catch (Exception e) {
                System.debug(e.getMessage());
                insert new API_Error_Log__c(Exception_Type__c = 'Transportation Claim Email', Error_Message__c = 'Email has not been sent correctly.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());
            }
            
        }
    }
    
}