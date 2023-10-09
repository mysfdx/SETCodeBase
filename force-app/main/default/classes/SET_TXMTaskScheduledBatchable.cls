/* Name:  SET_TXMTaskScheduledBatchable
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SET_TXMTaskScheduledBatchable implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        //String query = 'Select whatID, OwnerId, Description, CreatedDate, Id From Task Where Activity_Type__c = \'TXM\' AND SET_TXM_1st_Child_Task__c = true';
        //LAST_N_DAYS:30
        String query;
        if(!Test.isRunningTest()) {
            query = 'Select whatID, OwnerId, Description, CreatedDate, Id From Task Where Activity_Type__c = \'TXM\' AND SET_Parent_Task_ID__c=null AND CreatedDate <= LAST_N_DAYS:60';
              
        }
        
        else {
            query = 'Select whatID, OwnerId, Description, CreatedDate, Id From Task Where Activity_Type__c = \'TXM\' AND SET_Parent_Task_ID__c=null AND CreatedDate <= TODAY';
        }
        SET_TXMTaskBatch taskBatch = new SET_TXMTaskBatch(query);
        database.executebatch(taskBatch);
    }
}