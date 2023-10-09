/* Name:  DS_AllSubCategoryCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_AllSubCategoryCon
{ 
    public DS_AllSubCategoryCon(ApexPages.StandardController controller) {

    }

  
    public PageReference searchCategory()
    {
        system.debug('==here==');
        String categoryName = Apexpages.currentPage().getParameters().get('cName');
        LstDSSubcategory = [Select Id, Name, Type__c From DS_Subcategory__c Where Name Like :CategoryName+'%' AND Type__c =:lstProduct[0].Type__c Order by Name];
        LstCategoryWrapper = new List<CategoryWrapper>();
        LstCategoryWrapper2 = new List<CategoryWrapper>();
        
        for(DS_Subcategory__c subcategory :LstDSSubcategory)
        {
            if(setCategoryId.contains(subcategory.Id))
                LstCategoryWrapper.add(new CategoryWrapper(subcategory, true));
            else
                LstCategoryWrapper2.add(new CategoryWrapper(subcategory, false));
        }
        
        if(!LstCategoryWrapper2.isEmpty())
            LstCategoryWrapper.addAll(LstCategoryWrapper2);
        
        return null;
    }
    
    public PageReference addCategory()
    {
        Pagereference page;
        if(String.isNotBlank(accId))
            page = new Pagereference('/apex/DS_CreateNewSubCategory?pId=' +productId+ '&vid=' +vendorId+'&aid='+accId);
        else if(String.isNotBlank(vendorId))
            page = new Pagereference('/apex/DS_CreateNewSubCategory?pId=' +productId+ '&vid=' +vendorId);
        else
            page = new Pagereference('/apex/DS_CreateNewSubCategory?pId=' +productId);
        return page;
    }

    public PageReference cancel()
    {
        Pagereference page;
        
        if(String.isNotBlank(accId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId+'&aid='+accId);
        else if(String.isNotBlank(vendorId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId);
        else
            page = new Pagereference('/' +productId);
        return page;
    }

    public PageReference next()
    {
        if(setCategoryId.contains(LstDSSubcategory[0].Id))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This product already has this sub-category'));
            return null;
        }
        
        DS_Product_Subcategory__c productSubcategory = new DS_Product_Subcategory__c();
        productSubcategory.Product__c = productId;
        productSubcategory.Subcategory__c = LstDSSubcategory[0].Id;
        insert productSubcategory;
        
        Pagereference page;
        
        if(String.isNotBlank(accId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId+'&aid='+accId);
        else if(String.isNotBlank(vendorId))
            page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +productId+ '&vid=' +vendorId);
        else
            page = new Pagereference('/' +productId);
        
        return page;
    }

    public List<DS_Subcategory__c> LstDSSubcategory {get; set;}
    public List<CategoryWrapper> LstCategoryWrapper {get; set;}
    public List<CategoryWrapper> LstCategoryWrapper2 {get; set;}
    public Boolean IsDisplayTbl {get; set;}
    String type, productId, vendorId, accId;
    Set<Id> setCategoryId = new Set<Id>();
    List<DS_Product__c> lstProduct;
    
    public PageReference initAllCategory()
    {
        if(ApexPages.currentPage().getParameters().containsKey('pId'))
        {
            LstCategoryWrapper = new List<CategoryWrapper>();
            LstCategoryWrapper2 = new List<CategoryWrapper>();
            productId = ApexPages.currentPage().getParameters().get('pId');
            vendorId = ApexPages.currentPage().getParameters().get('vId');
            
            lstProduct = [Select Id, Type__c From DS_Product__c Where Id =:productId];
            //type = ApexPages.currentPage().getParameters().get('type');
            if(!lstProduct.isEmpty() && lstProduct[0].Type__c != null)
                LstDSSubcategory = [Select Id, Name, Type__c From DS_Subcategory__c Where Type__c =:lstProduct[0].Type__c Order by Name];
            
            //if(ApexPages.currentPage().getParameters().containsKey('pId'))
                //productId = ApexPages.currentPage().getParameters().get('pId');
            
            if(LstDSSubcategory != null && LstDSSubcategory.size() > 0)
            {
                List<DS_Product_Subcategory__c> lstProductSubcategory = [Select Subcategory__c from DS_Product_Subcategory__c Where Product__c =:productId];
                for(DS_Product_Subcategory__c productSubcategory :lstProductSubcategory)
                    setCategoryId.add(productSubcategory.Subcategory__c);
                    
                for(DS_Subcategory__c subcategory :LstDSSubcategory)
                {
                    if(setCategoryId.contains(subcategory.Id))
                        LstCategoryWrapper.add(new CategoryWrapper(subcategory, true));
                    else
                        LstCategoryWrapper2.add(new CategoryWrapper(subcategory, false));
                }
                
                if(!LstCategoryWrapper2.isEmpty())
                    LstCategoryWrapper.addAll(LstCategoryWrapper2);
            }
            
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('aId'))
            accId = ApexPages.currentPage().getParameters().get('aId');

        return null;
    }
    
    public void selectCategory()
    {
        LstDSSubcategory = [Select Id, Name, Type__c From DS_Subcategory__c Where Id =:System.currentPagereference().getParameters().get('categoryId') Order by Name];
        IsDisplayTbl = true;
    }
    
    public class CategoryWrapper
    {
        public Boolean IsRelated {get; set;}
        public DS_Subcategory__c Category {get; set;}
        
        public CategoryWrapper(DS_Subcategory__c Category, Boolean IsRelated)
        {
            this.Category = Category;
            this.IsRelated = IsRelated;
        }
    }
}