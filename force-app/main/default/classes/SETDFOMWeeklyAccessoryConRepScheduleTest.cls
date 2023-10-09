@isTest
class SETDFOMWeeklyAccessoryConRepScheduleTest
{
    static testMethod void testSSETDFOMWeeklyConReportSch()
    {
        SET_DFOM_Email__c SET_DFOM_Email = new SET_DFOM_Email__c();
        SET_DFOM_Email.Name = 'DFOM Email';
        SET_DFOM_Email.Email_Recipient__c = 'Test@jm.com';
        insert SET_DFOM_Email;
        
        EmailTemplate template = [Select DeveloperName from EmailTemplate Limit 1];
        
        Send_Email_Info__c cmpcontEmail = new Send_Email_Info__c();
        cmpcontEmail.Name = 'Competitive Contact Email Information';
        cmpcontEmail.Email_template_to_use__c = template.DeveloperName;
        insert cmpcontEmail;
        
        SET_DFOM_Picklists__c set_Dfom_Picklists = new SET_DFOM_Picklists__c();
        set_Dfom_Picklists.Name = 'SET Picklist Values';
        set_Dfom_Picklists.Area_Picklist__c = 'A;B';
        set_Dfom_Picklists.District_Picklist__c = '01;02;03;04;05;06;07;08;09;10;11;12;13;14';
        set_Dfom_Picklists.Day_Picklist__c = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday';
        insert set_Dfom_Picklists;
        
        Profile profile = [Select Id from Profile Where Name like 'SET%' limit 1];
    
        User userNew = new User();
        userNew.FirstName = 'firstName';
        userNew.LastName = 'lastName';
        userNew.Alias = 'pTst';
        userNew.Username = userNew.Email = 'setEmail@testNew.com';
        userNew.EmailEncodingKey = 'UTF-8';
        userNew.LanguageLocaleKey = 'en_US';
        userNew.LocaleSidKey = 'en_US';
        userNew.TimeZoneSidKey = 'America/Los_Angeles';
        userNew.ProfileId = profile.Id;
        userNew.SET_Area__c = 'A';
        userNew.SET_District__c = '01';
        insert userNew;
        
        //RecordType recordType = [Select Id from RecordType Limit 1];
        string taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId(); 
        
        Task taskOne = new Task();
        taskOne.Subject = 'Call';
        taskOne.OwnerId = userNew.Id;
        taskOne.Description = 'Test Description for task';
        taskOne.SET_Date_of_Visit__c = Date.Today() - 7;
        taskOne.Activity_Type__c = 'Accessory';
        taskOne.Status = 'Completed';
        taskOne.RecordTypeId = taskRecordTypeId;
        taskOne.Priority = 'Normal';
        insert taskOne;
        
        system.debug('taskOne===='+taskOne);
        
        SETDFOMWeeklyAccessoryConReportSchedule scheduleReport = new SETDFOMWeeklyAccessoryConReportSchedule();
        string strSchTime = '0 05 7 ? * MON *';
        system.schedule('DFOM Weekly Accessory Contact Report Test', strSchTime, scheduleReport);
    }
}