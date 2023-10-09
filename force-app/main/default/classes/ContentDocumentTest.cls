/*
Name:ContentDocumentTest
Purpose:This has been used to cover all Triggers and handlers of ContentDocument, ContentDocumentLink and ContentVersion
Author: Neha Agrawal
Date: 10/9/2020
*/

@istest
Private class ContentDocumentTest {
    @testSetup 
    static void setup(){
        Account a = new Account(Name='Acme', Dealer_Code__c='01234');
        insert a;

        Contact con = new Contact(
                AccountId = a.Id,
                LastName = 'portalUser'
              
        );
        insert con;

        Profile p = [select Id,name from Profile where Name = 'Dealer User Community Profile 1' Limit 1];
        User newUser = new User(
                profileId = p.Id,
                username = 'testuser@setdjithandler.com',
                email = 'testuser@setdjithandler.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='sjuser',
                lastname='portalUser',
                contactId = con.id
            
        );
        insert newUser;
        case c =new case(Form_name__c='Incentives Challenge',status='New',Challenge__c='CH_SET_CHALLENGE', contactId=con.id, community_contact__c=con.Id);
        Insert c;
        // Task Insert
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('SET Task').getRecordTypeId();
        Task taskOne = new Task();
        taskOne.Subject = 'TXM Call';
        taskOne.Is_Attachment_Present__c='No';
        taskOne.Status = 'In Progress';
        taskOne.RecordTypeId = taskRecordTypeId;
        taskOne.Priority = 'Normal';
        taskOne.WhatId = c.Id;
        insert taskOne;
    
       //insert content Version
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
   
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink for Case
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'I';
        cdl.Visibility='AllUsers';
        Insert cdl;
        
       
         //Create ContentDocumentLink for Task
         ContentDocumentLink cdlTask = New ContentDocumentLink();
        cdlTask.LinkedEntityId = taskOne.Id;
        cdlTask.ContentDocumentId = conDocId;
        cdlTask.shareType = 'V';
        Insert cdlTask;
    
    }
    static testmethod void AttachCaseDoc() { 
      
       Case ca=[Select Casenumber, id from Case where Form_name__c='Incentives Challenge' limit 1];
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
       //cv.FirstPublishLocationId = c.Id;
        Insert cv;
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE id=:cv.id].ContentDocumentId;
        //Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document'].ContentDocumentId;
        //Create ContentDocumentLink  for Case
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ca.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
      
             
    } 
    static testmethod void DeleteCaseDoc() { 
        Case ca=[Select Casenumber, id from Case where Form_name__c='Incentives Challenge' limit 1];
        ContentDocumentLink conlink=[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:ca.Id limit 1];
        // Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE LinkedEntityId =:ca.Id limit 1].ContentDocumentId;
        ContentDocument doc=[Select id from ContentDocument where id=:conlink.ContentDocumentId];
        Delete doc;
    } 
    static testmethod void attachTaskDoc() { 
        Task ta=[Select id from TASK where Subject='TXM Call' limit 1];
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
       //cv.FirstPublishLocationId = c.Id;
        Insert cv;
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE id=:cv.id].ContentDocumentId;
        //Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document'].ContentDocumentId;
        //Create ContentDocumentLink  for Case
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ta.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
      
    }
    static testmethod void removeTaskDoc() { 
        Task ta=[Select id from TASK where Subject='TXM Call' limit 1];
        ContentDocumentLink conlink=[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:ta.Id limit 1];
        // Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE LinkedEntityId =:ca.Id limit 1].ContentDocumentId;
        ContentDocument doc=[Select id from ContentDocument where id=:conlink.ContentDocumentId];
        Delete conlink;
        
        
    } 
    static testmethod void deleteTaskDoc() { 
        Task ta=[Select id from TASK where Subject='TXM Call' limit 1];
        ContentDocumentLink conlink=[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:ta.Id limit 1];
        // Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE LinkedEntityId =:ca.Id limit 1].ContentDocumentId;
        ContentDocument doc=[Select id from ContentDocument where id=:conlink.ContentDocumentId];
        Delete conlink;
        Delete doc;
        
    } 
}