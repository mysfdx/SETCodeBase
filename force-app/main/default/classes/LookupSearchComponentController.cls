/* Name:  LookupSearchComponentController
Created By:  Neha Agrawal
Created Date:  2022-05-30
Description: created for backhaul form but can be used for any type of custom lookup.

Change log

*/
public without sharing class LookupSearchComponentController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        String query;
        system.debug('fieldName is  '+fieldName);
        if(ObjectName=='Account'){
            query='Select Id,'+fieldName+' FROM '+ObjectName+' WHERE Active_Dealer__c=true';
        }
        
        if(String.isNotBlank(value)){
            for(sObject so : Database.Query
                (query+' AND ( Name LIKE \'%' + value + '%\' OR Dealer_Code__c LIKE \'%'+value + '%\')')) {
                //String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(so, so.Id));
            }
        }
        else{
            for(sObject so : Database.Query(query)) {
                //String fieldvalue = (String)so.get(fieldName);
                //system.debug('so is '+so);
                sObjectResultList.add(new SObjectResult(so, so.Id));
            }
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public sObject rec;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(sObject recNameTemp, Id recIdTemp) {
            rec = recNameTemp;
            recId = recIdTemp;
        }
    }
}