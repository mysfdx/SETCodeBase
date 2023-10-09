@isTest
private class DS_LinkPopulate_Test {

    static testMethod void linkPopulateTest() {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;        
        DS_Vendor__c vendor = TestClientUtils.getVendor('TestVendor');
        insert vendor;        
        DS_Link__c prodLink = TestClientUtils.getLink('TestLink', null, product.Id, null);
        insert prodLink;        
        DS_Link__c acctLink = TestClientUtils.getLink('TestLink1', newAccount.Id, null, null);
        insert acctLink;        
        DS_Link__c vendorLink = TestClientUtils.getLink('TestLink2', null, null, vendor.Id);
        insert vendorLink;        
        DS_Link__c link1 = TestClientUtils.getLink('TestLink3', null, null, vendor.Id);
        
        ApexPages.Standardcontroller sch3 = new ApexPages.Standardcontroller(link1);
        DS_LinkPopulate linkPopulate2 = new DS_LinkPopulate(sch3);
        linkPopulate2.saveDate();
        linkPopulate2.doCancel();
        
        ApexPages.currentPage().getParameters().put('aid', newAccount.Id);
        ApexPages.Standardcontroller acctsch = new ApexPages.Standardcontroller(acctLink);
        DS_LinkPopulate newLinkPopulate = new DS_LinkPopulate(acctsch);
        newLinkPopulate.saveDate();
        newLinkPopulate.doCancel();
        
        ApexPages.currentPage().getParameters().put('pId', product.Id);
        ApexPages.Standardcontroller prodsc = new ApexPages.Standardcontroller(prodLink);
        DS_LinkPopulate objLinkPopulate = new DS_LinkPopulate(prodsc);
        objLinkPopulate.saveDate();
        objLinkPopulate.doCancel();
        
        ApexPages.currentPage().getParameters().put('lId', vendor.Id);
        ApexPages.Standardcontroller vendorsc = new ApexPages.Standardcontroller(vendorlink);
        DS_LinkPopulate linkPopulate = new DS_LinkPopulate(vendorsc);
        linkPopulate.saveDate();
        linkPopulate.doCancel();
    }
    
    static testMethod void testDealerProdProd() {  
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        DS_Link__c DSlink = TestClientUtils.getLink('TestLink', null, product.Id, null);
        insert DSlink;      
        DS_Dealer_Product__c dealerProd = TestClientUtils.getDealerProd(newAccount.Id, product.Id, true);                   
        ApexPages.currentPage().getParameters().put('dealerProdId', dealerProd.Id);
        ApexPages.Standardcontroller scForDealerProd = new ApexPages.Standardcontroller(DSlink);
        DS_LinkPopulate linkPopulateForDealerProd = new DS_LinkPopulate(scForDealerProd);
        linkPopulateForDealerProd.saveDate();
        linkPopulateForDealerProd.doCancel();     
    }
    
    static testMethod void testDealerProdSubProd() {  
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        DS_Subcategory__c subProd = TestClientUtils.getSubcategory('TestCategory', 'CRM');
        insert subProd;        
        DS_Dealer_Product__c dealerProd = TestClientUtils.getDealerProd(newAccount.Id, product.Id, true);        
        Dealer_Product_Subproduct__c dealerSubProd = TestClientUtils.getDealerSubProd(newAccount.Id, product.Id, subProd.Id, true);  
        DS_Link__c DSlink = TestClientUtils.getLink('TestLink', null, product.Id, null);
        insert DSlink;  
        DS_Link__c DSlinkForSubProd = TestClientUtils.getLink('TestLink', null, null, null);
        insert DSlinkForSubProd;  
        DS_Link__c DSlinkForDealerProd = TestClientUtils.getLink('TestLink', null, null, null);
        DSlinkForDealerProd.DS_Dealer_Product__c = dealerProd.Id;
        insert DSlinkForDealerProd; 
        DS_Link__c DSlinkForDealerSubProd = TestClientUtils.getLink('TestLink', null, null, null);
        DSlinkForDealerSubProd.DS_Dealer_Subproduct__c = dealerSubProd.Id;
        insert DSlinkForDealerSubProd;   
        
        ApexPages.Standardcontroller scForDealerSubProd1 = new ApexPages.Standardcontroller(DSlinkForDealerProd);
        DS_LinkPopulate linkPopulateForDealerSubProd1 = new DS_LinkPopulate(scForDealerSubProd1);
        linkPopulateForDealerSubProd1.saveDate();
        linkPopulateForDealerSubProd1.doCancel();
        
        ApexPages.Standardcontroller scForDealerSubProd2 = new ApexPages.Standardcontroller(DSlinkForDealerSubProd);
        DS_LinkPopulate linkPopulateForDealerSubProd2 = new DS_LinkPopulate(scForDealerSubProd2);
        linkPopulateForDealerSubProd2.saveDate();
        linkPopulateForDealerSubProd2.doCancel();
                  
        ApexPages.currentPage().getParameters().put('dealerSubProdId', dealerSubProd.Id);
        ApexPages.Standardcontroller scForDealerSubProd = new ApexPages.Standardcontroller(DSlink);
        DS_LinkPopulate linkPopulateForDealerSubProd = new DS_LinkPopulate(scForDealerSubProd);
        linkPopulateForDealerSubProd.saveDate();
        linkPopulateForDealerSubProd.doCancel();
        
        ApexPages.currentPage().getParameters().put('retURL', subProd.Id);
        ApexPages.Standardcontroller scForSubProd = new ApexPages.Standardcontroller(DSlinkForSubProd);
        DS_LinkPopulate linkPopulateForSubProd = new DS_LinkPopulate(scForSubProd);
        linkPopulateForSubProd.saveDate();
        linkPopulateForSubProd.doCancel();
    }

}