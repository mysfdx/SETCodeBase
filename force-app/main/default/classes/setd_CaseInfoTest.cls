@IsTest
private class setd_CaseInfoTest {
	
	@IsTest
	private static void createCaseInfoByFormName_MockData_CaseInfo() {
		setd_CaseInfo setdCaseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfo = setdCaseInfo.createCaseInfoByFormName('test_form');

		System.assertNotEquals(null, caseInfo.userObject, 'User record set incorrectly');
		System.assertNotEquals(null, caseInfo.caseObject, 'Case record not set correctly');
		System.assertEquals('test_form', caseInfo.caseObject.Form_Name__c, 'Incorrectly set form name on Case record');
	}

	@IsTest
	private static void createCaseObject_MockIds_Case() {
		Id fakeContactId = getFakeContactId();
		Id fakeAccountId = getFakeAccountId();

		setd_CaseInfo setdCaseInfo = new setd_CaseInfo();
		Case testCase = setdCaseInfo.createCaseObject('test_form', new Contact(Id=fakeContactId), new Account(Id=fakeAccountId));

		System.assertEquals('test_form', testCase.Form_Name__c, 'Form name was set incorrectly');
		System.assertNotEquals(null, testCase.RecordTypeId, 'Record type was not set on case');
		System.assertNotEquals(null, testCase.Community_Contact__c, 'Community contact was not set');
		System.assertNotEquals(null, testCase.AccountId, 'Account was not set');
	}

	private static Id getFakeContactId() {
		String fakeId =  Contact.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}

	private static Id getFakeAccountId() {
		String fakeId =  Account.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}
}