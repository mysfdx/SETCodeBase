@IsTest
private class PayeeValidationServiceTest {
	@IsTest
	private static void stampCaseIdOnPayees_testPayees_PayeesWithCaseIds() {
		Case testCase = new Case();
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', null),
			createTestPayee('New Car Pullboard Program', '234567890123', null),
			createTestPayee('New Car Pullboard Program', '345678901234', null)
		};
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		
		testService.stampCaseIdOnPayees(getFakeCaseId());
		for (Payee__c payee : testService.getPayees()) {
			System.assertNotEquals(null, payee.Case__c, 'Case Id was not stamped on payee record');
		}
	}
	
	@IsTest
	private static void getPayees_3TestPayees_3TestPayees() {
		Case testCase = new Case();
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', null),
			createTestPayee('New Car Pullboard Program', '234567890123', null),
			createTestPayee('New Car Pullboard Program', '345678901234', null)
		};
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		System.assertEquals(3, testService.getPayees().size(), 'Incorrect number of payees was returned');
	}
	
	@IsTest
	private static void validatePayees_1Type1ValidPercentagePayee_SuccessfulValidation() {
		Case testCase = new Case(Pullboard_Program_New_Car__c='Pay Individual', Market_Challenge_Program_New_Car__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', null),
			createTestPayee('New Car Pullboard Program', '234567890123', null),
			createTestPayee('New Car Market Challenge', '345678901234', 100)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals(null, exceptionType, 'Payee validation failed unexpectedly');
	}
	
	@IsTest
	private static void validatePayees_1Type2ValidPercentagePayees_SuccessfulValidation() {
		Case testCase = new Case(Pullboard_Program_New_Car__c='Pay Individual', Market_Challenge_Program_New_Car__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', 100),
			createTestPayee('New Car Market Challenge', '234567890123', 50),
			createTestPayee('New Car Market Challenge', '345678901234', 50)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals(null, exceptionType, 'Payee validation failed unexpectedly');
	}
	
	@IsTest
	private static void validatePayees_2TypeValidPercentagePayees_SuccessfulValidation() {
		Case testCase = new Case(Pullboard_Program_New_Car__c='Pay Individual', Market_Challenge_Program_New_Car__c='Pay Individual', Market_Challenge_Program_Certified__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', 100),
			createTestPayee('New Car Market Challenge', '234567890123', 100),
			createTestPayee('TCUV Market Challenge', '345678901234', 100)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals(null, exceptionType, 'Payee validation failed unexpectedly');
	}
	
	@IsTest
	private static void validatePayees_1InvalidPercentagePayees_ExceptionCaught() {
		Case testCase = new Case(Pullboard_Program_New_Car__c='Pay Individual', Market_Challenge_Program_New_Car__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', 100),
			createTestPayee('New Car Market Challenge', '234567890123', 30),
			createTestPayee('New Car Market Challenge', '345678901234', 50)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals('PayeeValidationService.TotalPercentageException', exceptionType, 'Validation exception was thrown incorrectly');
	}
	
	@IsTest
	private static void validatePayees_2InvalidPercentagePayees_ExceptionCaught() {
		Case testCase = new Case(Pullboard_Program_New_Car__c='Pay Individual', Market_Challenge_Program_New_Car__c='Pay Individual', Market_Challenge_Program_Certified__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', 10),
			createTestPayee('TCUV Market Challenge', '345678901234', 100),
			createTestPayee('New Car Market Challenge', '234567890123', 30),
			createTestPayee('New Car Market Challenge', '345678901234', 50)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals('PayeeValidationService.TotalPercentageException', exceptionType, 'Validation exception was thrown incorrectly');
	}
	
	@IsTest
	private static void validatePayees_2PayeeEnrollments1PayeeType_ExceptionCaught() {
		Case testCase = new Case(Market_Challenge_Program_New_Car__c='Pay Individual');
		List<Payee__c> testPayees = new List<Payee__c> {
			createTestPayee('New Car Pullboard Program', '123456789012', null),
			createTestPayee('TCUV Market Challenge', '345678901234', 100)
		};
		String exceptionType;
		PayeeValidationService testService = new PayeeValidationService(testCase, testPayees);
		try {
			testService.validatePayees();
		} catch(Exception e) {
			exceptionType = e.getTypeName();
		}
		System.assertEquals('PayeeValidationService.MissingPayeeTypeException', exceptionType, 'Validation exception was thrown incorrectly');
	}
	
	private static Payee__c createTestPayee(String payeeType, String spinId, Decimal percentage) {
		return new Payee__c(Payee_Type__c = payeeType, Percentage__c = percentage, SPIN_ID__c = spinId, First_Name__c='test', Last_Name__c='payee');
	}
	
	private static Id getFakeCaseId() {
		String fakeId =  Case.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
		return Id.valueOf(fakeId);
	}
}