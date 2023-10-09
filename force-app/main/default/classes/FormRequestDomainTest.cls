@IsTest
public class FormRequestDomainTest {

	@IsTest
	private static void deserializeFormRequest_ValidJsonString_FormRequest() {
		String jsonString = '{' +
			'"deliveryStatus": "sample",' +
			'"contact":{"email": "sample"},' +
			'"faxNumber": "sample",' +
			'"fedexNumber": "sample",' +
			'"incentiveAmount": "sample",' +
			'"model": "sample",' +
			'"modelYear": "sample"' +
		'}';
		
		String exceptionThrown;
		try {
			FormRequestDomain testDomain = new FormRequestDomain();
			FormRequest result = testDomain.deserializeFormRequest(FormRequest.FormName.RETURN_TO_PORT, jsonString);
		} catch(Exception e) {
			exceptionThrown = e.getTypeName();
		}

		System.assertEquals(null, exceptionThrown, 'Exception was thrown unexpectedly');
	}
	
	@IsTest
	private static void deserializeFormRequest_ValidJsonString_InvalidRequestException() {
		String jsonString = '{' +
			'"invalidField1": "sample",' +
			'"invalidField2": "sample",' +
			'"invalidField3": "sample"' +
		'}';
		
		String exceptionThrown;
		try {
			FormRequestDomain testDomain = new FormRequestDomain();
			FormRequest result = testDomain.deserializeFormRequest(FormRequest.FormName.INCENTIVES_CHALLENGE, jsonString);
		} catch(Exception e) {
			exceptionThrown = e.getTypeName();
		}
		
		System.assertEquals('FormRequestDomain.InvalidRequestException', exceptionThrown, 'Exception was thrown unexpectedly');
	}
}