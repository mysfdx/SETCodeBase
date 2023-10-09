@isTest
public with sharing class ServiceRetentionControllerTest {	
	static testmethod void testThisClass() {
    	Test.startTest();
    	    //Create the Account used for the test cases
	    	Account acc = testClientUtils.createAccount();
	    	Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
            acc.RecordTypeId=rtByName.getRecordTypeId();
	    	insert acc;
	    	
	    	SET_Dealer_Performance_Metrics__c s = testClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
	    	s.Service_Cust_Ret_Var_to_Objective__c = 100;
            s.Service_Cust_Retention__c = 100;
            s.Svc_Cust_Ret_Target__c = 100;
            s.MTD_Sales_Current_Year__c = 100;
            s.Retention_As_of_Date__c = System.Today();
            s.As_of_Date__c = System.Today();
	        insert s;
	        
	        ServiceRetentionController ctl = new ServiceRetentionController();
	        ctl.AccountId = acc.Id;
	        ctl.getServiceRetention();
	        
	   Test.stopTest();	       
    }    
}