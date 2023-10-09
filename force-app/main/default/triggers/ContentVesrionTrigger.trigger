/* Created By:  Neha Agrawal
Created Date:  2020-10-19
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-09
Description: To prevent community users from uploading new versions of file on Incentive Challenge cases  
*/

trigger ContentVesrionTrigger on ContentVersion (before update, before insert) {
    
    if ( bypassExecution_Content__c.getInstance().TR_JMA_ContentVersionTrigger__c ) 
        return;
    System.debug('Content Version TRIGGER DEBUG' + ': update-' + Trigger.isUpdate + 
                 ': insert-' + Trigger.isInsert + ': delete-' + Trigger.isDelete);
   // String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
   // if(ProfileName=='Dealer User Community Profile 1'){
    
    if((Trigger.isInsert || Trigger.isUpdate)&& trigger.isbefore) {
        system.debug('trigger.newmap is '+ trigger.newMap);
         system.debug('trigger.new is '+ trigger.new);
        ContentVersionTriggerHandler conver=new ContentVersionTriggerHandler(trigger.new);
        conver.OnInsertUpdateContentVersion();
        /*For(ContentVersion cv: Trigger.new){
            if(!string.isEmpty(cv.contentDocumentId)){
                cv.addError('Sorry new version can not be added');
            }
            
        }*/
    }
    //}
    
}