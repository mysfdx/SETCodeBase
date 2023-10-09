/*
Change Log
08/13/2020 Neha Agrawal Changed the return type of Post method so that response can be in JSON format.
*/

@RestResource(urlMapping='/forms/incentives-challenge/*')
global class avs_IncentivesChallengeResource {
	
	@HttpPost
	global static SalesforceResponse postMethod() {
		RestResponse response = RestContext.response;
		try {
			FormRequestDomain domain = new FormRequestDomain();
			FormRequest request = domain.deserializeFormRequest(FormRequest.FormName.INCENTIVES_CHALLENGE, RestContext.request.requestBody.toString());
			
			avs_ResourceSubmission submission = new avs_ResourceSubmission();
			Case caseRecord = submission.submitForm(request, 'Dealer Incentives Challenge');
			response.statusCode = 201;
			return new SalesforceResponse(caseRecord);
		} catch(avs_ResourceException e) {
			response.statusCode = 400;
			insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());
			return new SalesforceResponse(false, e.getErrorMessage());
		} catch(Exception e) {
			response.statusCode = 500;
			insert new API_Error_Log__c(Exception_Type__c = e.getTypeName(), Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString());
			return new SalesforceResponse(false, e.getMessage());
		}
	}
	
	global class SalesforceResponse {
		Boolean success { get; set; }
		String message { get; set; }
		case caseRecord { get; set; }
        String CaseNumber { get; set; }
		
		global SalesforceResponse(Case caseRecord) {
			this.success = true;
			this.caseRecord = caseRecord;
            this.CaseNumber= [Select Casenumber,id from Case where id=:caseRecord.id].caseNumber;
		}
		
		global SalesforceResponse(Boolean isSuccessful, String message) {
			this.success = isSuccessful;
			this.message = message;
		}
	}
}