/* Created By:  Magulan Duraipandian
Created Date:  2017-07-06
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-06-23
Description:   
*/

trigger SET_CaseTrigger on Case (before insert, after insert, before update, after update) {

    if ( bypassExecution_Case__c.getInstance().TR_JMA_CaseTrigger__c ) 
        return;
        
    List<Profile> lstProfile = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
    System.debug('lstProfile  ==== '+lstProfile );
    
    if (lstProfile.size() > 0){
    System.debug('lstProfile[0].Name  ==== '+lstProfile[0].Name );
        if ( lstProfile[0].Name == 'JMSC - Dealer Services' || lstProfile[0].Name == 'System Administrator' ) {
            if (trigger.isBefore) {
                if (trigger.isUpdate) 
                    DS_CaseTriggerHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap);
            }
            else if ( trigger.isAfter ) {
                if ( trigger.isInsert ) 
                    DS_CaseTriggerHandler.onAfterInsert(trigger.new);
                else if (trigger.isUpdate) 
                    DS_CaseTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
            }   
        }     
/* Modified By: Chandra Marthala
   Reason : Added Logic for SET - Parts Technical Profile to create Knowledge task without any cust emails etc 
*/    
       else if  (lstProfile[0].Name ==  'SET- Parts Technical' || lstProfile[0].Name == 'System Administrator') {
           if (trigger.isAfter ) {
             if (trigger.isUpdate)
                    SET_Parts_CaseTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
            }
        }
         else {
            if ( trigger.isBefore ) {
                if ( trigger.isInsert ) 
                    SET_CaseTriggerHandler.onBeforeInsert(trigger.new);
                else if ( trigger.isUpdate )
                    SET_CaseTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);            
            }
        }
     }
        
}