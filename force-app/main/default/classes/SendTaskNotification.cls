/*Name:SendTaskNotification
Purpose: Apex Controller for Send Task Notification VF component used to send to Task email at creation and completion
VF template helped to fetch task related to object name and record name
Author:Neha Agrawal
Date:3/16/2021

Change Log
Date - Changed by - Change Description
4/16/2021 - Neha Agrawal - Checking if Task what id is null or not.
*/


public class SendTaskNotification {
    public ID taskId {get; set;}
    Public String TaskRecordName;

    
    //used to fetch task related to Object name
    public string getObjectName() {
        if (String.isBlank(this.taskId)) 
            return null;
        else
        {
            Task t=[Select Subject,WhoId,WhatId,Who.FirstName,Who.Name,Who.type,What.type,what.name From task 
                    where id =: taskId limit 1];
            if(t.whatId<>Null){
            TaskRecordName=t.what.name;
            String ObjectAPIName=t.what.type;
            
            String ObjectLabel=ObjectAPIName.replace('__c','').replace('_', ' ');
            if(t.what.type=='Account'){
                ObjectLabel='Account/Dealer';
            }
           
            return ObjectLabel;
            }
            else
                return null;
            
        }
        
    }
    
    //used to fetch task related to record name
    public string getRecordName() {
        if (String.isBlank(this.taskId)) 
            return null;
        else
        {
         return TaskRecordName;
        }
        
    }
 
}