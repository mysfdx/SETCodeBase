/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger CaseCommentTrigger on CaseComment (after insert) {

	if ( trigger.isAfter ) {
		DS_CaseCommentTriggerHandler.onAfterInsert(trigger.new);
	}
	
}