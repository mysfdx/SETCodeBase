@IsTest
private class setd_FormSubmissionTest {
	
	@TestSetup
	private static void setupTest() {
		insert new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'mock@email.com');
	}
	
	@IsTest
	private static void submitFormObject_PayeesInserted() {
		Case mockCase = new Case();
		List<Payee__c> testPayees = new List<Payee__c> {
			new Payee__c(Percentage__c = 100, Payee_Type__c = 'New_Car_Market_Challenge', SPIN_ID__c = '0000000000', First_Name__c = 'test', Last_Name__c = 'payee')
		};
		
		setd_FormSubmission formSubmission = new setd_FormSubmission();
		formSubmission.caseRecord = mockCase;
		formSubmission.payees = testPayees;
		formSubmission.submitFormObject();
		
		List<Case> caseRecords = [SELECT Id FROM Case];
		System.assertEquals(1, caseRecords.size(), 'Case record was not inserted');
		List<Payee__c> payees = [SELECT Id, Case__c FROM Payee__c];
		System.assertEquals(1, payees.size(), 'Payees were not inserted correctly');
		System.assertNotEquals(null, payees[0].Case__c, 'Case lookup was not stamped correctly');
	}
	
	
	@IsTest
	private static void submitFormObject_VehiclesInserted() {
		Case mockCase = new Case();
		List<Vehicle__c> testVehicles = new List<Vehicle__c> { new Vehicle__c() };
		
		setd_FormSubmission formSubmission = new setd_FormSubmission();
		formSubmission.caseRecord = mockCase;
		formSubmission.vehicles = testVehicles;
		formSubmission.submitFormObject();
		
		List<Case> caseRecords = [SELECT Id FROM Case];
		System.assertEquals(1, caseRecords.size(), 'Case record was not inserted');
		List<Vehicle__c> vehicles = [SELECT Id, Case__c FROM Vehicle__c];
		System.assertEquals(1, vehicles.size(), 'Vehicles were not inserted correctly');
		System.assertNotEquals(null, vehicles[0].Case__c, 'Case lookup was not stamped correctly');
	}
	
	@IsTest
	private static void submitFormObject_VinEntriesInserted() {
		Case mockCase = new Case();
		List<String> testVins = new List<String> { '12345' };
		
		setd_FormSubmission formSubmission = new setd_FormSubmission();
		formSubmission.caseRecord = mockCase;
		formSubmission.vinEntries = testVins;
		formSubmission.submitFormObject();
		
		List<Case> caseRecords = [SELECT Id FROM Case];
		System.assertEquals(1, caseRecords.size(), 'Case record was not inserted');
		List<VIN__c> vinEntries = [SELECT Id, Case__c FROM VIN__c];
		System.assertEquals(1, vinEntries.size(), 'Vins were not inserted correctly');
		System.assertNotEquals(null, vinEntries[0].Case__c, 'Case lookup was not stamped correctly');
	}
	
	@IsTest
	private static void submitFormObject_VinObjectsInserted() {
		Case mockCase = new Case();
		List<VIN__c> testVins = new List<VIN__c> {
			new VIN__c(Name = 'Test 1', Model_Number__c = '1234'),
			new VIN__c(Name = 'Test 2', Model_Number__c = '0000')
		};
		
		setd_FormSubmission formSubmission = new setd_FormSubmission();
		formSubmission.caseRecord = mockCase;
		formSubmission.vins = testVins;
		formSubmission.submitFormObject();
		
		List<Case> caseRecords = [SELECT Id FROM Case];
		System.assertEquals(1, caseRecords.size(), 'Case record was not inserted');
		List<VIN__c> vinEntries = [SELECT Id, Case__c FROM VIN__c];
		System.assertEquals(2, vinEntries.size(), 'Vins were not inserted correctly');
		System.assertNotEquals(null, vinEntries[0].Case__c, 'Case lookup was not stamped correctly');
	}
}