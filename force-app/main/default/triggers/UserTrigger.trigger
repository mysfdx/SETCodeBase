/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04

Change Log

Date - Changed by - Change Description

2021-02-01-Joshua Hunt
8th Sept 2021 -- Neha Agrawal -- Added Deactivate community user job running flag check to prevent user 
                                 trigger execution.
*/

trigger UserTrigger on User (before insert, before update) {
    system.debug('It executes');
    if(!DeactivateUsers.deactivateUserJobRunning){
        system.debug('Does not executed: becuase value is : '+ DeactivateUsers.deactivateUserJobRunning);
        
        SET_UserTrigger_Handler userAreaDistrictpopulate=new SET_UserTrigger_Handler();
        if(trigger.isBefore && trigger.isInsert){
            userAreaDistrictpopulate.onBeforeInsert(trigger.new);
        }
        
        if(trigger.isBefore && trigger.isUpdate){
            
            userAreaDistrictpopulate.onBeforeUpdate(trigger.newMap);
            
            
        }
        
    }
}