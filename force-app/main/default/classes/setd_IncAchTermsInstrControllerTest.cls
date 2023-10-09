@IsTest
private class setd_IncAchTermsInstrControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_IncAchTermsInstrController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('INC ACH TERMS/INS', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	@IsTest
	private static void getCommunityDomain_FormsUrlDomain() {
		String results = setd_IncAchTermsInstrController.getCommunityDomain();
		
		System.assert(String.isNotBlank(results), 'Empty string was returned');
		System.assert(results.endsWith('Forms'), 'Incorrect form domain url was returned');
	}
}