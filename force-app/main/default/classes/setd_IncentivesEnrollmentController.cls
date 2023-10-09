/* Name:  setd_IncentivesEnrollmentController
Created By:  SET Salesforce System Admin
Created Date:  2019-10-16
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_IncentivesEnrollmentController {

	@AuraEnabled
	public static setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('INC Enrollment');

		caseInfoObject.caseObject.Market_Challenge_Program_New_Car__c = 'No Change';
		caseInfoObject.caseObject.Market_Challenge_Program_Certified__c = 'No Change';
		caseInfoObject.caseObject.Pullboard_Program_New_Car__c = 'No Change';
		caseInfoObject.caseObject.Pullboard_Program_Certified__c = 'No Change';
		return caseInfoObject;
	}

	@AuraEnabled
	public static PicklistWrapper getPicklists() {
		return new PicklistWrapper();
	}

	public class PicklistWrapper {
		@AuraEnabled
		public avs_PicklistUtil.PicklistValue[] marketChallengeProgramsNewCar { get; set; }
		@AuraEnabled
		public avs_PicklistUtil.PicklistValue[] marketChallengeProgramsCertified { get; set; }
		@AuraEnabled
		public avs_PicklistUtil.PicklistValue[] pullboardProgramsNewCar { get; set; }
		@AuraEnabled
		public avs_PicklistUtil.PicklistValue[] pullboardProgramsCertified { get; set; }
		@AuraEnabled
		public PayeeTypeWrapper[] payeeTypeWrapper { get; set; }

		public PicklistWrapper() {
			avs_PicklistUtil utilities = new avs_PicklistUtil();
			this.marketChallengeProgramsNewCar = utilities.getPicklistValues('Case', 'Market_Challenge_Program_New_Car__c');
			this.marketChallengeProgramsCertified = utilities.getPicklistValues('Case', 'Market_Challenge_Program_Certified__c');
			this.pullboardProgramsNewCar = utilities.getPicklistValues('Case', 'Pullboard_Program_New_Car__c');
			this.pullboardProgramsCertified = utilities.getPicklistValues('Case', 'Pullboard_Program_Certified__c');
			setPayeeTypes();
		}
		
		private void setPayeeTypes() {
			List<PayeeTypeWrapper> payeeTypes = new List<PayeeTypeWrapper>();
			avs_PicklistUtil utilities = new avs_PicklistUtil();
			for (avs_PicklistUtil.PicklistValue entry : utilities.getPicklistValues('Payee__c', 'Payee_Type__c')) {
				if (entry.value == 'New_Car_Market_Challenge') {
					payeeTypes.add(new PayeeTypeWrapper('Market_Challenge_Program_New_Car__c', entry));
				}
				if (entry.value == 'TCUV_Market_Challenge') {
					payeeTypes.add(new PayeeTypeWrapper('Market_Challenge_Program_Certified__c', entry));
				}
				if (entry.value == 'New_Car_Pullboard_Program') {
					payeeTypes.add(new PayeeTypeWrapper('Pullboard_Program_New_Car__c', entry));
				}
				if (entry.value == 'TCUV_Pullboard_Challenge') {
					payeeTypes.add(new PayeeTypeWrapper('Pullboard_Program_Certified__c', entry));
				}
			}
			this.payeeTypeWrapper = payeeTypes;
		}
	}
	
	public class PayeeTypeWrapper {
		@AuraEnabled
		public String enrollmentType;
		@AuraEnabled
		public avs_PicklistUtil.PicklistValue picklistEntry;
		
		public PayeeTypeWrapper(String enrollmentType, avs_PicklistUtil.PicklistValue picklistEntry) {
			this.enrollmentType = enrollmentType;
			this.picklistEntry = picklistEntry;
		}
	}
}