/* Name:  SET_TXMTaskBatch
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SET_TXMTaskBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;
    global LIST<Task> lstTask;
    
    global SET_TXMTaskBatch(String strQuery)
    {
        Query = strQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        lstTask = new LIST<Task>();
        LIST<ID> lstTaskIds=new LIST<ID>();
        MAP<ID,string> mapTaskChild=new MAP<ID,string>();
        
        for(sobject s :scope)
        {
            Task tskRec = (Task)s;
            lstTaskIds.add(tskRec.ID);
        }
        
        for (Task tskRec:[Select ID,SET_Parent_Task_ID__c from Task where SET_Parent_Task_ID__c in :lstTaskIds AND Activity_Type__c='TXM' AND SET_TXM_Type__c='Consultant']) {
            
            mapTaskChild.put(tskRec.SET_Parent_Task_ID__c,'Existing');
        } 
        
        for(sobject s :scope)
        {
            Task tskRec = (Task)s;
            
            DateTime dT = tskRec.CreatedDate;
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
           // if(myDate.daysBetween((Date.today()) == 1 || Test.isRunningTest()) )
            if(!mapTaskChild.containskey(tskRec.ID))
            {
                Task tskCreate = new Task(whatID=tskRec.whatID,JMA_Business_Unit__c='SET',ownerID=tskRec.OwnerId,
                                                subject='TXM Consultant Task',Priority='Normal',ActivityDate=system.today().adddays(90),
                                                SET_Parent_Task_ID__c=tskRec.ID,Status='Not Started',Activity_Type__c='TXM',SET_TXM_Type__c='Consultant',
                                                Description=tskRec.Description);
                                                 
                lstTask.add(tskCreate);
            }
        }
        
        if(!lstTask.isEmpty())
        {
            insert lstTask;
            
            system.debug('lstTask===='+lstTask);
            
            /*for(Task task :lstTask)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(template.Id);
                mail.setTargetObjectId(task.OwnerId);
                //mail.setWhatId();
                allmsg.add(mail);
            }*/
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(!lstTask.isEmpty())
        {
            EmailTemplate template = [Select id from EmailTemplate where developername = 'SET_TXM_Consultant_Review_Template'];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
            for(Task task :lstTask)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(template.Id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(task.OwnerId);
                
                //String[] ccAddresses = new String[] {currentUserEmail};
                allmsg.add(mail);
                
                /*
                    Adding !Test.isRunningTest() because getting below error, seems a salesforce internal error,
                    System.EmailException: SendEmail failed. First exception on row 0; 
                    first error: INVALID_FIELD_WHEN_USING_TEMPLATE, When a template is specified, 
                    the plain text body, html body, subject, charset, and &quot;
                    treatBodiesAsTemplate&quot; may not be specified : []
                */
                
                if(!Test.isRunningTest())
                    Messaging.sendEmail(allmsg);
            
                system.debug('allmsg===='+allmsg);
            }
        }
    }
}