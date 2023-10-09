/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description: this is used to populate Name field from First and Last Name.  
*/

trigger SET_Competitive_Contact_trigger on Competitive_Contact__c (before insert, before update) {

    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate)){
        SET_Competitive_Contact_Trigger_Handler.populateCCName(trigger.new);
    }


}