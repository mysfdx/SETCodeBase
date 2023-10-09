@isTest
private class DS_AllSubCategoryCon_Test {

    static testMethod void allSubCategoryConTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Product__c newProduct = TestClientUtils.getProduct('TestProduct1', 'Apps Services', 'CRM');
        insert newProduct;
        
        DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subcategory;
        
        DS_Subcategory__c newSubcategory = TestClientUtils.getSubcategory('TestNewCategory', 'CRM');
        insert newSubcategory;
        
        DS_Vendor_Product__c vendorProduct = new DS_Vendor_Product__c();
        vendorProduct.Product__c = product.Id;
        vendorProduct.Vendor__c = vendor.Id;
        insert vendorProduct;
        
        DS_Product_Subcategory__c productSubcategory = new DS_Product_Subcategory__c();
        productSubcategory.Product__c = product.Id;
        productSubcategory.Subcategory__c = subcategory.Id;
        insert productSubcategory;
        
        PageReference pageRef = Page.DS_AllSubCategory;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(productSubcategory);
        ApexPages.currentPage().getParameters().put('aId', newAccount.id);
        ApexPages.currentPage().getParameters().put('vId', vendor.id);
        ApexPages.currentPage().getParameters().put('categoryId', subcategory.Id);
        ApexPages.currentPage().getParameters().put('pId', product.id);
        ApexPages.currentPage().getParameters().put('cName', subcategory.Name);
        DS_AllSubCategoryCon objAllSubCategoryCon = new DS_AllSubCategoryCon(sc);
        
        objAllSubCategoryCon.initAllCategory();
        objAllSubCategoryCon.addCategory();
        objAllSubCategoryCon.cancel();
        objAllSubCategoryCon.selectCategory();
        objAllSubCategoryCon.next();
        objAllSubCategoryCon.searchCategory();
        objAllSubCategoryCon.next();
        objAllSubCategoryCon.LstDSSubcategory = new List<DS_Subcategory__c>();
        objAllSubCategoryCon.LstDSSubcategory.add(newSubcategory);
        objAllSubCategoryCon.next();
    }
    
}