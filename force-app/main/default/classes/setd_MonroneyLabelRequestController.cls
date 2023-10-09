/* Name:  setd_MonroneyLabelRequestController
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_MonroneyLabelRequestController {
	
	@AuraEnabled
	static public setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('NV Monroney Label Req');
		
		setd_Utilities utilities = new setd_Utilities();
		caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
		caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
		return caseInfoObject;
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getShippingOptions() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		List<avs_PicklistUtil.PicklistValue> results = utilities.getPicklistValues('Case', 'Preferred_Shipping__c');
		return results;
	}
	
	@AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getReasonRequests() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Reason_for_Request__c');
	}
}