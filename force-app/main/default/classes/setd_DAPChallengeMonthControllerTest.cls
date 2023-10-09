@IsTest
private class setd_DAPChallengeMonthControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_DAPChallengeMonthController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('DAP Challenge by Month', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}}