/*Name:EmailController
Purpose: Apex Controller for sending Email from Process builder or flows 
https://jmfamily.atlassian.net/browse/SS1SP-52, https://jmfamily.atlassian.net/browse/SS1SP-140
Author:Neha Agrawal
Date:08/02/2021

Change Log
Date - Changed by - Change Description
08/09/2021 -  Neha Agrawal - Added documentforce.com to FinancialEdit images becuase 
                             community user is running the code
11/10/2021 - Neha Agrawal - Added Instancename.content.force.com for PROD only.
11/14/2022 - Neha Agrawal - For UAT & PROD it should be MyDomainName.file.force.com after enabling Enhanced Domain
*/

public class EmailController {
    
    public class EmailWrapper {
        @InvocableVariable public String strEmailTemplate;
        @InvocableVariable public String strRecordId;
        @InvocableVariable public String strToEmail;
        @InvocableVariable public String strCCEmail;
        @InvocableVariable public String strContactId;
        @InvocableVariable public String strFinancialStatementEdit;
    }    
    @InvocableMethod (label='Invoke Send Email') 
    Public static void incentiveApproveNote (list<EmailWrapper> lstEmailWrapper){
        
        if((!String.isBlank(lstEmailWrapper[0].strFinancialStatementEdit))&&
           lstEmailWrapper[0].strFinancialStatementEdit<>Null){
               calloutForFinancialEdits(lstEmailWrapper[0].strFinancialStatementEdit,lstEmailWrapper[0].strEmailTemplate,
                                        lstEmailWrapper[0].strRecordId,lstEmailWrapper[0].strContactId,
                                        lstEmailWrapper[0].strToEmail,lstEmailWrapper[0].strCCEmail);
           }
        else
        {
            List<Messaging.EmailFileAttachment> blankAttachList=new List<Messaging.EmailFileAttachment>(); 
            EmailSetup(lstEmailWrapper[0].strEmailTemplate,lstEmailWrapper[0].strRecordId,
                       lstEmailWrapper[0].strContactId,lstEmailWrapper[0].strToEmail,lstEmailWrapper[0].strCCEmail,
                       blankAttachList); 
        }
        
        
    }
    
    @future(Callout=true)
    public static void calloutForFinancialEdits(String financialEdits,String templateName,String recordId,
                                                String contactId,String toRecipients, String ccRecipients){
                                                    List<Blob> blobList=new List<Blob>();
                                                    PageReference pageRef;
                                                    system.debug('financialEdits is '+financialEdits);
                                                    Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(financialEdits);           
                                                    while (imgMatcher.find()) { 
                                                        String imageURL='';
                                                        String imageTag = imgMatcher.group();
                                                        System.debug('imageTag^^'+imageTag );              
                                                        imageURL= imageTag.substringBetween(' src="', '"' );
                                                        System.debug('imageURL^^' + imageURL );
                                                        system.debug('unescapeHtml4 URL is '+imageURL.unescapeHtml4());
                                                        String decodedURL = imageURL.unescapeHtml4();
                                                        system.debug('decodedURL is '+decodedURL);
                                                        if(decodedURL.contains('/Forms')){
                                                            system.debug('Contains forms.');
                                                            // For UAT & PROD it should be MyDomainName.file.force.com after enabling Enhanced Domain
                                                            // For UAT it should be document.force.com
                                                             String documentforceURL = Url.getSalesforceBaseUrl().toExternalForm().split('.my')[0]+'.file.force.com';
                                                            // For PROD it should be Instancename.content.force.com
                                                            //String instanceName = [select InstanceName from Organization limit 1].InstanceName;
                                                            //System.debug('instanceName '+ instanceName);
                                                            //String documentforceURL = Url.getSalesforceBaseUrl().toExternalForm().split('.my')[0]+'--c.'+instanceName+'.content.force.com';
                                                            String finalURL = decodedURL.replace('/Forms', documentforceURL);
                                                            pageRef = new PageReference( finalURL );
                                                        }
                                                        else{
                                                            pageRef = new PageReference( decodedURL );
                                                        }
                                                        
                                                        if(!test.isRunningTest()){
                                                            Blob b = pageRef.getContent();
                                                            blobList.add(b);
                                                        }else{
                                                            blobList.add(blob.valueof('TEST'));
                                                        }
                                                        
                                                        //System.debug( 'blob=' + b );
                                                        
                                                    }
                                                    List<Messaging.EmailFileAttachment> attachmentList= new List<Messaging.EmailFileAttachment>();
                                                    if(!blobList.isEmpty()){
                                                        
                                                        Integer Count=1;
                                                        for(Blob b:blobList ){
                                                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                                            attach.setContentType('image/jpeg');
                                                            attach.Body = b;
                                                            attach.setFileName('FinancialEdit_'+Count+'.jpeg');
                                                            Count++;
                                                            attachmentList.add(attach);
                                                        }
                                                    }
                                                    if(!attachmentList.isEmpty()){
                                                        EmailSetup(templateName,recordId,contactId,toRecipients,
                                                                   ccRecipients,attachmentList);
                                                    }
                                                    else
                                                    {
                                                        List<Messaging.EmailFileAttachment> blankAttachList=new List<Messaging.EmailFileAttachment>(); 
                                                        EmailSetup(templateName,recordId,contactId,toRecipients,
                                                                   ccRecipients,
                                                                   blankAttachList);
                                                    }
                                                    
                                                    
                                                    
                                                }
    
    Public static void EmailSetup(String template,String recordId,
                                  String contactId, String toAddresses, String ccAddresses, 
                                  List<Messaging.EmailFileAttachment> attachList){
                                      Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();   
                                      if(!String.isBlank(toAddresses)){
                                          List<string> toAddressesList=toAddresses.split(';');
                                          // Set the tO Recipient of the Email.
                                          objEmail.setToAddresses(toAddressesList); 
                                      } 
                                      if(!String.isBlank(ccAddresses)){
                                          List<string> ccAddressesList=ccAddresses.split(';');
                                          // Set the CC Recipient.
                                          objEmail.setccAddresses(ccAddressesList); 
                                      }
                                      if(!test.isRunningTest()){
                                          if(!String.isBlank(template)&&!String.isBlank(contactId)){
                                              // Set the Template Id 
                                              objEmail.setTemplateId([SELECT Name FROM EmailTemplate WHERE 
                                                                      Name = :template LIMIT 1].Id);
                                              // To set the context and ensures that merge fields in the template 
                                              // contain the correct data.
                                              objEmail.setTargetObjectId(contactId);
                                          }
                                          
                                      }
                                      else{
                                          objEmail.setPlainTextBody('Testing Email');
                                      }
                                      if(!String.isBlank(recordId)){
                                          //Set the what id so that template merge fields should work fine
                                          objEmail.setWhatId(recordId);
                                      }
                                      if(!attachList.isEmpty()){
                                          //Set the attachment list to email
                                          objEmail.setFileAttachments(attachList);
                                      }
                                      
                                      objEmail.setTreatTargetObjectAsRecipient(false);
                                      objEmail.setSaveAsActivity(false);
                                      
                                      Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(
                                          new Messaging.SingleEmailMessage[] {objEmail});
                                      if(!emailResult[0].isSuccess()){
                                          System.debug('Error :' +emailResult[0].getErrors());
                                      } else{
                                          System.debug('Success');
                                      } 
                                      
                                  }
}