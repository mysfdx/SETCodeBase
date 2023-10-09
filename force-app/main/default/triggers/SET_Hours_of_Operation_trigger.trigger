/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger SET_Hours_of_Operation_trigger on Hours_of_Operation__c (before insert, before update) {

	if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate)){
		SET_Hours_of_Operation_triggerHandler.validateHours(trigger.new);
	}

}