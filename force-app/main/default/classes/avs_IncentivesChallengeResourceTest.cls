@IsTest
private class avs_IncentivesChallengeResourceTest {
	
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
		avs_IncentivesChallengeResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
	}
	
	@IsTest
	private static void postMethod_MockRequest_1ErrorLog() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf('');
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_IncentivesChallengeResource.postMethod();
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
		request.challenge = 'Other';
		request.vin = '000';
		request.model = '0000';
		request.modelYear = '0000';
		request.retailDate = '2019-01-01';
		request.contestNumber = '00000';
		
		return JSON.serialize(request, true);
	}
}