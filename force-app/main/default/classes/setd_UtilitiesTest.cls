@IsTest
private class setd_UtilitiesTest {
	
	@IsTest
	private static void getFieldValue_mockSObject_DefaultSet() {
		Account testAccount = new Account(Name = 'test account');
		
		setd_Utilities utilities = new setd_Utilities();
		String result = utilities.getFieldValue(testAccount, 'Name');
		System.assertEquals('test account', result, 'Default field was not set correctly');
	}
	
	@IsTest
	private static void getFieldValue_mockNullSObject_DefaultSet() {
		Contact testContact = null;
		
		setd_Utilities utilities = new setd_Utilities();
		String result = utilities.getFieldValue(testContact, 'Name');
		System.assertEquals(null, result, 'Default field was not set correctly');
	}
	
	@IsTest
	private static void getFieldValue_mockSObjectNullField_DefaultSet() {
		Account testAccount = new Account();
		
		setd_Utilities utilities = new setd_Utilities();
		String result = utilities.getFieldValue(testAccount, 'Name');
		System.assertEquals(null, result, 'Default field was not set correctly');
	}
	
	@IsTest
	private static void formatPhoneNumber_InvalidPhoneNumber_ValidPhoneNumber() {
		setd_Utilities utilities = new setd_Utilities();
		String result = utilities.formatPhoneNumber('(999) 345-2121');
		System.assertEquals('9993452121', result, 'Phone number not formatted correctly');
	}
	
	@IsTest
	private static void formatPhoneNumber_ValidPhoneNumber_ValidPhoneNumber() {
		setd_Utilities utilities = new setd_Utilities();
		String result = utilities.formatPhoneNumber(' 890 09 0980 0980');
		System.assertEquals('8900909800980', result, 'Phone number not formatted correctly');
	}
}