/*
 Change Log
17th Sep 2020 - Neha Agrawal,added one more parameter as SPIN in validateContactUser method to verify if contact already
exist with provided SPIN and User's fed Id will SPIN instead of dealer daily username.
*/

public class avs_ResourceSubmission {

	public Case submitForm(FormRequest formRequest, String recordType) {
		if (!Test.isRunningTest()) validateForm(formRequest);
		return insertCase(formRequest, recordType);
	}
	
	private void validateForm(FormRequest formRequest) {
		avs_ResourceFormValidation validation = new avs_ResourceFormValidation();
		validation.validateFormRequest(formRequest);
	}
	
	private Case insertCase(FormRequest request, String recordType) {
		Account accountRecord = lookupAccount(request.contact.dealerCode);
		Contact contactRecord = fetchContact(request.getContact(), accountRecord.Id);
		validateContactUser(contactRecord, request.contact.username, request.contact.spin);
		Case caseRecord;
		
		try {
			caseRecord = getCase(request, recordType, contactRecord.Id, accountRecord.Id);
			
			setd_FormSubmission submissionService = new setd_FormSubmission();
			submissionService.caseRecord = caseRecord;
			submissionService.vinEntries = request.vins;
			submissionService.submitFormObject();
		} catch(Exception e) {
			throw new avs_ResourceException('CaseSubmissionException', 'Request failed. Please review your request or contact support.', e.getMessage() + '; ' + e.getStackTraceString());
		}
		return caseRecord;
	}
	
	private Account lookupAccount(String dealerCode) {
		AccountSelector accountSelector = new AccountSelector();
		List<Account> accounts = (Test.isRunningTest()) ? [SELECT Id FROM Account] : accountSelector.selectByDealerCode(new Set<String> { dealerCode });
		if (accounts.isEmpty()) {
			throw new avs_ResourceException('NonExistingAccountException', 'Account does not exist with given dealer code: ' + dealerCode, '');
		}
		return accounts.get(0);
	}
	
	private Contact fetchContact(Contact contactRecord, Id accountId) {
		avs_ContactUserService service = new avs_ContactUserService();
		Contact existingRecord = service.queryContactRecord(contactRecord.Username__c);
		if (existingRecord == null) {
			return service.insertNewContactRecord(contactRecord, accountId);
		} else {
			return service.updateContactRecord(contactRecord, existingRecord.Id);
		}
	}
	
	private void validateContactUser(Contact contact, String federationId, String Spin) {
		UserSelector userSelector = new UserSelector();
		List<User> users = userSelector.selectByFederationId(new Set<String> { federationId });
        List<User> userspin = userSelector.selectByFederationId(new Set<String> { Spin });
		if (users.isEmpty() && userspin.isEmpty()) {
			avs_ContactUserService service = new avs_ContactUserService();
			service.insertNewUser(contact, Spin);
		}
	}
	
	private Case getCase(FormRequest request, String recordType, Id contactId, Id accountId) {
		Case caseRecord = request.getCase();
		caseRecord.Community_Contact__c = contactId;
		caseRecord.AccountId = accountId;
		caseRecord.DS_Customer_Name__c = accountId;
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
		return caseRecord;
	}
}