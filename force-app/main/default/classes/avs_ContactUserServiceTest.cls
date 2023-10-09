@IsTest
private class avs_ContactUserServiceTest {
	
	@TestSetup
	private static void setupTest() {
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;
		
		Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', Username__c = 'test@username', AccountId = testAccount.Id);
		insert testContact;
	}
	
	@IsTest
	private static void insertNewContactFromDetail_MockContactDetail_ContactCreated() {
		Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
		Contact contact = new Contact(
			FirstName = 'testing',
			LastName = 'test',
			Email = 'testing@testing.com',
			Phone = '0912342345',
			Username__c = 'testUsername@dp',
			Current_Dealer_Role__c = '999'
		);
		
		avs_ContactUserService testService = new avs_ContactUserService();
		testService.insertNewContactRecord(contact, testAccount.Id);
		
		List<Contact> contacts = [SELECT Username__c, FirstName, LastName, Email, Current_Dealer_Role__c, Phone FROM Contact WHERE Email = 'testing@testing.com'];
		System.assertEquals(1, contacts.size(), 'Contact failed to be created');
		System.assertEquals('testing', contacts.get(0).FirstName, 'failed to be updated');
		System.assertEquals('test', contacts.get(0).LastName, 'failed to be updated');
		System.assertEquals('0912342345', contacts.get(0).Phone, 'failed to be updated');
		System.assertEquals('testUsername', contacts.get(0).Username__c, 'failed to be updated');
		System.assertEquals('999', contacts.get(0).Current_Dealer_Role__c, 'Current Dealer Role failed to be updated');
		System.assertEquals('0912342345', contacts.get(0).Phone, 'Phone failed to be updated');
	}
	
	@IsTest
	private static void updateContactFromDetail_MockCotactDetail_ContactUpdated() {
		Contact testContact = [SELECT Username__c, FirstName, LastName, Email FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
		Contact contact = new Contact(
			Phone = '0912342345',
			Current_Dealer_Role__c = '999'
		);
		
		avs_ContactUserService testService = new avs_ContactUserService();
		testService.updateContactRecord(contact, testContact.Id);
		
		Contact resultContact = [SELECT Username__c, FirstName, LastName, Email, Current_Dealer_Role__c, Phone FROM Contact WHERE Id = :testContact.Id];
		System.assertEquals('999', resultContact.Current_Dealer_Role__c, 'Current Dealer Role failed to be updated');
		System.assertEquals('0912342345', resultContact.Phone, 'Phone failed to be updated');
	}
	
	@IsTest
	private static void insertNewUser_SetupContact_UserCreated() {
		Contact testContact = [SELECT Username__c, FirstName, LastName, Email FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
		avs_ContactUserService testService = new avs_ContactUserService();
		testService.insertNewUser(testContact, 'Incentivetest');
		
		List<User> testUsers = [SELECT Id, FederationIdentifier FROM User WHERE ContactId = :testContact.Id];
		System.assertEquals(1, testUsers.size(), 'User failed to be created');
		System.assertEquals('Incentivetest', testUsers.get(0).FederationIdentifier, 'Federation Id was failed to be stamped on User');
	}
}