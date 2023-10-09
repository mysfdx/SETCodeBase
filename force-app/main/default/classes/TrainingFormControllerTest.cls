/*
Created By: Neha Agrawal-- ENHC0012046
Created Date: 11th Aug 2020
Description: Test class for Training Form Controller


Changelog 

Author--             Date--                       Purpose--
Neha Agrawal        12/16/2020          Added few new fields CHG0040513
Neha Agrawal        7/12/2021          To rename Training Expense plan to Rewards and Recognition and added 
fields Jira reference SS1SP-72, SS1SP-111, SS1SP-115
Neha Agrawal        10/20/2022       Changes to Program Start Date, added custom setting.
*/


@istest
global class TrainingFormControllerTest {
    
    @TestSetup
    global static void buildTestData()
    {
        Referral_Source__c testTactDate= New Referral_Source__c();
        testTactDate.Name='TACTProgramStartDates';
        testTactDate.FirstDate__c=True;
        testTactDate.SecondDate__c=False;
        testTactDate.ThirdDate__c=True;
        insert testTactDate;
        Account a = new Account(Name='TestAcme', Dealer_Code__c='01235');
        a.District__c='1';
        insert a;
        
        Activity_Summary__c a1=new Activity_Summary__c(name='1');
        insert a1;
        
        Apprentice__c testAppr = new Apprentice__c();
        testAppr.Apprentice_SPIN_new__c='123456789102';
        testAppr.Dealer__c=a.id;
        testAppr.Mentor__c='Louis';
        testAppr.Phase__c='Enrollment';
        testAppr.Career_Path__c='Yes';
        testAppr.On_Boarding_Plan__c='Yes';
        testAppr.Contact_Date__c=System.today();
        testAppr.Apprentice_Cell_Phone__c='1234567890';
        testAppr.Apprentice_Email_Address__c='test@gmail.com';
        testAppr.Apprentice_Shirt_Size__c='L';
        testAppr.Mentor_Cell_Phone__c='1234567890';
        testAppr.mentor_Spin__c='123456789102';
        testAppr.Mentor_Email_Address__c='test@gmail.com';
        testAppr.Mentor_Shirt_Size__c='L';
        testAppr.Name='Paulina';
        
        insert testAppr;
    }
    @IsTest
    global static void RecordUpdate(){
        Apprentice__c apptest=[Select id, Dealer__c,Apprentice_SPIN_New__c,  name,Mentor__c, Contact_Date__c, Phase__c, Enrollment__c, 
                               Phase_1__c, Phase_2__c, Phase_3__c, Apprentice_Cell_Phone__c,Mentor_Cell_Phone__c,
                               Apprentice_Email_Address__c,Mentor_Email_Address__c,Mentor_SPIN__c,Mentor_Shirt_Size__c,
                               Apprentice_Shirt_Size__c,Program_Start_Date__c,Apprentice_Program_Termination_Date__c,
                               Termination_Status__c,Graduation_Date__c,Reason_for_Termination__c
                               from Apprentice__c where Apprentice_SPIN_new__c='123456789102'];
        
        update apptest;
    }
    
    @IsTest
    global static void RecordCreate(){
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Apprentice__c());
        TrainingFormController t=new TrainingFormController(sc);
        Account acc =[Select id from Account where Dealer_Code__c='01235']; 
        
        t.SearchRecord();
        t.appr.Apprentice_SPIN_new__c='123456789105';
        t.appr.Dealer__c=acc.Id;
        t.appr.Phase__c='Enrollment';
        t.appr.Contact_Date__c=System.today();
        t.appr.name='Paulina';
        t.appr.Mentor__c='Test';
        t.appr.Apprentice_Cell_Phone__c='1234567890';
        t.appr.Apprentice_Email_Address__c='test@gmail.com';
        t.appr.Apprentice_Shirt_Size__c='L';
        t.appr.Mentor_Cell_Phone__c='1234567890';
        t.appr.mentor_Spin__c='123456789102';
        t.appr.Mentor_Email_Address__c='test@gmail.com';
        t.appr.Mentor_Shirt_Size__c='L';
        t.selectedDateString=Date.newInstance(2023,1,1).format();
        Attachment attachtest=new Attachment();    
        attachtest.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attachtest.body=bodyBlob;
        t.save();
        t.proceed();
        t.showPopup();
        t.clearMessage();
        t.closePopup();
    }
    
}