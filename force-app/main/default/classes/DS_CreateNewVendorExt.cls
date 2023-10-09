/* Name:  DS_CreateNewVendorExt
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateNewVendorExt
{
    DS_Vendor__c DSVendor;
    String accId;
    Boolean IsDealerVendorReq;
	public String subprod = 'no';
        
    public DS_CreateNewVendorExt(ApexPages.StandardController controller) {
        DSVendor = (DS_Vendor__c)controller.getRecord();
        if(ApexPages.currentPage().getParameters().containsKey('aId')) {
            accId = ApexPages.currentPage().getParameters().get('aId');
        }
        
        IsDealerVendorReq  = false;
        if(ApexPages.currentPage().getParameters().containsKey('origin')) {
            IsDealerVendorReq = true;
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
    }
    
    public Pagereference createNewVendor()
    {
        Pagereference page;
        String url;
        insert DSVendor;
        
        //Commented for Deleting "DS_DealerVendor__c" object.
        /*        
        DS_Dealer_Vendor__c DealerVendor = new DS_Dealer_Vendor__c();
        DealerVendor.Dealer__c = accId;
        DealerVendor.Vendor__c = DSVendor.Id;
        insert DealerVendor;
        */
        
        if(IsDealerVendorReq)
        {
            page = new ApexPages.StandardController(new Account(Id = accId)).view();
            return page;
        }
        url = '/apex/DS_SelectProductType?id='+accId+ '&vId='+DSVendor.Id;
        if ( subProd == 'yes' )
        	url += '&subprod=yes';
        page = new Pagereference(url);
        return page;
    }
    
    public Pagereference cancel()
    {
        Pagereference page;
        String url = '/apex/DS_AllVendorInfo?id='+accId;
        if ( subProd == 'yes' )
        	url += '&subprod=yes';
        page = new Pagereference(url);
        return page;
    }
}