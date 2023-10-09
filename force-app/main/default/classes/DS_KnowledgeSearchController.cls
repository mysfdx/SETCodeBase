/* Name:  DS_KnowledgeSearchController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_KnowledgeSearchController {
   
   public Case cas {get;set;}
   public List < Knowledge__kav > listKnowledge {get;set;}
   public String CaseId {get;set;}
   public Boolean fromCaseBool {get;set;}
   public String selectedKnow {get;set;}
   Map < Id, Knowledge__kav> mapKnowledge = new Map < Id, Knowledge__kav>();
   
   public DS_KnowledgeSearchController() {
       fromCaseBool = false;
       cas = new Case();
       CaseId = ApexPages.currentPage().getParameters().get('CaseId');
       if ( CaseId != null && CaseId != 'null' )
           fromCaseBool = true;
   }
   
   /*
    Created By   : Magulan Duraipandian
    Created Date : 9/19/2016
    Purpose      : To fetch related Knowledge Articles 
    Modified By  : Chandra Marthala
    Modified date: 10/16/2018
    Purpose      ; Sub product retirement  
    */ 
    
    public void fetchArticles() {
        if ( cas.DS_Vendor_Product_cust__c != null || cas.Subject != null || cas.DS_App_Function__c != null ) {
            Boolean andBool = false;
            String strSOQL = 'SELECT KnowledgeArticleId, Id, ArticleNumber, Title, DS_Vendor__c, DS_Product__c, DS_App_Function__c, LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';
            
            strSOQL += ' WHERE language=\'en_US\' AND PublishStatus = \'Online\' AND KnowledgeArticleId != null AND DS_Product__c = \'' + cas.DS_Vendor_Product_cust__c + '\'';
            
          /*
            if ( String.isNotBlank(cas.DS_Subproduct__c) ) {
                strSOQL += ' AND ( DS_Subproduct__c = \'' + cas.DS_Subproduct__c + '\' ';
                andBool = true; 
            } */
            
            if ( String.isNotBlank(cas.Subject) ) {
                if ( andBool )
                    strSOQL += ' OR DS_Problem_Statement__c LIKE \'%' + String.escapeSingleQuotes(cas.Subject) + '%\' ';
                else {
                    strSOQL += ' AND ( DS_Problem_Statement__c LIKE \'%' + String.escapeSingleQuotes(cas.Subject) + '%\' ';
                    andBool = true; 
                }
            }
            
            if ( String.isNotBlank(cas.DS_App_Function__c) ) {
                if ( andBool )
                    strSOQL += ' OR DS_App_Function__c = \'' + String.escapeSingleQuotes(cas.DS_App_Function__c) + '\' ';
                else {
                    strSOQL += ' AND ( DS_App_Function__c = \'' + String.escapeSingleQuotes(cas.DS_App_Function__c) + '\' ';
                    andBool = true; 
                }
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
    
    public PageReference attachAndEmailCustomers() {
        CaseArticle CA = new CaseArticle();
        CA.CaseId = CaseId;
        CA.KnowledgeArticleId = selectedKnow;
        insert CA;
                
        List<DS_Customer_Details__c> emailList = new List<DS_Customer_Details__c>();
        emailList = [ SELECT Id, DS_Customer_Email__c, DS_Customer_Name__c, Name FROM DS_Customer_Details__c WHERE DS_Customer_Name__c =: CaseId ];

        Case caseInfo = [ SELECT Id, User_Assigned_To__r.Name, DS_Customer_Visible_Description__c, DS_Vendor_Product_cust__r.Name, CaseNumber, Description, Subject FROM Case WHERE Id =: CaseId ];  
          
        List < Messaging.SingleEmailMessage > listMsgs = new List < Messaging.SingleEmailMessage >();
        for(DS_Customer_Details__c ds : emailList) {
            if ( String.isNotBlank(ds.DS_Customer_Email__c) ) {
                List<String> emailstring = new List<String>();              
                emailstring.add(ds.DS_Customer_Email__c);
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setBCCAddresses(emailstring);
                String htmlBdy = ds.Name + ',<br/><br/>Your Requested IT ticket # ' + caseInfo.CaseNumber + '.<br/><br/>';
                htmlBdy += 'You called on: ' + cas.DS_Vendor_Product_cust__r.Name + '<br/>';
                htmlBdy += 'Ticket Description: ' + cas.Description + '<br/>';
                htmlBdy += 'Ticket Subject: ' + cas.Subject + '<br/>';
                htmlBdy += 'Ticket Assigned To: ' + cas.User_Assigned_To__r.Name + '<br/>';
                htmlBdy += 'Please check the below knowledge article.<br/><br/> ' + mapKnowledge.get(selectedKnow);
                m.setHTMLBody(htmlBdy);
                listMsgs.add(m);
            }
        }
        if ( listMsgs.size() > 0 ) {
            Messaging.sendEmail(listMsgs);
        }        
        
        return backToCase();        
    }
    
    public PageReference backToCase() {
        PageReference pg = new PageReference('/' + CaseId);
        pg.setRedirect(true);
        return pg;
    }
    
}