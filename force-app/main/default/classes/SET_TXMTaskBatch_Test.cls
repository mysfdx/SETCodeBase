@isTest
class SET_TXMTaskBatch_Test {
    static testMethod void testTXMTaskBatch() {
        SET_DFOM_Email__c SET_DFOM_Email = new SET_DFOM_Email__c();
        SET_DFOM_Email.Name = 'DFOM Email';
        SET_DFOM_Email.Email_Recipient__c = 'Test@jm.com';
        insert SET_DFOM_Email;
        
        EmailTemplate template = [Select DeveloperName from EmailTemplate Limit 1];
        
        Send_Email_Info__c cmpcontEmail = new Send_Email_Info__c();
        cmpcontEmail.Name = 'Competitive Contact Email Information';
        cmpcontEmail.Email_template_to_use__c = template.DeveloperName;
        insert cmpcontEmail;
        
        string dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();

        Account account = new Account(Name='JMA Account Test', JMA_Billing_Postal_Code__c='11111', JMA_Business_Unit__c = 'JMA',recordTypeId = 
        dealerRecordTypeId,JMA_Status__c='Prospect',JMA_Phone_Number__c='987-654-9832',JMA_Physical_Phone__c= '9090909090',
        JMA_Physical_State__c='NY',JMA_Physical_Street__c='Street1',JMA_Physical_Street_2__c='Street2',JMA_Physical_ZipCode__c='42277788'
        ,JMA_Physical_Country__c ='US', JMA_Physical_City__c ='NY',JMA_Physical_Fax__c='987-654-9832', JMA_Billing_City__c = 'Chicago',
        JMA_Billing_Country__c = 'US', JMA_FWS_Number__c = String.valueOf(1),JMA_chk_Lead_creation_flg__c=true, SET_Consultant__c = UserInfo.getUserId());
        
        insert account;
        
        string taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        Task taskOne = new Task();
        taskOne.Subject = 'TXM Call';
        taskOne.Description = 'Test Description for task';
        taskOne.SET_Date_of_Visit__c = Date.Today() - 7;
        taskOne.Activity_Type__c = 'TXM';
        taskOne.Status = 'In Progress';
        taskOne.RecordTypeId = taskRecordTypeId;
        taskOne.Priority = 'Normal';
        taskOne.WhatId = account.Id;
        //taskOne.JMA_Have_Referral_Details__c = 'Yes';
        taskOne.SET_TXM_1st_Child_Task__c = true;
        taskOne.OwnerId = UserInfo.getUserId();
        insert taskOne;
        
        Test.StartTest();
        
        String query = 'Select whatID, OwnerId, Description, CreatedDate, Id From Task Where Activity_Type__c = \'TXM\' AND SET_TXM_1st_Child_Task__c = true';
        
        SET_TXMTaskBatch txmTaskBatch = new SET_TXMTaskBatch(query);
        
        ID batchprocessid = Database.executeBatch(txmTaskBatch);
        
        Test.StopTest();

    }
}