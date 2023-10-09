public without sharing class SET_TaskTriggerHandler {
    
    public static Boolean IsExecuted = false;
    public static String profileName;
    /*******************************************************************************************
    
    Intital Creation History
    Created By: Jay B
    Created On: 1/29/2014
    Purpose: This requirement is part of Competitive Contact CR ticket. An email should be 
    sent to an Email group
    Process: This is invoked FROM Task Trigger
    
    Modified On:8/15/2014
    Modified By:Jay B
    Purpose: Leveraged COE_CodeLibrary class to extract name for Related to field value.
    
    
    Modified On:04/29/2015
    Modified By:Rakshik Bhan
    Purpose: Need to send task completion email notification for "DFOM ME Recap" activity type which doesn't have an associated account.
    Ticket: TKT0566474
    
    Modified On:10/29/2020
    Modified By:Neha Agrawal
    Purpose: Changes in onAfterInsert to avoid the execution of methods if Case Form name is Incentive Challenge
    Ticket: CHG0038967

    Modified On:1/27/2021
    Modified By:Neha Agrawal
    Purpose: Moving to lightning where Attachments are files so created new code for identifying if files present 
             on task or not to set value of is Attchament present field on Task and commented handleattachment method.
    Ticket: During Lightning Migration Project
    

    Modified On:5/25/2021
    Modified By:Neha Agrawal
    Purpose: To add Task Creator as CC to all contact report emails.
    Ticket: During SET STGY 15 Salesforce Project, issue SS1SP-46
  
    ********************************************************************************/   
    
    public static void onBeforeInsert(List < Task > newTasks) {
        populateAreaDist(newTasks, null);
    }
    
    public static void onBeforeUpdate(List < Task > newTasks, Map < Id, Task > oldMap) {
        validateTXMTasks(newTasks, oldMap);
        populateAreaDist(newTasks, oldMap);
    }
    
    public static void onAfterInsert(List < Task > newTasks, Map < Id, Task > newMap) {
        list<id> caseids=new List<id>();
        Map<id, case> CaseMap;
        boolean isItIncentive=false;
        for ( Task newTask : newTasks ) {
		if ( newTask.whatID != null && string.valueof(newTask.WhatID).startswith('500') ) {
		caseids.add(newTask.whatID);
		}
        }
        if(!caseids.isEmpty()){
            CaseMap= new Map<id, case>([Select id, Form_Name__c from Case where id in:caseids]);
        
        system.debug('newTasks is '+newTasks);
            for ( Task newTask : newTasks ) {
            if(CaseMap.get(newTask.whatID).form_Name__c=='Incentives Challenge'){
                isItIncentive=true;
            }
        }
        }
        
        
        if(!isItIncentive){
        //handleAddAttachment(newMap);
        String RetStatus = SET_TaskTriggerHandler.SendCompContactEmail(newTasks);
        system.debug('RetStatus in after insert is ' + RetStatus);
        SET_createConsultant_Task.createAutoTask(newTasks);
        }
        
    }
    
    public static void onAfterUpdate(List < Task > newTasks, Map < Id, Task > newMap, Map < Id, Task > oldMap) {
        //if ( !SET_TaskTriggerHandler.IsExecuted )
            //handleAddAttachment(newMap);
        String RetStatus = SendCompContactEmail(newTasks, oldMap);
        system.debug('RetStatus in after update is ' + RetStatus);
        createRecurrenceTasks(newTasks, oldMap);
        SET_createConsultant_Task.createDFOMTask(newTasks, oldMap);
        SET_createConsultant_Task.closeTXMTask(newTasks, oldMap);
        SET_createConsultant_Task.sendTaskPendingReminder(newTasks, oldMap); 
    }

    public static string SendCompContactEmail(LIST<Task> lstTaskRecords,Map < Id,Task> mpOldTask) {
        /*******************************************************************************************

        Intital Creation History
        Created By: Jay B
        Created On: 1/29/2014
        Purpose: This is the method that sends email to competitive contacts that is invoked FROM Task trigger after update.
        Process: This is invoked FROM Task Trigger after update
        ********************************************************************************/   

        string RetValue='-';
        List < Messaging.SingleEmailMessage > allemail = new List < Messaging.SingleEmailMessage > ();
        Send_Email_Info__c cmpcontEmail = Send_Email_Info__c.getInstance('Competitive Contact Email Information');
        EmailTemplate EmailToUse=new EmailTemplate();
        LIST < String > mailAddrs = new LIST < String >();
        LIST < Task > lstRecapTask = new LIST < Task >();

        system.debug('Started Trigger handler');
        List < ID > grpmemberid = new List < ID >();
        try {

            LIST<Competitive_Contact__c> lstComContact=new LIST<Competitive_Contact__c>();
            LIST<string> CompIds=new LIST<string>();

            system.debug('Tasks:'+lstTaskRecords);
            system.debug('Tasks::::'+mpOldTask);       

            for ( Task tskRec:lstTaskRecords) {
                system.debug('WhatId:'+tskRec.WhatId);
                system.debug('SUbject:'+tskRec.Subject);
                /*if ( TskRec.WhatId!=null && tskRec.Subject=='Competitive Contacts' && ((!mpOldTask.containsKey( TskRec.Id)&& tskRec.Status=='Completed')||(mpOldTask.containsKey( TskRec.Id) && tskRec.Status=='Completed' && mpOldTask.get(TskRec.Id).Status <> tskRec.Status ))) {
                CompIds.add( TskRec.WhatId);
                system.debug('Inside If');

                } */
                if ( TskRec.WhatId == null && tskRec.Status=='Completed' && tskRec.Activity_Type__c!='Competitive Contact' && (!mpOldTask.containsKey( TskRec.Id) || mpOldTask.get(TskRec.Id).Status <> tskRec.Status))
                    lstRecapTask.add( TskRec);
            }

            system.debug('lstRecapTask===='+lstRecapTask);
            if ( !lstRecapTask.isEmpty() )
                sendReCapEmail(lstRecapTask);
            
            system.debug('CompIds===='+CompIds);
            if ( CompIds.size() > 0 ) {
                EmailToUse = [ SELECT Subject, DeveloperName, Body FROM EmailTemplate e WHERE DeveloperName =: cmpcontEmail.Email_template_to_use__c ];
                for ( GroupMember gm1 : [ SELECT userOrGroupId FROM groupMember WHERE group.name = :cmpcontEmail.Group_Name__c ] ) 
                    grpmemberid.add(gm1.userOrGroupId);

                system.debug('cmpcontEmail.Group_Name__c===='+cmpcontEmail.Group_Name__c);
                system.debug('grpmemberid===='+grpmemberid);

                for (user u1: [SELECT id, email FROM user WHERE id IN: grpmemberid and IsActive = true]) {
                    mailAddrs.add(u1.email);
                }

                system.debug('mailAddrs===='+mailAddrs);
                system.debug('testing===='+[SELECT Name,ID FROM Competitive_Contact__c WHERE id in :CompIds]);
                for (Competitive_Contact__c cmpRec:[SELECT Name,ID FROM Competitive_Contact__c WHERE id in :CompIds] ) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(mailAddrs);
                    system.debug('Competitive COntact Email:'+mailAddrs);
                    string mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,'https://'+System.URL.getSalesforceBaseUrl().getHost()+'/' +string.valueOf(cmpRec.ID));
                    mail.setPlainTextBody(mailbody);
                    string emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,cmpRec.Name);

                    mail.setSubject(emailSubject);
                    allemail.add(mail);
                }
            }          
            //Below part is to consolidate changes of existing production trigger to this class usign a different method.
            List <Messaging.SingleEmailMessage> lstEmailforSendtoGrp=new List <Messaging.SingleEmailMessage>();
            lstEmailforSendtoGrp=SET_TaskTriggerHandler.SendEmailToGroup(lstTaskRecords, mpOldTask);
            system.debug('lstEmailforSendtoGrp===='+lstEmailforSendtoGrp);
            system.debug('lstTaskRecords===='+lstTaskRecords);
            if (lstEmailforSendtoGrp.size()>0) {
                allemail.addAll(lstEmailforSendtoGrp);
            }
            //End of consolidation.

            if (allemail.size() > 0) {
                
                Messaging.SendEmailResult[] results= Messaging.sendEmail(allemail);
                if(results.Size()>0){
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully');
                    } else {
                        System.debug('The email failed to send:' +  results[0].errors[0].message);
                    }
                }
                
                //Messaging.sendEmail(allemail); 
                //system.debug('===<><>'+Messaging.sendEmail(allemail, false));
                RetValue='Success';
            }
        }
        catch(exception e) {
            system.debug('Exception is ' + e.getMessage());
            RetValue='Failed';
        }

        return RetValue;
    }
    
    //Below method is called FROM Insert operation, WHERE oldmap is not there.
    public static string SendCompContactEmail(LIST<Task> lstTaskRecords) {        
        Map < Id,Task> mpTaskRecords=new Map < Id,Task>();
        string RetValue=SET_TaskTriggerHandler.SendCompContactEmail(lstTaskRecords, mpTaskRecords);
        return RetValue;    
    }
    
    public static List <Messaging.SingleEmailMessage> SendEmailToGroup(LIST<Task> lsttasks,Map < Id,Task> mpOldTask) {
        
    /*******************************************************************************************
    
    Intital Creation History
    Created By: Jay B
    Created On: 2/4/2014
    Purpose: This is the method that sends email to DPR and other user group that is invoked FROM Task trigger after update.
    Process: This is invoked FROM Task Trigger after insert/update. This merges the trigger code for SendEmailToGroup.
    ********************************************************************************/
    
        Map < String, Profile_allowed_to_runSendEmailToGroup__c> MpprfRecs = Profile_allowed_to_runSendEmailToGroup__c.getAll();
        set<string>profileset = new set<string>();
        list<string>profilelst = new LIST<string>();
        List < Messaging.SingleEmailMessage > allemail = new List < Messaging.SingleEmailMessage > ();
        LIST<string> AcitivityTypeList = new LIST<string>();
        List < Id > DFOMAcctIds = new List < Id >();    
        
        Send_Email_Info__c cmpcontEmail=Send_Email_Info__c.getInstance('Send Completion Email');
        if (cmpcontEmail.Activity_Type__c!=null) {
            AcitivityTypeList=cmpcontEmail.Activity_Type__c.split(';');
        }
        for (string rec : MpprfRecs.KeySet()) {
            string getprofilename = MpprfRecs.get(rec).Allowed_Profile__c;
            profilelst = getprofilename.split(';');
            profileset.addAll(profilelst);
            
        }        
        list < string > groupname = new list < string > ();
        List < String > mailAddrs = new List < String > ();
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();   
        string grpforEmail = cmpcontEmail.Group_Name__c + ';' + cmpcontEmail.Group_Names__c;
        LIST<string> lstGrps = grpforEmail.split(';'); 
        system.debug('SET_TaskTriggerHandler.profileName is ' + SET_TaskTriggerHandler.profileName);
        if ( profileset.contains(SET_TaskTriggerHandler.profileName) ) {
            EmailTemplate EmailToUse=new EmailTemplate();
            EmailToUse=[SELECT Subject,DeveloperName,Body FROM EmailTemplate e WHERE DeveloperName=:cmpcontEmail.Email_template_to_use__c];  
            system.debug('Email to use ' + EmailToUse);        
            List < string > Accountid = new list < string > ();
            MAP<Task,string> mpTskGrp = new MAP<Task,string>();
            Map < Id,string> AccountAreaMap=new Map < Id,string>();
            Map < Id,Task> TaskIDMap=new Map < Id,Task>();
            for ( Task t1: lsttasks) {                        
                 if ( T1.whatid != null) {
                    Accountid.add( T1.whatid);
                 }
                 
                 if ( (!mpOldTask.containsKey( T1.Id) && t1.Status=='Completed')||(mpOldTask.containsKey( T1.Id) && t1.Status=='Completed' && mpOldTask.get(T1.Id).Status <> t1.Status) )  {
                    if ( t1.Activity_Type__c == 'DealershipRoleChanges' && t1.Activity_Type_Sub_Category__c.contains('Comptroller') )
                        groupname.add('SET COMPTROLLER CHANGES');
                    if ( t1.Activity_Type__c == 'DealershipRoleChanges' && ( T1.Activity_Type_Sub_Category__c.contains('Dealer Principal') || t1.Activity_Type_Sub_Category__c.contains('General Manager') || t1.Activity_Type_Sub_Category__c.contains('Operational Manager')) )
                        groupname.add('SET DEALERSHIP ROLE CHANGES');
                    string grpTsk='-';
                    if (cmpcontEmail.Activity_Type__c.toUpperCase().contains( T1.Activity_Type__c.toUpperCase() ) && string.valueof( T1.WhatId).startswith('001')) {
                        DFOMAcctIds.add( T1.whatID);
                        TaskIDMap.put( T1.whatID,t1);
                    }       
                    else {    
                        system.debug('Inside else');
                        for (string strGrp : lstGrps) {
                            if ( t1.Activity_Type__c !=null && strGrp.toUpperCase().contains( T1.Activity_Type__c.toUpperCase())) {                        
                                grpTsk = strGrp;
                                groupname.add(strGrp);
                                mpTskGrp.put( T1,grpTsk);
                                break;
                            }                        
                        }
                        if (grpTsk=='-') { //Did not find in the group name is CS
                            grpTsk='SET ALL OTHER';
                            groupname.add(grpTsk);
                            mpTskGrp.put( T1,grpTsk);
                        }
                    }  
                    
                 }
            }      
              
            if ( DFOMAcctIds.size() > 0 ) {
                for ( Account accountRec:[SELECT ID,Area__c FROM Account WHERE ID in :DFOMAcctIds] ) {
                    AccountAreaMap.put(accountRec.ID,accountRec.Area__c);   
                }            
                for ( ID tskID:TaskIDMap.keySet() ) {
                    if ( AccountAreaMap.containsKey( TskID) ) {
                        string dFOMGrp='SET '+TaskIDMap.get(TskID).Activity_Type__c.toupperCase() + '-' + AccountAreaMap.get(TskID);
                        groupname.add(dFOMGrp);
                        mpTskGrp.put( TaskIDMap.get(TskID),dFOMGrp);
                    }                
                }            
            }        
          
            MAP<string,string> mprecName=new MAP<string,string>();
            mprecName = COE_CodeLibrary.getsObjectNameFieldValue(AccountID);
            List < Id > lstUserIds=new List < Id >();
            MAP <string,List < Id >> grpmemberid = new MAP <string,List < Id >>();
            Map < Id,string> mpUserEmail=new Map < Id,string>();
            for ( groupmember gm1: [ SELECT userOrGroupId,group.name FROM groupMember WHERE group.name IN : groupname ] ) {
                lstUserIds.add(gm1.userOrGroupId);
                if (grpmemberid.containsKey(gm1.group.name)) {
                    List < Id > lstIds=new List < Id >();
                    lstIds = grpmemberid.get(gm1.group.name);
                    lstIds.add(gm1.userOrGroupId);
                    grpmemberid.put(gm1.group.name,lstIds);
                }
                else {
                    List < Id > lstIds=new List < Id >();
                    lstIds.add(gm1.userOrGroupId);
                    grpmemberid.put(gm1.group.name,lstIds);
                }
            }
            
            for ( User u1: [ SELECT id, email FROM user WHERE id IN: lstUserIds and IsActive = true]) {
                //mailAddrs.add(u1.email);
                mpUserEmail.put(u1.id,u1.Email);   
            }            
            system.debug('mpTskGrp is ' + mpTskGrp.keySet());
            for ( Task taskrec : mpTskGrp.keySet() ) {
                if ( Taskrec.Activity_Type__c == 'DealershipRoleChanges') {
                    if ( taskrec.Activity_Type_Sub_Category__c.contains('Comptroller') ) {                    
                        String subjHdr;
                        String emailSubject;
                        String mailbody;
                        String accountName;
                        List < Id > lstUsrIDs = new List < Id >();
                        mailAddrs = new LIST<string>(); 
                        system.debug('grpmemberid is ' + grpmemberid);
                        system.debug('mpUserEmail is ' + mpUserEmail);
                        if ( grpmemberid.containsKey('SET COMPTROLLER CHANGES') ) {
                            for ( Id usrrecId : grpmemberid.get('SET COMPTROLLER CHANGES') ) {
                                 if ( mpUserEmail.containsKey(usrrecId) )  {
                                    mailAddrs.add(mpUserEmail.get(usrrecId));
                                 }
                            }
                            system.debug('mailAddrs are ' + mailAddrs);
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            system.debug('Mail sent to:'+mailAddrs);
                            mail.setToAddresses(mailAddrs);
                            mail.setCCAddresses(new string[] {taskrec.createdbyid});
                            if ( mprecName.containskey( Taskrec.whatid) ) {
                                accountName = mprecName.get(Taskrec.whatid);
                            }
                            else {
                               accountName = '';
                            }
                            //mail.setSubject( Taskrec.Activity_Type__c + ' : ' + accountName + ' Task Information');  
                            //mail.setPlainTextBody('A new Contact Report has been completed ' + '\n' + fullFileURL + '/' + taskrec.Id);          
                            
                            mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,fullFileURL + '/' + taskrec.Id);
                            mailbody=mailbody.replace('##TaskType##','Dealership Role Comptroller Changes');
                            mail.setPlainTextBody(mailbody);
                            subjHdr = 'Dealership Role Comptroller Changes : ' + accountName;  
                            emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,subjHdr);
                            mail.setSubject(emailSubject + ' - ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mail===='+mail);
                            allemail.add(mail);    
                        }                       
                    }
                    if ( Taskrec.Activity_Type_Sub_Category__c.contains('Dealer Principal') ) {         
                        String subjHdr;
                        String emailSubject;
                        String mailbody;
                        String accountName;
                        List < Id > lstUsrIDs = new List < Id >();
                        mailAddrs = new LIST<string>(); 
                        system.debug('grpmemberid is ' + grpmemberid);
                        system.debug('mpUserEmail is ' + mpUserEmail);
                        if ( grpmemberid.containsKey('SET DEALERSHIP ROLE CHANGES') ) {
                            for ( Id usrrecId : grpmemberid.get('SET DEALERSHIP ROLE CHANGES') ) {
                                 if ( mpUserEmail.containsKey(usrrecId) )  {
                                    mailAddrs.add(mpUserEmail.get(usrrecId));
                                 }
                            }
                            system.debug('mailAddrs are ' + mailAddrs);
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            system.debug('Mail sent to:'+mailAddrs);
                            mail.setToAddresses(mailAddrs);
                            mail.setCCAddresses(new string[] {taskrec.createdbyid});
                            if ( mprecName.containskey( Taskrec.whatid) ) {
                                accountName = mprecName.get(Taskrec.whatid);
                            }
                            else {
                               accountName = '';
                            }
                            //mail.setSubject( Taskrec.Activity_Type__c + ' : ' + accountName + ' Task Information');  
                            //mail.setPlainTextBody('A new Contact Report has been completed ' + '\n' + fullFileURL + '/' + taskrec.Id);          
                            
                            mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,fullFileURL + '/' + taskrec.Id);                   
                            system.debug('Inside if 2 - Sub Category = ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mailbody = '+mailbody);
                            mailbody = mailbody.replace('##TaskType##','Dealership Role Dealer Principal Changes');
                            system.debug('mailbody ===='+mailbody);
                            mail.setPlainTextBody(mailbody);
                            subjHdr = 'Dealership Role Dealer Principal Changes : ' + accountName;
                            emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,subjHdr);
                            mail.setSubject(emailSubject + ' - ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mail===='+mail);
                            allemail.add(mail);  
                        }           
                    }                   
                    if ( taskrec.Activity_Type_Sub_Category__c.contains('General Manager')) {          
                        String subjHdr;
                        String emailSubject;
                        String mailbody;
                        String accountName;
                        List < Id > lstUsrIDs = new List < Id >();
                        mailAddrs = new LIST<string>(); 
                        system.debug('grpmemberid is ' + grpmemberid);
                        system.debug('mpUserEmail is ' + mpUserEmail);
                        if ( grpmemberid.containsKey('SET DEALERSHIP ROLE CHANGES') ) {
                            for ( Id usrrecId : grpmemberid.get('SET DEALERSHIP ROLE CHANGES') ) {
                                 if ( mpUserEmail.containsKey(usrrecId) )  {
                                    mailAddrs.add(mpUserEmail.get(usrrecId));
                                 }
                            }
                            system.debug('mailAddrs are ' + mailAddrs);
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            system.debug('Mail sent to:'+mailAddrs);
                            mail.setToAddresses(mailAddrs);
                            mail.setCCAddresses(new string[] {taskrec.createdbyid});
                            if ( mprecName.containskey( Taskrec.whatid) ) {
                                accountName = mprecName.get(Taskrec.whatid);
                            }
                            else {
                               accountName = '';
                            }
                            //mail.setSubject( Taskrec.Activity_Type__c + ' : ' + accountName + ' Task Information');  
                            //mail.setPlainTextBody('A new Contact Report has been completed ' + '\n' + fullFileURL + '/' + taskrec.Id);   
                            mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,fullFileURL + '/' + taskrec.Id);                       
                            system.debug('Inside if 3 - Sub Category = ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mailbody = '+mailbody);
                            mailbody=mailbody.replace('##TaskType##','Dealership Role General Manager Changes');
                            mail.setPlainTextBody(mailbody);
                            subjHdr='Dealership Role General Manager Changes : ' + accountName;
                            emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,subjHdr);
                            mail.setSubject(emailSubject + ' - ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mail===='+mail);
                            allemail.add(mail); 
                        }   
                    }                   
                    if ( Taskrec.Activity_Type_Sub_Category__c.contains('Operational Manager')) {      
                        String subjHdr;
                        String emailSubject;
                        String mailbody;
                        String accountName;
                        List < Id > lstUsrIDs = new List < Id >();
                        mailAddrs = new LIST<string>(); 
                        system.debug('grpmemberid is ' + grpmemberid);
                        system.debug('mpUserEmail is ' + mpUserEmail);
                        if ( grpmemberid.containsKey('SET DEALERSHIP ROLE CHANGES') ) {
                            for ( Id usrrecId : grpmemberid.get('SET DEALERSHIP ROLE CHANGES') ) {
                                 if ( mpUserEmail.containsKey(usrrecId) )  {
                                    mailAddrs.add(mpUserEmail.get(usrrecId));
                                 }
                            }
                            system.debug('mailAddrs are ' + mailAddrs);
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            system.debug('Mail sent to:'+mailAddrs);
                            mail.setToAddresses(mailAddrs);
                            mail.setCCAddresses(new string[] {taskrec.createdbyid});
                            if ( mprecName.containskey( Taskrec.whatid) ) {
                                accountName = mprecName.get(Taskrec.whatid);
                            }
                            else {
                               accountName = '';
                            }
                            system.debug('Inside if 4');
                            mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,fullFileURL + '/' + taskrec.Id);
                            system.debug('mailbody = '+mailbody);
                            system.debug('Inside if 4 - Sub Category = ' + taskrec.Activity_Type_Sub_Category__c);
                            mailbody=mailbody.replace('##TaskType##','Dealership Role Operational Manager Changes');
                            mail.setPlainTextBody(mailbody);
                            subjHdr='Dealership Role Operational Manager Changes : ' + accountName;
                            emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,subjHdr);
                            mail.setSubject(emailSubject + ' - ' + taskrec.Activity_Type_Sub_Category__c);
                            system.debug('mail===='+mail);
                            allemail.add(mail); 
                        }                       
                    }       
                } else {
                    String grpName = mpTskGrp.get(Taskrec);
                    system.debug('grpName is ' + grpName);
                    List < Id > lstUsrIDs = new List < Id >();
                    mailAddrs = new LIST<string>(); 
                    system.debug('grpmemberid is ' + grpmemberid);
                    system.debug('mpUserEmail is ' + mpUserEmail);
                    if ( grpmemberid.containsKey(grpName) ) {
                        for ( Id usrrecId : grpmemberid.get(grpName) ) {
                             if ( mpUserEmail.containsKey(usrrecId) )  {
                                mailAddrs.add(mpUserEmail.get(usrrecId));
                             }
                        }
                        system.debug('mailAddrs are ' + mailAddrs);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        system.debug('Mail sent to:'+mailAddrs);
                        mail.setToAddresses(mailAddrs);
                        mail.setCCAddresses(new string[] {taskrec.createdbyid});
                        String accountName = '';
                        if ( mprecName.containskey( Taskrec.whatid) ) {
                            accountName = mprecName.get(Taskrec.whatid);
                        }
                        else {
                           accountName = '';
                        }
                        //mail.setSubject( Taskrec.Activity_Type__c + ' : ' + accountName + ' Task Information');  
                        //mail.setPlainTextBody('A new Contact Report has been completed ' + '\n' + fullFileURL + '/' + taskrec.Id);          
                        
                        String mailbody=EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c,fullFileURL + '/' + taskrec.Id);
                        if ( Taskrec.Activity_Type__c !=null) {
                           mailbody=mailbody.replace('##TaskType##',taskrec.Activity_Type__c);
                        }
                        mail.setPlainTextBody(mailbody);
                        String subjHdr;
                        if ( Taskrec.Activity_Type__c!=null && taskrec.Activity_Type__c!='' ) {
                            subjHdr=taskrec.Activity_Type__c+' : ' + accountName;       
                        }
                        else {
                            subjHdr=accountName;
                        }                
                        String emailSubject=EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c,subjHdr);
                        mail.setSubject(emailSubject);
                        system.debug('mail===='+mail);
                        allemail.add(mail);  
                    }   
                }                 
            }   
        }  
        return allemail;
    }
    
    /*
    public static Schema.SObjectType getSobjectTypeByPrefix( String SObjectPrefix ) {
        for ( Schema.SObjectType ot : Schema.getGlobalDescribe().values() ) {
            String keyPrefix = (String)ot.getDescribe().getKeyPrefix();
            if ( keyPrefix != null && keyPrefix.equals( SObjectPrefix ) ) {
                return ot;
            }
        }
        return null;
    }
    */
    /*
        Modified by Magulan Duraipandian List<Task> lstTaskInfo = [ SELECT Id, (SELECT Id FROM Attachments) FROM Task WHERE Id IN :newMap.keySet() AND JMA_Business_Unit__c != null ];    
        Date: 7/29/2016 
    */
    /*public static void handleAddAttachment(Map < Id, Task> newMap) {
        IsExecuted = true;
 
        List<Task> lstTask = new List<Task>();
            
        //List<Task> lstTaskInfo = [ SELECT Id, (SELECT Id FROM Attachments) FROM Task WHERE Id IN :newMap.keySet() AND JMA_Business_Unit__c != null ];
        List<Task> lstTaskInfo = [ SELECT Id, (SELECT Id FROM Attachments) FROM Task WHERE Id IN :newMap.keySet()];
        
        for ( Task task :lstTaskInfo) {
            system.debug('task.Attachments ===='+task.Attachments.size());
            Task newTask = new Task(Id = task.Id);
            
            if ( Task.Attachments.size() > 0)
                newTask.Is_Attachment_Present__c = 'Yes';
            else
                newTask.Is_Attachment_Present__c = 'No';
                
            lstTask.add(newTask);
        }
        
        if (!lstTask.isEmpty())
            update lstTask;
    }*/
    
    public static void populateAreaDist(LIST<Task> taskList, Map < Id, Task > oldMap) {
        Map < Id, Account > acctDistMap=new Map < Id,Account> ();
        //Map < Id,User> userDistMap=new Map < Id,User> ();
        List < Id > accountIDList=new List < Id >();
        //List < Id > userIDList=new List < Id >();
        String dealerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        
        for ( Task newTask : taskList ) {
            //validate for SET
            if ( dealerRecordTypeId==newTask.RecordTypeID ) {
                if ( newTask.whatID != null && string.valueof(newTask.WhatID).startswith('001') ) {
                    if ( oldMap == null )
                        accountIDList.add(newTask.whatID);
                    else {
                        if ( newTask.whatId != oldMap.get(newTask.Id).WhatId )
                            accountIDList.add(newTask.whatID);
                    }
                        
                }
                //userIDList.add(newTask.ownerID);    
            }
        }
        
        if ( accountIDList.size() > 0 ) {
            for ( Account actDist: [ SELECT District__c,ID,Area__c FROM Account WHERE ID IN: accountIDList ] ) 
                acctDistMap.put(actDist.ID,actDist);
                
             
             /*for (User usrRec:[SELECT SET_Area__c,SET_District__c,ID FROM User WHERE ID in :userIDList]) {
                userDistMap.put(usrRec.ID,usrRec);
             }*/
                
                
            for ( Task newTask:taskList) {
                if (dealerRecordTypeId==newTask.RecordTypeID) {
                    /*if (userDistMap.get(newTask.ownerID).SET_Area__c!=null && userDistMap.get(newTask.ownerID).SET_Area__c!='' ) {
                        newTask.SET_SORT_AREA__c=userDistMap.get(newTask.ownerID).SET_Area__c;
                    }
                    else {*/
                    if (newTask.whatID!=null && string.valueof(newTask.whatID).startswith('001') && acctDistMap.containsKey(newTask.whatID) ) {
                        newTask.SET_SORT_AREA__c= acctDistMap.get(newTask.whatID).Area__c;
                    }
                    //}
                    
                    /*if (userDistMap.get(newTask.ownerID).SET_District__c!=null) {
                        newTask.SET_SORT_DISTRICT__c= decimal.valueof(userDistMap.get(newTask.ownerID).SET_District__c);
                    }
                    else {*/
                    if (newTask.whatID!=null && string.valueof(newTask.whatID).startswith('001') && acctDistMap.containsKey(newTask.whatID) &&
                        acctDistMap.get(newTask.whatID).District__c != null ) {
                        newTask.SET_SORT_DISTRICT__c = decimal.valueof(acctDistMap.get(newTask.whatID).District__c);
                    }
                    //} 
                } 
            }
        }
        
    }
    
    /*******************************************************************************************
    
    Intital Creation History
    Created By: Rakshik Bhan
    Created On: 04/29/2015
    Purpose: This is the method that sends email when a task with activity type "DFOM ME Recap" is completed. 
    The reason for creating this separate method is that all the rest of the activity types the Area is fetched FROM the associated account 
    but DFOM ME Recap doesn't have an associated account so the Area has to be fetched FROM the user details.
    
    Process: This is invoked FROM Task Trigger after insert/update.
    ********************************************************************************/    
    
    public static void sendReCapEmail(List<Task> lstNewTask) {
        isExecuted = true;
        
        List<Task> lstTask = new List<Task>();
        
        for ( Task t1 :lstNewTask) {
            if ( T1.Activity_Type__c == 'DFOM ME Recap') {
                lstTask.add( T1);
            }
        }
        
        if (!lstTask.isEmpty())
        {
            Send_Email_Info__c cmpcontEmail = Send_Email_Info__c.getInstance('Send Completion Email');
            
            EmailTemplate EmailToUse = [SELECT Subject,DeveloperName,Body FROM EmailTemplate e WHERE DeveloperName =:cmpcontEmail.Email_template_to_use__c];
            
            Set<String> setGroup = new Set<String>();
            for ( Task t1 :lstTask)
            {
                string groupName = 'SET '+t1.Activity_Type__c.toupperCase()+' - '+t1.SET_Area__c;
                setGroup.add(groupName);
            }
            
            List<Groupmember> lstGroupMember = [SELECT userOrGroupId, group.name FROM groupMember WHERE group.Name In :setGroup];
            system.debug('lstGroupMember===='+lstGroupMember);
            system.debug('setGroup===='+setGroup);
            Set<String> setUserId = new Set<String>();
            if (!lstGroupMember.isEmpty())
            {
                for (GroupMember groupMember :lstGroupMember)
                {
                    setUserId.add(groupMember.userOrGroupId);
                }
            }
            List<String> lstUserEmail = new List<String>();
            system.debug('setUserId===='+setUserId);
            
            if (!setUserId.isEmpty() ) {
                List<User> lstUser = [SELECT id, email FROM user WHERE id IN :setUserId];
                for (User user :lstUser ) 
                    lstUserEmail.add(user.Email);
            }
            
            system.debug('lstUserEmail===='+lstUserEmail);
            
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();   
            List < Messaging.SingleEmailMessage> lstEmail = new List <Messaging.SingleEmailMessage >();
            
            for ( Task taskrec :lstTask ) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(lstUserEmail);
                mail.setCCAddresses(new string[] {taskrec.createdbyid});
                string mailbody = EmailToUse.Body.replace(cmpcontEmail.replace_field_in_template__c, fullFileURL + '/' + taskrec.Id);
                
                mailbody = mailbody.replace('##TaskType##' ,taskrec.Activity_Type__c);
                mail.setPlainTextBody(mailbody);
                
                string subjHdr;
                subjHdr = taskrec.Activity_Type__c+' : ';
                string emailSubject = EmailToUse.Subject.replace(cmpcontEmail.replace_field_in_template__c, subjHdr);
                mail.setSubject(emailSubject);
                lstEmail.add(mail);
            }
            
            if ( lstEmail.size() > 0 ) {
                system.debug('lstEmail===='+lstEmail);
                Messaging.sendEmail(lstEmail, false);
            }
        }
    }    
    
    /*
        Created By   : Magulan Duraipandian
        Created Date : 05/25/2017
        Purpose      : To validate TXM Consultant and TXM DFOM tasks
    */ 
    public static void validateTXMTasks(List < Task > newTasks, Map < Id, Task > oldMap) {
        Set < String > setProfiles = new Set < String >();
        setProfiles.addAll(System.Label.SET_Profiles_Allowed_for_editing_TXM.split(';'));
        for ( Task tsk : newTasks ) {
            if ( !setProfiles.contains(SET_TaskTriggerHandler.profileName) && ( oldMap.get(Tsk.Id).Subject == 'TXM Consultant Task' || oldMap.get(Tsk.Id).Subject == 'TXM DFOM Task' ) ) {
                if ( tsk.Subject != oldMap.get(Tsk.Id).Subject ) 
                    tsk.Subject.addError('Subject cannot be updated for this activity. Only System Administrator can update it. Previous Subject value was ' + oldMap.get(Tsk.Id).Subject + '. Please add the original value to proceed.');
                else if ( tsk.ActivityDate != oldMap.get(Tsk.Id).ActivityDate )
                    tsk.ActivityDate.addError('Date cannot be updated for this activity. Only System Administrator can update it. Previous Due Date value was '  + oldMap.get(Tsk.Id).ActivityDate.format() + '. Please add the original value to proceed. ');
            }
        }
    }
    
    /*
        Created By   : Magulan Duraipandian
        Created Date : 05/25/2017
        Purpose      : To create recurrence tasks for TXM Consultant and TXM DFOM tasks
    */ 
    public static void createRecurrenceTasks(List < Task > newTasks, Map < Id, Task > oldMap) {
        List < Task > newInsertTasks = new List < Task >();
        for ( Task tsk : newTasks ) {
            if ( tsk.Status == 'Completed' && tsk.Status != oldMap.get(Tsk.Id).Status ) {
                if ( tsk.Subject == 'TXM Consultant Task' ) {
                    Task newTsk = tsk.clone();
                    newTsk.Status = 'Not Started';
                    newTsk.ActivityDate = system.today().addMonths(6);
                    newTsk.Description = '';
                    newInsertTasks.add(newTsk);                                        
                } 
            }
        }
        if ( newInsertTasks.size() > 0 )
            insert newInsertTasks;
    }
    
}