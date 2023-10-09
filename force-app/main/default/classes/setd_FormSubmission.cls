/* Name:  setd_FormSubmission
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-04-06
Description:   
*/

public without sharing class setd_FormSubmission {
	public Case caseRecord { get; set; }
	public Payee__c[] payees { get; set; }
	public Vehicle__c[] vehicles { get; set; }
	public VIN__c[] vins { get; set; }
	public String[] vinEntries { get; set; }
	
	PayeeValidationService payeeValidationService;
	
	public Case submitFormObject() {
		initializeValidations();
		insert this.caseRecord;
		postSubmissionInserts();
		
		return [SELECT Id, RecordTypeId, Form_Name__c, CaseNumber, AccountId, Community_Contact__c,Challenge__c FROM Case WHERE Id = :this.caseRecord.Id LIMIT 1];
	}
	
	private void initializeValidations() {
		this.payeeValidationService = new PayeeValidationService(this.caseRecord, this.payees);
		if (this.caseRecord.Form_Name__c == 'INC Enrollment') {
			payeeValidationService.validatePayees();
		}
	}
	
	private void postSubmissionInserts() {
		insertPayees();
		insertVehicles();
		insertVinEntries();
		updateCaseContact();
	}
	
	private void insertPayees() {
		if (this.payees != null && !this.payees.isEmpty()) {
			payeeValidationService.stampCaseIdOnPayees(caseRecord.Id);
			insert payeeValidationService.getPayees();
		}
	}
	
	private void insertVehicles() {
		if (this.vehicles != null && !this.vehicles.isEmpty()) {
			for (Vehicle__c vehicle : this.vehicles) {
				vehicle.Case__c = this.caseRecord.Id;
			}
			insert this.vehicles;
		}
	}
	
	private void insertVinEntries() {
		if (this.vinEntries != null && !this.vinEntries.isEmpty()) {
			List<VIN__c> vinCollection = new List<VIN__c> ();
			for(String vinEntry : this.vinEntries) {
				vinCollection.add(new VIN__c(Name = vinEntry, Case__c = this.caseRecord.Id));
			}
			insert vinCollection;
		} else if (this.vins != null && !this.vins.isEmpty()) {
			for(VIN__c vin : this.vins) {
				vin.Case__c = this.caseRecord.Id;
			}
			insert this.vins;
		}
	}
	
	private void updateCaseContact() {
		String updatedPhone = this.caseRecord.RTP_Contact_Phone__c;
		if (String.isNotBlank(updatedPhone) && (String.isBlank(this.caseRecord.Submitted_On_Behalf_Of_Dealer__c) || this.caseRecord.Submitted_On_Behalf_Of_Dealer__c.equalsIgnoreCase('No'))) {
			SObject updatedContact = this.caseRecord.Community_Contact__c.getSObjectType().newSObject(this.caseRecord.Community_Contact__c);
			updatedContact.put('Phone', updatedPhone);
			update updatedContact;
		}
	}
}