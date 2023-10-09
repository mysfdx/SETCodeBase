/*
Name:ContentVersionTriggerHandler
Purpose:Handler class for ContentVersionTrigger
Author: Neha Agrawal
Date: 10/9/2020
*/

public class ContentVersionTriggerHandler {
    
    List<ContentVersion> ContentVersionList = new List<ContentVersion>();
    public ContentVersionTriggerHandler(List<ContentVersion> ContentVersionList) {
        this.ContentVersionList = ContentVersionList;
    }
    public void OnInsertUpdateContentVersion(){
        Set<Id> SetOfCd = new Set<Id>();
        Set<Id> SetOfCase = new Set<Id>();
        map<Id,Id> MapOfCdNCdl = new map<Id,Id>();
        Map<Id,String> MapOfStatus= new Map<Id,String>();
        for(ContentVersion cv :ContentVersionList){
            if(!string.isEmpty(cv.contentDocumentId))
                SetOfCd.add(cv.ContentDocumentId);
        }
        system.debug('Set Of Content Doc'+SetOfCd);
        if(!SetOfCd.isEmpty()){
           for(ContentDocumentLink cdl : [SELECT LinkedEntityId,ContentDocumentId,LinkedEntity.type FROM ContentDocumentLink WHERE ContentDocumentId IN:SetOfCd]){
               if(cdl.LinkedEntity.type=='case') {
                   SetOfCase.add(cdl.LinkedEntityId);
                   MapOfCdNCdl.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
               }
        } 
        }
        String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
        if(!SetOfCase.isEmpty()){
             MapOfStatus = getCaseFormMap(SetOfCase);
        
        for(ContentVersion cv :ContentVersionList){
            Id cdlId = MapOfCdNCdl.get(cv.ContentDocumentId);
            if(!string.isEmpty(cv.contentDocumentId) && MapOfStatus.get(cdlId)=='Incentives Challenge'&& ProfileName=='Dealer User Community Profile 1'){
                cv.addError('Sorry, file version can not be changed');
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