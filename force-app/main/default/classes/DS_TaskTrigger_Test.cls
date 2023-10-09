/* Name:  DS_TaskTrigger_Test
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

@isTest
private class DS_TaskTrigger_Test {

    @TestSetup
    static void setupData() {
        Send_Email_Info__c objSendEmail = new Send_Email_Info__c(Name = 'Competitive Contact Email Information', replace_field_in_template__c = '##TaskRecord##', Email_template_to_use__c='Competitive_Contact_Task_Completed');
        insert objSendEmail;
    }
    
    static testMethod void taskTriggerTest() {
        Account account = TestClientUtils.createAccount();
        insert account;
        
        LIST<Id> whatIds = new LIST<Id>();
        whatIds.add(account.Id);
        
        LIST<Task> lstTask = new LIST<Task>();
        lstTask = TestClientUtils.createTask( whatIds, 'Competitive Contacts' , 'Completed');
        for(Task task :lstTask) {
            task.DS_Time_Spent_In_Minutes__c = 10;
            task.DS_Total_Time_Spent_In_Hours__c = 2;
            task.JMA_Business_Unit__c = 'JMSC';
        }
        insert lstTask;
        
        for(Task task :lstTask) {
            task.DS_Time_Spent_In_Minutes__c = 40;
            task.DS_Total_Time_Spent_In_Hours__c = 1;
        }
        
        DS_TaskTriggerHandler.IsExecuted  = false;
        update lstTask;
    }
}