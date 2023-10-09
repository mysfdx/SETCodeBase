@isTest
class SETDFOMMonthlyContactReportConTest
{
    static testMethod void testSETDFOMMonthlyContactReport()
    {
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
        
        User user = new User();
        user.FirstName = 'firstName';
        user.LastName = 'lastName';
        user.Alias = 'pTst';
        user.Username = user.Email = 'setEmail1@testNew.com';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.ProfileId = profile.Id;
        user.SET_Area__c = 'B';
        user.SET_District__c = '9';
        
        insert user;
        
        EmailTemplate template = [Select DeveloperName from EmailTemplate Limit 1];
        
        Send_Email_Info__c cmpcontEmail = new Send_Email_Info__c();
        cmpcontEmail.Name = 'Competitive Contact Email Information';
        cmpcontEmail.Email_template_to_use__c = template.DeveloperName;
        insert cmpcontEmail;
        
        Send_Email_Info__c cmpcontEmail1 = new Send_Email_Info__c();
        cmpcontEmail1.Name = 'Send Completion Email';
        cmpcontEmail1.replace_field_in_template__c = '##TaskRecord##';
        cmpcontEmail1.Email_template_to_use__c = template.DeveloperName;
        cmpcontEmail1.Activity_Type__c = 'Collision Consult;DFOM Contact;eCommerce Parts;Parts Consult;PIPA;Svc Consult;Whls Consult;Tire Consult';
        cmpcontEmail1.Group_Name__c = 'SET DPR;SET GME;SET GM CHANGES;SET OWNERSHIP CHANGES;SET Buy/Sell;SET Capital;SET Package Update;SET Performance;SET Facility';
        insert cmpcontEmail1;
        
        SET_DFOM_Picklists__c set_Dfom_Picklists = new SET_DFOM_Picklists__c();
        set_Dfom_Picklists.Name = 'SET Picklist Values';
        set_Dfom_Picklists.Area_Picklist__c = 'A;B';
        set_Dfom_Picklists.District_Picklist__c = '01;02;03;04;05;06;07;08;09;10;11;12;13;14';
        insert set_Dfom_Picklists;
        
        //RecordType recordType = [Select Id from RecordType Limit 1];
        string taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        
        Task taskOne = new Task();
        taskOne.Subject = 'Call';
        taskOne.OwnerId = userNew.Id;
        taskOne.Description = 'Test Description for task';
        taskOne.SET_Date_of_Visit__c = Date.Today() - 1;
        taskOne.Activity_Type__c = 'DFOM ME Recap';
        taskOne.Status = 'Completed';
        taskOne.RecordTypeId = taskRecordTypeId;
        taskOne.Priority = 'Normal';
        taskOne.SET_NGP__c = 'NGP1';
        taskOne.SET_Tires__c = 'Tires1';
        taskOne.SET_SORT_DISTRICT__c = 1;
        taskOne.SET_SORT_AREA__c = 'A';
        insert taskOne;
        
        Task taskTwo = new Task();
        taskTwo.Subject = 'Call';
        taskTwo.OwnerId = user.Id;
        taskTwo.Description = 'Test Description for task';
        taskTwo.SET_Date_of_Visit__c = Date.Today() - 1;
        taskTwo.Activity_Type__c = 'DFOM ME Recap';
        taskTwo.Status = 'Completed';
        taskTwo.RecordTypeId = taskRecordTypeId;
        taskTwo.Priority = 'Normal';
        taskTwo.SET_NGP__c = 'NGP2';
        taskTwo.SET_Tires__c = 'Tires2';   
        taskTwo.SET_SORT_DISTRICT__c = 8;
        taskTwo.SET_SORT_AREA__c = 'B';        
        insert taskTwo;
        
        //ApexPages.currentPage().getParameters().put('forMonth', 'December');
        PageReference pageRef = Page.SETDFOMMonthlyContactReportPDF; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('forMonth', system.now().adddays(-2).format('MMMM')+'-'+ system.now().adddays(-2).format('yyyy'));
        //ApexPages.currentPage().getParameters().put('forMonth', 'Jan');
        SETDFOMMonthlyContactReportCon firstSETDFOMMonthlyContactReportCon = new SETDFOMMonthlyContactReportCon();
        /*firstSETDFOMMonthlyContactReportCon.StrArea = 'A';
        firstSETDFOMMonthlyContactReportCon.StrActivity = 'Svc Misc';*/
        firstSETDFOMMonthlyContactReportCon.StrDistrict = '01';
        firstSETDFOMMonthlyContactReportCon.StrArea = 'A';
        firstSETDFOMMonthlyContactReportCon.NewTask.SET_Date_of_Visit__c = Date.Today() - 7;
        firstSETDFOMMonthlyContactReportCon.secondTask.SET_Date_of_Visit__c = Date.today();
        //firstSETDFOMMonthlyContactReportCon.lstActivityInfo = new List<Task>();
        //firstSETDFOMMonthlyContactReportCon.lstActivityInfo.add(taskOne);
        firstSETDFOMMonthlyContactReportCon.fetchActivity();
        system.debug('firstSETDFOMMonthlyContactReportCon.secondTask.SET_Date_of_Visit__c===='+firstSETDFOMMonthlyContactReportCon.secondTask.SET_Date_of_Visit__c);
        system.debug('firstSETDFOMMonthlyContactReportCon.NewTask.SET_Date_of_Visit__c===='+firstSETDFOMMonthlyContactReportCon.NewTask.SET_Date_of_Visit__c);
        firstSETDFOMMonthlyContactReportCon.exportXls();
        //firstSETDFOMMonthlyContactReportCon.getActivityOptions();
        firstSETDFOMMonthlyContactReportCon.getLstArea();
        firstSETDFOMMonthlyContactReportCon.getLstDistrict();
        firstSETDFOMMonthlyContactReportCon.getLstMonth();
    }
}