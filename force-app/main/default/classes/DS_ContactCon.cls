/* Name:  DS_ContactCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_ContactCon
{
    public String VendorOrProductName {get; set;}
    public DS_Vendor_Contact__c DSVendorContact {get; set;}
    List<DS_Vendor__c> lstDSVendor;
    public DS_Contact__c DSContact {get; set;}
    public Boolean IsCreateContactShow {get; set;}
    String vendorOrProductId;
    public String vendorOrProductLbl {get; set;}
    List<DS_Vendor_Product__c> lstDSVendorProduct;
    
    public DS_ContactCon()
    {
        Boolean 
        IsCreateContactShow = false;
        VendorOrProductName = '-';
        vendorOrProductId = ApexPages.currentPage().getParameters().get('Id');
        if(ApexPages.currentPage().getParameters().containsKey('origin'))
            vendorOrProductLbl = 'Vendor';
        
        if(vendorOrProductLbl == 'Vendor')
        {
            lstDSVendor =[Select Id, Name from DS_Vendor__c where Id =:vendorOrProductId];
            VendorOrProductName = lstDSVendor[0].Name;
        }
        else
        {
            lstDSVendorProduct = [Select Id, Name from DS_Vendor_Product__c where Id =:vendorOrProductId];
            if(!lstDSVendorProduct.isEmpty())
                VendorOrProductName = lstDSVendorProduct[0].Name;
            vendorOrProductLbl = 'Vendor Product';
        }
        
        DSVendorContact = new DS_Vendor_Contact__c();
        DSContact = new DS_Contact__c();
    }
    
    public PageReference createContact()
    {
        if(DSVendorContact.Contact__c != null)
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error ,'You can’t create a New Contact if you have selected a Contact'); 
            ApexPages.addMessage(errMsg);
            return null;
        }
        else
            IsCreateContactShow = true;
        return null;
    }

    public PageReference cancel()
    {
        PageReference page;
        
        if(vendorOrProductLbl == 'Vendor')
        {
            page = new ApexPages.StandardController(new DS_Vendor__c(Id = vendorOrProductId)).view();
        }
        else
        {
            page = new ApexPages.StandardController(new DS_Vendor_Product__c(Id = vendorOrProductId)).view();
        }
        return page;
    }

    public PageReference save()
    {
        if(vendorOrProductLbl == 'Vendor')
        {
            DSVendorContact.Vendor__c = vendorOrProductId;
            insert DSVendorContact;
            PageReference page = new ApexPages.StandardController(new DS_Vendor__c(Id = vendorOrProductId)).view();
            return page;
        }
        else
        {
            DS_Product_Contact__c dsProductContact = new DS_Product_Contact__c();
            dsProductContact.Contact__c = DSVendorContact.Contact__c;
            dsProductContact.Vendor_Product__c = vendorOrProductId;
            insert dsProductContact;
            PageReference page = new ApexPages.StandardController(new DS_Vendor_Product__c(Id = vendorOrProductId)).view();
            return page;
        }
    }
    
    public PageReference createNewContact()
    {
        if(vendorOrProductLbl == 'Vendor')
        {
            PageReference page = new PageReference('/apex/DS_CreateContact?Id=' +lstDSVendor[0].Id+ '&origin=vendor');
            return page;
        }
        else
        {
            PageReference page = new PageReference('/apex/DS_CreateContact?Id='+lstDSVendorProduct[0].Id);
            return page;
        }
    }
}