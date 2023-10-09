/* Name:  SET_AttachmentTriggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class SET_AttachmentTriggerHandler
{
    /*public void onAfterInsert(Map<Id, Attachment> newMap)
    {
        handlerAddAttachment(newMap);
        
        system.debug('===='+newMap);
    }*/
    
    public void onAfterDelete(Map<Id, Attachment> oldMap)
    {
        handleRemoveAttachment(oldMap);
        
        system.debug('lstTask ===='+oldMap);
    }
    
    /*
    public void handlerAddAttachment(Map<Id, Attachment> newMap)
    {
        List<Task> lstTask = new List<Task>();
        
        for(Attachment attachment :newMap.values())
        {
            if(String.valueOf(attachment.parentId).startsWith('00T'))
            {
                Task task = new Task(Id = attachment.parentId);
                task.IsAttachmentPresent__c = true;
                lstTask.add(task);
            }
        }
        
        
        system.debug('lstTask ===='+lstTask);
        
        if(!lstTask.isEmpty())
            update lstTask;
    }
    */
    
    public void handleRemoveAttachment(Map<Id, Attachment> newMap)
    {
        SET_TaskTriggerHandler.IsExecuted = true;
        
        Set<String> setTaskId = new Set<String>();
        
        for(Attachment attachment :newMap.values())
        {
            if(String.valueOf(attachment.parentId).startsWith('00T'))
                setTaskId.add(attachment.parentId);
        }
        
        system.debug('setTaskId ===='+setTaskId);
        
        if(!setTaskId.isEmpty())
        {
            List<Task> lstTask = new List<Task>();
            
            List<Task> lstTaskInfo = [Select Id, (Select Id from Attachments) from Task where Id IN :setTaskId];
            
            for(Task task :lstTaskInfo)
            {
                system.debug('task.Attachments ===='+task.Attachments.size());
                
                if(task.Attachments.size() == 0)
                {
                    Task newTask = new Task(Id = task.Id);
                    newTask.Is_Attachment_Present__c = 'No';
                    lstTask.add(newTask);
                }
            }
            
            system.debug('lstTaskInfo ===='+lstTaskInfo);
            
            if(!lstTask.isEmpty())
                update lstTask;
        }
    }
}