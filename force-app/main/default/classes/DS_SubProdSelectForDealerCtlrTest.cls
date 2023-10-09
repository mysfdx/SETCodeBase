@isTest
private class DS_SubProdSelectForDealerCtlrTest {
    static testMethod void subProdTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subcategory;
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        DS_Product__c prod = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert prod;
        DS_Vendor_Product__c vendorProd = TestClientUtils.getVendorProd(vendor, prod, true);
        apexpages.currentpage().getparameters().put('subProdId', subcategory.Id);
        apexpages.currentpage().getparameters().put('acctId', newAccount.Id);
        apexpages.currentpage().getparameters().put('vendorId', vendor.Id);
        apexpages.currentpage().getparameters().put('prodId', prod.Id);
        DS_SubProdSelectForDealerCtlr obj = new DS_SubProdSelectForDealerCtlr();
        obj.listSelectedSubProduct = new List < DS_Subcategory__c > {subcategory};
        obj.filterSubProds();
        obj.selectSubProd();
        obj.nxt();
        obj.cncl();
    }
}