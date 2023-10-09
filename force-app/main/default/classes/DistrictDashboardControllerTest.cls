@isTest
public with sharing class DistrictDashboardControllerTest {
    static testMethod void testThisClass() {
    	
    	Test.startTest();
    	    Id masterAccountId = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
	    	
	        District_Area_Ownership_Mapping__c damap = testClientUtils.createDistrictAreaOwnershipMapping('0', '1', UserInfo.getUserId(), 'Area');
	        insert damap;
	        
	        PageReference p = Page.DistrictDashboard;
	        p.getParameters().put('district','-1');
	        Test.setCurrentPage(p);
	        DistrictDashboardController ctl = new DistrictDashboardController();
	        ctl.getDealers();
	        
    	Test.stopTest();
    	    
    }    
}