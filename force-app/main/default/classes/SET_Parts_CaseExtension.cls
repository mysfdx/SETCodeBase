/******************************************************************************************************************
    * Author:  Chandra Marthala
    * Process: Case
    * Purpose: Override Parts Case's edit page with custom page and auto populate/assign the multiple fields values from Case parent obj 
    *          i.e Product,subProduct and dealer.
    * Notes:   NA       
    * Modified By  : Chandra Marthala, Neha Agrawal
    * Modified Date : 05/05/2018, 09/03/2022
    * Purpose      : Removed reference of Sub Product and also not to pre-poluate Parts Category,
                     to use the dynamic lookup for account.
    *******************************************************************************************************************/
public class SET_Parts_CaseExtension {
   Public String CreatedByUser {get;set;}
   public List < Case > listRecentCases {get;set;} 
   public List < Case > listRecentCasesByUsername {get;set;} 
   public List < Case > listCriticalOpenCases {get;set;}
   public Case cas {get;set;}
   public DS_Product__c vendorProduct {get;set;}
   public String casStatus {get;set;}
   public Boolean caseDealerBool {get;set;}
   public List < Knowledge__kav > listKnowledge {get;set;}
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
   public String accountId{get;set;}
   
/*******************************************************************
   Purpose: Standard Controller Calls required methods to process required functionalities
   Parameters: None
   Returns: Constructor
   Throws : N/A                                                    
********************************************************************/
    
    public SET_Parts_CaseExtension(ApexPages.StandardController stdController) {
        webServiceDownBool = false;
        dealerNotFoundBool = false;
        caseDealerBool = true;
        casStatus = 'Open';
        cas = new Case();
        vendorProduct = new DS_Product__c();
        CreatedByUser = UserInfo.getName();
        CreatedByUser = CreatedByUser + '  ' + System.now();
        DS_Product__c p;
        List < DS_Product__c > listProds = [ SELECT Id FROM DS_Product__c WHERE Name LIKE 'PDC-VIN Restricted%' ORDER BY Id ASC ];
        
        if ( listProds.size() > 0 )
        p = listProds.get(0);

        if( p != null )
        cas.DS_Vendor_Product_cust__c = p.Id; 
        cas.DS_Vendor_Product_cust__c = null; 
        cas.DS_Requester_Type__c='Dealer';
        cas.DS_Time__c = '0';
        listRecentCases = new List < Case >();
        listCriticalOpenCases = new List < Case >();
        fetchRecentCases();
    }
    
    /*
    Purpose      : To show related cases for SET Parts Support Team
    */
    
public void fetchRecentCases() {
            Boolean andBool = false;
            listRecentCases = new List < Case >();
            listRecentCasesByUsername = new List < Case >();
            String strSubjectQuery = '';
            String strSOQL = 'SELECT Id, Priority, Status, CaseNumber, DS_Vendor_Product_cust__c, DS_Short_Description__c, DS_Customer_Name__c, CreatedDate, Subject,Comments__c,DS_Username__c,DS_Customer_Name_cust__c,Origin,DS_Support_Team__c,User_Assigned_To__c FROM CASE WHERE ';
            if ( String.isNotBlank(cas.DS_Vendor_Product_cust__c) ) {
                strSOQL += 'DS_Support_Team__c = \'SET Parts Support\' AND DS_Vendor_Product_cust__c = \'' + cas.DS_Vendor_Product_cust__c + '\' ';
                andBool = true;
            }
            if ( andBool )
                listCriticalOpenCases = Database.query(strSOQL + ' AND Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
            else 
                listCriticalOpenCases = Database.query(strSOQL + ' Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
            if ( String.isNotBlank(cas.Subject) ) {
                for ( String str : cas.Subject.split(' ') )
                    strSubjectQuery += 'Subject LIKE \'%' + String.escapeSingleQuotes(str)+ '%\' OR ';
                strSubjectQuery = strSubjectQuery.removeEnd('OR ');
                if (andBool)
                    strSOQL += 'AND ( ' + strSubjectQuery ;                         
                else
                    strSOQL += '( ' + strSubjectQuery;
                strSOQL += ' )';
            }
            if ( andBool ){
                listRecentCases = Database.query(strSOQL + 'AND Priority != \'Critical\' ORDER BY CreatedDate DESC  LIMIT 5');
            }
            else {
              if ( String.isNotBlank(cas.Subject) ) {

                listRecentCases = Database.query(strSOQL + 'AND Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');
                }
                
                else {

                listRecentCases = Database.query(strSOQL + ' Priority != \'Critical\' ORDER BY CreatedDate DESC LIMIT 5');

            }
            }
            fetchArticles();
    }
    
    /*

    Purpose      : To fetch related Knowledge Articles 
    */ 
    
    public void fetchArticles() {
                    listKnowledge = new List < Knowledge__kav >();
        if ( cas.DS_Vendor_Product_cust__c != null ) {
            String strSubjectQuery = '';
            String strSOQL = 'SELECT Id, KnowledgeArticleId, ArticleNumber, Title, DS_Product__c,  LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';            
            strSOQL += ' WHERE language=\'en_US\' AND publishstatus = \'online\' AND KnowledgeArticleId != null AND DS_Product__c = \'' + cas.DS_Vendor_Product_cust__c + '\'';
            if ( String.isNotBlank(cas.Subject) ) {
                for ( String str : cas.Subject.split(' ') )
                    strSubjectQuery += 'DS_Problem_Statement__c LIKE \'%' + String.escapeSingleQuotes(str)+ '%\' OR ';
                strSubjectQuery = strSubjectQuery.removeEnd('OR ');
                strSOQL += 'AND ( ' + strSubjectQuery + ' )';
            }
            strSOQL += ' LIMIT 5';
 /*           listKnowledge = new List < Knowledge__kav >();*/
            listKnowledge = Database.query(strSOQL);
        }
    }
    
    /*
    Purpose      : To redirect the user to the new case 
    */    
    
   public PageReference newCase() {
       system.debug('Account id is '+accountId);
       if(accountId==null && cas.DS_Requester_Type__c == 'Dealer'){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Dealer Code is required'));
           return null;
       }
       If(cas.Subject== null || cas.DS_Customer_Name_cust__c==null || cas.DS_Vendor_Product_cust__c==null){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                      'Subject, Customer Name & Parts Category are required'));
           return null;
       }
        Case newCaseToInsert = new Case();
        List < CaseArticle > listCaseArticlesToInsert = new List < CaseArticle >();
        DS_Customer_Details__c cust = new DS_Customer_Details__c();             
        if ( accountId != null ) {
            Account acc = new Account();
            List<Contact> ItConlist = new List<Contact>();
            List<Contact> DDAdmnConList = new List<Contact>();
            acc = [ SELECT Id, Name, Dealer_Code__c, District__c FROM Account WHERE Id =: accountId];
            ItConList = [ Select Id,Name,Phone,Email,Role__c from Contact where Role__c='IT Contact' and AccountId =: accountId ];
            DDAdmnConList = [ Select Id,Name,Phone,Email,Role__c from Contact where Role__c='DD System Admin' and AccountId =: accountId ];
            
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
            system.debug('Account id '+ accountId);
            newCaseToInsert.DS_Customer_Name__c = accountId;
            
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

        
        if ( cas.DS_Vendor_Product_cust__c != null ) {
            newCaseToInsert.DS_Vendor_Product_cust__c = cas.DS_Vendor_Product_cust__c;
        }
        
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
        
        
        if ( cas.Origin != null ) {
            newCaseToInsert.Origin = cas.Origin;
        }
              
        if ( String.isNotBlank(cas.DS_Requester_Type__c) && cas.DS_Requester_Type__c == 'Associate') {
            newCaseToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DS_Associate').getRecordTypeId();
        }
        
        newCaseToInsert.DS_Time_Entry_Mins__c = '5';        
        newCaseToInsert.DS_Support_Team__c = 'SET Parts Support';
        newCaseToInsert.Priority = 'Normal';  
        newCaseToInsert.Business_Unit__c = 'SET';
        newCaseToInsert.DS_LOB__c = 'SET';  
        newCaseToInsert.DS_Resolution__c = 'Resolved';  
        newCaseToInsert.Status = 'Closed';
        newCaseToInsert.User_Assigned_To__c = UserInfo.getUserId();
        newCaseToInsert.DS_Resolution_Category__c = 'Request for Help';
        
        try {
            insert newCaseToInsert;
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }        
        
        for ( Knowledge__kav k : listKnowledge) {
            if ( cas.DS_Vendor_Product_cust__c != null ) {
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
        System.debug('listCaseArticlesToInsert === ' + listCaseArticlesToInsert);
        try {
            if ( listCaseArticlesToInsert.size() > 0 )
                    insert listCaseArticlesToInsert;
            } catch(DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
        }        
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
            pg = new PageReference('/Apex/SET_Parts_Case_OverridePage');
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
    Purpose      : To fetch Customer Details from Active Directory using username 
    */  
    
    public void fetchCustomerDetails() {
        webServiceDownBool = false;
        dealWrap = null;
        Boolean ADCheckBool = false;
        listDealWrappers = new List < DealerWrapper >(); 
        Http http = new Http();
        String strAPIURL = 'callout:UserInfo/UserInfo';
        HttpRequest req = new HttpRequest();
        if ( String.isNotBlank(cas.DS_Username__c )) 
           strAPIURL += '?username=' + cas.DS_Username__c + '&spin=';
        req.setEndpoint(strAPIURL);
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setMethod('GET');
        req.setTimeOut(120000);
        HTTPResponse resultResp = http.send(req);
        system.debug('Output is ' + resultResp.getBody());
        if ( resultResp.getBody().equalsIgnoreCase('User not found') ) {
            applyDefaultValues();    
        } else if ( resultResp.getStatusCode() == 503 ) {
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
                        accountId = primaryDealerId;
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
        accountId = null;
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