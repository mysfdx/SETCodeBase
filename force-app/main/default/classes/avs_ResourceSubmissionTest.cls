@IsTest
public class avs_ResourceSubmissionTest {
	
	@TestSetup
	private static void setupTest() {
		Account testAccount = new Account(Name = 'test account', Dealer_Code__c = '999');
		insert testAccount;
		
		Contact testContact = new Contact(FirstName = 'test', LastName = 'contact', Email = 'tester@test.com', Username__c = 'testingUsername');
		insert testContact;
	}
	
	@IsTest
	private static void submitForm_MockForm_SuccessfulNewContact() {
		FormRequest testRequest = createTestRequest('newTester@test.com', 'newUsername');
		avs_ResourceSubmission submission = new avs_ResourceSubmission();
		submission.submitForm(testRequest, 'Case');
		
		System.assertEquals(1, [SELECT Id FROM Contact WHERE Username__c = 'testingUsername'].size(), 'New contact failed to be created');
		Case resultCase = [SELECT Id, Community_Contact__c, AccountId FROM Case LIMIT 1];
		System.assertNotEquals(null, resultCase.Community_Contact__c, 'Contact lookup was not set correctly');
		System.assertNotEquals(null, resultCase.AccountId, 'Account lookup was not set correctly');
	}
	
	private static FormRequest createTestRequest(String email, String username) {
		FormRequest request = new FormRequest();
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = email;
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.contact.phone = '0000000000';
		request.contact.spin = '000';
		request.contact.username = username;
		request.contact.dealerRole = 'test';
		return request;
	}
}