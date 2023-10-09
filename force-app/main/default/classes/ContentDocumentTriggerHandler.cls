/*
Name:ContentDocumentTriggerHandler
Purpose:Handler class for ContentDocumentTrigger
Author: Neha Agrawal
Date: 10/9/2020
*/

public class ContentDocumentTriggerHandler {
    Map<Id,ContentDocument> condocMap=new Map<Id,ContentDocument>();
    
    public ContentDocumentTriggerHandler(Map<Id,ContentDocument> condocMap) {
        this.condocMap = condocMap;
        system.debug('condocMap '+ condocMap);
    }
    public void PreventDelete() {
        Map<Id, List<Id>> DocToDelete = new Map<Id, List<Id>>();
        Set<Id> SetOfCaseId = new Set<Id>();
        Map<Id, Id> ConDocToCase=new Map<Id, Id>();
        //set<id> caseids=new Set<id>();
        Map<Id,String> MapofStatus =new Map<Id,String>();
        Map<Id, List<Id>> caseToDocMap = new Map<Id, List<Id>>();
        
        list<ContentDocumentLink> clinks = [select Id, LinkedEntityId, ContentDocumentId,LinkedEntity.type from ContentDocumentLink where ContentDocumentId IN :condocMap.keySet()];
        system.debug('Clinks '+ clinks.size());
        for(ContentDocumentLink cl : clinks){
            system.debug('cl.LinkedEntity.type '+cl.LinkedEntity.type);
            if(cl.LinkedEntity.type=='case') 
            {
                ConDocToCase.put(cl.ContentDocumentId,cl.LinkedEntityId);
                SetOfCaseId.add(cl.LinkedEntityId);
                
            }
        }
        String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
        If(!SetOfCaseId.isEmpty()){
            
        MapofStatus=getCaseFormMap(SetOfCaseId);
        System.debug('ConDoctoCase is '+ ConDocToCase.values());
        
            For(ContentDocument d: condocMap.values()){
                id Caselink=ConDocToCase.get(d.Id);
                System.debug('Case is '+ Caselink);
                if(MapofStatus.get(Caselink)=='Incentives Challenge' && ProfileName=='Dealer User Community Profile 1'){
                    
                    d.adderror('Sorry, file can Not be deleted..!!');
                    
                }
            }
        }
        
        
    }
    
    public Map<Id,String> getCaseFormMap(Set<id> Caseset) {
        Map<Id,String> MapofCase =new Map<Id,String>();
        if(!Caseset.isEmpty())
        {
            for (Case cs : [Select Id, status,form_name__c from case where id IN: caseset]) {
                MapofCase.Put(cs.id, cs.form_name__c);
            } 
        }
        
        return MapofCase;
    }
    
}