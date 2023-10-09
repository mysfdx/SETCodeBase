@isTest
private class DS_CreateDealerProductCon_Test {
    static testMethod void createDealerProductConTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Product__c hardwareProduct = TestClientUtils.getProduct('TestProduct1', 'Hardware', 'DSM');
        insert hardwareProduct;
        
        DS_Product__c dataConnectionProduct = TestClientUtils.getProduct('TestNewProduct', 'Data Connection', 'CRM');
        insert dataConnectionProduct;
        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;
        
       /* DS_Subcategory__c subcategory = TestClientUtils.getSubcategory('TestCat', 'TestType');
        insert subcategory;*/
        
        DS_Dealer_Product__c dealerProduct = new DS_Dealer_Product__c();
        dealerProduct.Dealer__c = newAccount.Id;
        dealerProduct.Product__c = product.Id;
        dealerProduct.Name = 'testProdealer';
        insert dealerProduct;
        
        //DS_Product_Subcategory__c prodSubProd = TestClientUtils.getProdSubProd(product, subcategory, true);
        
        ApexPages.currentPage().getParameters().put('pId', hardwareProduct.Id);
        DS_CreateDealerProductCon objCreateDealerProductCon = new DS_CreateDealerProductCon();
        //objCreateDealerProductCon.save();
        objCreateDealerProductCon.cancel();
        
        ApexPages.currentPage().getParameters().put('pId', dataConnectionProduct.Id);
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        DS_CreateDealerProductCon dataCreateDealerProductCon = new DS_CreateDealerProductCon();
        //dataCreateDealerProductCon.save();
        dataCreateDealerProductCon.cancel();
        
        ApexPages.currentPage().getParameters().put('id', newAccount.Id);
        ApexPages.currentPage().getParameters().put('pId', product.Id);
        ApexPages.currentPage().getParameters().put('vid', vendor.Id);
        DS_CreateDealerProductCon createDealerProductCon = new DS_CreateDealerProductCon();
        List<SelectOption> lstOptions = new List<SelectOption>();
      //  lstOptions.add(new SelectOption(subcategory.Id, 'TestCat1'));
        createDealerProductCon.LstAvlCategory = lstOptions;
     //   createDealerProductCon.LstSelectedCategory = lstOptions;
        createDealerProductCon.save();
        createDealerProductCon.cancel();
        ApexPages.currentPage().getParameters().put('pdId', dealerProduct.Id);
        DS_CreateDealerProductCon createDealerProductCon1 = new DS_CreateDealerProductCon();
    }
}