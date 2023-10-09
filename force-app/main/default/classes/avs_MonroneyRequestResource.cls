@RestResource(urlMapping='/forms/monroney-label-request/*')
global class avs_MonroneyRequestResource {
	
	@HttpPost
	global static String postMethod() {
		RestResponse response = RestContext.response;
		try {
			FormRequestDomain domain = new FormRequestDomain();
			FormRequest request = domain.deserializeFormRequest(FormRequest.FormName.MONRONEY_LABEL_REQUEST, RestContext.request.requestBody.toString());
			
			avs_ResourceSubmission submission = new avs_ResourceSubmission();
			Case caseRecord = submission.submitForm(request, 'DD Forms');
			response.statusCode = 201;
			return String.valueOf(new SalesforceResponse(caseRecord));
		} catch(avs_ResourceException e) {
			response.statusCode = 400;
			insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());
			return String.valueOf(new SalesforceResponse(false, e.getErrorMessage()));
		} catch(Exception e) {
			response.statusCode = 500;
			insert new API_Error_Log__c(Exception_Type__c = e.getTypeName(), Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString());
			return String.valueOf(new SalesforceResponse(false, e.getMessage()));
		}
	}
	
	public class SalesforceResponse {
		Boolean success { get; set; }
		String message { get; set; }
		String caseRecord { get; set; }
		
		public SalesforceResponse(Case caseRecord) {
			this.success = true;
			this.caseRecord = String.valueOf(caseRecord);
		}
		
		public SalesforceResponse(Boolean isSuccessful, String message) {
			this.success = isSuccessful;
			this.message = message;
		}
	}
}