@IsTest
private class setd_MCBChallengeControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_MCBChallengeController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('ACCT MCB Challenge', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
}