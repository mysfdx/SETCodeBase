/* Name:  TaskContentDocHandler
Created By:  Joshua Hunt
Created Date:  2021-02-01
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class TaskContentDocHandler {
    Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>();
    Map<Id, List<ContentDocumentLink>> taskFileMaptoDelete = new Map<Id, List<ContentDocumentLink>>();
    List<Task> taskToUpdate=new List<Task>();
    
    public TaskContentDocHandler(Map<Id, ContentDocumentLink> contentDocumentLinkMap) {
        this.contentDocumentLinkMap = contentDocumentLinkMap;
    }
    public TaskContentDocHandler(Map<Id, List<ContentDocumentLink>> taskFileMaptoDelete) {
        this.taskFileMaptoDelete = taskFileMaptoDelete;
    }
    public void taskFileAddition() {
        System.debug('Task File Addition');
        
        
        for(Task t: [SELECT Id, Is_Attachment_Present__c FROM Task WHERE Id IN :getTaskIdCollection()]){
            if(t.Is_Attachment_Present__c <>'Yes'){
                t.Is_Attachment_Present__c='Yes';
                taskToUpdate.add(t);
            }
            
        }
        if(!taskToUpdate.isEmpty())
            update taskToUpdate;
    }
    public void taskFileRemoval(){
        System.debug('Task File Removal');
        set<id> taskIdWithFiles=new Set<id>();
        List<ContentDocumentLink> taskFiles =[SELECT Id, LinkedEntityId, ContentDocumentId 
                                              FROM ContentDocumentLink WHERE LinkedEntityId IN :getTaskIdCollection()];
        if(!taskFiles.isEmpty()){
            for(ContentDocumentLink conLnk:taskFiles){
                taskIdWithFiles.add(conLnk.LinkedEntityId);
            }
            for(Task t: [SELECT Id, Is_Attachment_Present__c FROM Task WHERE Id IN :getTaskIdCollection()]){
                if(!taskIdWithFiles.contains(t.Id) && t.Is_Attachment_Present__c <>'No'){
                    t.Is_Attachment_Present__c='No';
                    taskToUpdate.add(t);
                }
            }
            if(!taskToUpdate.isEmpty())
                update taskToUpdate;
        }
        else
        {
            for(Task t: [SELECT Id, Is_Attachment_Present__c FROM Task WHERE Id IN :getTaskIdCollection()]){
                if(t.Is_Attachment_Present__c <>'No'){
                    t.Is_Attachment_Present__c='No';
                    taskToUpdate.add(t);
                }
            }
            if(!taskToUpdate.isEmpty())
                update taskToUpdate;
        }
    }
    
    public void taskFileDeletion(){
        Map<Id, List<ContentDocumentLink>> totalTaskFileMap=new Map<Id, List<ContentDocumentLink>>();
        System.debug('Task File Deletion');
        List<ContentDocumentLink> totalTaskFiles =[SELECT Id, LinkedEntityId, ContentDocumentId 
                                              FROM ContentDocumentLink WHERE 
                                              LinkedEntityId IN :taskFileMaptoDelete.keySet()];
        
        
        for(ContentDocumentLink link: totalTaskFiles){
            if(!totalTaskFileMap.containsKey(link.LinkedEntityId)){
                    totalTaskFileMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
                }
                totalTaskFileMap.get(link.LinkedEntityId).add(link);
        }
        for(Task t: [SELECT Id, Is_Attachment_Present__c FROM Task WHERE Id IN :taskFileMaptoDelete.keySet()]){
            if((totalTaskFileMap.get(t.id).size()-taskFileMaptoDelete.get(t.Id).size())==0 && 
              t.Is_Attachment_Present__c <>'No'){
                 t.Is_Attachment_Present__c='No';
                    taskToUpdate.add(t);
            }
        }
        if(!taskToUpdate.isEmpty())
                update taskToUpdate;
    }
    public Set<Id> getTaskIdCollection() {
        Set<Id> taskIds = new Set<Id>();
        for (ContentDocumentLink contentDocument : this.contentDocumentLinkMap.values()) {
            taskIds.add(contentDocument.LinkedEntityId);
        }
        return taskIds;
    }
}