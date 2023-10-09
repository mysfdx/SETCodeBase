@IsTest
private class setd_AppealsControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_AppealsController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('Appeals', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	@IsTest
	private static void getAccountDistricts_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_AppealsController.getAccountDistricts();
		
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}
	
	@IsTest
	private static void getReasonAppeals_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_AppealsController.getReasonAppeals();
		
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}
}