/*
Name:ContentDocumentTest
Purpose:This has been used to cover FeedComment Trigger
Author: Neha Agrawal
Date: 10/25/2020
*/

@isTest
public class FeedCommentTest {
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
        caseshare cs= new Caseshare(CaseAccessLevel='Edit',CaseId=c.id,RowCause='Manual',UserOrGroupId=newUser.id);
       insert cs;
    }
    
    static testmethod void FeedCommentTestMethod(){
        User portaluser=[select id, username from user where lastname='portalUser' and profile.name='Dealer User Community Profile 1'];
        system.runAs(portaluser){
            Case ca=[Select Casenumber, id from Case where Form_name__c='Incentives Challenge' limit 1];
        FeedItem f = new FeedItem();
        f.ParentId = ca.Id;
        f.body = 'test';
        insert f;
        FeedComment fc = new FeedComment();
        fc.CommentBody = 'legal test';
        fc.FeedItemId = f.Id;   // please add this
        insert fc;
        }
    }
}