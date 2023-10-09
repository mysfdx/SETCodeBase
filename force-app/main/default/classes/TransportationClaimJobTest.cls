/* Name:  TransportationClaimJobTest
Created By:Neha Agrawal
Created Date:  2021-03-23
Last Modified By:  Neha Agrawal
Last Modified Date: 2021-04-23
Description: Test Class for TransportClaimCarrierReportJob

***********************************************
Change Log

Changed by--     Date--                  Pupose--
Neha Agrawal--   28th May 2021--   to remove the see all data true now using setup method.
*/

@isTest
public class TransportationClaimJobTest {
    
    @testSetup static void setupCustomSetting() {
        
        TransportClaimCarrierMails__c emailAddress= new TransportClaimCarrierMails__c();
        emailAddress.Name = 'CarrierEmails';
        emailAddress.ACE__c = 'Test@jm.com';
        emailAddress.STS_and_Other__c = 'Test@jm.com';
        emailAddress.Centurion__c = 'Test@jm.com';
        emailAddress.Longhorn__c = 'Test@jm.com';
        emailAddress.Trans_Claims_Not_Processed_Emails__c='Test@jm.com';
        emailAddress.Trans_Claims_Under_Review_Emails__c='Test@jm.com';
        emailAddress.AMJ__c='Test@jm.com';
        emailAddress.HICKS__c='Test@jm.com';
        emailAddress.NorthBeach__c='Test@jm.com';
        emailAddress.DMX__c='Test@jm.com';
        emailAddress.Masney__c='Test@jm.com';
        emailAddress.Runbuggy__c='Test@jm.com';
        insert emailAddress;
    }
    
    @isTest
    public static void ACEexecuteTest(){
        
        SchedulableContext sc = null;
        TransportClaimCarrierReportJob reportJob = new TransportClaimCarrierReportJob();
        reportJob.execute(sc);
    }
    
}