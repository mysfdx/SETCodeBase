/* Name:  setd_AppealsController
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_AppealsController {
	
	@AuraEnabled
	static public setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('Appeals');
		
		setd_Utilities utilities = new setd_Utilities();
		caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
		caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
		caseInfoObject.caseObject.SPIN__c = '104';
		return caseInfoObject;
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getReasonAppeals() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Reason_for_Appeal__c');
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getAccountDistricts() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Account', 'District__c');
	}
}