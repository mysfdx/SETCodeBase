/* Name:  avs_ResourceFormValidation
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2022-07-04
Description: Added ETA and VFT.

Changelog 
Changed By - Date - Purpose
Neha Agrawal - 05/12/2023 - Added Sold Order form validations
*/

public class avs_ResourceFormValidation {
	
	@TestVisible private List<String> contactRequirements = new List<String> {
		'email', 'firstName', 'lastName', 'username', 'phone', 'dealerCode', 'dealerRole', 'spin'
	};
	@TestVisible private List<String> returnToPortRequired = new List<String> {
		'authorizedName', 'deliveryStatus', 'returnPort', 'backhaulRequested', 'vin', 'model', 'accessory1'
	};
	@TestVisible private List<String> incentivesChallengeRequired = new List<String> {
		'challenge', 'vin',  'model',  'modelYear',  'retailDate',  'contestNumber'
	};
	@TestVisible private List<String> monroneyRequestRequired = new List<String> {
		'preferredShipping', 'requestReason', 'vins'
	};
	@TestVisible private List<String> acctDupCOfORequired = new List<String> {
		'vin', 'model', 'modelYear', 'duplicateReason', 'titledVehicle', 'dealerSignature'
	};
    @TestVisible private List<String> etaRequired = new List<String> {
		'vin1', 'etaReason'
	};
    @TestVisible private List<String> voidForTradeRequired = new List<String> {
		'vin1'
	};
    @TestVisible private List<String> soldOrderRequired = new List<String> {
		'modelYear','model','series','exteriorColor','salesPersonFirstName','salesPersonLastName',
            'salesPersonEmail','customerFirstName','customerLastName','buyerOrderVersionData',
            'driverLicenseVersionData', 'buyersOrderFileName','driverLicenseFileName'
	};    

	public void validateFormRequest(FormRequest request) {
		validateContactDetails(request);
		if (request.formType == FormRequest.FormName.RETURN_TO_PORT) {
			validateRequiredFields(this.returnToPortRequired, request);
		} else if (request.formType == FormRequest.FormName.INCENTIVES_CHALLENGE) {
			validateRequiredFields(this.incentivesChallengeRequired, request);
		} else if (request.formType == FormRequest.FormName.MONRONEY_LABEL_REQUEST) {
			validateRequiredFields(this.monroneyRequestRequired, request);
		} else if (request.formType == FormRequest.FormName.ACCT_DUP_CERT_OF_ORIGIN) {
			validateRequiredFields(this.acctDupCOfORequired, request);
        } else if(request.formType == FormRequest.FormName.ETA){
            validateRequiredFields(this.etaRequired, request);
        } else if(request.formType == FormRequest.FormName.VOID_FOR_TRADE){
            validateRequiredFields(this.voidForTradeRequired, request);
        } else if(request.formType == FormRequest.FormName.SOLD_ORDER){
            validateRequiredFields(this.soldOrderRequired, request);
        } else {
			throw new NoSuchElementException('Form Type is not valid');
		}
	}
	
	private void validateContactDetails(FormRequest request) {
		List<String> missingFields = new List<String> ();
		String contactJson = (request.contact == null) ? '{}' : JSON.serialize(request.contact);
		Map<String, Object> deserializedForm = (Map<String, Object>)JSON.deserializeUntyped(contactJson);
		for (String fieldName : this.contactRequirements) {
			if (deserializedForm.get(fieldName) == null || String.isBlank(String.valueOf(deserializedForm.get(fieldName)))) {
				missingFields.add(fieldName);
			}
		}
		if (!missingFields.isEmpty()) {
			throw new avs_ResourceException('MissingRequiredFieldsException', 'Missing required contact fields: ' + String.join(missingFields, ', '), '');
		}
	}
	
	private void validateRequiredFields(List<String> requiredFields, FormRequest formRequest) {
		List<String> missingFields = new List<String> ();
		String formJson = JSON.serialize(formRequest);
		Map<String, Object> deserializedForm = (Map<String, Object>)JSON.deserializeUntyped(formJson);
		for (String fieldName : requiredFields) {
			Object value = deserializedForm.get(fieldName);
			if (value == null || String.isBlank(String.valueOf(value)) || String.valueOf(value).replaceAll(' ', '').equals('[]')) {
				missingFields.add(fieldName);
			}
		}
		if (!missingFields.isEmpty()) {
			throw new avs_ResourceException('MissingRequiredFieldsException', 'Missing required form fields: ' + String.join(missingFields, ','), '');
		}
	}
}