@IsTest
private class avs_ResourceFormValidationTest {

	@IsTest
	private static void validateFormRequest_ReturnToPortForm_NoExceptions() {
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.RETURN_TO_PORT;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.returnPort = '098098';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.returnToPortRequired = new List<String> { 'returnPort' };
		try {
			testValidation.validateFormRequest(request);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorMessage = e.getTypeName();
		}
		System.assertEquals(null, errorMessage, 'Validation exception was thrown unexpectedly : ' + errorMessage);
	}
	
	@IsTest
	private static void validateFormRequest_ReturnToPortForm_MissingRequirements() {
		String errorType;
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.RETURN_TO_PORT;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.returnToPortRequired = new List<String> { 'returnPort' };
		try {
			testValidation.validateFormRequest(request);
		}  catch(avs_ResourceException e) {
			errorType = e.getExceptionName();
			errorMessage = e.getErrorMessage();
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorType = e.getTypeName();
			errorMessage = e.getMessage();
		}
		System.assertEquals('MissingRequiredFieldsException', errorType, 'Validation passed unexpectedly');
		System.assertEquals('Missing required form fields: returnPort', errorMessage, 'Error message does not match expected');
	}
	
	@IsTest
	private static void validateFormRequest_IncChallengeForm_NoExceptions() {
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.INCENTIVES_CHALLENGE;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.challengeReason = 'test';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.incentivesChallengeRequired = new List<String> { 'challengeReason' };
		try {
			testValidation.validateFormRequest(request);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorMessage = e.getTypeName();
		}
		System.assertEquals(null, errorMessage, 'Validation exception was thrown unexpectedly : ' + errorMessage);
	}
	
	@IsTest
	private static void validateFormRequest_IncChallengeForm_MissingRequirements() {
		String errorType;
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.INCENTIVES_CHALLENGE;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.incentivesChallengeRequired = new List<String> { 'challengeReason' };
		try {
			testValidation.validateFormRequest(request);
		}  catch(avs_ResourceException e) {
			errorType = e.getExceptionName();
			errorMessage = e.getErrorMessage();
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorType = e.getTypeName();
			errorMessage = e.getMessage();
		}
		System.assertEquals('MissingRequiredFieldsException', errorType, 'Validation passed unexpectedly');
		System.assertEquals('Missing required form fields: challengeReason', errorMessage, 'Error message does not match expected');
	}
	
	@IsTest
	private static void validateFormRequest_MonroneyRequestForm_NoExceptions() {
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.MONRONEY_LABEL_REQUEST;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.vins = new List<String> { '0000' };
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.monroneyRequestRequired = new List<String> { 'vins' };
		try {
			testValidation.validateFormRequest(request);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorMessage = e.getTypeName();
		}
		System.assertEquals(null, errorMessage, 'Validation exception was thrown unexpectedly : ' + errorMessage);
	}
	
	@IsTest
	private static void validateFormRequest_MonroneyRequestForm_MissingRequirements() {
		String errorType;
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.MONRONEY_LABEL_REQUEST;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.monroneyRequestRequired = new List<String> { 'vins' };
		try {
			testValidation.validateFormRequest(request);
		}  catch(avs_ResourceException e) {
			errorType = e.getExceptionName();
			errorMessage = e.getErrorMessage();
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorType = e.getTypeName();
			errorMessage = e.getMessage();
		}
		System.assertEquals('MissingRequiredFieldsException', errorType, 'Validation passed unexpectedly');
		System.assertEquals('Missing required form fields: vins', errorMessage, 'Error message does not match expected');
	}
	
	@IsTest
	private static void validateFormRequest_AcctDupCOfOForm_NoExceptions() {
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.ACCT_DUP_CERT_OF_ORIGIN;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.titledVehicle = 'true';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.acctDupCOfORequired = new List<String> { 'titledVehicle' };
		try {
			testValidation.validateFormRequest(request);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorMessage = e.getTypeName();
		}
		System.assertEquals(null, errorMessage, 'Validation exception was thrown unexpectedly : ' + errorMessage);
	}
	
	@IsTest
	private static void validateFormRequest_AcctDupCOfOForm_MissingRequirements() {
		String errorType;
		String errorMessage;
		FormRequest request = new FormRequest();
		request.formType = FormRequest.FormName.ACCT_DUP_CERT_OF_ORIGIN;
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = 'test@email.com';
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		
		avs_ResourceFormValidation testValidation = new avs_ResourceFormValidation();
		testValidation.contactRequirements = new List<String> { 'firstName', 'lastName', 'email' };
		testValidation.acctDupCOfORequired = new List<String> { 'titledVehicle' };
		try {
			testValidation.validateFormRequest(request);
		}  catch(avs_ResourceException e) {
			errorType = e.getExceptionName();
			errorMessage = e.getErrorMessage();
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
			errorType = e.getTypeName();
			errorMessage = e.getMessage();
		}
		System.assertEquals('MissingRequiredFieldsException', errorType, 'Validation passed unexpectedly');
		System.assertEquals('Missing required form fields: titledVehicle', errorMessage, 'Error message does not match expected');
	}
}