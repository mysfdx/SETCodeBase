/*Name:SendTaskNotificationTest
Purpose: Test Class for SendTaskNotification
Author:Neha Agrawal
Date:3/16/2021

Change Log
Date - Changed by - Change Description
*/


@isTest
public class SendTaskNotificationTest {

    @testSetup
    static void setTestData() {
        Account acct = TestClientUtils.createAccount();
        insert acct;
        Task t= new Task(Subject = 'Test1'
                      , ActivityDate = System.Today() + 1
                      , Description = 'this is a test'
                      , Status = 'New'
                      , WhatId = acct.id
                      , Activity_Type__c = 'Awards');
       
        insert t;
        
    }
    static testMethod void TestSendTaskNotificationMethods(){
    task NotificationTask=[Select id,Subject,WhoId,WhatId,Who.FirstName,Who.Name,Who.type,What.type,what.name From task 
                    where Activity_Type__c = 'Awards' limit 1];
        if(NotificationTask!=null)
        {
            SendTaskNotification st=new SendTaskNotification();
            st.taskId=NotificationTask.id;
            st.getObjectName();
            st.getRecordName();
            
        }
        
    }
      
}