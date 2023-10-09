/* Name:  setd_AcctDupCertOfOriginController
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_AcctDupCertOfOriginController {
	
	@AuraEnabled
	static public setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('ACCT Dup C of O');
		
		setd_Utilities utilities = new setd_Utilities();
		caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
		caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
		return caseInfoObject;
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getReasonForDuplicates() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Reason_for_Duplicate__c');
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getTitledVehicleOptions() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Vehicle_Titled__c');
	}
}