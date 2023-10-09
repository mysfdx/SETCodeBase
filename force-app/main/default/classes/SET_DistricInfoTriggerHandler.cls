/* Name:  SET_DistricInfoTriggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Magulan Duraipandian
Last Modified Date: 2017-07-06
Description:   
*/

public with sharing class SET_DistricInfoTriggerHandler {
    
    public static void onAfterUpdate(List < SET_DISTRICT_INFO__c > listDistInfo, Map < Id, SET_DISTRICT_INFO__c > oldMap) {
        updateAccts(listDistInfo, oldMap);
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 12/5/2016
    Purpose      : To populate FTS and Owner on accounts if it is changed in SET District INFO
    */
    static void updateAccts(List < SET_DISTRICT_INFO__c > listDistInfo, Map < Id, SET_DISTRICT_INFO__c > oldMap) {
        Set < Id > setDisInfoIds = new Set < Id >();
        Set < Id > setDisInfoIdsForCustResp = new Set < Id >();
        Map < Id, Id > mapDistInfoIdFTSId = new Map < Id, Id >();
        Map < Id, Id > mapDistInfoIdOwnerId = new Map < Id, Id >();
        
        for ( SET_DISTRICT_INFO__c dist : listDistInfo ) {
            if ( dist.FTS__c != oldMap.get(dist.Id).FTS__c && dist.FTS__c != null ) {
                setDisInfoIds.add(dist.Id);
                mapDistInfoIdFTSId.put(dist.Id, dist.FTS__c);
            }
            if ( dist.Account_Owner__c != oldMap.get(dist.Id).Account_Owner__c && dist.Account_Owner__c != null ) {
                setDisInfoIds.add(dist.Id);
                mapDistInfoIdOwnerId.put(dist.Id, dist.Account_Owner__c);
            }
            if ( dist.Customer_Response__c != oldMap.get(dist.Id).Customer_Response__c && dist.Customer_Response__c != null ) {
                setDisInfoIdsForCustResp.add(dist.Id);
            }
        }
        
        if ( setDisInfoIds.size() > 0 ) {
            List < Account > listAcct = new List < Account >(); 
            for ( Account a : [ SELECT Id, SET_DISTRICT_INFO__c FROM Account WHERE SET_DISTRICT_INFO__c IN: setDisInfoIds ] ) {
                Account acct = new Account(Id = a.Id);
                if ( mapDistInfoIdFTSId.containsKey(a.SET_DISTRICT_INFO__c) )
                    acct.SET_FTS__c = mapDistInfoIdFTSId.get(a.SET_DISTRICT_INFO__c);
                if ( mapDistInfoIdOwnerId.containsKey(a.SET_DISTRICT_INFO__c) )
                    acct.OwnerId = mapDistInfoIdOwnerId.get(a.SET_DISTRICT_INFO__c);
                listAcct.add(acct);
            }
            if ( listAcct.size() > 0 )
                update listAcct;
        }
        
        if ( setDisInfoIdsForCustResp.size() > 0 ) {            
            List < Case > listCases = new List < Case >(); 
            Map < Id, String > mapSETDistInfoIdEmail = new Map < Id, String >();
            Id SETFTSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SET FTS Case').getRecordTypeId();
            
            for ( SET_DISTRICT_INFO__c dist : [ SELECT Id, Customer_Response__r.Email FROM SET_DISTRICT_INFO__c WHERE Id IN: setDisInfoIdsForCustResp ] )
                mapSETDistInfoIdEmail.put(dist.Id, dist.Customer_Response__r.Email);
                
            for ( Case cas : [ SELECT Id, Account.SET_DISTRICT_INFO__c FROM Case WHERE RecordTypeId =: SETFTSRecordTypeId AND Account.SET_DISTRICT_INFO__c IN: setDisInfoIdsForCustResp AND IsClosed = false ] ) 
                listCases.add(new Case(Id = cas.Id, SET_Customer_Response_Email__c = mapSETDistInfoIdEmail.get(cas.Account.SET_DISTRICT_INFO__c)));
            
            if ( listCases.size() > 0 )    
                update listCases;
        }
    }
    
}