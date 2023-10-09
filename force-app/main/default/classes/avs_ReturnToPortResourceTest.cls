@IsTest
private class avs_ReturnToPortResourceTest {
	
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
	private static void insertReturnToPortForm_MockRequest_NoErrors() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(createTestRequest('tester@test.com', '0000'));
        req.requestURI='return-to-port';
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_ReturnToPortResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
	}
    @IsTest
	private static void insertETAForm_MockRequest_NoErrors() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(createTestRequest('tester@test.com', '0000'));
        req.requestURI='eta';
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_ReturnToPortResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
	}
    @IsTest
	private static void insertVoidForTradeForm_MockRequest_NoErrors() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(createTestRequest('tester@test.com', '0000'));
        req.requestURI='sold-order';
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_ReturnToPortResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
	}
	
    @IsTest
	private static void insertSoldOrderForm_MockRequest_NoErrors() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf(createTestRequest('tester@test.com', '0000'));
        req.requestURI='void-for-trade';
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_ReturnToPortResource.postMethod();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT Id FROM Case].size(), 'Incorrect number of cases inserted');
	}
    
	@IsTest
	private static void insertReturnToPortForm_MockRequest_1ErrorLog() {
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueOf('');
        req.requestURI='return-to-port';
		RestContext.request = req;
		RestContext.response = new RestResponse();
		
		Test.startTest();
		avs_ReturnToPortResource.postMethod();
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
		request.authorizedName = 'authorizedName';
		request.deliveryStatus = 'CUSTOMER';
		request.returnPort = 'Jacksonville';
		request.backhaulRequested = 'false';
		request.vin = 'vin';
        request.vin1 = 'vin1';
        request.etaReason = 'etaReason';
		request.model = 'model';
		request.accessory1 = 'accessory1';
        request.modelYear='2023';
        request.exteriorColor='Black';   
        request.salesPersonEmail='Test@test.com';
        request.salesPersonFirstName='Test';
        request.salesPersonLastName='Test';
        request.customerFirstName='Test';
        request.customerLastName='Test';
        request.buyerOrderVersionData='Test';
        request.buyersOrderFileName='Test.pdf';
        request.driverLicenseFileName='Test.pdf';
        request.driverLicenseVersionData='Test';   
		
		return JSON.serialize(request, true);
	}
}