@isTest(SeeAllData=TRUE) 
public with sharing class MTD_YTDSalesControllerTest {
   	static testMethod void testThisClass() {
    	Test.startTest();
    	    //Create the Account used for the test cases
	    	Account acc = testClientUtils.createAccount();
	    	Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            acc.RecordTypeId=rtByName.getRecordTypeId();
	    	insert acc;
	    	SET_Dealer_Performance_Metrics__c s = testClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
	    	s.YTD_Sales_Previous_Year__c = 1000;
            s.YTD_Sales_Current_Year__c = 1000;
            s.MTD_Sales_Previous_Year__c = 1000;
            s.MTD_Sales_Current_Year__c = 1000;
            s.As_of_Date__c = System.Today();
	        insert s;
	        MTD_YTDSalesController ctl = new MTD_YTDSalesController();
	        ctl.AccountId = acc.Id;
	        ctl.getChartAsOfDate();
	        MTD_YTDSalesController.retrieveMTDData(acc.Id, null,null);
	        MTD_YTDSalesController.retrieveYTDData(acc.Id, null,null);
	   Test.stopTest();
    }
}