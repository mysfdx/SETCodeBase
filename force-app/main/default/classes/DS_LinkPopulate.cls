/* Name:  DS_LinkPopulate
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_LinkPopulate {
    public DS_Link__c linkRec {get;set;}
    public String VendorName {get; set;}
    public String LabelName {get; set;}
    Id subProdId;
    
    public DS_LinkPopulate(ApexPages.StandardController stdController) {    
        ID recID = stdController.getID();
        if (recID == null) {
            linkRec = new DS_Link__c();
        }
        else {
            //it is an edit                     
            linkRec = [ SELECT ID,Product__c, Product__r.Name, Vendor__c, Vendor__r.Name,Account__c, Account__r.Name, Data_URL__c,Name, User_ID__c, Password__c, 
                        IP__c, DS_Dealer_Product__c, DS_Dealer_Subproduct__c, DS_Note__c 
                        FROM DS_Link__c 
                        WHERE id=:recID];
            if(String.isNotBlank(linkRec.Product__c)) {
                VendorName = linkRec.Product__r.Name;
                LabelName = 'Product';
            }
            else if(String.isNotBlank(linkRec.Vendor__c))
            {
                VendorName = linkRec.Vendor__r.Name;
                LabelName = 'Vendor';
            }
            /*else if(String.isNotBlank(linkRec.Group__c))
            {
            VendorName = linkRec.Group__r.Name;
            LabelName = 'Group';
            }*/
            else if(String.isNotBlank(linkRec.Account__c)) {
                VendorName = linkRec.Account__r.Name;
                LabelName = 'Dealer';
            }
        }
        
        
        if ( String.isNotBlank(ApexPages.currentPage().getParameters().get('lId')) ) {
            List<DS_Vendor__c> lstDSVendor = [Select Name from DS_Vendor__c where Id =:ApexPages.currentPage().getParameters().get('lId')];
            VendorName = lstDSVendor[0].Name;
            linkRec.Vendor__c = ApexPages.currentPage().getParameters().get('lId');
            //dispVendor = true;
            LabelName = 'Vendor';
        }
        else if ( String.isNotBlank(ApexPages.currentPage().getParameters().get('pId')) ) {
            List<DS_Product__c> lstDSProduct =[Select Id, Name from DS_Product__c where Id =:ApexPages.currentPage().getParameters().get('pId')];
            VendorName = lstDSProduct[0].Name;
            linkRec.Product__c = ApexPages.currentPage().getParameters().get('pId');
            //dispVendor = true;
            LabelName = 'Product';
        }
        /*else if(String.isNotBlank(ApexPages.currentPage().getParameters().get('gId')))
        {
        List<DS_Group__c> lstDSGroup = [Select Name from DS_Group__c where Id =:ApexPages.currentPage().getParameters().get('gId')];
        VendorName = lstDSGroup[0].Name;
        linkRec.Group__c = ApexPages.currentPage().getParameters().get('gId');
        //dispVendor = true;
        LabelName = 'Group';
        }*/
        
        else if ( String.isNotBlank(ApexPages.currentPage().getParameters().get('aId')) ) {
            List<Account> lstAccount = [Select Name from Account where Id =:ApexPages.currentPage().getParameters().get('aId')];
            VendorName = lstAccount[0].Name;
            linkRec.Account__c = ApexPages.currentPage().getParameters().get('aId');
            //dispVendor = true;
            LabelName = 'Account';
        } else if ( String.isNotBlank(ApexPages.currentPage().getParameters().get('dealerProdId')) ) {
            Id dealerProdId = ApexPages.currentPage().getParameters().get('dealerProdId');
            linkRec.DS_Dealer_Product__c = dealerProdId;
            DS_Dealer_Product__c dealerProd = [ SELECT Id, Name FROM DS_Dealer_Product__c WHERE Id =: dealerProdId];
            VendorName = dealerProd.Name;
            LabelName = 'Dealer Product';
        } else if ( String.isNotBlank(ApexPages.currentPage().getParameters().get('dealerSubProdId')) ) {
            Id dealerSubProdId = ApexPages.currentPage().getParameters().get('dealerSubProdId');
            linkRec.DS_Dealer_Subproduct__c = dealerSubProdId;
            Dealer_Product_Subproduct__c dealerSubProd = [ SELECT Id, DS_Dealer_Product_Subproduct_Name__c FROM Dealer_Product_Subproduct__c WHERE Id =: dealerSubProdId];
            VendorName = dealerSubProd.DS_Dealer_Product_Subproduct_Name__c;
            LabelName = 'Dealer Sub Product';
        }
        String returnURL = ApexPages.currentPage().getParameters().get('retURL');
        if ( String.isNotBlank(returnURL) ) {
            if ( ! returnURL.contains('apex') ) {
                returnURL = returnURL.remove('/');
                Id recordId = returnURL;
                if ( String.valueOf(recordId.getSobjectType()) == 'DS_Subcategory__c' ) {
                    subProdId = returnURL;
                }
            }
        }
    }

    public pageReference saveDate() {        
        if ( linkRec.ID == null ) {
            if ( String.isNotBlank(subProdId) )
                linkRec.DS_Subproduct__c = subProdId;
            insert linkRec;
        }
        else {
            update linkRec;
        }   
        
        if(linkRec.Vendor__c !=null) {
            Pagereference pgRef=new Pagereference('/' + linkRec.Vendor__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.Product__c !=null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.Product__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        /*if(linkRec.Group__c !=null){
        Pagereference pgRef=new Pagereference('/' + linkRec.Group__c);
        pgRef.setRedirect(true);
        return pgRef;
        }*/
        
        if ( linkRec.Account__c != null ) {
            Pagereference pgRef = new Pagereference('/' + linkRec.Account__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( String.isNotBlank(subProdId) ) {
            Pagereference pgRef=new Pagereference('/' + subProdId);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.DS_Dealer_Product__c != null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.DS_Dealer_Product__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.DS_Dealer_Subproduct__c != null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.DS_Dealer_Subproduct__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        return null;
    }
     
    public pageReference doCancel() {
        if ( linkRec.Vendor__c != null ) {
            Pagereference pgRef = new Pagereference('/' + linkRec.Vendor__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.Product__c != null ) {
            Pagereference pgRef = new Pagereference('/' + linkRec.Product__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        /*if(linkRec.Group__c !=null){
        Pagereference pgRef=new Pagereference('/' + linkRec.Group__c);
        pgRef.setRedirect(true);
        return pgRef;
        }*/
        
        if ( linkRec.Account__c !=null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.Account__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( String.isNotBlank(subProdId) ) {
            Pagereference pgRef=new Pagereference('/' + subProdId);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.DS_Dealer_Product__c != null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.DS_Dealer_Product__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        if ( linkRec.DS_Dealer_Subproduct__c != null ) {
            Pagereference pgRef=new Pagereference('/' + linkRec.DS_Dealer_Subproduct__c);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
        return null;    
    }
}