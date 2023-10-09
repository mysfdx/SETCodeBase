@IsTest
private class setd_MonroneyLabelRequestControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_MonroneyLabelRequestController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('NV Monroney Label Req', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	@IsTest
	private static void getReasonRequests_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_MonroneyLabelRequestController.getReasonRequests();
		
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}
	
	@IsTest
	private static void getShippingOptions_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_MonroneyLabelRequestController.getShippingOptions();
		
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}
}