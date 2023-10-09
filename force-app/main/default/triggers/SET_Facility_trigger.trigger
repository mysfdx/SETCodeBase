/* Created By:  Magulan Duraipandian -- TKT0544571
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description: requirement 3C. Need to propagate Otehr manfucturer field value to Account object  
*/

trigger SET_Facility_trigger on Facility__c (after insert, after update) {
	
	SET_Facility_TriggerHandler FacilityTrg=new SET_Facility_TriggerHandler();
	if(trigger.isAfter){
		if(trigger.isUpdate){
			FacilityTrg.onAfterUpdate(trigger.new);
		}
		else if(trigger.isInsert){
			FacilityTrg.onAfterInsert(trigger.new);
		}
	}

}