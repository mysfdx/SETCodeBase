@IsTest
private class setd_ModifyShipmentRequestControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_ModifyShipmentRequestController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('NV Stop Shipment Req', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	@IsTest
	private static void getShipmentActions_NoArguments_PicklistValues() {
		List<avs_PicklistUtil.PicklistValue> results = setd_ModifyShipmentRequestController.getShipmentActions();
		
		System.assert(!results.isEmpty(), 'Incorrect list of required documents returned');
	}
}