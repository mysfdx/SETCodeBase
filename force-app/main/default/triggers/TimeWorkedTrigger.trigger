/* Created By:  Magulan Duraipandian
Created Date:  2017-06-08
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger TimeWorkedTrigger on DS_Time_Worked__c (before update) {
    
    /*
        Bypass execution if the requisite custom setting is set
    */
    if ( ByPassExecution_TimeWorked__c.getInstance().TR_TimeWorkedTrigger__c )
        return;
    TimeWorkedTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
}