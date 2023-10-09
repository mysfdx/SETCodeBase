@IsTest
private class avs_MonroneyRequestResourceTest {
	
	@TestSetup
	private static void setupTest() {
		Account testAccount = new Account(Name = 'test account', Dealer_Code__c = '0000');
		insert new List<Account> {
			testAccount
		};
		
		Contact testContact = new Contact(FirstName = 'test', LastName = 'contact', Email = 'tester@test.com');
		insert new List<Contact> {
			testContact
		};
	}
	
	@IsTest
	private static void postMethod_MockRequest_NoErrors() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(createTestRequest('tester@test.com', '0000'));
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_MonroneyRequestResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
		System.assertEquals(3, [SELECT Id FROM VIN__c].size(), 'Incorrect number vins were inserted');
	}
	
	@IsTest
	private static void postMethod_MockRequest_1ErrorLog() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf('');
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_MonroneyRequestResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(0, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
		System.assertEquals(1, [SELECT Id FROM API_Error_Log__c].size(), 'Error logs failed to be inserted');
	}
	
	private static String createTestRequest(String email, String dealerCode) {
		FormRequest request = new FormRequest();
		request.contact = new FormRequest.ContactDetail();
		request.contact.email = email;
		request.contact.firstName = 'john';
		request.contact.lastName = 'doe';
		request.contact.phone = '0000000000';
		request.contact.dealerCode = dealerCode;
		request.contact.spin = '000';
		request.contact.username = 'test';
		request.contact.dealerRole = 'test';
		request.preferredShipping = 'US_MAIL';
		request.requestReason = 'Other';
		request.vins = new List<String> { '000', '000', '000' };

		
		return JSON.serialize(request, true);
	}
}