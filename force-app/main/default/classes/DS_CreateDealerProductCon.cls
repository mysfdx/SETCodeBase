/* Name:  DS_CreateDealerProductCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateDealerProductCon {
    public PageReference cancel() {
        Pagereference page;
        if(String.isNotBlank(DealerId))
            page = new Pagereference('/'+DealerId);
        else if(String.isNotBlank(VendorId))
            page = new Pagereference('/'+VendorId);
        else
            page = new ApexPages.StandardController(new DS_Product__c(Id = Product.Id)).view();
        
        return page;
    }
     
    public PageReference save() {
        if ( (Product.RecordType.DeveloperName == 'Apps_Services' || Product.RecordType.DeveloperName == 'Hardware' || Product.RecordType.DeveloperName == 'Data_Connection') && String.isNotBlank(DealerProduct.Dealer__c) ) {
            List<Account> lstDealer = [Select Name from Account where Id =:DealerProduct.Dealer__c];            
            String strDealerProdName = '';
            if ( LstDSVendor != null && LstDSVendor.size() > 0 ) 
                strDealerProdName += LstDSVendor[0].Name + ' ';
            strDealerProdName += Product.Name+ ' ' +lstDealer[0].Name;
            
            if ( strDealerProdName.length() <= 80 )
                DealerProduct.Name = strDealerProdName;
            else 
                DealerProduct.Name = strDealerProdName.left(80);
        }
        
       /* String strSelectedCategories;
        
        DealerProduct.Sub_Category__c = strSelectedCategories; */
        system.debug('Dealer Prod is ' + DealerProduct);
        upsert DealerProduct;
        system.debug('DealerProduct>>>>'+DealerProduct);
      /*  List<DS_Dealer_Product_Subcategory__c> lstDealerProdCategory = new List<DS_Dealer_Product_Subcategory__c>();
        
        if ( LstSelectedCategory != null && LstSelectedCategory.size() > 0 ) {
            system.debug('*****mapSubCategoryWithDPCategory>>>>'+mapSubCategoryWithDPCategory);
            for(SelectOption option :LstSelectedCategory)
            {
                if(!mapSubCategoryWithDPCategory.containsKey(option.getValue()))
                {
                    system.debug('*****option.getValue()>>>>'+option.getValue());
                    system.debug('*****mapSubCategoryWithDPCategory.containsKey(option.getValue())>>>>'+mapSubCategoryWithDPCategory.containsKey(option.getValue()));
                
                    DS_Dealer_Product_Subcategory__c dealerProductSubcategory = new DS_Dealer_Product_Subcategory__c();
                    dealerProductSubcategory.Dealer_Product__c = DealerProduct.Id;
                    dealerProductSubcategory.Subcategory__c = option.getValue();
                    lstDealerProdCategory.add(dealerProductSubcategory);
                }
                //if(strSelectedCategories == null)
                    //st;rSelectedCategories = option.getValue();
                //else
                    //strSelectedCategories += ';' +option.getValue();
            }
                        
            if(!lstDealerProdCategory.isEmpty())
                insert lstDealerProdCategory;
        }
        
        system.debug('lstDealerProdCategory>>>>'+lstDealerProdCategory);
        
        if(LstAvlCategory != null && LstAvlCategory.size() > 0)
        {
            lstDealerProdCategory.clear();
            for(SelectOption option :LstAvlCategory)
            {
                if(mapSubCategoryWithDPCategory.containsKey(option.getValue()))
                {
                    DS_Dealer_Product_Subcategory__c dealerProductSubcategory = mapSubCategoryWithDPCategory.get(option.getValue());
                    lstDealerProdCategory.add(dealerProductSubcategory);
                }
            }
            
            if(!lstDealerProdCategory.isEmpty())
                delete lstDealerProdCategory;
        } */
        
        Pagereference page;
        if(String.isNotBlank(ProductDealerId))
            page = new Pagereference('/'+ProductDealerId);        
        else if(String.isNotBlank(DealerId))
            page = new Pagereference('/'+DealerId);
        else if(String.isNotBlank(VendorId))
            page = new Pagereference('/'+VendorId);
        else if(String.isBlank(DealerId))
            page = new ApexPages.StandardController(new DS_Product__c(Id = Product.Id)).view();
        
        return page;
    }

    public boolean IsHardware {get; set;}
    public boolean IsAppService {get; set;}
    public boolean IsDataConnections {get; set;}
    public DS_Dealer_Product__c DealerProduct {get; set;}
    DS_Product__c Product;
    public String dateTimeValue { get; set; }
    public List<Account> LstDealer {get; set;}
    public String CancelBtnLbl { get; set; }
    public String DealerId { get; set; }
    public String VendorId { get; set; }
    public List<DS_Dealer_Product__c> LstDealerProduct { get; set; }
    public List<DS_Vendor__c> LstDSVendor { get; set; }
    public String ProductDealerId { get; set; }
    
    public DS_CreateDealerProductCon()
    {
      //  IsCRMOrDSM = false;
        CancelBtnLbl = 'Cancel';
        Product = [Select Id, RecordType.DeveloperName, Name, Type__c from DS_Product__c where Id =:ApexPages.currentPage().getParameters().get('pId')];
        if(ApexPages.currentPage().getParameters().containsKey('id'))
            DealerId = ApexPages.currentPage().getParameters().get('id');
            
        ProductDealerId = ApexPages.currentPage().getParameters().get('pdId');
        
        if( String.isNotBlank(ApexPages.currentPage().getParameters().get('pdId')) ) {
            LstDealerProduct = DS_DealerProductSOQLMethods.fetchDealerProductsByIds(new Set < Id >{ApexPages.currentPage().getParameters().get('pdId')});
        }
        else if(String.isNotBlank(ApexPages.currentPage().getParameters().get('pId')) && String.isNotBlank(DealerId)) {
            LstDealerProduct = DS_DealerProductSOQLMethods.fetchDealerProductsByIdsAndDealerIds(new Set < Id >{ApexPages.currentPage().getParameters().get('pdId')}, new Set < Id >{DealerId});
        }
                                
        if(LstDealerProduct != null && LstDealerProduct.size() > 0)
            DealerProduct = LstDealerProduct[0];
        else {
            DealerProduct = new DS_Dealer_Product__c();
            DealerProduct.Product__c = Product.Id;
            DealerProduct.Dealer__c = DealerId;
        }
        if(ApexPages.currentPage().getParameters().containsKey('vid'))
        {
            VendorId = ApexPages.currentPage().getParameters().get('vid');
            LstDSVendor = [Select Name From DS_Vendor__c Where Id =:VendorId];
        }
        
        if(Product.RecordType.DeveloperName == 'Apps_Services')
        {
            IsAppService = true;
            IsHardware = false;
            IsDataConnections = false;
        }
        else if(Product.RecordType.DeveloperName == 'Hardware')
        {
            IsAppService = false;
            IsHardware = true;
            IsDataConnections = false;
        }
        else if(Product.RecordType.DeveloperName == 'Data_Connection')
        {
            IsAppService = false;
            IsHardware = false;
            IsDataConnections = true;
        }
        
       /* if(Product.Type__c == 'CRM' || Product.Type__c == 'DMS')
        {
            IsCRMOrDSM = true;
            Map<Id, DS_Product_Subcategory__c> mapProductSubcategory = new Map<Id, DS_Product_Subcategory__c>(
                                                                        [Select Subcategory__r.Name, Subcategory__c 
                                                                            From DS_Product_Subcategory__c 
                                                                            Where Product__c =:Product.Id]);
            LstAvlCategory = new LIST<SelectOption>();
            LstSelectedCategory = new LIST<SelectOption>();
            Set<Id> setCategory = new Set<Id>();
            
            for(DS_Product_Subcategory__c category :mapProductSubcategory.values())
            {
                setCategory.add(category.Subcategory__c);
            }
            
            system.debug('LstDealerProduct== '+LstDealerProduct);
            
            if(LstDealerProduct != null && LstDealerProduct.size() > 0)
            {
                List<DS_Dealer_Product_Subcategory__c> lstDealerProductSubcategory = [Select Id, Subcategory__r.Name, Subcategory__c
                                                                                    From DS_Dealer_Product_Subcategory__c
                                                                                    Where Subcategory__c IN :setCategory
                                                                                    AND Dealer_Product__c =:LstDealerProduct[0].Id];
                
                system.debug('lstDealerProductSubcategory== '+lstDealerProductSubcategory);
                
                if(!lstDealerProductSubcategory.isEmpty())
                {
                    for(DS_Dealer_Product_Subcategory__c dealerProductSubcategory :lstDealerProductSubcategory)
                    {
                        //setSelectedCategoryId.add(dealerProductSubcategory.Subcategory__c);
                        mapSubCategoryWithDPCategory.put(dealerProductSubcategory.Subcategory__c, dealerProductSubcategory);
                        LstSelectedCategory.add(new SelectOption(dealerProductSubcategory.Subcategory__c, dealerProductSubcategory.Subcategory__r.Name));
                    }
                }
            }
            
            for(DS_Product_Subcategory__c category :mapProductSubcategory.values())
            {
                if(!mapSubCategoryWithDPCategory.containsKey(category.Subcategory__c))
                    LstAvlCategory.add(new SelectOption(category.Subcategory__c, category.Subcategory__r.Name));
            }
        }*/
    }
    
    //Set<Id> setSelectedCategoryId = new Set<Id>();
    public LIST<SelectOption> LstAvlCategory {get; set;}
    public LIST<SelectOption> LstSelectedCategory {get; set;}
    /*public Boolean IsCRMOrDSM {get; set;}
    Map<Id, DS_Dealer_Product_Subcategory__c> mapSubCategoryWithDPCategory = new Map<Id, DS_Dealer_Product_Subcategory__c>();*/
}