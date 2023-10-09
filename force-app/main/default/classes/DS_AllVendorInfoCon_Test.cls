@isTest
private class DS_AllVendorInfoCon_Test {

    static testMethod void allVendorInfoConTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_AllVendorInfoCon newAllVendorInfoCon = new DS_AllVendorInfoCon();
        newAllVendorInfoCon.addVendor();
        newAllVendorInfoCon.next();
        
        PageReference pageRef = Page.DS_AllVendorInfo;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', newAccount.id);
        ApexPages.currentPage().getParameters().put('vendorid', vendor.id);
        ApexPages.currentPage().getParameters().put('prod', 'yes');
        ApexPages.currentPage().getParameters().put('origin', 'vendor');
        ApexPages.currentPage().getParameters().put('vName', 'TestVendor');
        DS_AllVendorInfoCon objAllVendorInfoCon = new DS_AllVendorInfoCon();
        
        objAllVendorInfoCon.addVendor();
        objAllVendorInfoCon.selectVendor();
        objAllVendorInfoCon.cancel();
        objAllVendorInfoCon.searchVendors();
        objAllVendorInfoCon.next();
    }
    
}