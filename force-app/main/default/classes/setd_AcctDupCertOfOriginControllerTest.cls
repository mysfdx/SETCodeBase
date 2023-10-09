@IsTest
private class setd_AcctDupCertOfOriginControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_AcctDupCertOfOriginController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('ACCT Dup C of O', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	@IsTest
	private static void getReasonForDuplicates_NoArguments_NoExceptions() {
		String exceptionCaught;
		String errorMessage = '';
		try {
			List<avs_PicklistUtil.PicklistValue> picklistValues = setd_AcctDupCertOfOriginController.getReasonForDuplicates();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
			errorMessage = e.getMessage() + '; ' + e.getStackTraceString();
		}
		System.assertEquals(null, exceptionCaught, errorMessage);
	}
	
	@IsTest
	private static void getTitledVehicleOptions_NoArguments_NoExceptions() {
		String exceptionCaught;
		String errorMessage = '';
		try {
			List<avs_PicklistUtil.PicklistValue> picklistValues = setd_AcctDupCertOfOriginController.getTitledVehicleOptions();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
			errorMessage = e.getMessage() + '; ' + e.getStackTraceString();
		}
		System.assertEquals(null, exceptionCaught, errorMessage);
	}
}