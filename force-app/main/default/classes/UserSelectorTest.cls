@IsTest
private class UserSelectorTest {

	@TestSetup
	private static void setupTest() {
		User testUser1 = createTestUser('test1', '123-456-7891');
		User testUser2 = createTestUser('test2', '123-456-7892');
		User testUser3 = createTestUser('test3', '123-456-7893');
		insert new List<User> {
			testUser1, testUser2, testUser3
		};
	}

	@IsTest
	private static void selectById_3Ids_3Users() {
		Set<Id> testIds = new Map<Id, User>([SELECT Id FROM User LIMIT 3]).keySet();
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectById(testIds);

		System.assertEquals(3, results.size(), 'Incorrect number of users were returned');
	}

	@IsTest
	private static void selectById_1Id_1User() {
		Set<Id> testIds = new Map<Id, User>([SELECT Id FROM User LIMIT 1]).keySet();
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectById(testIds);

		System.assertEquals(1, results.size(), 'Incorrect number of users were returned');
	}

	@IsTest
	private static void selectById_1FakeId_0Users() {
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectById(new Set<Id> { getFakeUserId() });

		System.assertEquals(0, results.size(), 'Incorrect number of users were returned');
	}
	
	@IsTest
	private static void selectByUsername_1Email_1Users() {
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectByUsername(new Set<String> { 'dummytest1@username.com' });
		
		System.assertEquals(1, results.size(), 'Incorrect number of users were returned');
	}
	
	@IsTest
	private static void selectByUsername_1Email_0Users() {
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectByUsername(new Set<String> { 'test99@username.com' });
		
		System.assertEquals(0, results.size(), 'Incorrect number of users were returned');
	}
	
	@IsTest
	private static void selectByContactId_1ContactId_0Users() {
		UserSelector testSelector = new UserSelector();
		List<User> results = testSelector.selectByContactId(new Set<Id> { Contact.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12) });
		
		System.assertEquals(0, results.size(), 'Incorrect number of users were returned');
	}

	private static User createTestUser(String userName, String mobileNumber) {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		return new User(
			FirstName = 'Test',
			LastName = userName,
			Username = 'dummy'+userName + '@username.com',
			CompanyName = 'COMPANY',
			Title = 'Mr',
			Email = 'dummy' + userName + '@test.com',
			MobilePhone = mobileNumber,
			Alias = 'other',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US',
			ProfileId = testProfile.Id
		);
	}

	private static Id getFakeUserId() {
		String fakeId =  User.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}
}