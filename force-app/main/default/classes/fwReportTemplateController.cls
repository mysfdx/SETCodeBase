/*
Change Log
Date --- Modified By --- Purpose
05/20/2022 --- Neha Agrawal -- New class for newly created vf component ie.fwReportTemplateVFComponent 
for Factory warranty team
*/
public class fwReportTemplateController {
    
    public Id accountId {get;set;}
    public String recordTypeName {get;set;}
    
    public List<Factory_Warranty_Reports__c> getfwRecords()
    {
        List<Factory_Warranty_Reports__c> fwRecord;
        fwRecord = [SELECT Status__c, Dealer_Code__c,Claim_Number__c,Claim_Amount__c, Alternate_Claim__c, 
                    Part_Number__c, Repair_Order_Number__c, Warranty_Analyst_Notes__c,VIN__c,Claim_Age__c
                    FROM Factory_Warranty_Reports__c WHERE Dealer__c =: accountId AND Email_Sent__c=False
                    AND RecordType.DeveloperName =:recordTypeName];
        return fwRecord;
    }

}