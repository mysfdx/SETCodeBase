@IsTest
private class setd_ReturnToPortControllerTest {

	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_ReturnToPortController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('Return to Port', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}

	@IsTest
	private static void getReturnToPorts_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_ReturnToPortController.getReturnToPorts();
	
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}

	@IsTest
	private static void getVehicleDeliveryStatuses_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> picklistValues = setd_ReturnToPortController.getVehicleDeliveryStatuses();
		
		System.assertEquals(false, picklistValues.isEmpty(), 'No picklist entries were returned');
	}
}