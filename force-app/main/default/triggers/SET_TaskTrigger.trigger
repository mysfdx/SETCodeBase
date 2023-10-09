/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger SET_TaskTrigger on Task (after delete, after insert, after update, before delete, before insert, before update) {
    
    /*
        Bypass execution if the requisite custom setting is set
    */
    if ( bypassExecution_Task__c.getInstance().TR_SET_TaskTrigger__c )
        return;

    /*******************************************************************************************

    Intital Creation History
    Created By: Jay B
    Created On: 1/29/2014
    Purpose: This is the general trigger on Task object. 
    Process: This trigger will invoke Underlying Apex methods based on condition.

    Modification History
    Modified By:
    Modified On:
    Purpose:

    ********************************************************************************/   
    String strProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;  
    SET_TaskTriggerHandler.profileName = strProfileName;
    if ( SET_TaskTriggerHandler.profileName == 'JMSC - Dealer Services' || SET_TaskTriggerHandler.profileName == 'JMSC - Parent Profile' ) {
        DS_TaskTriggerHandler objTaskTgr = new DS_TaskTriggerHandler();
        if (Trigger.isAfter) {   
            if ( Trigger.isUpdate ) {
                if ( !DS_TaskTriggerHandler.IsExecuted )
                    objTaskTgr.onAfterUpdate(trigger.new, trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                objTaskTgr.onAfterInsert(trigger.new);
            }
        }
    } else {
        if ( Trigger.isAfter ) {   
            if ( Trigger.isUpdate )
                SET_TaskTriggerHandler.onAfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
            else if (Trigger.isInsert) 
                SET_TaskTriggerHandler.onAfterInsert(Trigger.new, trigger.newMap);
        } else if ( Trigger.isBefore ) {
            if ( trigger.isInsert ) 
                SET_TaskTriggerHandler.onBeforeInsert(trigger.new);
            else if ( trigger.isUpdate ) 
                SET_TaskTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
        } 
    }

}