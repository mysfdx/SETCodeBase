/*
 Change log
 4/9/2020 - Neha Agrawal - added the if else condition in getFields(String recordId), now community user will not receive 
 error if they will view the cases created by any other community user. Instead of error there will one message.
*/

public with Sharing class setd_CaseViewController {
    
    @AuraEnabled
    static public List<String> getFields(String recordId) {
        system.debug('Case Id '+ recordId);
        Case caseRecord = [SELECT Form_Name__c FROM Case WHERE Id = :recordId];
        
        if(!string.isEmpty(caseRecord.Form_Name__c)){
            Form__mdt form = [SELECT MasterLabel, DeveloperName, Fields_Json__c FROM Form__mdt WHERE MasterLabel = :caseRecord.Form_Name__c];
            return (String[])JSON.deserialize(form.Fields_Json__c.replaceAll('\\s', ''), List<String>.class);
        }
        else{
            return new List<string>();
        }
        
    }
    
    @AuraEnabled
    public static Boolean isPortalUser() {
        Id userId = UserInfo.getUserId();
        return [SELECT IsPortalEnabled FROM User WHERE Id = :userId].IsPortalEnabled;
    }    
}