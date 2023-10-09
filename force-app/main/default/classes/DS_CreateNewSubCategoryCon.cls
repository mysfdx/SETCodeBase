/* Name:  DS_CreateNewSubCategoryCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateNewSubCategoryCon
{
    public DS_CreateNewSubCategoryCon()
    {
        productId = ApexPages.currentPage().getParameters().get('pId');
        vendorId = ApexPages.currentPage().getParameters().get('vId');
        accId = ApexPages.currentPage().getParameters().get('aid');
        Subcategory = new DS_Subcategory__c();
    }
    
    public PageReference cancel() {
        Pagereference page;
        if(String.isNotBlank(accId))
            page = new PageReference('/'+accId);
        else if(String.isNotBlank(vendorId))
            page = new PageReference('/'+vendorId);
        else
            page = new PageReference('/'+productId);
            
        return page;
    }


    public PageReference saveCategory()
    {
        List<DS_Product__c> lstProduct = [Select Id, Type__c From DS_Product__c Where Id =:productId];
        Subcategory.Type__c = lstProduct[0].Type__c;
        insert Subcategory;
        
        DS_Product_Subcategory__c productSubcategory = new DS_Product_Subcategory__c();
        productSubcategory.Product__c = productId;
        productSubcategory.Subcategory__c = Subcategory.Id;
        insert productSubcategory;
        
        Pagereference page;
        
        if(String.isNotBlank(accId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId+ '&aid='+accId);
        else if(String.isNotBlank(vendorId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId);
        else
            page = new PageReference('/'+productId);
        
        return page;
    }

    public DS_Subcategory__c Subcategory {get; set;}
    String productId, vendorId, accId;
}