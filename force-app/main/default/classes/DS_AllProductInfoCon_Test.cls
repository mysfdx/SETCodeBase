@isTest
private class DS_AllProductInfoCon_Test {

    static testMethod void allProductInfoConTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Product__c newProduct = TestClientUtils.getProduct('TestProduct1', 'Apps Services', 'CRM');
        insert newProduct;
        
        DS_Vendor_Product__c vendorProd = TestClientUtils.getVendorProd(vendor, newProduct, true);
        
        ApexPages.currentPage().getParameters().put('id', newAccount.id);
        ApexPages.currentPage().getParameters().put('vid', vendor.id);
        ApexPages.currentPage().getParameters().put('prod', 'yes');
        ApexPages.currentPage().getParameters().put('vendorid', newProduct.id);
        ApexPages.currentPage().getParameters().put('pName', 'TestProduct');
        ApexPages.currentPage().getParameters().put('subProd', 'yes');        
        DS_AllProductInfoCon objAllProductInfoCon = new DS_AllProductInfoCon();
        delete vendorProd;
        objAllProductInfoCon.searchProducts();
        objAllProductInfoCon.selectProduct();
        objAllProductInfoCon.cancel();
        objAllProductInfoCon.addProduct();
        objAllProductInfoCon.next();
    }
    
}