@isTest
private class DS_ContactCon_Test
{
    static testMethod void contactConTest()
    {
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Vendor_Product__c vendorProduct = new DS_Vendor_Product__c();
        vendorProduct.Product__c = product.Id;
        vendorProduct.Vendor__c = vendor.Id;
        insert vendorProduct;
        
        DS_Contact__c contact = TestClientUtils.getDSContact('TestFirstName', 'TestLastName', 'T@jm.com', '0987654321');
        insert contact;
        
        DS_Vendor_Contact__c vendorContact = new DS_Vendor_Contact__c();
        vendorContact.Contact__c = contact.Id;
        vendorContact.Vendor__c = vendor.Id;
        insert vendorContact;
        
        ApexPages.currentPage().getParameters().put('id', vendorProduct.id);
        DS_ContactCon contactCon = new DS_ContactCon();
        contactCon.createContact();
        contactCon.cancel();
        contactCon.createNewContact();
        //delete vendorContact;
        contactCon.DSVendorContact = vendorContact;
        contactCon.save();
        
        ApexPages.currentPage().getParameters().put('id', vendor.id);
        ApexPages.currentPage().getParameters().put('origin', 'yes');
        DS_ContactCon newContactCon = new DS_ContactCon();
        
        newContactCon.DSVendorContact = vendorContact;
        newContactCon.createContact();
        newContactCon.cancel();
        //newContactCon.save();
        newContactCon.createNewContact();
    }
}