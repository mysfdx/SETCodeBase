/* Created By:  Neha Agrawal-- ENHC0012046
Created Date:  2020-07-19
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-08-09
Description: Trigger which runs before insert and update of Apprentice record for autopopulating some fields
*/

trigger ApprenticeWithActivitySummary on Apprentice__c (before insert, before update) {
 if (trigger.isBefore) {
                if (trigger.isInsert) 
                    ApprenticeWithActivitySummaryHandler.onBeforeInsert(Trigger.new);
            }
    if (trigger.isUpdate){
        ApprenticeWithActivitySummaryHandler.onBeforeUpdate(Trigger.new);
    }
    
}