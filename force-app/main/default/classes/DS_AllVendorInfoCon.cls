/* Name:  DS_AllVendorInfoCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_AllVendorInfoCon {
	public String subProdId;
	public String subprod = 'no';
    String DealerId;
    String VendorId;    
    public List<DS_Vendor__c> LstVendor {get; set;}
    public List<DS_Vendor__c> LstSelectedVendor {get; set;}
    public Boolean IsDisplayTbl {get; set;}
    Boolean IsDealerVendorReq;
    public String SaveOrNextBtnLbl {get; set;}
    public Boolean IsProdReq {get; set;}
    
    public PageReference searchVendors() {
        String vendorName = Apexpages.currentPage().getParameters().get('vName');
        system.debug('====vendorName  = '+vendorName);
        LstVendor = [Select Id, Name, Address__c, Vendor_Performance__c From DS_Vendor__c Where Name Like :vendorName+'%' Order by Name];
        system.debug('====LstVendor = '+LstVendor);
        return null;
    }
    
    
    public DS_AllVendorInfoCon() {
        IsDealerVendorReq  = false;
        SaveOrNextBtnLbl = 'Next';
        IsProdReq = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('id'))
        {
            DealerId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('prod'))
        {
            IsProdReq = true;
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subProdId') ) {
            subProdId = ApexPages.currentPage().getParameters().get('subProdId');
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('origin'))
        {
            IsDealerVendorReq = true;
            SaveOrNextBtnLbl = 'Save';
        }
        
        LstVendor = [Select Id, Name, Vendor_Performance__c, Address__c From DS_Vendor__c order by Name limit 50000];
        IsDisplayTbl = false;
    }
    
    public PageReference addVendor()
    {
        Pagereference page;
        String url;
        if(IsDealerVendorReq) {
            url = '/apex/DS_CreateNewVendor?aId='+DealerId+ '&origin=dealer';
        } else {
            url = '/apex/DS_CreateNewVendor?aId='+DealerId;
        }
        if ( subProd =='yes' )
        	url += '&subProd=yes';
        page = new Pagereference(url);
        return page;
    }
    
    public PageReference cancel()
    {
        Pagereference page = new ApexPages.StandardController(new Account(Id = DealerId)).view();
        return page;
    }

    public PageReference next()
    {
        //Commented for Deleting "DS_DealerVendor__c" object.
        /*
        if(IsDealerVendorReq)
        {
            List<DS_Dealer_Vendor__c> lstDealerVendor = [Select Id from DS_Dealer_Vendor__c Where Vendor__c =:VendorId AND Dealer__c =:DealerId];
            
            if(!lstDealerVendor.isEmpty())
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error ,'This Vendor has already been associated to this Dealer'); 
                ApexPages.addMessage(errMsg);
                return null;
            }
            
            DS_Dealer_Vendor__c DealerVendor = new DS_Dealer_Vendor__c();
            DealerVendor.Dealer__c = DealerId;
            DealerVendor.Vendor__c = VendorId;
            insert DealerVendor;
        }
        */
      
        Pagereference page;
        
        if ( IsDealerVendorReq && subProd != 'yes' )
        {
            page = new ApexPages.StandardController(new Account(Id = DealerId)).view();
            return page;
        }
        
        String url = '/apex/DS_AllProductInfo?id='+DealerId+ '&vId='+VendorId+'&prod=no';
            if ( subProd =='yes' )
            	url += '&subprod=yes';
            page = new Pagereference(url);
        return page;
    }

    public void selectVendor()
    {
        VendorId = System.currentPagereference().getParameters().get('vendorid');
        LstSelectedVendor = [Select Id, Name, Vendor_Performance__c, Address__c From DS_Vendor__c Where Id =:VendorId];
        IsDisplayTbl = true;
    }
}