@isTest
class SET_TXMTaskScheduledBatchable_Test {

    static testMethod void testTXMTaskScheduledBatchable() {
        SET_DFOM_Email__c SET_DFOM_Email = new SET_DFOM_Email__c();
        SET_DFOM_Email.Name = 'DFOM Email';
        SET_DFOM_Email.Email_Recipient__c = 'Test@jm.com';
        insert SET_DFOM_Email;
        
        EmailTemplate template = [Select DeveloperName from EmailTemplate Limit 1];
        
        Send_Email_Info__c cmpcontEmail = new Send_Email_Info__c();
        cmpcontEmail.Name = 'Competitive Contact Email Information';
        cmpcontEmail.Email_template_to_use__c = template.DeveloperName;
        insert cmpcontEmail;

        Account acct = TestClientUtils.createAccount();
        acct.SET_Consultant__c = UserInfo.getUserId();
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        insert acct;
        
        Task taskOne = new Task();
        taskOne.Subject = 'TXM Call';
        taskOne.Description = 'Test Description for task';
        taskOne.SET_Date_of_Visit__c = Date.Today() - 7;
        taskOne.Activity_Type__c = 'TXM';
        taskOne.Status = 'In Progress';
        taskOne.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        taskOne.Priority = 'Normal';
        taskOne.WhatId = acct.Id;
        taskOne.SET_TXM_1st_Child_Task__c = true;
        taskOne.OwnerId = UserInfo.getUserId();
        insert taskOne;
        
        string strSchTime = '0 58 * * * ?';
        String jobId = System.schedule('testScheduledApex', strSchTime, new SET_TXMTaskScheduledBatchable());
    }
    
}