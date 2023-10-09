@isTest
private class DS_CreateContactCon_Test
{
    static testMethod void createContactConTest()
    {
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Vendor_Product__c vendorProduct = new DS_Vendor_Product__c();
        vendorProduct.Product__c = product.Id;
        vendorProduct.Vendor__c = vendor.Id;
        insert vendorProduct;
        
        DS_Vendor__c vendor1 = TestClientUtils.getVendor('NewVendor');
        insert vendor1;
        
        DS_Product__c product1 = TestClientUtils.getProduct('NewProduct', 'Data Connection', 'DSM');
        insert product1;
        
        DS_Vendor_Product__c vendorProduct1 = new DS_Vendor_Product__c();
        vendorProduct1.Product__c = product1.Id;
        vendorProduct1.Vendor__c = vendor1.Id;
        insert vendorProduct1;
        
        ApexPages.currentPage().getParameters().put('id', vendorProduct.id);
        DS_CreateContactCon newCreateContactCon = new DS_CreateContactCon();
        
        DS_Contact__c newContact = TestClientUtils.getDSContact('TestFirstName1', 'TestLastName1', 'T1@jm.com', '0187654321');
        newCreateContactCon.DSContact = newContact;
        newCreateContactCon.createNewContact();
        newCreateContactCon.cancel();
        
        PageReference pageRef = Page.DS_CreateContact;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', vendor.id);
        ApexPages.currentPage().getParameters().put('origin', 'vendor');
        DS_CreateContactCon objCreateContactCon = new DS_CreateContactCon();
        
        DS_Contact__c contact = TestClientUtils.getDSContact('TestFirstName', 'TestLastName', 'T@jm.com', '0987654321');
        objCreateContactCon.DSContact = contact;
        objCreateContactCon.createNewContact();
        objCreateContactCon.cancel();
    }
}