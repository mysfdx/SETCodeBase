/* Created By:  Neha Agrawal
Created Date:  2020-10-13
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-09
Description: To prevent community users from deleting files on Incentive Challenge cases  
*/

trigger ContentDocumentTrigger on ContentDocument (before delete) {
    
    if ( bypassExecution_Content__c.getInstance().TR_JMA_ContentDocumentTrigger__c ) 
        return;
    System.debug('Content Document TRIGGER DEBUG' + ': update-' + Trigger.isUpdate + ': insert-' + Trigger.isInsert + ': delete-' + Trigger.isDelete);
    string strObjPrefix;
    boolean isItCase=false;
    set<Id> taskIds=new Set<Id>();
    Map<Id,List<ContentDocumentLink>> taskFilesToDelete=new Map<Id,List<ContentDocumentLink>>();
    if(Trigger.isBefore && Trigger.isDelete){
        
        list<ContentDocumentLink> clinks = [select Id, LinkedEntityId, ContentDocumentId,LinkedEntity.type from 
                                            ContentDocumentLink where ContentDocumentId IN :Trigger.oldMap.keySet()];
        system.debug('Clinks '+ clinks.size());
        for(ContentDocumentLink cl : clinks){
            strObjPrefix = String.valueOf(cl.LinkedEntityId).substring(0, 3);
            system.debug('cl.LinkedEntity.type '+cl.LinkedEntity.type+' linked entity id is '+ cl.LinkedEntityId);
            if(cl.LinkedEntity.type=='Task' || strObjPrefix == Task.sObjectType.getDescribe().getKeyPrefix()) 
            {
                if(!taskFilesToDelete.containsKey(cl.LinkedEntityId)){
                    taskFilesToDelete.put(cl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                taskFilesToDelete.get(cl.LinkedEntityId).add(cl);
            }
                                       
            if(cl.LinkedEntity.type=='Case'){
                isItCase=true;
            }
        }
        if(isItCase){
            ContentDocumentTriggerHandler fileDel=new ContentDocumentTriggerHandler(Trigger.oldMap);
        fileDel.PreventDelete();
        }
        if(!taskFilesToDelete.isEmpty()){
            TaskContentDocHandler taskmap=new TaskContentDocHandler(taskFilesToDelete);
            taskmap.taskFileDeletion();
        }
        
    }
}