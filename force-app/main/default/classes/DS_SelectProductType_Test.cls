@isTest
private class DS_SelectProductType_Test
{
    static testMethod void selectProductTypeTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_SelectProductType newSelectProductType = new DS_SelectProductType();
        newSelectProductType.next();
        
        PageReference pageRef = Page.DS_CreateNewVendor;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', newAccount.id);
        ApexPages.currentPage().getParameters().put('vid', vendor.id);
        DS_SelectProductType objSelectProductType = new DS_SelectProductType();
        
        objSelectProductType.next();
        objSelectProductType.cancel();
        objSelectProductType.getLstRecordType();
    }
}