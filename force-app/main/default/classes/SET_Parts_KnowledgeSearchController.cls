/*******************************************************************
   Modified By  : Chandra Marthala
   Modified Date : 05/05/2018
   Purpose      : Removed reference of Sub Product 
********************************************************************/

public with sharing class SET_Parts_KnowledgeSearchController {
   
   public Case cas {get;set;}
   public List < Knowledge__kav > listKnowledge {get;set;}
   public String CaseId {get;set;}
   public Boolean fromCaseBool {get;set;}
   public String selectedKnow {get;set;}
   Map < Id, Knowledge__kav> mapKnowledge = new Map < Id, Knowledge__kav>();
   
   public SET_Parts_KnowledgeSearchController() {
       fromCaseBool = false;
       cas = new Case();
       CaseId = ApexPages.currentPage().getParameters().get('CaseId');
       if ( CaseId != null && CaseId != 'null' )
           fromCaseBool = true;
   }
   
   /*
    Purpose      : To fetch related Knowledge Articles 
    */ 
    
    public void fetchArticles() {
        if ( cas.DS_Vendor_Product_cust__c != null || cas.Subject != null ) {
            Boolean andBool = false;
            String strSOQL = 'SELECT KnowledgeArticleId, Id, ArticleNumber, Title, DS_Vendor__c, DS_Product__c,  LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';
            
            strSOQL += ' WHERE language=\'en_US\' AND PublishStatus = \'Online\' AND KnowledgeArticleId != null AND DS_Product__c = \'' + cas.DS_Vendor_Product_cust__c + '\'';
            
                        
            if ( String.isNotBlank(cas.Subject) ) {
                  strSOQL += ' AND ( DS_Problem_Statement__c LIKE \'%' + String.escapeSingleQuotes(cas.Subject) + '%\' ';
                    andBool = true; 
                 }
            
                               
            if ( andBool )
             strSOQL += ' )';
            
            listKnowledge = new List < Knowledge__kav >();
            listKnowledge = Database.query(strSOQL);
            mapKnowledge = new Map < Id, Knowledge__kav>();
            for ( Knowledge__kav k : listKnowledge ) {
                mapKnowledge.put(k.Id, k);
            }
        }
    }
    
    public PageReference redirectToArticleCreate() {
        PageReference pg = new PageReference('/knowledge/publishing/articleEdit.apexp?type=Knowledge__kav');
        pg.setRedirect(true);
        return pg;
    }
    

    public PageReference backToCase() {
        PageReference pg = new PageReference('/' + CaseId);
        pg.setRedirect(true);
        return pg;
    }
    
}