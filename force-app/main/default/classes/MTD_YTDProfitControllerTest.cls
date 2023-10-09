@isTest(SeeAllData=TRUE)
public with sharing class MTD_YTDProfitControllerTest {
   	static testMethod void testThisClass() {
    	Test.startTest();
    	    Id masterAccountId = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
	    	//Create the Account used for the test cases
	    	Account acc = testClientUtils.createAccount();
	    	Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
            acc.RecordTypeId=rtByName.getRecordTypeId();
	    	insert acc;
	    	
	    	SET_Dealer_Performance_Metrics__c s = testClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
	    	s.YTD_Profit_Previous_Year__c = 1000;
            s.YTD_Profit_Current_Year__c = 1000;
            s.MTD_Profit_Previous_Year__c = 1000;
            s.MTD_Profit_Current_Year__c = 1000;
            s.As_of_Date__c = System.Today();
	        insert s;
	        
	        MTD_YTDProfitController ctl = new MTD_YTDProfitController();
	        ctl.AccountId = acc.Id;
	        ctl.getChartAsOfDate();
	        MTD_YTDProfitController.retrieveMTDData(acc.Id,null,null);
	        MTD_YTDProfitController.retrieveYTDData(acc.Id,null,null);
		Test.stopTest();	       
    }
    
}