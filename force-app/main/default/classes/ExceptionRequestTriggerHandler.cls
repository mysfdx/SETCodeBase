public class ExceptionRequestTriggerHandler {
    
    List<Messaging.SingleEmailMessage> emailToSentList= New List<Messaging.SingleEmailMessage>();
    List<Exception_Request__c> erToUpdate=New List<Exception_Request__c>();
    //bypassExecution_ExceptionRequest__c obj = bypassExecution_ExceptionRequest__c.getOrgDefaults();
    
    
    public void afterUpdate(Map<Id, Exception_Request__c> erNewMap){
        For(Exception_Request__c e:erNewMap.Values()){
            system.debug('exception request status is '+e.Status__c);
            If(e.Status__c=='Incentive Approved' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Incentive_Exception_Request_Approved',e,'Accounting', false);
               }
            If(e.Status__c=='Incentive Approved' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Exception_Request_Approved',e,'Accounting',false);
               }
            If(e.Status__c=='Incentive Denied' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Incentive_Exception_Request_Reject',e,'',True);
               }
            If(e.Status__c=='Incentive Denied' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Exception_Request_Reject',e,'',True);
               }
            If(e.Status__c=='Approved for SET to Pay' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Exception_Request_Approved_for_SET_to_Pay',e,'Accounting', True);
               }
            If(e.Status__c=='Approved for SET to Pay' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Approved_for_SET_to_Pay',e,'Accounting', True);
               }
            If(e.Status__c=='Unable to Process Payment' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Exception_Request_Unable_to_Process_Payment',e,'NewCarIncentive',True);
               }
            If(e.Status__c=='Unable to Process Payment' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Unable_to_Process_Payment',e,'TCUVIncentive',True);
               }
            If(e.Status__c=='Previously Paid' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Exception_Request_Previously_Paid',e,'NewCarIncentive',True);
               }
            If(e.Status__c=='Previously Paid' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Previously_Paid',e,'TCUVIncentive',True);
               }
            If(e.Status__c=='Payment Processed' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   sendOtherExceptionEmail('Exception_Request_Payment_Processed',e,'NewCarIncentive',True);
               }
            If(e.Status__c=='Payment Processed' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   sendOtherExceptionEmail('TCUV_Payment_Processed',e,'TCUVIncentive',True);
               }
            If(e.Status__c=='Additional Approval Required' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   If(e.Manual_Total_VIN_Amount__c>10000 || e.Total_VIN_Amount__c>10000 ||
                      e.Manual_Total_VIN_Amount__c>50000 || e.Total_VIN_Amount__c>50000 ){
                          sendOtherExceptionEmail('Exception_Request_Additional_Approval',e,'Additional',false);
                      }
                   else{
                       e.addError('Amount should be greater than either 10k or 50k. Please verify approver '+ 
                                  'Limits follow JMFE Approval Guidelines.');
                   }
                   
               }
            If(e.Status__c=='Additional Approval Required' && 
               e.Exception_Request_Type__c=='TCUV Incentive Exception Request'){
                   If(e.Manual_Total_VIN_Amount__c>10000 || e.Total_VIN_Amount__c>10000 ||
                      e.Manual_Total_VIN_Amount__c>50000 || e.Total_VIN_Amount__c>50000){
                          sendOtherExceptionEmail('TCUV_Additional_Approval',e,'Additional',false);
                      }
                   else{
                       e.addError('Amount should be greater than either 10k or 50k');
                   }
               }
            If(e.Status__c=='Ready for Processing' && 
               e.Exception_Request_Type__c=='New Car Incentive Exception Request'){
                   If(e.SETF_Sub_Programs__c=='PAL'){
                       sendOtherExceptionEmail('Exception_Request_SETF_Sub_Program',e,'PAL',false);
                   }
                   else If(e.SETF_Sub_Programs__c=='College-Military' || e.SETF_Sub_Programs__c=='Bonus/Presold'){
                       sendOtherExceptionEmail('Exception_Request_SETF_Sub_Program',e,'OtherThanPal',false);
                       
                   }
               }
            If(!emailToSentList.isEmpty()){
                system.debug('emailToSentList is '+emailToSentList);
                Messaging.sendEmail(emailToSentList);//Send Email 
            }
            If(!erToUpdate.isEmpty()){
                system.debug('erToUpdate is '+erToUpdate);
                system.database.update(erToUpdate, false);
                for(Exception_Request__c erRecord: erToUpdate){
                    Approval.LockResult lockResult= Approval.Lock(erRecord, false);
                    System.debug('Lock record Success is '+lockResult.isSuccess());
                }
                
                //obj.VR_RecordLocked_Validation__c = True;
                //update obj;
            }
            
        }
        
    }
    private void sendOtherExceptionEmail(String templateName, Exception_Request__c exceptionRecord, 
                                         String ReceipientType, Boolean requesterAsRecp){
                                             
                                             Incentive_Exception_Email__c incEmail=Incentive_Exception_Email__c.getInstance('OtherExceptionEmails');
                                             String newCarEmailAdd=incEmail.New_Car_Email_Address__c;
                                             String tcuvEmailAdd=incEmail.TCUV_Email_Address__c;
                                             Incentive_Exception_Email__c tcuvAddApprover=Incentive_Exception_Email__c.getInstance('TCUVAdditionalApprover');
                                             Incentive_Exception_Email__c newCarAddApprover=Incentive_Exception_Email__c.getInstance('NewCarAdditionalApprover');
                                             
                                             EmailTemplate emailtemp = [SELECT Id, Subject, HTMLValue, Body FROM 
                                                                        EmailTemplate WHERE DeveloperName  =:templateName];
                                             List<Messaging.EmailFileAttachment> emailFiles = 
                                                 new List<Messaging.EmailFileAttachment>{};
                                                     List<String> toAddresses= New List<String>();
                                             List<String> ccAddresses= New List<String>();
                                             Exception_Request__c exceptionReq;
                                             system.debug('exceptionRecord status is '+exceptionRecord.Status__c);
                                             Messaging.SingleEmailMessage mail = 
                                                 Messaging.renderStoredEmailTemplate(emailtemp.Id, 
                                                                                     exceptionRecord.CreatedById, 
                                                                                     exceptionRecord.Id);
                                             String emailSubject = mail.getSubject();
                                             String emailTextBody = mail.getPlainTextBody();
                                             String emailHTMLBody=mail.getHtmlBody();
                                             If(ReceipientType=='Additional'){
                                                 Set<Id> contentDocIds = new Set<Id>();
                                                 list<contentDocumentLink> contentDocLink=[SELECT LinkedEntityId,ContentDocumentId
                                                                                           FROM ContentDocumentLink WHERE 
                                                                                           LinkedEntityId=:exceptionRecord.Id];
                                                 if(!contentDocLink.isEmpty()){
                                                     for(ContentDocumentLink link:contentDocLink){
                                                         contentDocIds.add(link.ContentDocumentId);
                                                     }
                                                     List<ContentVersion> documents= new List<ContentVersion>{};
                                                         documents.addAll([
                                                             SELECT Id, Title, FileType, VersionData, isLatest, 
                                                             PathOnClient, ContentDocumentId FROM ContentVersion
                                                             WHERE isLatest = true AND ContentDocumentId in: contentDocIds
                                                         ]);
                                                     
                                                     for (ContentVersion document: documents) {
                                                         Messaging.EmailFileAttachment attachment = 
                                                             new Messaging.EmailFileAttachment();
                                                         blob WOCFbody = document.versiondata;
                                                         attachment.setBody(WOCFbody);
                                                         attachment.setFileName(document.PathOnClient);
                                                         
                                                         emailFiles.add(attachment);
                                                     }
                                                 }
                                                 
                                                 if(!emailFiles.isEmpty()){
                                                     mail.setFileAttachments(emailFiles);
                                                 }
                                                 exceptionReq=[SELECT Id, CreatedById, Name,Approval_History__c,
                                                               Total_VIN_Amount__c,Manual_Total_VIN_Amount__c,
                                                               Exception_Request_Type__c, Final_Approver__c 
                                                               FROM Exception_Request__c 
                                                               WHERE Id=:exceptionRecord.Id LIMIT 1];
                                                 
                                             }
                                             mail.setSubject(emailSubject);
                                             mail.setHtmlBody(emailHTMLBody);
                                             mail.setUseSignature(false);
                                             mail.setTargetObjectId(exceptionRecord.CreatedById);
                                             //mail.setWhatId(er.Id);
                                             mail.setTreatTargetObjectAsRecipient(false);
                                             
                                             If(ReceipientType<>'' && ReceipientType=='Accounting'){
                                                 String accountingAddress=incEmail.Accounting_Email__c;
                                                 toAddresses.addAll(accountingAddress.Split(';'));
                                             }
                                             If(ReceipientType<>'' && ReceipientType=='NewCarIncentive'){
                                                 String newCarInc=incEmail.New_Car_Incentive_Team__c;
                                                 toAddresses.addAll(newCarInc.Split(';'));
                                             }
                                             If(ReceipientType<>'' && ReceipientType=='TCUVIncentive'){
                                                 String tcuvInc=incEmail.TCUV_Incentive_Team__c;
                                                 toAddresses.addAll(tcuvInc.Split(';'));
                                             }
                                             If(ReceipientType<>'' && ReceipientType=='PAL'){
                                                 String palEmail=incEmail.PAL_Email__c;
                                                 toAddresses.addAll(palEmail.Split(';'));
                                             }
                                             If(ReceipientType<>'' && ReceipientType=='OtherThanPal'){
                                                 String otherThanPal=incEmail.Other_than_PAL_Email__c;
                                                 toAddresses.addAll(otherThanPal.Split(';'));
                                             }
                                             If(ReceipientType<>'' && ReceipientType=='Additional'){
                                                 exceptionReq.Approval_History__c += '\r\n\r\n';
                                                 If((exceptionReq.Total_VIN_Amount__c>10000 && 
                                                     exceptionReq.Total_VIN_Amount__c<=50000)
                                                    || (exceptionReq.Manual_Total_VIN_Amount__c>10000 && 
                                                        exceptionReq.Manual_Total_VIN_Amount__c<=50000)){
                                                            
                                                            If(exceptionReq.Exception_Request_Type__c==
                                                               'New Car Incentive Exception Request'){
                                                                   String newCarOver10To=
                                                                       newCarAddApprover.Over_10k_To_Emails__c;
                                                                   toAddresses.addAll(newCarOver10To.Split(';'));
                                                                   exceptionReq.Approval_History__c += 
                                                                       'Additional Approval request for over 10k has been sent to '+toAddresses;
                                                                   String newCarOver10CC=
                                                                       newCarAddApprover.Over_10k_CC_Emails__c;
                                                                   If(String.isNotBlank(newCarOver10CC)){
                                                                       ccAddresses.addAll(newCarOver10CC.split(';')); 
                                                                   }
                                                                   
                                                                   
                                                               }
                                                            Else If(exceptionReq.Exception_Request_Type__c==
                                                                    'TCUV Incentive Exception Request'){
                                                                        String TCUVOver10To=tcuvAddApprover.Over_10k_To_Emails__c;
                                                                        toAddresses.addAll(TCUVOver10To.Split(';'));
                                                                        exceptionReq.Approval_History__c += 
                                                                            'Additional Approval request for over 10k has been sent to '+toAddresses;
                                                                        String TCUVOver10CC=tcuvAddApprover.Over_10k_CC_Emails__c;
                                                                        If(String.isNotBlank(TCUVOver10CC)){
                                                                            ccAddresses.addAll(TCUVOver10CC.split(';')); 
                                                                        }
                                                                    }
                                                            
                                                            
                                                        }
                                                 Else If(exceptionReq.Total_VIN_Amount__c>50000 ||
                                                         exceptionReq.Manual_Total_VIN_Amount__c>50000){
                                                             
                                                             If(exceptionReq.Exception_Request_Type__c==
                                                                'New Car Incentive Exception Request'){
                                                                    String newCarOver50To=newCarAddApprover.Over_50k_To_Emails__c;
                                                                    toAddresses.addAll(newCarOver50To.Split(';'));
                                                                    exceptionReq.Approval_History__c += 
                                                                        'Additional Approval request for over 50k has been sent to '+toAddresses;
                                                                    String newCarOver50CC=newCarAddApprover.Over_50k_CC_Emails__c;  
                                                                    If(String.isNotBlank(newCarOver50CC)){
                                                                        ccAddresses.addAll(newCarOver50CC.split(';')); 
                                                                    }
                                                                }
                                                             Else If(exceptionReq.Exception_Request_Type__c==
                                                                     'TCUV Incentive Exception Request'){
                                                                         String TCUVOver50To=tcuvAddApprover.Over_50k_To_Emails__c;
                                                                         toAddresses.addAll(TCUVOver50To.Split(';'));
                                                                         exceptionReq.Approval_History__c += 
                                                                             'Additional Approval request for over 50k has been sent to '+toAddresses;
                                                                         String TCUVOver50CC=tcuvAddApprover.Over_50k_CC_Emails__c;
                                                                         If(String.isNotBlank(TCUVOver50CC)){
                                                                             ccAddresses.addAll(TCUVOver50CC.split(';')); 
                                                                         }
                                                                     }
                                                             
                                                         }
                                                 exceptionReq.Final_Approver__c='Record is locked and pending for approval.';
                                                 if(!checkRecursive.alreadyProcessed.contains(exceptionReq.Id)){
                                                     erToUpdate.add(exceptionReq);
                                                     checkRecursive.alreadyProcessed.add(exceptionReq.Id);
                                                 }
                                             }
                                             
                                             If(requesterAsRecp==True){
                                                 toAddresses.add(exceptionRecord.Requester_Email__c);
                                             }
                                             If(!toAddresses.isEmpty()){
                                                 mail.setToAddresses(toAddresses);//Set To Email Address
                                             }
                                             If(!ccAddresses.isEmpty()){
                                                 mail.setCCAddresses(ccAddresses);//Set CC Email Address
                                             }
                                             mail.setSaveAsActivity(true); 
                                             If(exceptionRecord.Exception_Request_Type__c==
                                                'New Car Incentive Exception Request'){
                                                    mail.setReplyTo(newCarEmailAdd);    
                                                }
                                             else if(exceptionRecord.Exception_Request_Type__c==
                                                     'TCUV Incentive Exception Request'){
                                                         mail.setReplyTo(tcuvEmailAdd);    
                                                     }
                                             
                                             emailToSentList.add(mail); 
                                         }
}