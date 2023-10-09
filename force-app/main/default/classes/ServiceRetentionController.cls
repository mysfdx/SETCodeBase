/* Name:  ServiceRetentionController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class ServiceRetentionController {
	global Id AccountId{get;set;}
	global String area{get;set;}
	global String district{get;set;}
	
	public SET_Dealer_Performance_Metrics__c getServiceRetention()
	{
		SET_Dealer_Performance_Metrics__c data = new SET_Dealer_Performance_Metrics__c();
		
		for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(AccountId, area, district, null))
    	{
    		data = s;
    	}
    	
    	if(data.Svc_Cust_Ret_Target__c == null)
    	  data.Svc_Cust_Ret_Target__c = 0;
    	
    	return data;
	}
}