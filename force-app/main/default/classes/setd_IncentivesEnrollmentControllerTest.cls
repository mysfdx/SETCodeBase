@IsTest
private class setd_IncentivesEnrollmentControllerTest {

	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_IncentivesEnrollmentController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('INC Enrollment', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}

	@IsTest
	private static void getPicklists_NoArguments_PicklistWrapper() {
		setd_IncentivesEnrollmentController.PicklistWrapper picklistWrapper = setd_IncentivesEnrollmentController.getPicklists();

		System.assertEquals(false, picklistWrapper.marketChallengeProgramsCertified.isEmpty(), 'No picklist entries were returned');
		System.assertEquals(false, picklistWrapper.marketChallengeProgramsNewCar.isEmpty(), 'No picklist entries were returned');
		System.assertEquals(false, picklistWrapper.pullboardProgramsCertified.isEmpty(), 'No picklist entries were returned');
		System.assertEquals(false, picklistWrapper.pullboardProgramsNewCar.isEmpty(), 'No picklist entries were returned');
		System.assertEquals(false, picklistWrapper.payeeTypeWrapper.isEmpty(), 'No picklist entries were returned');
	}
}