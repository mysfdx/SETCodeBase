/* Name:  PayeeValidationService
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class PayeeValidationService {
	Case caseRecord;
	Map<String, String> payeeEnrollmentsMap;
	Integer totalPercentage = 100;
	List<Payee__c> payees;
	
	public PayeeValidationService(Case caseRecord, List<Payee__c> payees) {
		this.caseRecord = caseRecord;
		this.payees = payees;
		this.payeeEnrollmentsMap = new Map<String, String> {
			'Market_Challenge_Program_New_Car__c' => 'New Car Market Challenge',
			'Market_Challenge_Program_Certified__c' => 'TCUV Market Challenge'
		};
	}
	
	public void stampCaseIdOnPayees(Id caseId) {
		for(Payee__c payee : this.payees) {
			payee.Case__c = caseId;
		}
	}
	
	public List<Payee__c> getPayees() {
		return this.payees;
	}
	
	public void validatePayees() {
		List<String> payeeEnrollments = getPayeeEnrollments();
		Map<String, Decimal> payeeTypeMap = getPayeeTypeMap();
		validatePayeeTypes(payeeEnrollments, payeeTypeMap.keySet());
		calculatePercentagePayees(payeeTypeMap);
		setPayeeTypes();
	}
	
	private List<String> getPayeeEnrollments() {
		List<String> payeeEnrollments = new List<String>();
		for (String enrollment : this.payeeEnrollmentsMap.keySet()) {
			String enrollmentValue = String.valueOf(this.caseRecord.get(enrollment));
			if (enrollmentValue == 'Pay Individual') {
				payeeEnrollments.add(enrollment);
			}
		}
		return payeeEnrollments;
	}
	
	private Map<String, Decimal> getPayeeTypeMap() {
		Map<String, Decimal> payeeTypeMap = new Map<String, Decimal>();
		for (Payee__c payee : this.payees) {
			validatePayee(payee);
			if (this.payeeEnrollmentsMap.values().contains(payee.Payee_Type__c)) {
				if (!payeeTypeMap.containsKey(payee.Payee_Type__c)) {
					payeeTypeMap.put(payee.Payee_Type__c, 0);
				}
				Decimal percentage = (payee.Percentage__c == null) ? 0 : payee.Percentage__c;
				Decimal percentageSum = payeeTypeMap.get(payee.Payee_Type__c) + percentage;
				payeeTypeMap.put(payee.Payee_Type__c, percentageSum);
			}
		}
		return payeeTypeMap;
	}
	
	private void validatePayee(Payee__c payee) {
		validatePayeeRequirements(payee);
		validateSPIN(payee);
	}
	
	private void validatePayeeRequirements(Payee__c payee) {
		if (payee.Payee_Type__c == null || payee.SPIN_ID__c == null || payee.First_Name__c == null || payee.Last_Name__c == null) {
			throw new InvalidPayeeException('Missing fields on Payee entry');
		}
	}
	
	private void validateSPIN(Payee__c payee) {
		if (String.valueOf(payee.SPIN_ID__c).length() != 12) {
			throw new InvalidPayeeException('Make sure SPIN ID entered is 12 digits');
		}
	}
	
	private void validatePayeeTypes(List<String> payeeEnrollments, Set<String> payeeTypesEntered) {
		Set<String> payeeTypesByEnrollments = new Set<String>();
		for (String enrollment : payeeEnrollments) {
			payeeTypesByEnrollments.add(this.payeeEnrollmentsMap.get(enrollment));
		}
		if (!payeeTypesEntered.containsAll(payeeTypesByEnrollments) || (payeeTypesByEnrollments.size() != payeeTypesEntered.size())) {
			throw new MissingPayeeTypeException('Missing Payee types according to your Enrollment selection');
		}
	}
	
	private void calculatePercentagePayees(Map<String, Decimal> payeeTypeMap) {
		for (String payeeType : payeeTypeMap.keySet()) {
			if (this.totalPercentage != payeeTypeMap.get(payeeType)) {
				throw new TotalPercentageException('Percentage does not equal 100% for: ' + payeeType);
			}
		}
	}
	
	private void setPayeeTypes() {
		for (Payee__c payee : this.payees) {
			payee.Payee_Type__c = payee.Payee_Type__c.replaceAll(' ', '_');
		}
	}
	
	public class InvalidPayeeException extends Exception { }
	public class TotalPercentageException extends Exception { }
	public class MissingPayeeTypeException extends Exception { }
}