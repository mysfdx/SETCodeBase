/******************************************************************************************************************
* Author:  Joshua Hunt
* Process: Case
* Notes:   NA       
* Modified By  : Joshua Hunt
* Modified Date : 11/16/2022
* Purpose      : Allow for distribution team to log calls using custom VF page.
*******************************************************************************************************************/
public class SET_Distribution_Call_Log_Extension {
    Public String CreatedByUser {get;set;}
    public List < Case > listRecentCases {get;set;} 
    public List<VIN__c> vinList { get; set; }
    public List < Case > listRecentCasesByUsername {get;set;} 
    public List < Case > listCriticalOpenCases {get;set;}
    public Case cas {get;set;}
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
    public Integer vinIndex {get; set;}
    public Boolean dealerNotFoundBool {get;set;}
    public Boolean webServiceDownBool {get;set;}
    public String accountId{get;set;}
    //public Case newCaseToInsert;
    public String buttonChosen {get; set;}
   
    
    public SET_Distribution_Call_Log_Extension(ApexPages.StandardController stdController) {
        vinList=new List<VIN__c>();
        VIN__c fisrtVin=new VIN__c();
        vinList.add(fisrtVin);
        webServiceDownBool = false;
        dealerNotFoundBool = false;
        caseDealerBool = true;
        casStatus = 'Open';
        cas = new Case();
        CreatedByUser = UserInfo.getName();
        CreatedByUser = CreatedByUser + '  ' + System.now();
        
        cas.DS_Time__c = '0';
        listRecentCases = new List < Case >();
        listCriticalOpenCases = new List < Case >();
        fetchRecentCases();
    }
    Public void addVinRow()
    {
        VIN__c v = new VIN__c();
        vinList.add(v);
    }
    public void removeVin(){
        vinIndex=Integer.valueOf(ApexPages.currentPage().getParameters().get('vinIndex'));
        vinList.remove(vinIndex);  
    }
    /*
Purpose      : To show related cases for SET Distribution Team
*/
    
    public void fetchRecentCases() {
        Boolean andBool = false;
        listRecentCases = new List < Case >();
        listRecentCasesByUsername = new List < Case >();
        String strSubjectQuery = '';
        String strSOQL = 'SELECT Id, Priority, Status, CaseNumber,SET_District__c, DS_Short_Description__c, DS_Customer_Name__c, CreatedDate, Subject,Comments__c,DS_Username__c,DS_Customer_Name_cust__c,AccountId,Origin,DS_Support_Team__c,User_Assigned_To__c FROM CASE WHERE ';
        /*if {strSOQL += 'SET_Distribution_Case = \'0127j000000D136AAC\'; andBool = true; }
if ( andBool )
listCriticalOpenCases = Database.query(strSOQL + ' AND Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate ASC LIMIT 20');
else 
listCriticalOpenCases = Database.query(strSOQL + ' Status != \'Closed\' AND Priority = \'Critical\' ORDER BY CreatedDate ASC LIMIT 20');*/
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
            listRecentCases = Database.query(strSOQL + 'AND Priority != \'Critical\' ORDER BY CreatedDate ASC  LIMIT 20');
        }
        else {
            if ( String.isNotBlank(cas.Subject) ) {
                
                listRecentCases = Database.query(strSOQL + 'AND Priority != \'Critical\' ORDER BY CreatedDate ASC LIMIT 20');
            }
            
            else {
                
                listRecentCases = Database.query(strSOQL + ' Priority != \'Critical\' ORDER BY CreatedDate ASC LIMIT 20');
                
            }
        }
        //fetchArticles();
    }
    
    /*

Purpose      : To fetch related Knowledge Articles 
*/ 
    
    /*public void fetchArticles() {
listKnowledge = new List < Knowledge__kav >();
if ( cas.DS_Vendor_Product_cust__c != null ) {
String strSubjectQuery = '';
String strSOQL = 'SELECT Id, KnowledgeArticleId, ArticleNumber, Title, DS_Product__c,  LastModifiedDate, CreatedBy.Name, Summary FROM Knowledge__kav';            
strSOQL += ' WHERE language=\'en_US\' AND publishstatus = \'online\' AND KnowledgeArticleId != null ';
if ( String.isNotBlank(cas.Subject) ) {
for ( String str : cas.Subject.split(' ') )
strSubjectQuery += 'cas.Subject LIKE \'%' + String.escapeSingleQuotes(str)+ '%\' OR ';
strSubjectQuery = strSubjectQuery.removeEnd('OR ');
strSOQL += 'AND ( ' + strSubjectQuery + ' )';
}
strSOQL += ' LIMIT 20';
// listKnowledge = new List < Knowledge__kav >();
listKnowledge = Database.query(strSOQL);
}
}*/
    
    /*
Purpose      : To redirect the user to the new case 
*/    
    
    public PageReference newCase() {
        system.debug('Account id is '+accountId);
        if(accountId==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Dealer Code is required'));
            return null;
            
        }
        If(cas.Subject== null || cas.Parts_Category__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                       'Subject & Call Category are required'));
            return null;
        }
        If(cas.Parts_Category__c=='Sold Order' && cas.Sales_Person_Email__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                       'For Sold Order request, Sales Person Email is required'));
            return null; 
        }
        If(cas.Parts_Category__c=='Other' && cas.Other_Distribution_Category__c==null){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                      'Other Category is required'));
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
        
        if(!Test.isRunningTest()){
            newCaseToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SET_Distribution_Case').getRecordTypeId();
        }
        newCaseToInsert.Type=cas.Type;
        newCaseToInsert.Parts_Category__c=cas.Parts_Category__c;
        if ( cas.Sales_Person_Email__c != null ) {
            newCaseToInsert.Sales_Person_Email__c=cas.Sales_Person_Email__c;
        }
        if ( cas.Other_Distribution_Category__c != null ) {
            newCaseToInsert.Other_Distribution_Category__c = cas.Other_Distribution_Category__c;
        }
        newCaseToInsert.AccountId=accountId;
        newCaseToInsert.Priority = 'Normal';  
        newCaseToInsert.Business_Unit__c = 'SET';
        newCaseToInsert.DS_LOB__c = 'SET';  
        newCaseToInsert.DS_Resolution__c = 'Resolved';  
        newCaseToInsert.Status = 'In Progress';
        newCaseToInsert.User_Assigned_To__c = UserInfo.getUserId();
        
        
        try {
            insert newCaseToInsert;
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }        
        
        /*for ( Knowledge__kav k : listKnowledge) {
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
System.debug('listCaseArticlesToInsert === ' + listCaseArticlesToInsert);*/
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
        system.debug('buttonChosen '+buttonChosen);
        if ( buttonChosen == 'Save_New' ) {	
            strURL ='/apex/SET_Distribution_Call_Log';
            pg = new PageReference(strURL);
            //pg = ApexPages.currentPage();
            //pg.getParameters().put('retURL', '500');	
            //pg.getParameters().put('cas7', 'Closed');	
        }	
        else if (buttonChosen == 'Save_Details'){	
            strURL = '/' + newCaseToInsert.Id;          	
            pg = new PageReference(strURL);
        }              	
        pg.setRedirect(true);	
        return pg;
    }
    /*public PageReference saveAndNew() {
        PageReference newPG;   
       // newPG = newCase('SAVE_NEW');
        system.debug('newPG '+newPG);
        newPG.setRedirect(true);  
        return newPG;
    }
    
    public PageReference saveAndDetails() {
        PageReference dtlPG;   
       // dtlPG =  newCase('SAVE_DETAILS');
        system.debug('dtlPG '+dtlPG);
        dtlPG.setRedirect(true);  
        return dtlPG;
    }*/
    
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