@IsTest
private class setd_IncAchAuthorizationControllerTest {
	
	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_IncAchAuthorizationController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('INC ACH Authorization', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
    
    @IsTest
	private static void getPaymentOptions_NoArguments_NoExceptions() {
  		String exceptionCaught;
  		List<avs_PicklistUtil.PicklistValue> utilities;

  		try {
    		utilities = setd_IncAchAuthorizationController.getPaymentOptions();
  		} catch(Exception e) {
    		exceptionCaught = e.getTypeName();
  		}

		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
	}
}