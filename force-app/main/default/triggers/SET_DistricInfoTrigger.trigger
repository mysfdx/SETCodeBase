/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger SET_DistricInfoTrigger on SET_DISTRICT_INFO__c (after update) {
    SET_DistricInfoTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
}