/*
Name:ContentDocumentLinkTrigger
Purpose:To trigger the notification to case owner when file uploades on Incentive Challenge cases
Author: Neha Agrawal
Date: 10/9/2020
*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert , after update, after delete) {
   if ( bypassExecution_Content__c.getInstance().TR_JMA_ContentDocumentLinkTrigger__c ) 
        return;
   
    System.debug('ContentDocumentLinkTrigger DEBUG' + ': update-' + Trigger.isUpdate + ': insert-' + Trigger.isInsert + ': delete-' + Trigger.isDelete);
    string strObjPrefix;
    //String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
   //if(ProfileName=='Dealer User Community Profile 1'){
    Map<Id, ContentDocumentLink> ContentDocLnMap=new Map<id, ContentDocumentLink>();
    Map<Id, ContentDocumentLink> taskContentDocLnMap=new Map<id, ContentDocumentLink>();
    if (Trigger.isInsert || Trigger.isUpdate) {
        For(ContentDocumentLink clIterator: Trigger.new){
            system.debug('clIterator.LinkedEntity.type is '+ clIterator.LinkedEntity.type);
            strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == Case.sObjectType.getDescribe().getKeyPrefix()) {
                ContentDocLnMap.put(clIterator.id,clIterator);
            }
            if(strObjPrefix == Task.sObjectType.getDescribe().getKeyPrefix()) {
                taskContentDocLnMap.put(clIterator.id,clIterator);
            }
            
        }
            if(!ContentDocLnMap.isEmpty()){
                //CaseAttachmentsCountService countService = new CaseAttachmentsCountService(Trigger.newMap);
                //countService.stampAttachmentCount();
                PublishCaseCommentService caseCommentService = new PublishCaseCommentService(ContentDocLnMap);
                caseCommentService.publishCaseComments();
                
            }
        if(!taskContentDocLnMap.isEmpty()){
            TaskContentDocHandler taskmap=new TaskContentDocHandler(taskContentDocLnMap);
            taskmap.taskFileAddition();
        }
        
    } 
        else if (Trigger.isDelete) {
        For(ContentDocumentLink clIterator: Trigger.old){
            strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == Task.sObjectType.getDescribe().getKeyPrefix()) {
                taskContentDocLnMap.put(clIterator.id,clIterator);
                system.debug('Task Content document Link '+ clIterator);
            }
        }
          if(!taskContentDocLnMap.isEmpty()){
            TaskContentDocHandler taskmap=new TaskContentDocHandler(taskContentDocLnMap);
            taskmap.taskFileRemoval();
        }
        
    }
   
    
}