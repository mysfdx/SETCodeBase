/*
Name:PublishCaseCommentService
Purpose:Handler for Content Document Link Trigger
Author: Neha Agrawal
Date: 10/9/2020
*/

public class PublishCaseCommentService {
    Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>();
    Map<Id, List<Id>> caseToDocumentsMap = new Map<Id, List<Id>> ();
    
    public PublishCaseCommentService(Map<Id, ContentDocumentLink> contentDocumentLinkMap) {
        this.contentDocumentLinkMap = contentDocumentLinkMap;
    }
    
    public void publishCaseComments() {
        List<String> linkedEntIds = new List<String>();
        
        for(ContentDocumentLink link : this.contentDocumentLinkMap.values()) {
            linkedEntIds.add( link.LinkedEntityId );
        }
        
        List<ContentDocumentLink> conDocLinks = [
            SELECT LinkedEntityId,ContentDocumentId
            FROM ContentDocumentLink
            WHERE Id IN : contentDocumentLinkMap.keyset()
            AND LinkedEntity.Type = 'Case'
            AND LinkedEntityId IN :linkedEntIds
        ];
        List<Case> caseRecords = [
            SELECT Id, Unread_File__c
            FROM Case
            WHERE Id IN :LinkedEntIds
            AND Form_name__c='Incentives Challenge'
        ];
        Set<Id> caseRecordIds = new Map<Id, Case> (caseRecords).keySet();
        List<Case> unreadCaseFileList=New List<Case>();
        if(!conDocLinks.isEmpty()) {
            for(case c:caseRecords){
                c.Unread_File__c=True;
                unreadCaseFileList.add(c);
            }
            List<String> documentIds = new List<String>();
            for(ContentDocumentLink conDocLink : conDocLinks) {
                if (caseRecordIds.contains(conDocLink.LinkedEntityId)) {
                    documentIds.add(conDocLink.ContentDocumentId);
                    if(!caseToDocumentsMap.containsKey(conDocLink.LinkedEntityId)) {
                        caseToDocumentsMap.put(conDocLink.LinkedEntityId, new List<Id>());
                    }
                    List<Id> stagingIds = caseToDocumentsMap.get(conDocLink.LinkedEntityId);
                    stagingIds.add(conDocLink.ContentDocumentId);
                    caseToDocumentsMap.put(conDocLink.LinkedEntityId,stagingIds);
                }
            }
            Map<Id, ContentDocument> ContentDocuments = new Map<Id,ContentDocument>([
                SELECT Title
                FROM ContentDocument
                WHERE Id IN:documentIds
                
            ]);
            String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
           
            List<CaseComment> ccList = new List<CaseComment>();
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            for(Id caseId : caseToDocumentsMap.keySet()){
                for(Id documentId : caseToDocumentsMap.get(caseId)){
                    CaseComment cc = new CaseComment(
                        ParentId = caseId,
                        CommentBody = 'A new file named ' + ContentDocuments.get(documentId).Title + ' has been uploaded',
                        IsPublished = true
                    );
                    ccList.add(cc);
                }
            }
             if(ProfileName=='Dealer User Community Profile 1'){
            database.insert(ccList,dlo);
                 if(!unreadCaseFileList.isEmpty()){
                     update unreadCaseFileList;
                 }
             }
        }
    }
}