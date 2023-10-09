@isTest
public with sharing class AreaDashboardControllerTest {
    static testMethod void testThisClass() {
    	Test.startTest();
    	    Id masterAccountId = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
	        District_Area_Ownership_Mapping__c damap = testClientUtils.createDistrictAreaOwnershipMapping('0', '1', UserInfo.getUserId(), 'Area');
	        insert damap;
	        PageReference p = Page.AreaDashboard;
	        p.getParameters().put('area','0');
	        Test.setCurrentPage(p);
	        AreaDashboardController ctl = new AreaDashboardController();
	        ctl.getDistricts();	        
    	Test.stopTest();
    }
}