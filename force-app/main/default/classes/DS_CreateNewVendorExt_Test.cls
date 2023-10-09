@isTest
private class DS_CreateNewVendorExt_Test
{
    static testMethod void createNewVendorExtTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        //insert vendor;
        
        PageReference pageRef = Page.DS_CreateNewVendor;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aId', newAccount.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vendor);
        DS_CreateNewVendorExt objCreateNewVendorExt = new DS_CreateNewVendorExt(sc);
        
        objCreateNewVendorExt.createNewVendor();
        objCreateNewVendorExt.cancel();
        ApexPages.currentPage().getParameters().put('origin', 'vendorPage');
        ApexPages.Standardcontroller sch = new ApexPages.Standardcontroller(new DS_Vendor__c());
        DS_CreateNewVendorExt newCreateNewVendorExt = new DS_CreateNewVendorExt(sch);
        newCreateNewVendorExt.createNewVendor();
    }
}