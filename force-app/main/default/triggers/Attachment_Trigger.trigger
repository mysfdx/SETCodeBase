/* Created By:  Magulan Duraipandian
Created Date:  2017-05-04
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

trigger Attachment_Trigger on Attachment (after delete) {
    
    if(trigger.isAfter) {       
        SET_AttachmentTriggerHandler newSET_AttachmentTriggerHandler = new SET_AttachmentTriggerHandler();
        
        if ( Trigger.isDelete ) {
            newSET_AttachmentTriggerHandler.onAfterDelete(Trigger.oldMap);
        }  
    }
    
}