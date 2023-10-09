@IsTest
private class setd_AcctAchPtsTermsInsControllerTest {

	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_AcctAchPtsTermsInsController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('ACCT ACH PTS TERMS/INS', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
}