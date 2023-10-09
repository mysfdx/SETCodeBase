@isTest
private class DS_CreateNewSubCategoryCon_Test
{
    static testMethod void createNewSubCategoryConTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        ApexPages.currentPage().getParameters().put('pid', product.Id);
        DS_CreateNewSubCategoryCon objCreateNewSubCategoryCon = new DS_CreateNewSubCategoryCon();
        objCreateNewSubCategoryCon.saveCategory();
        objCreateNewSubCategoryCon.cancel();
        
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        DS_CreateNewSubCategoryCon createNewSubCategoryCon = new DS_CreateNewSubCategoryCon();
        createNewSubCategoryCon.saveCategory();
        createNewSubCategoryCon.cancel();
        
        PageReference pageRef = Page.DS_AllVendorInfo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aid', newAccount.Id);
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        ApexPages.currentPage().getParameters().put('pid', product.Id);
        DS_CreateNewSubCategoryCon newCreateNewSubCategoryCon = new DS_CreateNewSubCategoryCon();
        newCreateNewSubCategoryCon.saveCategory();
        newCreateNewSubCategoryCon.cancel();
    }
}