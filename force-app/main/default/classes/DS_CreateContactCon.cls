/* Name:  DS_CreateContactCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateContactCon
{
    public String vendorOrProductId {get; set;}
    public DS_Contact__c DSContact {get; set;}
    Boolean IsVendor;
    public List<DS_Vendor__c> LstDSVendor { get; set; }
    
    public DS_CreateContactCon()
    {
        vendorOrProductId = ApexPages.currentPage().getParameters().get('Id');
        DSContact = new DS_Contact__c();
        
        if(ApexPages.currentPage().getParameters().containsKey('origin'))
        {
            IsVendor = true;
            LstDSVendor = [Select Name From DS_Vendor__c Where Id =:vendorOrProductId];
            if(!LstDSVendor.isEmpty())
                DSContact.Company_Name__c = LstDSVendor[0].Name;
        }
        else
            IsVendor = false;
    }
    
    public PageReference cancel()
    {
        PageReference page;
        
        if(IsVendor)
            page = new ApexPages.StandardController(new DS_Vendor__c(Id = vendorOrProductId)).view();
        else
            page = new ApexPages.StandardController(new DS_Vendor_Product__c(Id = vendorOrProductId)).view();
        
        return page;
    }


    public PageReference createNewContact()
    {
        insert DSContact;
        PageReference page;
        
        if(IsVendor)
        {
            DS_Vendor_Contact__c DSVendorContact = new DS_Vendor_Contact__c();
            DSVendorContact.Contact__c = DSContact.Id;
            DSVendorContact.Vendor__c = vendorOrProductId;
            insert DSVendorContact;
            page = new ApexPages.StandardController(new DS_Vendor__c(Id = vendorOrProductId)).view();
        }
        else
        {
            DS_Product_Contact__c dsProductContact = new DS_Product_Contact__c();
            dsProductContact.Contact__c = DSContact.Id;
            dsProductContact.Vendor_Product__c = vendorOrProductId;
            insert dsProductContact;
            page = new ApexPages.StandardController(new DS_Vendor_Product__c(Id = vendorOrProductId)).view();
        }
        
        return page;
    }
}