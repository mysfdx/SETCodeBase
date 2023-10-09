/* Name:  SET_CaseTriggerHandler
Created By:  Magulan Duraipandian
Created Date:  2017-07-06
Last Modified By:  SET Salesforce System Admin
Last Modified Date: 2018-04-26
Description:   
*/

public with sharing class SET_CaseTriggerHandler {
    
    public static void onBeforeInsert(List < Case > newCases) {
        populateSatisfiedDate(newCases, null);
    }
    
    public static void onBeforeupdate(List < Case > newCases, Map < Id, Case > oldMap) {
        populateSatisfiedDate(newCases, oldMap);
    }
    
    static void populateSatisfiedDate(List < Case > newCases, Map < Id, Case > oldMap) {
        for ( Case objCase : newCases ) {
            if ( String.isNotBlank(objCase.SET_Follow_Up_Results__c) ) {
                if ( oldMap == null || String.isBlank(oldMap.get(objCase.Id).SET_Follow_Up_Results__c) )
                    objCase.SET_Customer_Satisfied_Date__c = system.today();                                 
            } else if ( oldMap != null && String.isNotBlank(oldMap.get(objCase.Id).SET_Follow_Up_Results__c) ) {
                objCase.SET_Customer_Satisfied_Date__c = null;
            }
            if ( oldMap != null && objCase.SET_Follow_Up_Requested__c != 'Yes' && oldMap.get(objCase.Id).SET_Follow_Up_Requested__c == 'Yes' )
                objCase.SET_Customer_Satisfied_Date__c = null;
            else if ( oldMap != null && objCase.SET_Follow_Up_Requested__c == 'Yes' && oldMap.get(objCase.Id).SET_Follow_Up_Requested__c != 'Yes' && String.isNotBlank(objCase.SET_Follow_Up_Results__c) && String.isNotBlank(oldMap.get(objCase.Id).SET_Follow_Up_Results__c) )
                objCase.SET_Customer_Satisfied_Date__c = system.today();      
        }
    }
    
}