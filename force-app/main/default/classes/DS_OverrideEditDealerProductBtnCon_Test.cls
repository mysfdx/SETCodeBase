@isTest
private class DS_OverrideEditDealerProductBtnCon_Test
{
    static testMethod void createNewVendorExtTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_Product__c product = TestClientUtils.getProduct('TestProduct', 'Apps Services', 'CRM');
        insert product;
        
        DS_Dealer_Product__c dealerProduct = new DS_Dealer_Product__c();
        dealerProduct.Dealer__c = newAccount.Id;
        dealerProduct.Product__c = product.Id;
        dealerProduct.Name = 'testProdealer';
        insert dealerProduct;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(dealerProduct);
        DS_OverrideEditDealerProductBtnCon newDS_Override = new DS_OverrideEditDealerProductBtnCon(sc);
        newDS_Override.init();
    }
}