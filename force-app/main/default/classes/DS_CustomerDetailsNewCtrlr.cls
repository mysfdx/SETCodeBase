/* Name:  DS_CustomerDetailsNewCtrlr
Created By:  Magulan Duraipandian
Created Date:  2017-04-26
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CustomerDetailsNewCtrlr {
    
    public DS_Customer_Details__c custDetails {get;set;}
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
    public Id CaseId;
    Id custDetailsId = null;
    
    public DS_CustomerDetailsNewCtrlr(ApexPages.StandardController controller) {
        custDetailsId = controller.getId();
        if ( String.isNotBlank(custDetailsId) ) {
            custDetails = [ SELECT Name, Id, DS_Username__c, DS_Customer_Email__c, DS_Customer_Phone__c, DS_Primary_Dealer_Name__c, DS_SPIN__c FROM DS_Customer_Details__c WHERE Id =: custDetailsId ];
        } else {
            custDetails = new DS_Customer_Details__c();
        }
        system.debug(ApexPages.currentPage().getParameters());
        system.debug(ApexPages.currentPage().getParameters().get('CF00N46000008sJPe_lkid'));
        if ( ApexPages.currentPage().getParameters().get('CF00N46000008sJPe_lkid') != null ) {
            //CaseId = ApexPages.currentPage().getParameters().get('retURL').remove('/');
            CaseId = ApexPages.currentPage().getParameters().get('CF00N46000008sJPe_lkid');
        }
    }
    
    public void fetchCustomerDetails() {
        webServiceDownBool = false;
        dealWrap = null;
        Boolean ADCheckBool = false;
        listDealWrappers = new List < DealerWrapper >(); 
        Http http = new Http();
        String strAPIURL = 'callout:UserInfo/UserInfo';
        HttpRequest req = new HttpRequest();
        if ( String.isNotBlank(custDetails.DS_Username__c )) 
           strAPIURL += '?username=' + custDetails.DS_Username__c + '&spin=';
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
                        custDetails.DS_Primary_Dealer_Name__c = primaryDealerId;
                    }
                }
                custDetails.Name = strCustName;
                custDetails.DS_User_Id__c = strCustUserId;
                custDetails.DS_Customer_Phone__c = strCustPhone;
                custDetails.DS_Customer_Email__c = strCustEmail;
                custDetails.DS_SPIN__c = strSPIN; 
                dealerNotFoundBool = false;
            } else {
                applyDefaultValues();
            }
        }
    } 
    
    public void applyDefaultValues() {
        dealerNotFoundBool = true;
        dealWrap = null;
        custDetails.Name = '';
        custDetails.DS_SPIN__c = null;
        custDetails.DS_Customer_Email__c = '';
        custDetails.DS_Primary_Dealer_Name__c = null;
        custDetails.DS_Customer_Phone__c = '';
        String strSPIN = '';
        String strCustName = '';
        String strCustEmail = '';
        String strCustUserId = '';
        String strCustPhone = '';
    }
    
    public PageReference inserCust() {
        custDetails.DS_Customer_Name__c = CaseId;
        if ( String.isBlank(custDetailsId) )
            insert custDetails;
        else
            update custDetails;
        PageReference pg = new PageReference('/' + CaseId);
        pg.setRedirect(true);
        return pg;
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