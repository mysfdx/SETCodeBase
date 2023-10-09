@IsTest
private class AccountSelectorTest {

	@TestSetup
	private static void setupTest() {
		Account testAccount1 = createTestAccount('test1', '123');
		Account testAccount2 = createTestAccount('test2', '456');
		Account testAccount3 = createTestAccount('test3', '789');
		insert new List<Account> {
			testAccount1, testAccount2, testAccount3
		};
	}

	@IsTest
	private static void selectById_3Ids_3Accounts() {
		Set<Id> testIds = new Map<Id, Account> ([SELECT Id FROM Account LIMIT 3]).keySet();
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectById(testIds);

		System.assertEquals(3, results.size(), 'Incorrect number of Accounts were returned');
	}

	@IsTest
	private static void selectById_1Id_1Account() {
		Set<Id> testIds = new Map<Id, Account> ([SELECT Id FROM Account LIMIT 1]).keySet();
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectById(testIds);

		System.assertEquals(1, results.size(), 'Incorrect number of Accounts were returned');
	}

	@IsTest
	private static void selectById_1FakeId_0Accounts() {
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectById(new Set<Id> { getFakeAccountId() });

		System.assertEquals(0, results.size(), 'Incorrect number of Accounts were returned');
	}

	@IsTest
	private static void selectByDealerCode_3Codes_3Accounts() {
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectByDealerCode(new Set<String> { '123', '456', '789' });

		System.assertEquals(3, results.size(), 'Incorrect number of Accounts were returned');
	}

	@IsTest
	private static void selectByDealerCode_1Code_1Account() {
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectByDealerCode(new Set<String> { '123' });

		System.assertEquals(1, results.size(), 'Incorrect number of Accounts were returned');
	}

	@IsTest
	private static void selectByDealerCode_1FakeCode_0Accounts() {
		AccountSelector testSelector = new AccountSelector();
		List<Account> results = testSelector.selectByDealerCode(new Set<String> { '999' });

		System.assertEquals(0, results.size(), 'Incorrect number of Accounts were returned');
	}

	private static Account createTestAccount(String accountName, String dealerCode) {
		return new Account(
			Name = 'Test ' + accountName,
			Dealer_Code__c = dealerCode
		);
	}

	private static Id getFakeAccountId() {
		String fakeId =  Account.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}
}