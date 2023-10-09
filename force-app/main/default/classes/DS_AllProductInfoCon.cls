/* Name:  DS_AllProductInfoCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_AllProductInfoCon {
  public String subProdId;
  public String subprod = 'no';
    public String pordName; 
    public PageReference searchProducts()
    {
        String productName = Apexpages.currentPage().getParameters().get('pName');
        pordName = productName;
        
        LstProductWrapper = new List<ProductWrapper>();
        LstProductWrapper2 = new List<ProductWrapper>();
        //LstProduct = [Select Id, Name, Status__c, RecordTypeId From DS_Product__c Where Name Like :productName+'%' Order by Name limit 1000];
        if(productName != null){
            con = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id, Name, Status__c, RecordTypeId From DS_Product__c Where Name Like :productName+'%' ]));
            con.setPageSize(100);
            LstProductWrapper.clear();
            LstProductWrapper2.Clear();
            for(DS_Product__c product :(List<DS_Product__c>)con.getRecords())
            {
                if(setProductIds.contains(product.Id))
                    LstProductWrapper.add(new ProductWrapper(product, true));
                else
                    LstProductWrapper2.add(new ProductWrapper(product, false));
            }
            
            //if(!LstProductWrapper2.isEmpty())
            LstProductWrapper.addAll(LstProductWrapper2);
            
       
       }
        else{
            con = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id, Name, Status__c, RecordTypeId From DS_Product__c]));
            LstProductWrapper.clear();
            LstProductWrapper2.clear();
            List<DS_Vendor_Product__c> lstVendorProduct = [Select Product__c from DS_Vendor_Product__c where Vendor__c =:VendorId];
            system.debug('Get Products lstVendorProduct===='+lstVendorProduct);
            system.debug('Get Products the vendor Id is '+VendorId);
            
             
                
            if(!lstVendorProduct.isEmpty())
            {
                for(DS_Vendor_Product__c vendorProduct : lstVendorProduct)
                {
                    setProductIds.add(vendorProduct.Product__c);
                }
            }
            for(DS_Product__c product :(List<DS_Product__c>)con.getRecords())
            {
                if(setProductIds.contains(product.Id))
                    LstProductWrapper.add(new ProductWrapper(product, true));
                else
                    LstProductWrapper2.add(new ProductWrapper(product, false));
            }
            
            //if(!LstProductWrapper2.isEmpty())
            LstProductWrapper.addAll(LstProductWrapper2);         
        }
        return null;        
    }

    String DealerId;
    String VendorId;
    public List<ProductWrapper> LstProductWrapper {get; set;}
    public List<ProductWrapper> LstProductWrapper2 {get; set;}
    public List<DS_Product__c> LstProduct {get; set;}
    public List<DS_Product__c> LstSelectedProduct {get; set;}
    public Boolean IsDisplayTbl {get; set;}
    public String BtnLabel {get; set;}
    public Boolean IsDisplayAddProduct {get; set;}
    Set<Id> setProductIds;
    //public ApexPages.StandardSetController con;
    public list<DS_Product__c> listToDisplay {get; set;}
    
    
   public ApexPages.StandardSetController con {
       
        get {
            system.debug('setproductids in con '+setProductIds);
            list<DS_Product__c> productswithVendor = [Select Id, Name, Status__c, RecordTypeId FROM DS_Product__c where id in :setProductIds];
            list<DS_Product__c> productswithoutVendor = [Select Id, Name, Status__c, RecordTypeId FROM DS_Product__c where id NOT in :setProductIds order by Name];
            //productswithVendor.addAll(productswithoutVendor);
            if(con == null) {
                //con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Name, Status__c, RecordTypeId FROM DS_Product__c ]));
                con = new ApexPages.StandardSetController(productswithVendor);
                // sets the number of records in each page set
                con.setPageSize(100);
                system.debug('the size of the list is '+con.getResultSize());
            }
            return con;
        }
        set;
    }
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<ProductWrapper> getProducts() {
        system.debug('inside getproducts');
        setProductIds = new Set<Id>();
         LstProductWrapper = new List<ProductWrapper>();
        LstProductWrapper2 = new List<ProductWrapper>();
        /* if(ApexPages.currentPage().getParameters().containsKey('vid'))
        {
            VendorId = ApexPages.currentPage().getParameters().get('vid');
        }
         if ( ApexPages.currentPage().getParameters().containsKey('subProdId') ) {
            subProdId = ApexPages.currentPage().getParameters().get('subProdId');
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('prod') || subProd == 'yes') {
            IsDisplayAddProduct = true;
        }*/
        List<DS_Vendor_Product__c> lstVendorProduct = [Select Product__c from DS_Vendor_Product__c where Vendor__c =:VendorId];
        system.debug('Get Products lstVendorProduct===='+lstVendorProduct);
        system.debug('Get Products the vendor Id is '+VendorId);
        
         
            
        if(!lstVendorProduct.isEmpty())
        {
            for(DS_Vendor_Product__c vendorProduct : lstVendorProduct)
            {
                setProductIds.add(vendorProduct.Product__c);
            }
        }
        
        List<DS_Product__c> products = (List<DS_Product__c>)con.getRecords();
        system.debug('in get products the products are '+products);
        for (DS_Product__c product  : products){
            if(setProductIds.contains(product.Id))
                    LstProductWrapper.add(new ProductWrapper(product, true));
                else
                    LstProductWrapper2.add(new ProductWrapper(product, false));
            
         }
        system.debug('in getProducts the Lstproductwraper is '+LstProductWrapper);
        system.debug('in getProducts the Lstproductwraper is '+LstProductWrapper.size());
        
        LstProductWrapper.addAll(LstProductWrapper2);
        return LstProductWrapper;
    }
    
    public DS_AllProductInfoCon() {
        setProductIds = new Set<Id>();
        BtnLabel = 'Next';
        IsDisplayAddProduct = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('vid'))
        {
            VendorId = ApexPages.currentPage().getParameters().get('vid');
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subProdId') ) {
            subProdId = ApexPages.currentPage().getParameters().get('subProdId');
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('prod') || subProd == 'yes') {
            IsDisplayAddProduct = true;
        }
        
        List<DS_Vendor_Product__c> lstVendorProduct = [Select Product__c from DS_Vendor_Product__c where Vendor__c =:VendorId];
        system.debug('lstVendorProduct===='+lstVendorProduct);
        system.debug('the vendor Id is '+VendorId);
            
        if(!lstVendorProduct.isEmpty())
        {
            for(DS_Vendor_Product__c vendorProduct : lstVendorProduct)
            {
                setProductIds.add(vendorProduct.Product__c);
            }
        }
            
        
        LstProduct = new list<DS_Product__c>();
        list<DS_Product__c> productswithVendor = [Select Id, Name, Status__c, RecordTypeId FROM DS_Product__c where id in :setProductIds];
        list<DS_Product__c> productswithoutVendor = [Select Id, Name, Status__c, RecordTypeId FROM DS_Product__c where id NOT in :setProductIds order by Name];
        productswithvendor.addAll(productswithoutVendor);
        con = new apexpages.StandardSetController(productswithVendor);
        con.setPageSize(100);
        for(DS_Product__c prd : (list<DS_Product__c>)con.getRecords()){
            LstProduct.add(prd);
        }
        
        //if(!setProductIds.isEmpty())
            //LstProduct = [Select Id, Name, Status__c, RecordTypeId From DS_Product__c Where Id IN :setProductIds];
        
        if(ApexPages.currentPage().getParameters().containsKey('id'))
        {
            DealerId = ApexPages.currentPage().getParameters().get('id');
        }
        
        
        LstProductWrapper = new List<ProductWrapper>();
        LstProductWrapper2 = new List<ProductWrapper>();
        
        list<DS_Product__c> lstproducts2 = [Select Id, Name, Status__c, RecordTypeId From DS_Product__c where id in :setProductIds ];
        for(DS_Product__c p : lstproducts2){
            LstProductWrapper.add(new ProductWrapper(p, true));
        }
        
        
        system.debug('setProductIds===='+setProductIds);
        system.debug('LstProduct===='+LstProduct);
        if(!LstProduct.isEmpty())
        {
            for(DS_Product__c product :LstProduct)
            {
                if(!setProductIds.contains(product.Id))
                     LstProductWrapper2.add(new ProductWrapper(product, false));
               
                   
            }
            system.debug('in constructor lstproductwrapper '+LstProductWrapper);
            system.debug('in constructor lstproductwrapper size '+LstProductWrapper.size());
            system.debug('in constructor lstproductwrapper2 '+LstProductWrapper2);
            LstProductWrapper.addAll(LstProductWrapper2);
            
        }
        
        IsDisplayTbl = false;
    }
    
    public void selectProduct() {
        LstSelectedProduct = [Select Id, Name, Status__c, RecordTypeId From DS_Product__c Where Id =:System.currentPagereference().getParameters().get('vendorid')];
        IsDisplayTbl = true;
        if ( subProd != 'yes' )
          BtnLabel = 'Save';
    }
    
    public PageReference cancel() {
        Pagereference page;
        
        if(IsDisplayAddProduct) {
            String url = '/apex/DS_AllVendorInfo?id='+DealerId;
            if ( subProd =='yes' )
              url += '&subProd=yes';
            page = new Pagereference(url);
        } else {
            page = new Pagereference('/'+VendorId);
        }
        return page;
    }
    
    public PageReference addProduct() {
        Pagereference page;
        String url;
        if(String.isNotBlank(DealerId)) {
            url = '/apex/DS_SelectProductType?vid='+VendorId+'&id='+DealerId+'&pname='+pordName;
            if ( subProd =='yes' )
              url += '&subProd=yes';
        } else {
            url = '/apex/DS_SelectProductType?vid='+VendorId+'&pname='+pordName;
            if ( subProd =='yes' )
              url += '&subProd=yes';
        }
        page = new Pagereference(url);
        return page;
    }
    
   /* public void populateLstProductWrapper(){
         LstProduct = new list<DS_Product__c>();
        con = new apexpages.StandardSetController(Database.getQueryLocator([Select Id, Name, Status__c, RecordTypeId From DS_Product__c order by Name]));
        for(DS_Product__c prd : (list<DS_Product__c>)con.getRecords()){
            LstProduct.add(prd);
        }
        List<DS_Vendor_Product__c> lstVendorProduct = [Select Product__c from DS_Vendor_Product__c where Vendor__c =:VendorId];
        system.debug('lstVendorProduct===='+lstVendorProduct);
            
        if(!lstVendorProduct.isEmpty())
        {
            for(DS_Vendor_Product__c vendorProduct : lstVendorProduct)
            {
                setProductIds.add(vendorProduct.Product__c);
            }
        }
            
        //if(!setProductIds.isEmpty())
            //LstProduct = [Select Id, Name, Status__c, RecordTypeId From DS_Product__c Where Id IN :setProductIds];
        
        if(ApexPages.currentPage().getParameters().containsKey('id'))
        {
            DealerId = ApexPages.currentPage().getParameters().get('id');
        }
        
        LstProductWrapper = new List<ProductWrapper>();
        LstProductWrapper2 = new List<ProductWrapper>();
        
        system.debug('setProductIds===='+setProductIds);
        system.debug('LstProduct===='+LstProduct);
        if(!LstProduct.isEmpty())
        {
            for(DS_Product__c product :LstProduct)
            {
                if(setProductIds.contains(product.Id))
                    LstProductWrapper.add(new ProductWrapper(product, true));
                else
                    LstProductWrapper2.add(new ProductWrapper(product, false));
            }
            
            LstProductWrapper.addAll(LstProductWrapper2);
            system.debug('inside populate LstProductwrapper '+LstProductWrapper);
            
        }
    }*/
    
    public PageReference next() {
        Pagereference page;
        String url;
        List<DS_Vendor_Product__c> lstVendorProduct = [Select Id from DS_Vendor_Product__c where Product__c =:LstSelectedProduct[0].Id AND Vendor__c =:VendorId];
        
        if(lstVendorProduct.isEmpty()) {
            List<DS_Vendor__c> lstVendor = [Select Name From DS_Vendor__c Where Id =:VendorId];
            DS_Vendor_Product__c vendorProduct = new DS_Vendor_Product__c();
            vendorProduct.Product__c = LstSelectedProduct[0].Id;
            vendorProduct.Vendor__c = VendorId;
            String strVendorProdName = LstSelectedProduct[0].Name+ ' ' +lstVendor[0].Name;
            if ( strVendorProdName.length() <= 80 )
              vendorProduct.Name = strVendorProdName;
            else
              vendorProduct.Name = strVendorProdName.left(80);
            insert vendorProduct;
        }
    
    if ( subProd == 'yes' ) {
      url = '/apex/DS_SubProdSelectForDealerPage?vendorId=' + VendorId + '&prodId=' + LstSelectedProduct[0].Id;
      if ( String.isNotBlank(DealerId) )
            url += '&acctId=' + DealerId;
    } else if( !IsDisplayAddProduct ) {
            url = '/apex/DS_CreateDealerProduct?pId=' +LstSelectedProduct[0].Id+ '&vid=' +VendorId;
        }
        else {
            url = '/apex/DS_CreateDealerProduct?pId=' +LstSelectedProduct[0].Id+ '&id=' +DealerId+ '&vid=' +VendorId;
        }
    page = new Pagereference(url);
        return page;
    }
    
    public class ProductWrapper {
        public Boolean IsRelated {get; set;}
        public DS_Product__c Product {get; set;}
        
        public ProductWrapper(DS_Product__c DS_Product, Boolean IsRelated)
        {
            this.Product = DS_Product;
            this.IsRelated = IsRelated;
        }
    }
    
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
    public void first() {
        con.first();
    }

    // returns the last page of records
    public void last() {
        con.last();
    }

    // returns the previous page of records
    public void previous() {
        con.previous();
    }

    // returns the next page of records
    public void nextPage() {
        
        con.next();
    }

    // returns the PageReference of the original page, if known, or the home page.
    public void cancelAction() {
        con.cancel();
    }
}