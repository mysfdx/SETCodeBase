@isTest
public with sharing class SET_TaskTriggerTest {
    
    static String profileId = [ SELECT Id, Name FROM Profile WHERE Name = 'SET - Market Rep' LIMIT 1 ].Id;
    
    @testSetup
    static void setTestData() {
        ID CustSetID = TestClientUtils.createCustomSetting('Competitive Contact Email Information','Test_Email_Template','Test Group', '##TaskVal##');
        ID TestCustSetID = TestClientUtils.createCustomSetting('Test Email Template','Test_Email_Template','Test Group', '##TaskVal##');
        Folder fldr=new Folder();
        fldr = [ SELECT Id FROM Folder WHERE Type = 'Document' AND AccessType = 'Public' LIMIT 1 ];
        ID EmailTmplID = TestClientUtils.createEmailTemplate('##TaskVal##', 'This is test Template. Link ##TaskVal##', 'Competitive_Contact_Task_Completed', fldr.id);
        List < Send_Email_Info__c > listSendEmail = new List < Send_Email_Info__c >(); 
        String profileName = [ SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() ].Name;
        Profile_allowed_to_runSendEmailToGroup__c objProfAllowed = new Profile_allowed_to_runSendEmailToGroup__c(Name = 'Testing', Allowed_Profile__c = profileName);
        insert objProfAllowed;
        SET_DFOM_Email__c SET_DFOM_Email = new SET_DFOM_Email__c();
        SET_DFOM_Email.Name = 'DFOM Email';
        SET_DFOM_Email.Email_Recipient__c = 'Test@jm.com';
        insert SET_DFOM_Email;        
        EmailTemplate template = [ SELECT DeveloperName FROM EmailTemplate LIMIT 1 ]; 
        Send_Email_Info__c cmpcontEmail1 = new Send_Email_Info__c();
        cmpcontEmail1.Name = 'Send Completion Email';
        cmpcontEmail1.Activity_Type__c = 'DealershipRoleChanges';
        cmpcontEmail1.Group_Name__c = 'SET COMPTROLLER CHANGES;SET DEALERSHIP ROLE CHANGES';
        cmpcontEmail1.replace_field_in_template__c = '##TaskRecord##';
        cmpcontEmail1.Email_template_to_use__c = template.DeveloperName;
        listSendEmail.add(cmpcontEmail1);
        insert listSendEmail;
    }
    
    static testMethod void testConsTask() { 
        Test.startTest();
        SET_DISTRICT_INFO__c districtInfo = new SET_DISTRICT_INFO__c();
        districtInfo.Name = '10';
        districtInfo.DFOM_User__c = UserInfo.getUserId();
        districtInfo.DSM_User__c = UserInfo.getUserId();
        districtInfo.ISDM_User__c = UserInfo.getUserId();
        districtInfo.Distribution_Phone__c = '0123854796';
        districtInfo.DSM_Phone__c = '0123854796';
        districtInfo.ISDM_Phone__c = '0123854796';
        districtInfo.DTM_User__c = 'Kristian Chesser';
        districtInfo.DTM_Phone__c = '0123854796';
        districtInfo.Customer_Response_User__c = 'Joshua Forman';
        districtInfo.Customer_Response_Phone__c = '0123854796';
        districtInfo.Distribution_User__c = 'Joshua Forman';
        districtInfo.Distribution_Phone__c = '0123854796';
        insert districtInfo;
        
        String dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        Account acct = TestClientUtils.createAccount();
        acct.SET_Consultant__c = UserInfo.getUserId();
        acct.SET_DISTRICT_INFO__c = districtInfo.Id;            
        insert acct;
        
        List < Task > lstTask = new List < Task >();
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        Task taskOne = new Task();
        taskOne.Subject = 'TXM Call';
        taskOne.Description = 'Test Description for task';
        taskOne.SET_Date_of_Visit__c = Date.Today() - 7;
        taskOne.Activity_Type__c = 'TXM';
        taskOne.SET_TXM_Type__c = 'Consultant';
        taskOne.Status = 'In Progress';
        taskOne.RecordTypeId = taskRecordTypeId;
        taskOne.Priority = 'Normal';
        taskOne.WhatId = acct.Id;
        taskOne.SET_Reminder_Notifications__c = false;
        lstTask.add(taskOne);        
        Task taskSecond = new Task();
        taskSecond.Subject = 'TXM Call';
        taskSecond.ActivityDate = Date.today();
        taskSecond.Description = 'Test Description for task';
        taskSecond.SET_Date_of_Visit__c = Date.Today() - 7;
        taskSecond.Activity_Type__c = 'TXM';
        taskSecond.Status = 'In Progress';
        taskSecond.RecordTypeId = taskRecordTypeId;
        taskSecond.Priority = 'Normal';
        taskSecond.WhatId = acct.Id;
        taskSecond.SET_Reminder_Notifications__c = false;
        taskSecond.SET_Parent_Task_ID__c = taskOne.Id;
        taskSecond.SET_TXM_Type__c = 'Consultant';
        lstTask.add(taskSecond);
        insert lstTask;
        taskSecond = [ SELECT ID,SET_Reminder_Notifications__c ,Status,SET_Reminder_Notifications2__c FROM Task WHERE Id =: taskSecond.Id ];
        taskSecond.SET_Reminder_Notifications__c = true;
        taskSecond.Status = 'Completed';
        update taskSecond;        
        taskSecond.SET_Reminder_Notifications2__c = true;  
        update TaskSecond;      
        Test.stopTest();
    }
    
    static testMethod void TestTask() {
        Test.startTest(); 
        //Create Group
        Group grprec=TestClientUtils.createGroup('Test Group');
        insert grprec;
        //Create User
        User UsrRec = TestClientUtils.createUser(profileId, 'TestFirst', 'TestLastName', 'TestEmail_rec@jmfamily.com','standarduserwe@testorg.com1');
        insert UsrRec;

        //User UsrRec=[Select ID,objProfile.Id from User where id=:UserInfo.getUserId()];
        //Create GroupMemer
        GroupMember GrmMbrID=TestClientUtils.createGroupMbr(grprec.ID, UsrRec.Id);
        insert GrmMbrID;
        //Create Competitive Contact
        //String grmName=Send_Email_Info__c.getInstance('Competitive Contact Email Information').Group_Name__c;
        //GroupMember GrmMbrID=[Select UserOrGroupID from GroupMember where Group.Name=:grmName  limit 1] ;
        //User UsrRec=[Select ID,objProfile.Id from User where ID=:GrmMbrID.UserOrGroupID];


        system.runas(UsrRec) {
            Competitive_Contact__c CmpContact=TestClientUtils.createCompContact('TestFull Name', 'Testfirstname', 'Testlastname');
            insert CmpContact;
            // Create Task
            LIST<ID> CmpIDs=new LIST<ID>();
            CmpIDs.add(CmpContact.Id);
            LIST<Task> crTaskId=new LIST<Task>();
            crTaskId=TestClientUtils.createTask( CmpIDs,'Competitive Contacts' , 'Completed');
            for(Task task :crTaskId)
                task.Activity_Type__c = 'test';
            insert crTaskId;
        }
        User user = new User(FirstName='David320',LastName='Liu32',Email='3p2@test.com',Username='3p2@test.com',
             Alias='fatty', ProfileId = profileId, TimeZoneSidKey='America/Denver',LocaleSidKey='en_US',
             EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',CommunityNickname='nickname32', 
             NTID__c='IU1JMNAE');
        insert user;
        system.debug('user<><>'+user);
        System.RunAs(user) {
            String AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
            Account acc = new Account(Name='Sample Account');
            acc.District__c = '2';
            insert acc;
    
            Competitive_Contact__c CmpContactEmail=TestClientUtils.createCompContact('TestFullEmail Name', 'TestfirstnameEmail', 'TestlastnameEmail');
            insert CmpContactEmail;
    
            LIST<ID> lstCmpIds=new LIST<ID>();
            lstCmpIds.add(CmpContactEmail.Id);
            LIST<Task> createTaskRc=new LIST<Task>();
            LIST<Task> createTask = new LIST<Task>();
            createTask = TestClientUtils.createTask(lstCmpIds,'Competitive Contact' , 'In Progress');
            createTaskRc.add(createTask[0]);
            //createTask = TestClientUtils.createTask(lstCmpIds,'Competitive Contact1' , 'In Progress');
            //createTaskRc.add(createTask[0]);
            LIST<Task> tsks=new LIST<Task>();
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
    
            String dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
    
            for (Task tskrec:createTaskRc) {
                tskrec.WhatId = acc.Id;
                tskrec.RecordTypeId = taskRecordTypeId;
                tskrec.Subject = 'Call';
                tsks.add(tskrec);
            }
    
            Database.Saveresult[] sr = Database.insert(tsks);
    
            LIST<ID> lstTaskID=new LIST<ID>();
            for (Database.Saveresult srItem:sr){
                if (srItem.isSuccess()){
                    lstTaskID.add(srItem.getID());
                }
            }
    
            LIST<Task> lstTasks=new LIST<Task>();
            for ( Task tsknew: [Select ID, Status FROM Task WHERE Id IN: lstTaskID ] ) {
                tsknew.Status='Completed';
                lstTasks.add(tsknew);
            }
            if ( lstTasks.size() > 0 ) {
                lstTasks.get(0).WhatId = null;
                lstTasks.get(0).Activity_Type__c = 'DFOM ME Recap';
                update lstTasks;
            }
        }
    }
    
    static testMethod void testUpdateTasks() {
        SET_DISTRICT_INFO__c districtInfo = new SET_DISTRICT_INFO__c();
        districtInfo.Name = '10';
        districtInfo.DFOM_User__c = UserInfo.getUserId();
        districtInfo.DSM_User__c = UserInfo.getUserId();
        districtInfo.ISDM_User__c = UserInfo.getUserId();
        districtInfo.Distribution_Phone__c = '0123854796';
        districtInfo.DSM_Phone__c = '0123854796';
        districtInfo.ISDM_Phone__c = '0123854796';
        districtInfo.DTM_User__c = 'Kristian Chesser';
        districtInfo.DTM_Phone__c = '0123854796';
        districtInfo.Customer_Response_User__c = 'Joshua Forman';
        districtInfo.Customer_Response_Phone__c = '0123854796';
        districtInfo.Distribution_User__c = 'Joshua Forman';
        districtInfo.Distribution_Phone__c = '0123854796';
        insert districtInfo;
        List < Account > listAccts = TestClientUtils.createAccounts(7, false);
        for ( Account acct : listAccts ) {
            acct.SET_Consultant__c = UserInfo.getUserId();
            acct.SET_DISTRICT_INFO__c = districtInfo.Id; 
        }
        insert listAccts;
        List < Task > listTasks = new List < Task >();
        for ( Account acct : listAccts ) {
            Task objTask = TestClientUtils.createTask(acct.Id, null);
            listTasks.add(objTask);
        }
        insert listTasks;
        listTasks.get(0).Status = 'Completed';
        listTasks.get(0).Activity_Type__c = 'DealershipRoleChanges';
        listTasks.get(0).Activity_Type_Sub_Category__c = 'Comptroller';
        listTasks.get(1).Subject = 'TXM Consultant Task';
        listTasks.get(1).Activity_Type__c = 'TXM';
        listTasks.get(1).SET_TXM_Type__c = 'Consultant';
        listTasks.get(1).Status = 'Completed';
        listTasks.get(1).SET_Parent_Task_ID__c = listTasks.get(0).Id;        
        listTasks.get(2).Activity_Type__c = 'TXM';
        listTasks.get(2).Subject = 'TXM Consultant Task';
        listTasks.get(2).SET_TXM_Type__c = 'DFOM'; 
        listTasks.get(2).Status = 'Completed';
        listTasks.get(2).SET_Parent_Task_ID__c = listTasks.get(0).Id;
        listTasks.get(3).Subject = 'TXM Consultant Task'; 
        listTasks.get(3).Status = 'Completed';        
        listTasks.get(4).Status = 'Completed';
        listTasks.get(4).Activity_Type__c = 'DealershipRoleChanges';
        listTasks.get(4).Activity_Type_Sub_Category__c = 'Dealer Principal';   
        listTasks.get(5).Status = 'Completed';
        listTasks.get(5).Activity_Type__c = 'DealershipRoleChanges';
        listTasks.get(5).Activity_Type_Sub_Category__c = 'General Manager';
        listTasks.get(6).Activity_Type__c = 'DealershipRoleChanges';
        listTasks.get(6).Activity_Type_Sub_Category__c = 'Operational Manager';
        listTasks.get(6).Status = 'Completed';
        update listTasks;
    }

}