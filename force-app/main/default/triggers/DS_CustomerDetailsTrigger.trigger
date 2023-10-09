/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger DS_CustomerDetailsTrigger on DS_Customer_Details__c (after insert) {
    /*
        Bypass execution if the requisite custom setting is set
    */
    if(bypassExecution_CustomerDetails__c.getInstance().TR_DS_CustomerDetailsTrigger__c)
        return;
    DS_CustomerDetailsTriggerHandler.onAfterInsert(trigger.new);
}