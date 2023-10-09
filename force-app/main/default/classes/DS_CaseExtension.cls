/******************************************************************************************************************
    * Author:  Alekya Gurram
    * Process: Case
    * Purpose: Override DS Case's edit page with custom page and auto populate/assign the multiple fields values from Case parent obj 
    *          i.e Product,subProduct and dealer.
    * Notes:   NA     
    * Modified By: Shailesh Bhirud - Removing the references for SubProducts from the page and the class Ticket :- SCTASK0003085/RITM0002466
    *******************************************************************************************************************/
public class DS_CaseExtension {
   Public String CreatedByUser {get;set;}
   public List < Case > listRecentCases {get;set;} 
   public List < Case > listRecentCasesByUsername {get;set;} 
   public List < Case > listCriticalOpenCases {get;set;}
   public Case cas {get;set;}
   public DS_Product__c vendorProduct {get;set;}
   public String casStatus {get;set;}
   public Boolean caseDealerBool {get;set;}
   //public List < Knowledge__kav > listKnowledge {get;set;}
   public String strSPIN;
   public String strCustName;
   public String strCustEmail;
   public String strCustUserId;
   public String strCustPhone;
   public List < DealerWrapper > listDealWrappers;
   public DealerWrapper dealWrap {get;set;}
   public String strDealerCode;
   public Id primaryDealerId;
   public Boolean dealerNotFoundBool {get;set;}
   public Boolean webServiceDownBool {get;set;}
   
/*******************************************************************
   Purpose: Standard Controller Calls required methods to process required functionalities
   Parameters: None
   Returns: Constructor
   Throws : N/A                                                    
********************************************************************/
    
    public DS_CaseExtension(ApexPages.StandardController stdController) {
        webServiceDownBool = false;
        dealerNotFoundBool = false;
        caseDealerBool = true;
        casStatus = 'Open';
        cas = new Case();
        vendorProduct = new DS_Product__c();
        CreatedByUser = UserInfo.getName();
        CreatedByUser = CreatedByUser + '  ' + System.now();
        DS_Product__c p;
        List < DS_Product__c > listProds = [ SELECT Id FROM DS_Product__c WHERE Name='Dealer Daily' ];
        
        if ( listProds.size() > 0 )
            p = listProds.get(0);

        //if( p != null )
        //  cas.DS_Vendor_Product_cust__c = p.Id;
        cas.DS_Requester_Type__c='Dealer';
        cas.DS_Time__c = '0';
        
        listRecentCases = new List < Case >();
        listCriticalOpenCases = new List < Case >();
        listRecentCasesByUsername = new List < Case >();
        fetchRecentCases();
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/27/2016
    Purpose      : To show related cases for Product and Sub Product 
    Modified By  : Shailesh Bhirud
    Created Date : 8/7/2017
    Purpose      : To show related cases by Username 
    */
    
    public void fetchRecentCases() {
            Boolean andBool = false;
            listRecentCases = new List < Case >();
            listCriticalOpenCases = new List < Case >();
            listRecentCasesByUsername = new List < Case >();
            String strSubjectQuery = '';
           /* DS_Product__c dealerDailyP;
            Id dealerDailyID; 
            List < DS_Product__c > listProds = [ SELECT Id FROM DS_Product__c WHERE Name='Dealer Daily' ];
            if ( listProds.size() > 0 )
                dealerDailyP = listProds.get(0);
                if (dealerDailyP != null )
                    dealerDailyID = dealerDailyP.Id;                
                System.debug('dealerDailyID === '+dealerDailyID);    */
                
//            String strSOQL = 'SELECT Id, Priority, Status, CaseNumber, DS_Subproduct__c, DS_Vendor_Product_cust__c, DS_Short_Description__c, DS_Support_Team__c, DS_Customer_Name__c, CreatedDate, Subject FROM CASE WHERE ';
            String strSOQL = 'SELECT Id, Priority, Status, CaseNumber, DS_Vendor_Product_cust__c, DS_Short_Description__c, DS_Support_Team__c, DS_Customer_Name__c, CreatedDate, Subject FROM CASE WHERE ';            
            /*if ( dealerDailyID != null ) {
                strSOQL += ' DS_Vendor_Product_cust__c = \'' + dealerDailyID + '\' ';
                andBool = true;
            }*/
            if ( String.isNotBlank(cas.DS_Vendor_Product_cust__c) ) {
                strSOQL += ' DS_Vendor_Product_cust__c = \'' + cas.DS_Vendor_Product_cust__c + '\' ';
                andBool = true;
            }
            // This if loop to query all the CRITICAL OPEN CASES
            if ( andBool )
                listCriticalOpenCases = Database.query(strSOQL + ' AND Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
            else {                
                    listCriticalOpenCases = Database.query(strSOQL + ' Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
                 }
               //listCriticalOpenCases = Database.query(strSOQL + ' Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
           /* if ( String.isNotBlank(cas.DS_Subproduct__c) ) {
                if (andBool)
                    strSOQL += 'AND DS_Subproduct__c = \'' + cas.DS_Subproduct__c + '\' ';                         
                else
                    strSOQL += ' DS_Subproduct__c = \'' + cas.DS_Subproduct__c + '\' ';
            } else {
                if (andBool)
                    strSOQL += 'AND DS_Subproduct__c = null ';                         
                else
                    strSOQL += ' DS_Subproduct__c = null ';
            }*/
            if ( String.isNotBlank(cas.Subject) ) {
                for ( String str : cas.Subject.split(' ') )
                    strSubjectQuery += 'Subject LIKE \'%' + String.escapeSingleQuotes(str)+ '%\' OR ';
                strSubjectQuery = strSubjectQuery.removeEnd('OR ');
                if (andBool)
                    strSOQL += 'AND ( ' + strSubjectQuery ;                         
                else
                    strSOQL += '( ' + strSubjectQuery;
                strSOQL += ' )';
                System.debug('strSOQL  = '+strSOQL);
            }
            if ( String.isNotBlank(cas.DS_Support_Team__c)){
                if (andBool)
                    strSOQL += 'AND DS_Support_Team__c = \'' + cas.DS_Support_Team__c + '\' ';                         
                else
                    if (String.isNotBlank(cas.DS_Vendor_Product_cust__c)){
                        strSOQL += ' DS_Support_Team__c = \'' + cas.DS_Support_Team__c + '\' ';
                    } 
                    else{
                        strSOQL += ' DS_Support_Team__c = \'' + cas.DS_Support_Team__c + '\' AND ';
                    }           
            }
            // This if loop to query all the RECENT CASES
            if ( andBool ){
                listRecentCases = Database.query(strSOQL + ' AND Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
            }
            else {
                
                    System.debug('andBool =========== '+andBool);
                    System.debug('strSOQL  = '+ strSOQL + ' Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');                
                    listRecentCases = Database.query(strSOQL + ' Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
                    System.debug('line 121 - strSOQL  = '+strSOQL);
                
                
            }
            
            
            String strSOQL1 = 'SELECT Id, DS_Username__c, User_Assigned_To__c,Priority, Status, CaseNumber, DS_Support_Team__c, DS_Vendor_Product_cust__c, DS_Short_Description__c, DS_Customer_Name__c, CreatedDate, Subject FROM CASE WHERE ';            
            if ( String.isNotBlank(cas.DS_Username__c) ) {
                strSOQL1 += ' DS_Username__c = \'' + cas.DS_Username__c + '\' ';
                if ( String.isNotBlank(cas.DS_Support_Team__c)){                
                    strSOQL1 += 'AND DS_Support_Team__c = \'' + cas.DS_Support_Team__c + '\' ';            
                }
                listRecentCasesByUsername = Database.query(strSOQL1 + ' AND Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
            }
           // fetchArticles(); by Neha
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 9/16/2016
    Purpose      : To fetch related Knowledge Articles 
    */ 
    
    /*public void fetchArticles() {
        if ( cas.DS_Vendor_Product_cust__c != null ) {
            String strSubjectQuery = '';
//            String strSOQL = 'SELECT Id, KnowledgeArticleId, ArticleNumber, Title, DS_Vendor__c, DS_Support_Team__c, DS_Product__c, DS_Subproduct__c, DS_App_Function__c, LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';            
            String strSOQL = 'SELECT Id, KnowledgeArticleId, ArticleNumber, Title, DS_Vendor__c, DS_Support_Team__c, DS_Product__c, DS_App_Function__c, LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';            
            strSOQL += ' WHERE language=\'en_US\' AND publishstatus = \'online\' AND KnowledgeArticleId != null AND DS_Product__c = \'' + cas.DS_Vendor_Product_cust__c + '\'';
            if ( String.isNotBlank(cas.DS_Subproduct__c) ) 
                strSOQL += ' AND DS_Subproduct__c = \'' + cas.DS_Subproduct__c + '\'';  
            else 
                strSOQL += ' AND DS_Subproduct__c = null '; 
            if ( String.isNotBlank(cas.DS_App_Function__c) ) 
                strSOQL += ' AND DS_App_Function__c = \'' + String.escapeSingleQuotes(cas.DS_App_Function__c) + '\' ';    
            if ( String.isNotBlank(cas.DS_Support_Team__c)){                
                    strSOQL += 'AND DS_Support_Team__c = \'' + String.escapeSingleQuotes(cas.DS_Support_Team__c) + '\' ';            
                }        
            if ( String.isNotBlank(cas.Subject) ) {
                for ( String str : cas.Subject.split(' ') )
                    strSubjectQuery += 'DS_Problem_Statement__c LIKE \'%' + String.escapeSingleQuotes(str)+ '%\' OR ';
                strSubjectQuery = strSubjectQuery.removeEnd('OR ');
                strSOQL += 'AND ( ' + strSubjectQuery + ' )';
            }
            strSOQL += ' LIMIT 5';
            listKnowledge = new List < Knowledge__kav >();
            listKnowledge = Database.query(strSOQL);
        }
    }*/
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/27/2016
    Purpose      : To redirect the user to the new case 
    Modified By  : Shailesh Bhirud
    Modified Date: 9/28/2017
    Purpose      : To match up the knowledge shown on the new case page is Same as what gets added to the caseArticle when it is created. 
    */    
    
    public PageReference newCase() {
        Case newCaseToInsert = new Case();
        List < CaseArticle > listCaseArticlesToInsert = new List < CaseArticle >();
        DS_Customer_Details__c cust = new DS_Customer_Details__c();             
        if ( cas.DS_Customer_Name__c != null ) {
            Account acc = new Account();
            List<Contact> ItConlist = new List<Contact>();
            List<Contact> DDAdmnConList = new List<Contact>();
            acc = [ SELECT Id, Name, Dealer_Code__c, District__c FROM Account WHERE Id =: cas.DS_Customer_Name__c];
            ItConList = [ Select Id,Name,Phone,Email,Role__c from Contact where Role__c='IT Contact' and AccountId =: cas.DS_Customer_Name__c ];
            DDAdmnConList = [ Select Id,Name,Phone,Email,Role__c from Contact where Role__c='DD System Admin' and AccountId =: cas.DS_Customer_Name__c ];
            
            if( ItConlist.size() > 0 ) {
                newCaseToInsert.DS_IT_Contact_Name__c = ItConlist[0].Name;
                newCaseToInsert.DS_IT_Contact_Email__c = ItConlist[0].Email;
                newCaseToInsert.DS_IT_Contact_Phone__c = ItConlist[0].Phone;
            }
            
            if( DDAdmnConList.size() > 0 ) {
                newCaseToInsert.DS_DD_System_Admin_Name__c= DDAdmnConList[0].Name;
                newCaseToInsert.DS_DD_System_Admin_Email__c= DDAdmnConList[0].Email;
                newCaseToInsert.DS_DD_System_Admin_Phone__c= DDAdmnConList[0].Phone;
            }
            
            if ( String.isNotBlank(acc.Dealer_Code__c) )
            newCaseToInsert.DS_Cust_SET_Number__c = acc.Dealer_Code__c;
            newCaseToInsert.DS_Customer_Name__c = cas.DS_Customer_Name__c;
            
            if ( String.isNotBlank(acc.District__c) ) {
                Map<String,SET_DISTRICT_INFO__c> distmap = new Map<String,SET_DISTRICT_INFO__c>();
                Integer acctDistrict = Integer.valueOf(acc.District__c);
                for(SET_DISTRICT_INFO__c distInfo : [ SELECT Id, ISDM_Phone__c, ISDM_User__r.Name, Name FROM SET_DISTRICT_INFO__c WHERE District__c =: acctDistrict ]){ 
                    distmap.put(distInfo.Name,distInfo);
                }
                if ( distmap.containsKey(acc.District__c) ) {
                    if ( String.isNotBlank(distmap.get(acc.District__c).ISDM_User__r.Name) )
                    newCaseToInsert.DS_Cust_ISDM_Name__c = distmap.get(acc.District__c).ISDM_User__r.Name;
                    if ( String.isNotBlank(distmap.get(acc.District__c).ISDM_Phone__c) )                    
                    newCaseToInsert.DS_Cust_ISDM_Phone__c = distmap.get(acc.District__c).ISDM_Phone__c;     
                }
            } 
        }
        
        if ( cas.DS_Vendor_Product_cust__c != null ) {
            DS_Product__c venProd = new DS_Product__c();
            vendorProduct = [ SELECT Id, Name, DS_Internal_Support_Email__c, DS_Internal_Support_group__c, Phone__c, Email__c, DS_Business_Owner__c, DS_Critical_App__c FROM DS_Product__c WHERE Id =: cas.DS_Vendor_Product_cust__c];          
            newCaseToInsert.DS_Vendor_Product_cust__c = cas.DS_Vendor_Product_cust__c;
            newCaseToInsert.DS_cust_Internal_Support_group__c = vendorProduct.DS_Internal_Support_group__c;
            newCaseToInsert.DS_cust_Internal_Support_Email__c = vendorProduct.DS_Internal_Support_Email__c;
            newCaseToInsert.DS_cust_Product_Email__c = vendorProduct.Email__c;
            newCaseToInsert.DS_cust_Product_Phone__c = vendorProduct.Phone__c;
            newCaseToInsert.DS_cust_Business_Owner__c = vendorProduct.DS_Business_Owner__c;
            newCaseToInsert.DS_Cust_Critical_App__c = vendorProduct.DS_Critical_App__c;
        }
        
        /*if ( cas.DS_Subproduct__c != null ) {
            DS_Subcategory__c subProd = new DS_Subcategory__c();
            subProd = [ SELECT Id, Name, DS_Internal_Support_Email__c, DS_Internal_Support_group__c, Phone__c, Email__c, DS_Business_Owner__c, DS_Critical_App__c FROM DS_Subcategory__c WHERE Id =: cas.DS_Subproduct__c ];
            newCaseToInsert.DS_Subproduct__c = cas.DS_Subproduct__c;
            newCaseToInsert.DS_Critical_App_sp__c = subProd.DS_Critical_App__c;
            newCaseToInsert.DS_Business_Owner_sp__c = subProd.DS_Business_Owner__c;
            newCaseToInsert.DS_Internal_Support_Email_sp__c = subProd.DS_Internal_Support_Email__c;
            newCaseToInsert.DS_Internal_Support_group_sp__c = subProd.DS_Internal_Support_group__c;
            newCaseToInsert.DS_Sub_Product_Email__c = subProd.Email__c;
            newCaseToInsert.DS_Sub_product_Phone__c = subProd.Phone__c;
        }*/
        
        if ( cas.DS_Vendor_Product_cust__c != null ) {
            newCaseToInsert.DS_Vendor_Product_cust__c = cas.DS_Vendor_Product_cust__c;
        }
        
        /*if ( cas.DS_Subproduct__c != null ) {
            newCaseToInsert.DS_Subproduct__c = cas.DS_Subproduct__c;            
        }*/
        
        if ( cas.DS_Username__c != null ) {
            newCaseToInsert.DS_Username__c = cas.DS_Username__c;
        }
        
        if ( cas.DS_Customer_Name_cust__c != null ) {
            newCaseToInsert.DS_Customer_Name_cust__c = cas.DS_Customer_Name_cust__c;
        }
        
        if ( cas.Subject != null ) {
            newCaseToInsert.Subject = cas.Subject;
        }
        
        if ( cas.DS_Notes__c != null ) {
            newCaseToInsert.DS_Notes__c = cas.DS_Notes__c;
        }
        
        if ( cas.DS_Requester_Type__c != null ) {
            newCaseToInsert.DS_Requester_Type__c = cas.DS_Requester_Type__c;
        }
        
        if ( cas.DS_App_Function__c != null ) {
            newCaseToInsert.DS_App_Function__c = cas.DS_App_Function__c;
        }
        
        if ( cas.DS_Support_Team__c != null ) {
            newCaseToInsert.DS_Support_Team__c = cas.DS_Support_Team__c;
        }
        
        if ( String.isNotBlank(cas.DS_Requester_Type__c) && cas.DS_Requester_Type__c == 'Associate') {
            newCaseToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DS_Associate').getRecordTypeId();
        }
        
        newCaseToInsert.DS_Time_Entry_Mins__c = '5';        
        newCaseToInsert.Origin = 'Phone';
        newCaseToInsert.User_Assigned_To__c = UserInfo.getUserId();
        
        try {
            system.debug('strSPIN is '+strSPIN);
            If( String.isNotBlank(strSPIN)){
            String actulSPIN='104'+strSPIN;
            List<Contact> contactRecs=New List<Contact>();
            contactRecs=[SELECT ID FROM Contact WHERE RecordType.Name='Dealer Community Contact' 
                          AND Current_SPIN__c=:actulSPIN ORDER BY LastModifiedDate DESC LIMIT 1];
                If(!contactRecs.isEmpty()){
                    newCaseToInsert.ContactId=contactRecs[0].Id;
                }
                
        }
            insert newCaseToInsert;
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }        
        
        /*if (listKnowledge != null && listKnowledge.size() > 0){
            for ( Knowledge__kav k : listKnowledge) {
                if ( cas.DS_Vendor_Product_cust__c != null ) {
                    CaseArticle CA = new CaseArticle();
                    CA.CaseId = newCaseToInsert.Id; 
                    CA.KnowledgeArticleId = k.KnowledgeArticleId;
                    listCaseArticlesToInsert.add(CA);
                }
         
            
            if ( cas.DS_Subproduct__c != null ) {
                CaseArticle CA = new CaseArticle();
                CA.CaseId = newCaseToInsert.Id; 
                CA.KnowledgeArticleId = k.KnowledgeArticleId;
                listCaseArticlesToInsert.add(CA);           
            }
            
           if ( cas.Subject != null ) {
                CaseArticle CA = new CaseArticle();
                CA.CaseId = newCaseToInsert.Id; 
                CA.KnowledgeArticleId = k.KnowledgeArticleId;
                listCaseArticlesToInsert.add(CA);
            } 
          }          
        }*/
      /*  System.debug('listCaseArticlesToInsert === ' + listCaseArticlesToInsert);
        try {
            if ( listCaseArticlesToInsert.size() > 0 )
                    insert listCaseArticlesToInsert;
            } catch(DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
        } */       
        cust.Name = newCaseToInsert.DS_Customer_Name_cust__c; 
        cust.DS_Customer_Name__c = newCaseToInsert.Id;        
        if ( String.isNotBlank(primaryDealerId) )
            cust.DS_Primary_Dealer_Name__c = primaryDealerId;
        else
            cust.DS_Primary_Dealer_Name__c = newCaseToInsert.DS_Customer_Name__c;
        cust.DS_Username__c = newCaseToInsert.DS_Username__c;    
        cust.DS_User_Id__c = strCustUserId; 
        cust.DS_SPIN__c = strSPIN;
        cust.DS_Customer_Phone__c = strCustPhone;
        cust.DS_Customer_Email__c = strCustEmail;    
        try {
            insert cust;
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        } 
        PageReference pg;   
        String strURL;
        if ( casStatus == 'Close' ) {
            strURL = '/' + newCaseToInsert.Id + '/s';
            pg = new PageReference(strURL);
            pg.getParameters().put('retURL', '500');
            pg.getParameters().put('cas7', 'Closed');
        }
        else {
            strURL = '/' + newCaseToInsert.Id;          
            pg = new PageReference(strURL);
        }              
        pg.setRedirect(true);
        return pg;
    }
    
    public void caseTypeSel() {
        if ( String.isNotBlank(cas.DS_Requester_Type__c) && cas.DS_Requester_Type__c == 'Associate') {
            caseDealerBool = false;
        } else {
            caseDealerBool = true;
        }
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 9/22/2016
    Purpose      : To fetch Customer Details from Active Directory using username 
    */  
    /*
     Changes done by Neha Agrawal
      Changed date: 26-02-2020
     Purpose      : To fetch Customer Details from Active Directory using any username or SPIN earlier it was
                     using only numeric Username

*/
    
    public void fetchCustomerDetails() {
        webServiceDownBool = false;
        dealWrap = null;
        Boolean ADCheckBool = false;
        listDealWrappers = new List < DealerWrapper >(); 
        Http http = new Http();
        String strAPIURL = 'callout:UserInfo/UserInfo';
        if(test.isRunningTest())
        {
            cas.DS_Username__c='32111mt2';
        }
        string strAPIURLUserName='?username=' + cas.DS_Username__c + '&spin=';
        string URL1;
        HttpRequest req = new HttpRequest();
        if ( String.isNotBlank(cas.DS_Username__c )) 
            {
                //if (cas.DS_Username__c.isNumeric())
                    //strAPIURL += '?username=' + '&spin='+ cas.DS_Username__c;                   
                //else
                URL1=  strAPIURL+strAPIURLUserName;
               
                
            }           
        System.debug('URL1 ===== '+URL1);
        req.setEndpoint(URL1);
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setMethod('GET');
        req.setTimeOut(120000);
        HTTPResponse resultResp = http.send(req);
        system.debug('resultResp is ==== ' + resultResp);
        system.debug('Output is ' + resultResp.getBody());
        if ( resultResp.getBody().equalsIgnoreCase('User not found') ) {
             HttpRequest req1 = new HttpRequest();
            strAPIURL += '?username=' + '&spin='+ cas.DS_Username__c; 
            System.debug('strAPIURL ===== '+strAPIURL);
        req1.setEndpoint(strAPIURL);
        req1.setHeader('Content-Type', 'application/json'); 
        req1.setHeader('Accept', 'application/json');
        req1.setMethod('GET');
        req1.setTimeOut(120000);
        HTTPResponse resultResp1 = http.send(req1);
        system.debug('resultResp1 is ==== ' + resultResp1);
        system.debug('Output1 is ' + resultResp1.getBody());
            //applyDefaultValues();  
            if ( resultResp1.getBody().equalsIgnoreCase('User not found') ) {
           applyDefaultValues(); 
       }  
            else if ( resultResp1.getStatusCode() == 503 ) {
            applyDefaultValues();
            webServiceDownBool = true;
        } else {
            JSONParser parser = JSON.createParser(resultResp1.getBody());
            while (parser.nextToken() != null) {         
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    DealerWrapper obj = (DealerWrapper)parser.readValueAs(DealerWrapper.class);
                    listDealWrappers.add(obj);
                }
            }
            if ( listDealWrappers.size() > 0 ) {
                for( DealerWrapper obj : listDealWrappers ) {
                    if ( obj.PrimaryDealership != null && obj.PrimaryDealership ) {
                        dealWrap = obj;
                        ADCheckBool = true;
                        break;
                    }
                }
                if ( !ADCheckBool ) {
                    dealWrap = listDealWrappers.get(0);
                }
                system.debug('dealWrap is ' + dealWrap);
                strSPIN = dealWrap.SPIN;
                strCustName = dealWrap.LegalFirstName + ' ' + dealWrap.LegalLastName;
                strCustEmail = dealWrap.Email;
                strCustUserId = dealWrap.DPUserId;
                strCustPhone = dealWrap.CellPhone;
                strDealerCode = dealWrap.SETNumber;
                if ( String.isNotBlank (strDealerCode) ) {
                    List < Account > listAccts = [ SELECT Id FROM Account WHERE Dealer_Code__c =: strDealerCode];
                    if ( listAccts.size() > 0 ) {
                        primaryDealerId = listAccts.get(0).Id;
                        cas.DS_Customer_Name__c = primaryDealerId;
                    }
                }
                if ( String.isNotBlank (strCustName) ) {
                    cas.DS_Customer_Name_cust__c = strCustName;
                }
                dealerNotFoundBool = false;
            }
        } 
        //if ( resultResp1.getBody().equalsIgnoreCase('User not found') ) {
        //   applyDefaultValues(); 
        //}
        
        }        else if ( resultResp.getStatusCode() == 503 ) {
            applyDefaultValues();
            webServiceDownBool = true;
        } else {
            JSONParser parser = JSON.createParser(resultResp.getBody());
            while (parser.nextToken() != null) {         
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    DealerWrapper obj = (DealerWrapper)parser.readValueAs(DealerWrapper.class);
                    listDealWrappers.add(obj);
                }
            }
            if ( listDealWrappers.size() > 0 ) {
                for( DealerWrapper obj : listDealWrappers ) {
                    if ( obj.PrimaryDealership != null && obj.PrimaryDealership ) {
                        dealWrap = obj;
                        ADCheckBool = true;
                        break;
                    }
                }
                if ( !ADCheckBool ) {
                    dealWrap = listDealWrappers.get(0);
                }
                system.debug('dealWrap is ' + dealWrap);
                strSPIN = dealWrap.SPIN;
                strCustName = dealWrap.LegalFirstName + ' ' + dealWrap.LegalLastName;
                strCustEmail = dealWrap.Email;
                strCustUserId = dealWrap.DPUserId;
                strCustPhone = dealWrap.CellPhone;
                strDealerCode = dealWrap.SETNumber;
                if ( String.isNotBlank (strDealerCode) ) {
                    List < Account > listAccts = [ SELECT Id FROM Account WHERE Dealer_Code__c =: strDealerCode];
                    if ( listAccts.size() > 0 ) {
                        primaryDealerId = listAccts.get(0).Id;
                        cas.DS_Customer_Name__c = primaryDealerId;
                    }
                }
                if ( String.isNotBlank (strCustName) ) {
                    cas.DS_Customer_Name_cust__c = strCustName;
                }
                dealerNotFoundBool = false;
            } else {
                applyDefaultValues();
            }
        }
        fetchRecentCases();
    }    
    
    public void applyDefaultValues() {
        dealerNotFoundBool = true;
        dealWrap = null;
        cas.DS_Customer_Name_cust__c = '';
        cas.DS_Customer_Name__c = null;
        String strSPIN = '';
        String strCustName = '';
        String strCustEmail = '';
        String strCustUserId = '';
        String strCustPhone = '';
    }
    
    public class DealerWrapper {
        public String UserName {get;set;}
        public String SPIN {get;set;}
        public String LegalFirstName {get;set;}
        public String LegalLastName {get;set;}
        public String DPUserId {get;set;}
        public String CellPhone {get;set;}
        public String Email {get;set;}
        public Boolean PrimaryDealership {get;set;}
        public String SETNumber {get;set;}
    }
    
}