public class SET_createConsultant_Task {
    
    public static string ProcessTask {get;set;}
    public blob file {get; set;}
    public ContentVersion cv {get;set;}
    public List<ContentVersion> filelist {get; set;}
    Public String title {get;set;}
    Public String Type {get;set;}
    Public String fN {get;set;}

    public static void createAutoTask(LIST<Task> lstTasks) {
        LIST<ID> acctIDs = new LIST<ID>();
        ProcessTask='Process';
        MAP<ID,Account> mpAcctConsultant=new MAP<ID,Account>();
    
        for (Task tskRec:lstTasks) {
            system.debug('tskRec.ID:'+tskRec.ID);
            if(tskRec.Activity_Type__c=='TXM' && tskRec.SET_Parent_Task_ID__c==null  && tskRec.whatID!=null && string.valueof(tskRec.whatID).startswith('001')){
                 acctIDs.add(tskRec.whatID);
            }
        }
    
        for (Account acctRec : [ SELECT Name, SET_Consultant__c,ID,SET_Consultant__r.Name FROM Account WHERE Id IN :acctIDs ] ) {
            mpAcctConsultant.put(acctRec.ID,acctRec);
        }
       
        LIST<Task> newTasksList=new LIST<Task>();
        
        for (Task tskRec:lstTasks) {
            if ( tskRec.Activity_Type__c=='TXM' && tskRec.whatID!=null && string.valueof(tskRec.whatID).startswith('001')) {             
                 if(mpAcctConsultant.containsKey(tskRec.whatID)){
                    Task tskCreate = new Task(whatID=tskRec.whatID,JMA_Business_Unit__c='SET', OwnerID = mpAcctConsultant.get(tskRec.whatID).SET_Consultant__c,
                                                Subject = 'TXM Consultant Task',Priority='Normal', ActivityDate = System.today().addMonths(6),
                                                SET_Parent_Task_ID__c=tskRec.ID,Status='Not Started',Activity_Type__c='TXM',SET_TXM_Type__c='Consultant',
                                                Description = tskRec.Description, SET_TXM_1st_Child_Task__c= true, RecordTypeId = tskRec.RecordTypeId);
                                                 
                    newTasksList.add(tskCreate);                
                 }     
            }
        }
        if ( newTasksList.size() > 0 ) {   
            insert newTasksList;            
            //Modified by Rakshik on 8th January 2016 for 1st Child Task
            EmailTemplate template = [Select id, body,Subject from EmailTemplate where DeveloperName = 'SET_TXM_Consultant_Review_Template'];
            system.debug('==template '+template);
            
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            string emailBody=template.body;
            emailBody=emailBody.replace('#TaskID#',URL.getSalesforceBaseUrl().toExternalForm()+'/'+newTasksList[0].Id);
            emailBody=emailBody.replace('#TaskOwner#',mpAcctConsultant.get(newTasksList[0].whatID).SET_Consultant__r.Name);
            emailBody=emailBody.replace('#TaskSubject#',newTasksList[0].Subject);
            emailBody=emailBody.replace('#TaskWhat#',mpAcctConsultant.get(newTasksList[0].whatID).Name);
            emailBody=emailBody.replace('#TaskActivityDate#',string.valueof(newTasksList[0].ActivityDate));
            emailBody=emailBody.replace('#TaskPriority#',newTasksList[0].Priority);
            if (newTasksList[0].Description != null){
            emailBody=emailBody.replace('#TaskDescription#',newTasksList[0].Description);
            }
            else{
            emailBody=emailBody.replace('#TaskDescription#','');
            }
            mail.setPlainTextBody(emailBody);
            mail.setSubject(template.Subject);        
            mail.setTargetObjectId(newTasksList[0].OwnerId);
            mail.setSaveAsActivity(false);
            allmsg.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg);
            system.debug('results =='+results);
        }
    }
    //Email Reminders
    public static void sendTaskPendingReminder(LIST<Task> lstTasks, MAP<ID,task> mpOldTasks) {
        MAP<ID,Account> mpAcctConsultant = new MAP<ID,Account>();
        Map < String, EmailTemplate > mapEmailTemplate = new Map < String, EmailTemplate >();
        LIST<ID> acctIDs = new LIST<ID>();
        system.debug('sendTaskPendingReminder');
        for(Task tskRec :lstTasks) {
            if ( tskRec.Activity_Type__c == 'TXM' )
                acctIDs.add(tskRec.whatID);
        }
        
        if ( acctIDs.size() > 0 ) { 
            for (Account acctRec : [ SELECT Name, SET_Consultant__c,ID,SET_Consultant__r.Name,SET_DISTRICT_INFO__r.DFOM_User__r.Name,SET_DISTRICT_INFO__r.DFOM_User__c FROM Account WHERE Id IN: acctIDs ] ) 
               mpAcctConsultant.put(acctRec.ID,acctRec);
            
            for ( EmailTemplate EM : [ SELECT Id, Body, Subject, DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('SET_TXM_Consultant_Review_REMINDER_Template', 'SET_TXM_DFOM_REMINDER_Template') ] )
                mapEmailTemplate.put(EM.DeveloperName, EM);
                
            for(Task tskRec :lstTasks) {
                if ( tskRec.Activity_Type__c == 'TXM' ) {            
                    //Send the Email Reminder for the 1st Child Task after 30 days
                    if(tskRec.SET_Reminder_Notifications__c 
                    && tskRec.SET_Reminder_Notifications__c != mpOldTasks.get(tskRec.Id).SET_Reminder_Notifications__c) {
                        EmailTemplate template = mapEmailTemplate.get('SET_TXM_Consultant_Review_REMINDER_Template');
                        
                        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        string emailBody=template.body;
                        emailBody=emailBody.replace('#TaskID#',URL.getSalesforceBaseUrl().toExternalForm()+'/'+tskRec.Id);
                        emailBody=emailBody.replace('#TaskOwner#',mpAcctConsultant.get(tskRec.whatID).SET_Consultant__r.Name);
                        emailBody=emailBody.replace('#TaskSubject#',tskRec.Subject);
                        emailBody=emailBody.replace('#TaskWhat#',mpAcctConsultant.get(tskRec.whatID).Name);
                        emailBody=emailBody.replace('#TaskActivityDate#',string.valueof(tskRec.ActivityDate));
                        emailBody=emailBody.replace('#TaskPriority#',tskRec.Priority);
                        if (tskRec.Description != null){
                           emailBody=emailBody.replace('#TaskDescription#',tskRec.Description);
                        }
                        else{
                           emailBody=emailBody.replace('#TaskDescription#','');
                        }
                        mail.setPlainTextBody(emailBody);
                        mail.setSubject(template.Subject);        
                        mail.setTargetObjectId(tskRec.OwnerId);
                        mail.setSaveAsActivity(false);
                        allmsg.add(mail);
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg);
                        system.debug('sendTaskPendingReminder results =='+results);
                    }               
                    
                    //Send the Email Reminder for the 2nd Child Task after 15 days
                    else if(tskRec.SET_Reminder_Notifications2__c 
                    && tskRec.SET_Reminder_Notifications2__c != mpOldTasks.get(tskRec.Id).SET_Reminder_Notifications2__c) {
                        EmailTemplate template = mapEmailTemplate.get('SET_TXM_DFOM_REMINDER_Template');
                        
                        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        string emailBody=template.body;
                        emailBody=emailBody.replace('#TaskID#',URL.getSalesforceBaseUrl().toExternalForm()+'/'+lstTasks[0].Id);
                        emailBody=emailBody.replace('#TaskOwner#',mpAcctConsultant.get(tskRec.whatID).SET_DISTRICT_INFO__r.DFOM_User__r.Name);      
                        emailBody=emailBody.replace('#TaskSubject#',tskRec.Subject);
                        emailBody=emailBody.replace('#TaskWhat#',mpAcctConsultant.get(tskRec.whatID).Name);
                        emailBody=emailBody.replace('#TaskActivityDate#',string.valueof(tskRec.ActivityDate));
                        emailBody=emailBody.replace('#TaskPriority#',tskRec.Priority);
                        if (tskRec.Description != null){
                        emailBody=emailBody.replace('#TaskDescription#',tskRec.Description);
                        }
                        else{
                        emailBody=emailBody.replace('#TaskDescription#','');
                        }                               
                        mail.setPlainTextBody(emailBody);
                        mail.setSubject(template.Subject);          
                        mail.setTargetObjectId(tskRec.OwnerId);
                        mail.setSaveAsActivity(false);
                        allmsg.add(mail);
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg);
                        system.debug('sendTaskPendingReminder results == ' + results);
                    }
                }
            }
        }
    }

    public static void createDFOMTask(LIST<Task> lstTasks, MAP<ID,task> mpOldTasks) {  
        ProcessTask='Process';
        LIST<ID> acctIDs=new LIST<ID>();
        MAP<string,SET_DISTRICT_INFO__c> mpAcctConsultant=new MAP<string,SET_DISTRICT_INFO__c>();
    
        for (Task tskRec:lstTasks) {
            if(tskRec.Activity_Type__c=='TXM' && tskRec.SET_TXM_Type__c=='Consultant' && tskRec.Status=='Completed' && mpOldTasks.get(tskRec.ID).Status!='Completed' && tskRec.SET_Parent_Task_ID__c!=null  && mpOldTasks.containsKey(tskRec.ID) && tskRec.whatID!=null && string.valueof(tskRec.whatID).startswith('001') )    
                acctIDs.add(tskRec.whatID);
        }
        if ( acctIDs.size() > 0 ) {
            MAP<ID,Account> distMap=new MAP<ID,Account>();
            LIST<string> lstDistNames=new LIST<string>();
            for (Account acctRec:[Select DFOM__c, SET_DISTRICT_INFO__c,ID,SET_DISTRICT_INFO__r.Name,Name from Account where id in :acctIDs]) {
                distMap.put(acctRec.ID,acctRec);  
                lstDistNames.add(acctRec.SET_DISTRICT_INFO__r.Name);
            }
            
            for (SET_DISTRICT_INFO__c distDFOM:[Select Name,DFOM_User__c, DFOM_User__r.Name from SET_DISTRICT_INFO__c where name in :lstDistNames]){
               mpAcctConsultant.put(distDFOM.Name, distDFOM);  
            }
             
            LIST<Task> TasksList = new LIST<Task>();
            Set<String> setTaskId = new Set<String>();
            
             for (Task tskRec:lstTasks) {
                if(tskRec.Activity_Type__c=='TXM' && tskRec.SET_TXM_Type__c=='Consultant' && tskRec.Status=='Completed' && mpOldTasks.get(tskRec.ID).Status!='Completed' && tskRec.SET_Parent_Task_ID__c!=null  && mpOldTasks.containsKey(tskRec.ID) && tskRec.whatID!=null && string.valueof(tskRec.whatID).startswith('001')){
                     
                     if(distMap.containsKey(tskRec.whatID)) {
                         string distName=distMap.get(tskRec.whatID).SET_DISTRICT_INFO__r.Name;
                         if(mpAcctConsultant.containsKey(distName)) {                      
                             Task tskCreate=new Task(whatID=tskRec.whatID,JMA_Business_Unit__c='SET',ownerID=mpAcctConsultant.get(distName).DFOM_User__c,
                                                        subject='TXM DFOM Task',Priority='Normal',ActivityDate = system.today().adddays(30),
                                                        SET_Parent_Task_ID__c=tskRec.SET_Parent_Task_ID__c,Status='Not Started',Activity_Type__c='TXM',SET_TXM_Type__c='DFOM',
                                                        Description=tskRec.Description, RecordTypeId = tskRec.RecordTypeId, Is_Attachment_Present__c=tskRec.Is_Attachment_Present__c);
                            
                            setTaskId.add(tskRec.Id);                                                    
                            TasksList.add(tskCreate);
                        } 
                    }
                }
            }
            
            List<ContentVersion> filelist;
            
            if ( !setTaskId.isEmpty() ) {
                filelist = [ SELECT Id, FirstPublishLocationId, Title, pathOnClient FROM ContentVersion WHERE FirstPublishLocationId IN :setTaskId];        
            }    
            
            if ( TasksList.size() > 0 ) {
                insert TasksList;
                
                List<ContentVersion> lstCVToCreate = new List<ContentVersion>();
                    
                if ( !filelist.isEmpty() ) {
                    for(ContentVersion cv : filelist) {
                        ContentVersion cv1 = new ContentVersion();
                        
                         cv1.versionData = cv.versiondata;
        				 cv1.title = cv.title;
        				 cv1.FirstPublishLocationId = TasksList[0].Id;
        				 cv1.pathOnClient = cv.pathOnClient;
                         cv1.OwnerId = TasksList[0].OwnerId;
                        lstCVToCreate.add(cv1);
                    }
                }
                
                insert lstCVToCreate;
                SET_TaskTriggerHandler.IsExecuted = false;
                update TasksList;
            
                //Modified by Rakshik on 8th January 2016 for 2nd Child Task
                EmailTemplate template = [ SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'SET_TXM_DFOM_Template' ];
                system.debug('==template '+template);
                string distName=distMap.get(TasksList[0].whatID).SET_DISTRICT_INFO__r.Name;
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                string emailBody=template.body;
                emailBody=emailBody.replace('#TaskID#',URL.getSalesforceBaseUrl().toExternalForm()+'/'+TasksList[0].Id);
                emailBody=emailBody.replace('#TaskOwner#',mpAcctConsultant.get(distName).DFOM_User__r.Name);
                emailBody=emailBody.replace('#TaskSubject#',TasksList[0].Subject);
                emailBody=emailBody.replace('#TaskWhat#',distMap.get(TasksList[0].whatID).Name);
                emailBody=emailBody.replace('#TaskActivityDate#',string.valueof(TasksList[0].ActivityDate));
                emailBody=emailBody.replace('#TaskPriority#',TasksList[0].Priority);
                if (TasksList[0].Description != null) 
                   emailBody=emailBody.replace('#TaskDescription#',TasksList[0].Description);
                else
                   emailBody = emailBody.replace('#TaskDescription#','');
                mail.setPlainTextBody(emailBody);
                mail.setSubject(template.Subject);
                mail.setTargetObjectId(mpAcctConsultant.get(distName).DFOM_User__c);
                mail.setSaveAsActivity(false);
                allmsg.add(mail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg);
                system.debug('results =='+results);
            } 
        }    
    }


    public static void closeTXMTask(LIST<Task> lstTasks, MAP<ID,task> mpOldTasks) {    
        ProcessTask = 'Process';
        List < Id > taskIDs = new List < Id >(); 
        for (Task tskRec:lstTasks) {       
            if(tskRec.Activity_Type__c=='TXM' && tskRec.SET_TXM_Type__c=='DFOM' && tskRec.Status=='Completed' && tskRec.SET_Parent_Task_ID__c!=null  && mpOldTasks.containsKey(tskRec.ID) && tskRec.whatID!=null && string.valueof(tskRec.whatID).startswith('001'))
                taskIDs.add(tskRec.SET_Parent_Task_ID__c);
        }  
        if ( taskIDs.size() > 0 ) {    
            List < Task > TasksList = new List < Task >();
            for(Task tskRec:[Select Status,ID from Task where id in :taskIDs and Status !='Completed']) {    
                tskRec.Status='Completed';
                TasksList.add(tskRec);
            }
            if( TasksList.size() > 0 )
                update TasksList;
        }
    }
    
}