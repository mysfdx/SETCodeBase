/*
Created By: Neha Agrawal
Created Date: 04th August 2022
Description: AcctIncExceptionEmailService: Created to handle email responses for 
non Salesforce users for Accounting ACH Cases.
Changelog 

Author--             Date--                       Purpose--

*/
global class AcctIncExceptionEmailService implements Messaging.InboundEmailHandler {
    //New Car email addresses
    Incentive_Exception_Email__c newCarInitialApprover=
        Incentive_Exception_Email__c.getInstance('NewCarInitialApprover');
    Incentive_Exception_Email__c newCarAdditionalApprover=
        Incentive_Exception_Email__c.getInstance('NewCarAdditionalApprover');
    
    String newCarEmail=newCarInitialApprover.New_Car_Email_Address__c.toLowerCase();
    String tcuvEmail=newCarInitialApprover.TCUV_Email_Address__c.toLowerCase();
    
    String newCarInitialTo=newCarInitialApprover.To_Addresses__c;
    List<String> newCarInitialList=newCarInitialTo.split(';');
    List<String> newCarInitialToList=New List<String>();
    List<String> toAddressList=New List<String>();
    String newCarInitialCC=newCarInitialApprover.CC_Addresses__c;
    
    String newCarOver10To=newCarAdditionalApprover.Over_10k_To_Emails__c;
    String newCarOver50To=newCarAdditionalApprover.Over_50k_To_Emails__c;
    
    //TCUV email addresses
    Incentive_Exception_Email__c tcuvInitialApprover=Incentive_Exception_Email__c.getInstance('TCUVInitialApprover');
    Incentive_Exception_Email__c tcuvAdditionalApprover=
        Incentive_Exception_Email__c.getInstance('TCUVAdditionalApprover');
    
    String TCUVInitialTo=tcuvInitialApprover.To_Addresses__c;
    List<String> TCUVInitialList=TCUVInitialTo.split(';');
    List<String> TCUVInitialToList=New List<String>();
    String TCUVInitialCC=tcuvInitialApprover.CC_Addresses__c;
    
    String TCUVOver10To=tcuvAdditionalApprover.Over_10k_To_Emails__c;
    String TCUVOver50To=tcuvAdditionalApprover.Over_50k_To_Emails__c;  
    
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
                
            }
            System.debug('emailPlainBody.indexOfIgnoreCase Approved is ' +
                         emailPlainBody.indexOfIgnoreCase('Approved'));
            System.debug('emailPlainBody.LastindexOf Approve ' +emailPlainBody.LastindexOf('Approved'));
            
            For(String n: newCarInitialList){
                String lowerN=n.toLowerCase().trim();
                newCarInitialToList.add(lowerN);
            }
            newCarInitialList.clear();
            For(String t: TCUVInitialList){
                String lowerT=t.toLowerCase();
                TCUVInitialToList.add(lowerT);
            }
            TCUVInitialList.clear();
            system.debug('Email to address is '+email.toAddresses);
            system.debug('envelope from  address is '+envelope.fromAddress);
            system.debug('email from  address is '+email.fromAddress);
            system.debug('Email from name is '+email.fromName);
            system.debug('Email HTML body is '+email.htmlBody);
            system.debug('Email Text attachments is '+email.textAttachments);
            system.debug('Email Binary attachments is '+email.binaryAttachments);
            String erNumber;
            Pattern p = Pattern.compile('ER-\\d{8}+');
            Matcher m = p.matcher(email.Subject);
            while(m.find()){
                erNumber = m.group();
            }
            system.debug('Exception request Number is '+erNumber);
            if(erNumber == null) {
                For(String toAdd: email.toAddresses){
                    String toAddEmail=toAdd.toLowerCase();
                    toAddressList.add(toAddEmail);
                }
                
                //Create New ER and send approval requesting email with attachments.
                try{
                    If(toAddressList.contains(newCarEmail)){
                        createERRecord('New Car Incentive Exception Request',emailPlainBody,
                                       email.fromName,email.fromAddress,email.subject,email.binaryAttachments); 
                    }
                    else if(toAddressList.contains(tcuvEmail)){
                        createERRecord('TCUV Incentive Exception Request',emailPlainBody,
                                       email.fromName,email.fromAddress,email.subject,email.binaryAttachments);
                    }
                    result.message='Thank you for sending an exception request. Your request has been successfully submitted.';
                }
                catch(exception e){
                    system.debug('Exception occured '+e.getStackTraceString());
                    result.message='Some error occured, please contact to Salesforce Admin.';
                }
                
                
            } else { 
                
                
                //If subject contains request number.
                try{
                    Exception_Request__c existingER=[SELECT Id, CreatedById, Name, Status__c, Approval_History__c,
                                                     Exception_Request_Type__c, Total_VIN_Amount__c,
                                                     Manual_Total_VIN_Amount__c,Final_Approver__c
                                                     FROM Exception_Request__c WHERE Name=:erNumber LIMIT 1];
                    Boolean ERForFirstApproval;
                    String ERForAdditionalApproval;
                    If( email.Subject.containsIgnoreCase('New TCUV Exception Incentive Request Submitted')||
                       email.Subject.containsIgnoreCase('New Car Exception Incentive Request Submitted')){
                           system.debug('email.subject '+email.subject);
                           system.debug('TCUVInitialToList '+TCUVInitialToList);
                           system.debug('newCarInitialToList '+newCarInitialToList);
                           system.debug('existingER '+existingER);
                           system.debug('email.fromAddress.ToLowerCase() '+email.fromAddress.ToLowerCase());
                           ERForFirstApproval=validateRecordForFirstApproval(email.subject,TCUVInitialToList,
                                                                             newCarInitialToList,existingER,
                                                                             email.fromAddress.ToLowerCase()); 
                       }
                    else if(email.Subject.containsIgnoreCase('Additional approval is required on request')){
                        List<String> newCarOver10ToList=New List<String>();
                        List<String> newCarOver50ToList=New List<String>();
                        List<String> tcuvOver10ToList=New List<String>();
                        List<String> tcuvOver50ToList=New List<String>();
                        List<String> lowerList=New List<String>();
                        lowerList=newCarOver10To.Split(';');
                        For(String n10: lowerList){
                            String lowerN10=n10.toLowerCase().trim();
                            newCarOver10ToList.add(lowerN10);
                        }
                        lowerList.clear();
                        lowerList=newCarOver50To.Split(';');
                        For(String n50: lowerList){
                            String lowerN50=n50.toLowerCase().trim();
                            newCarOver50ToList.add(lowerN50);
                        }
                        lowerList.clear();
                        lowerList=TCUVOver10To.Split(';');
                        For(String t10: lowerList){
                            String lowerT10=t10.toLowerCase().trim();
                            tcuvOver10ToList.add(lowerT10);
                        }
                        lowerList.clear();
                        lowerList=TCUVOver50To.Split(';');
                        For(String t50: lowerList){
                            String lowerT50=t50.toLowerCase().trim();
                            tcuvOver50ToList.add(lowerT50);
                        }
                        lowerList.clear();
                        
                        ERForAdditionalApproval=validateRecordForAdditionalApproval(tcuvOver10ToList,tcuvOver50ToList, 
                                                                                    newCarOver10ToList,newCarOver50ToList,existingER,
                                                                                    email.fromAddress.ToLowerCase());
                    }
                    
                    
                    system.debug('ERForFirstApproval '+ERForFirstApproval);
                    system.debug('ERForAdditionalApproval '+ERForAdditionalApproval);
                    
                    If((ERForFirstApproval<>null &&ERForFirstApproval)  || (ERForAdditionalApproval=='Over 10k' ||ERForAdditionalApproval=='Over 50k')){
                        If(emailPlainBody.indexOfIgnoreCase('Approved')<>-1 && 
                           emailPlainBody.indexOfIgnoreCase('Approved')>=0 && 
                           emailPlainBody.indexOfIgnoreCase('Approved')<175){
                               //recordLockObj.VR_RecordLocked_Validation__c=false;
                               //update recordLockObj;
                               Approval.UnLockResult UnlockResult= Approval.UnLock(existingER, false);
                               System.debug('UnLock record Success is '+UnlockResult.isSuccess());
                               system.debug('will get approved.');
                               existingER.Status__c='Incentive Approved';
                               existingER.Final_Approver__c=email.fromName;
                               existingER.Approval_History__c+='\r\n\r\n';
                               if(ERForFirstApproval<>null && ERForFirstApproval){
                                   existingER.Approval_History__c+='Initially approved by '+email.fromName; 
                               }
                               else if(ERForAdditionalApproval=='Over 10k'){
                                   existingER.Approval_History__c+='Over 10k request approved by '+email.fromName;
                               }
                               else if(ERForAdditionalApproval=='Over 50k'){
                                   existingER.Approval_History__c+='Over 50k approved by '+email.fromName; 
                               }
                               
                               update existingER;
                               
                           }
                        Else If(emailPlainBody.indexOfIgnoreCase('Rejected')<>-1 && 
                                emailPlainBody.indexOfIgnoreCase('Rejected')>=0 && 
                                emailPlainBody.indexOfIgnoreCase('Rejected')<175){
                                    //recordLockObj.VR_RecordLocked_Validation__c=false;
                                    //update recordLockObj;
                                    Approval.UnLockResult UnlockResult= Approval.UnLock(existingER, false);
                                    System.debug('UnLock record Success is '+UnlockResult.isSuccess());
                                    system.debug('will get denied.');
                                    existingER.Status__c='Incentive Denied';
                                    existingER.Final_Approver__c=email.fromName;
                                    existingER.Approval_History__c+='\r\n\r\n';
                                    if(ERForFirstApproval<>null && ERForFirstApproval){
                                        existingER.Approval_History__c+='Initially denied by '+email.fromName;
                                    }
                                    else if(ERForAdditionalApproval=='Over 10k'){
                                        existingER.Approval_History__c+='Over 10k request denied by '+email.fromName;
                                    }
                                    else if(ERForAdditionalApproval=='Over 50k'){
                                        existingER.Approval_History__c+='Over 50k denied by '+email.fromName; 
                                    }
                                    update existingER;
                                }
                    }
                    
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
                    emailMessage.RelatedToId = existingER.Id;
                    insert emailMessage;
                    result.message='Thanks for sending mail. Email has been logged to the exception request.';
                }
                catch(exception e){
                    system.debug('Exception occured '+e.getMessage()+' '+e.getLineNumber()+' '+e.getCause()
                                +' '+e.getStackTraceString());
                    result.message='Some error occured, please contact to Salesforce Admin.';
                }
            }
            }
            else{
                result.message='Email body is blank that is why we are unable to process this email.';
            }
            return result;
        }
    private void createERRecord(String requestType, String emailBody, String fromName, 
                                String fromEmail, String Subject, 
                                Messaging.InboundEmail.BinaryAttachment[] attachments){
                                    List<Messaging.EmailFileAttachment> emailAttach = 
                                        New List<Messaging.EmailFileAttachment>{};
                                            Exception_Request__c exceptionReq=new Exception_Request__c();
                                    exceptionReq.Exception_Request_Type__c=requestType;   
                                    exceptionReq.Description__c=emailBody;  
                                    exceptionReq.Requester_Name__c=fromName;  
                                    exceptionReq.Requester_Email__c=fromEmail;
                                    exceptionReq.Subject__c=Subject;
                                    insert exceptionReq;
                                    if( attachments <>null){
                                        if(!attachments.isEmpty()){
                                            List<ContentVersion> contentVersionList=new List<ContentVersion>();
                                            For(Messaging.Inboundemail.BinaryAttachment file : 
                                                attachments){
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
                                                    emailAttach.add(singleAttach);
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
                                                cdl.LinkedEntityId = exceptionReq.Id;
                                                cdl.ContentDocumentId = ver.ContentDocumentId;
                                                cdl.shareType = 'V';
                                                conDocLinkList.add(cdl);
                                            }
                                            Database.insert(conDocLinkList, False);
                                        }
                                    }
                                    If(requestType.containsIgnoreCase('New Car')){
                                        sendApprovalEmail('Exception_Request_Approval_Request',emailAttach
                                                          ,exceptionReq.Id,newCarInitialToList,newCarInitialCC);  
                                    }
                                    Else If(requestType.containsIgnoreCase('TCUV')){
                                        sendApprovalEmail('TCUV_Exception_Request_Approval_Request',emailAttach
                                                          ,exceptionReq.Id,TCUVInitialToList,TCUVInitialCC);  
                                    }
                                    
                                }
    
    private void sendApprovalEmail(String templateName, List<Messaging.EmailFileAttachment> emailFiles,
                                   Id exceptionRecordId, List<String> approverList, String ccAddresses){
                                       EmailTemplate emailtemp = [SELECT Id, Subject, HTMLValue, Body FROM 
                                                                  EmailTemplate WHERE DeveloperName  =:templateName];
                                       Exception_Request__c er=[SELECT Id, CreatedById, Name
                                                                FROM Exception_Request__c 
                                                                WHERE Id=:exceptionRecordId LIMIT 1];
                                       system.debug('exceptionRecord id is '+exceptionRecordId);
                                       Messaging.SingleEmailMessage mail = 
                                           Messaging.renderStoredEmailTemplate(emailtemp.Id, er.CreatedById, er.Id);
                                       String emailSubject = mail.getSubject();
                                       String emailTextBody = mail.getPlainTextBody();
                                       //List<String> toAddressList=New List<String>();
                                       //toAddressList.add('neha.agrawal@dxc.com');
                                       
                                       if(!emailFiles.isEmpty()){
                                           mail.setFileAttachments(emailFiles);
                                       }
                                       mail.setSubject(emailSubject);
                                       mail.setPlainTextBody(emailTextBody);
                                       mail.setUseSignature(false);
                                       mail.setTargetObjectId(er.CreatedById);
                                       //mail.setWhatId(er.Id);
                                       mail.setTreatTargetObjectAsRecipient(false);
                                       mail.setToAddresses(approverList);//Set To Email Address
                                       If(String.isNotBlank(ccAddresses)){
                                           List<String> ccEmails=ccAddresses.Split(';');
                                           mail.setCCAddresses(ccEmails);
                                       }
                                       
                                       mail.setSaveAsActivity(true); 
                                       If(toAddressList.contains(newCarEmail)){
                                           mail.setReplyTo(newCarEmail);    
                                       }
                                       else if(toAddressList.contains(tcuvEmail)){
                                           mail.setReplyTo(tcuvEmail);    
                                       }
                                       
                                       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
                                       //er.Approval_History__c='Record is locked and pending for approval.';
                                       //er.Approval_History__c += '\r\n';
                                       er.Approval_History__c = 'Initial Approval request has been sent to '+ 
                                           approverList;
                                       er.Final_Approver__c='Record is locked and pending for approval.';
                                       Update er;
                                       //recordLockObj.VR_RecordLocked_Validation__c=True;
                                       //update recordLockObj;
                                       Approval.LockResult lockResult= Approval.Lock(er, false);
                                       System.debug('Lock record Success is '+lockResult.isSuccess());
                                       
                                   }
    private Boolean validateRecordForFirstApproval(String mailSubject, List<String> TCUVApprover, 
                                                   List<String> NewCarApprover, Exception_Request__c existingERNum, 
                                                   String fromEmail ){
                                                       system.debug('From Email is '+fromEmail);
                                                       System.debug('NewCarApprover.contains(fromEmail) '+ NewCarApprover.contains(fromEmail));
                                                       System.debug('NewCarApprover '+NewCarApprover);
                                                       System.debug('mailSubject.containsIgnoreCase(New Car) '+ 
                                                                    mailSubject.containsIgnoreCase('New Car Exception Incentive Request Submitted'));
                                                       System.debug('Status checking is  '+ existingERNum.Status__c.Equals('New')); 
                                                       System.debug('existingERNum.Status__c  is '+ existingERNum.Status__c);
                                                       If(NewCarApprover.contains(fromEmail) && 
                                                          mailSubject.containsIgnoreCase('New Car Exception Incentive Request Submitted') &&  
                                                          existingERNum.Status__c=='New'){
                                                              return True;
                                                          }
                                                       else If(TCUVApprover.contains(fromEmail) && 
                                                               mailSubject.containsIgnoreCase('New TCUV Exception Incentive Request Submitted') &&  
                                                               existingERNum.Status__c=='New'){
                                                                   return True;
                                                               }
                                                       else{
                                                           return False;
                                                       }
                                                   }
    private String validateRecordForAdditionalApproval(List<String> TCUVOver10,List<String> TCUVOver50, 
                                                       List<String> newCarOver10, List<String> newCarOver50, 
                                                       Exception_Request__c existingERNum, String fromEmail ){
                                                           String result='';
                                                           
                                                           system.debug('From Email is '+fromEmail);
                                                           System.debug('TCUVOver10.contains(fromEmail) '+
                                                                        TCUVOver10.contains(fromEmail));
                                                           System.debug('TCUVOver50.contains(fromEmail) '+
                                                                        TCUVOver50.contains(fromEmail));
                                                           System.debug('TCUVOver10 '+TCUVOver10);
                                                           System.debug('TCUVOver50 '+TCUVOver50);
                                                           System.debug('newCarOver10.contains(fromEmail) '+
                                                                        newCarOver10.contains(fromEmail));
                                                           System.debug('newCarOver50.contains(fromEmail) '+
                                                                        newCarOver50.contains(fromEmail));
                                                           System.debug('newCarOver50 '+newCarOver50);
                                                           System.debug('newCarOver10 '+newCarOver10);
                                                           System.debug('Status checking is  '+ 
                                                                        existingERNum.Status__c.Equals('Additional Approval Required')); 
                                                           System.debug('existingERNum.Status__c  is '+ existingERNum.Status__c);
                                                           If(existingERNum.Status__c.Equals('Additional Approval Required')){
                                                               If((existingERNum.Total_VIN_Amount__c>10000 && 
                                                                   existingERNum.Total_VIN_Amount__c<=50000) ||
                                                                  (existingERNum.Manual_Total_VIN_Amount__c>10000 && 
                                                                   existingERNum.Manual_Total_VIN_Amount__c<=50000)){
                                                                       If((existingERNum.Exception_Request_Type__c==
                                                                           'New Car Incentive Exception Request' && 
                                                                           newCarOver10.contains(fromEmail)) ||
                                                                          (existingERNum.Exception_Request_Type__c==
                                                                           'TCUV Incentive Exception Request' && 
                                                                           TCUVOver10.contains(fromEmail))){
                                                                               result='Over 10k';
                                                                           }
                                                                       
                                                                   }
                                                               else If(existingERNum.Total_VIN_Amount__c>50000 ||
                                                                       existingERNum.Manual_Total_VIN_Amount__c>50000){
                                                                           If((existingERNum.Exception_Request_Type__c==
                                                                               'New Car Incentive Exception Request' && 
                                                                               newCarOver50.contains(fromEmail)) ||
                                                                              (existingERNum.Exception_Request_Type__c==
                                                                               'TCUV Incentive Exception Request' && 
                                                                               TCUVOver50.contains(fromEmail))){
                                                                                   result='Over 50k';
                                                                               }
                                                                           
                                                                       }
                                                               
                                                           }
                                                           
                                                           system.debug('result '+result);
                                                           return result;
                                                       }
}