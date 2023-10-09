/* Name:  DS_TaskTriggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_TaskTriggerHandler
{
    public static boolean IsExecuted = false;
    
    public void onAfterInsert(LIST<Task> lstTask)
    {
        updateTotalTime(lstTask);
    }
    
    public void onAfterUpdate(LIST<Task> lstTask, Map<Id,Task> mpOldTask)
    {
        updateTotalTime(lstTask, mpOldTask);
    }
    
    public void updateTotalTime(LIST<Task> lstTaskRecords, Map<Id,Task> mpOldTask)
    {
        List<Task> LstTask = new List<Task>();
        
        for (Task taskObj :lstTaskRecords)
        {
            if(taskObj.JMA_Business_Unit__c == 'JMSC' && (taskObj.DS_Time_Spent_In_Minutes__c != mpOldTask.get(taskObj.Id).DS_Time_Spent_In_Minutes__c))
            {
                Task task = new Task(Id = taskObj.Id);
                Decimal timeSpent = taskObj.DS_Time_Spent_In_Minutes__c;
                
                if(taskObj.DS_Total_Time_Spent_In_Hours__c != null)
                    task.DS_Total_Time_Spent_In_Hours__c = taskObj.DS_Total_Time_Spent_In_Hours__c + (timeSpent / 60);
                else
                    task.DS_Total_Time_Spent_In_Hours__c = (timeSpent) / 60;
                task.DS_Time_Spent_In_Minutes__c = 0;
                
                LstTask.add(task);
            }
        }
        
        if(!LstTask.isEmpty())
        {
            IsExecuted = true;
            update LstTask;
        }
    }
    
    public void updateTotalTime(LIST<Task> lstTaskRecords)
    {
        List<Task> LstTask = new List<Task>();
        
        for (Task taskObj :lstTaskRecords)
        {
            if(taskObj.JMA_Business_Unit__c == 'JMSC' && taskObj.DS_Time_Spent_In_Minutes__c != null)
            {
                Decimal timeSpent = taskObj.DS_Time_Spent_In_Minutes__c;
                Task task = new Task(Id = taskObj.Id);
                if(taskObj.DS_Total_Time_Spent_In_Hours__c != null)
                    task.DS_Total_Time_Spent_In_Hours__c = taskObj.DS_Total_Time_Spent_In_Hours__c + (timeSpent / 60);
                else
                    task.DS_Total_Time_Spent_In_Hours__c = timeSpent / 60;
                
                task.DS_Time_Spent_In_Minutes__c = 0;
                LstTask.add(task);
            }
        }
        
        if(!LstTask.isEmpty())
        {
            IsExecuted = true;
            update LstTask;
        }
    }
}