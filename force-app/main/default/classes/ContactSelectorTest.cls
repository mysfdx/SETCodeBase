@IsTest
private class ContactSelectorTest {

	@TestSetup
	private static void setupTest() {
		Contact testContact1 = createTestContact('test1');
		Contact testContact2 = createTestContact('test2');
		Contact testContact3 = createTestContact('test3');
		insert new List<Contact> {
			testContact1, testContact2, testContact3
		};
	}

	@IsTest
	private static void selectById_3Ids_3Contacts() {
		Set<Id> testIds = new Map<Id, Contact>([SELECT Id FROM Contact LIMIT 3]).keySet();
		ContactSelector testSelector = new ContactSelector();
		List<Contact> results = testSelector.selectById(testIds);

		System.assertEquals(3, results.size(), 'Incorrect number of Contacts were returned');
	}

	@IsTest
	private static void selectById_1Id_1Contact() {
		Set<Id> testIds = new Map<Id, Contact>([SELECT Id FROM Contact LIMIT 1]).keySet();
		ContactSelector testSelector = new ContactSelector();
		List<Contact> results = testSelector.selectById(testIds);

		System.assertEquals(1, results.size(), 'Incorrect number of Contacts were returned');
	}

	@IsTest
	private static void selectById_1FakeId_0Contacts() {
		ContactSelector testSelector = new ContactSelector();
		List<Contact> results = testSelector.selectById(new Set<Id> { getFakeContactId() });

		System.assertEquals(0, results.size(), 'Incorrect number of Contacts were returned');
	}
	
	@IsTest
	private static void selectByEmail_2Email_2Contacts() {
		ContactSelector testSelector = new ContactSelector();
		List<Contact> results = testSelector.selectByEmail(new Set<String> { 'dummytest2@test.com', 'dummytest3@test.com' });
		
		System.assertEquals(2, results.size(), 'Incorrect number of Contacts were returned');
	}
	
	@IsTest
	private static void selectByUsername_1Username_1Contact() {
		ContactSelector testSelector = new ContactSelector();
		List<Contact> results = testSelector.selectByUsername(new Set<String> { 'test2@username' });
		
		System.assertEquals(1, results.size(), 'Incorrect number of Contacts were returned');
	}

	private static Contact createTestContact(String contactName) {
		return new Contact(
			FirstName = 'Test',
			LastName = contactName,
			Email = 'dummy' + contactName + '@test.com',
			Username__c = contactName + '@username'
		);
	}

	private static Id getFakeContactId() {
		String fakeId =  Contact.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}
}