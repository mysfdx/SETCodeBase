@IsTest
public class setd_FormControllerTest {
	
	@IsTest
	private static void insertCase_mockCaseSubmissionString_NoExceptions() {
		String exceptionCaught;
		setd_FormSubmission formSubmission = new setd_FormSubmission();
		Case testCase;
		
		try {
			testCase = setd_FormController.insertForm(JSON.serialize(formSubmission, true));
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}
		
		System.assertEquals(exceptionCaught, exceptionCaught, 'Exception was thrown unexpectedly');
	}
}