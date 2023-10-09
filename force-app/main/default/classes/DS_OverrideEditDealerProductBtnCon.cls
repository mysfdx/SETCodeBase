/* Name:  DS_OverrideEditDealerProductBtnCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_OverrideEditDealerProductBtnCon {
    DS_Dealer_Product__c dealerProduct;
    
    public DS_OverrideEditDealerProductBtnCon(ApexPages.StandardController controller) {
        dealerProduct = [Select Id, Product__c from DS_Dealer_Product__c where Id =:controller.getId()];
    }

    public PageReference init() {
        Pagereference page = new PageReference('/apex/DS_CreateDealerProduct?pId='+dealerProduct.Product__c+'&pdId='+dealerProduct.Id);
        return page;
    }
}