@isTest
private class DS_CreateProductExt_Test
{
    static testMethod void createProductExtTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        
        List<RecordType> lstAppsServicesRecordType = [Select Id From RecordType Where Name = 'Apps Services' AND SobjectType = 'DS_Product__c'];
        ApexPages.currentPage().getParameters().put('type', lstAppsServicesRecordType[0].Id);
        ApexPages.Standardcontroller scho = new ApexPages.Standardcontroller(new DS_Product__c());
        DS_CreateProductExt objCreateProductExt1 = new DS_CreateProductExt(scho);
        objCreateProductExt1.next();
        
        DS_Product__c newProduct = TestClientUtils.getProduct('TestNewProduct', 'Apps Services', 'CRM');
        List<RecordType> lstHardwareRecordType = [Select Id From RecordType Where Name = 'Hardware' AND SobjectType = 'DS_Product__c'];
        ApexPages.currentPage().getParameters().put('type', lstHardwareRecordType[0].Id);
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        ApexPages.Standardcontroller sch = new ApexPages.Standardcontroller(newProduct);
        DS_CreateProductExt objCreateProductExt = new DS_CreateProductExt(sch);
        objCreateProductExt.next();
        
        List<RecordType> lstRecordType = [Select Id From RecordType Where Name = 'Data Connection' AND SobjectType = 'DS_Product__c'];
        ApexPages.currentPage().getParameters().put('aid', newAccount.Id);
        ApexPages.currentPage().getParameters().put('type', lstRecordType[0].Id);
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(product);
        DS_CreateProductExt createProductExt = new DS_CreateProductExt(sc);
        createProductExt.next();
        createProductExt.prev();
    }
}