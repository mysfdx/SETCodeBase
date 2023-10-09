/*Name:TranportationClaimControllerTest
Purpose:Test Class for TranportationClaimController, ENHC0012574
Author:Neha Agrawal
Date:2/3/2021

Change Log
Date - Changed by - Change Description
*/

@IsTest
private class TranportationClaimControllerTest {
    
    @TestSetup
    private static void buildTestData(){
        TransportClaimCarrierMails__c emailAddress= new TransportClaimCarrierMails__c ();
        emailAddress.Name = 'CarrierEmails';
        emailAddress.ACE__c = 'Test@jm.com';
        emailAddress.STS_and_Other__c = 'Test@jm.com';
        emailAddress.Centurion__c = 'Test@jm.com';
        emailAddress.Longhorn__c = 'Test@jm.com';
        emailAddress.AMJ__c='Test@jm.com';
        emailAddress.HICKS__c='Test@jm.com';
        emailAddress.NorthBeach__c='Test@jm.com';
        emailAddress.DMX__c='Test@jm.com';
        emailAddress.Masney__c='Test@jm.com';
        emailAddress.Runbuggy__c='Test@jm.com';
        insert emailAddress;

        Account a = new Account(Name='Acme', Dealer_Code__c='01234');
        insert a;

        Contact con = new Contact(
                AccountId = a.Id,
                LastName = 'portalUser',
                email='Test@email.com'
              
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

    }
	
    @IsTest
    private static void transportClaimControllerTest(){
        user u=[Select id, username, name, contactId from user where username = 'testuser@setdjithandler.com' limit 1];
        System.runAs(u) {
       //Transportation_claim__c c=new Transportation_claim__c();
       TranportationClaimController.getDealerCodeOptions();
       TranportationClaimController.getCarrierNameOptions();
       TranportationClaimController.getVehicleTypeOptions();
       TranportationClaimController.getDeliveryTypeOptions();
       
       //transportClaimInfo transClaim=new transportClaimInfo();
       transportClaimInfo.claimInfo infoObject =TranportationClaimController.getTransportClaimInfo();
      
       Id claimId = TranportationClaimController.getInsertedClaim(infoObject.transportClaimObject);
            system.debug('Claim is '+claimId);
        }
       Transportation_claim__c tc=[Select id, name, Contact_Email__c  from Transportation_claim__c where 
                                   createdby.email='testuser@setdjithandler.com'];
        system.debug('TC.Id '+tc.id);
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
        cdl.LinkedEntityId = tc.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'I';
        cdl.Visibility='AllUsers';
        Insert cdl;
       TranportationClaimController.sendEmail(tc.id);
  
    }

}