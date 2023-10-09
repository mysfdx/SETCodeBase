/* Name:  DS_SelectProductType
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_SelectProductType {
    String vendorId;
    String accId;
    public String SelectedRecordType {get; set;}
    Public Map<Id,String> RecordTypeMap = new Map<Id,String>();
    public String prodName;
	public String subprod = 'no';
    
    public PageReference cancel() {
        Pagereference page = new Pagereference('/'+vendorId);
        return page;
    }
    
    public PageReference next() {
        prodName = Apexpages.currentPage().getParameters().get('pname');
        Pagereference page;
        String url;
        if(RecordTypeMap.get(SelectedRecordType) == 'Hardware') {
	        if(String.isNotBlank(accId))
	           url = '/apex/DS_CreateHardWareProduct?vId='+vendorId+'&type='+SelectedRecordType+'&aid='+accId+'&pname='+prodName;
	        else
	            url = '/apex/DS_CreateHardWareProduct?vId='+vendorId+'&type='+SelectedRecordType+'&pname='+prodName;
        }
        else if(RecordTypeMap.get(SelectedRecordType) == 'Apps_Services') {
	        if(String.isNotBlank(accId))
	            url = '/apex/DS_CreateAppServiceProduct?vId='+vendorId+'&type='+SelectedRecordType+'&aid='+accId+'&pname='+prodName;
	        else
	            url = '/apex/DS_CreateAppServiceProduct?vId='+vendorId+'&type='+SelectedRecordType+'&pname='+prodName;
        }
        else {
	        if(String.isNotBlank(accId))
	            url = '/apex/DS_CreateProduct?vId='+vendorId+'&type='+SelectedRecordType+'&aid='+accId+'&pname='+prodName;
	        else
	            url = '/apex/DS_CreateProduct?vId='+vendorId+'&type='+SelectedRecordType+'&pname='+prodName;
    	}
    	if ( subProd == 'yes' )
        	url += '&subprod=yes';
    	page = new Pagereference(url);
    	return page;
    }

    
    
    public DS_SelectProductType() {
        if(ApexPages.currentPage().getParameters().containsKey('id'))
        {
            accId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('vid'))
        {
            vendorId = ApexPages.currentPage().getParameters().get('vid');
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
    }
    
    public List<SelectOption> getLstRecordType()
    {
        List<RecordType> lstRecordType = [Select Id, DeveloperName from RecordType Where SobjectType = 'DS_Product__c'];
        List<SelectOption> options = new List<SelectOption>();
        
        if(!lstRecordType.isEmpty())
        {
            for(RecordType rType :lstRecordType)
            {
                options.add(new SelectOption(rType.Id, rType.DeveloperName));
                RecordTypeMap.put(rType.Id, rType.DeveloperName);
            }
        }
        
        return options;
    }
}