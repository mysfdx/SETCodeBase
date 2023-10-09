@IsTest
private class setd_CaseViewControllerTest {

	@IsTest
	private static void getFields_IncentivesChallenge_MetadataFields() {
		Case testCase = new Case(Form_Name__c = 'Incentives Challenge');
		insert testCase;
		
		setd_CaseViewController.isPortalUser();
		List<String> metadataFields = setd_CaseViewController.getFields(testCase.Id);

		System.assertEquals(false, metadataFields.isEmpty(), 'No available detail fields for form type');
	}
}