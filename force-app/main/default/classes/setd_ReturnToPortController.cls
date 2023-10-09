/* Name:  setd_ReturnToPortController
Created By:  SET Salesforce System Admin
Created Date:  2019-10-16
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_ReturnToPortController {

	@AuraEnabled
	static public setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('Return to Port');

		setd_Utilities utilities = new setd_Utilities();
		caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.contactObject, 'FirstName') + ' ' + utilities.getFieldValue(caseInfoObject.contactObject, 'LastName');
		caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
		return caseInfoObject;
	}

	@AuraEnabled
	static public List<avs_PicklistUtil.PicklistValue> getReturnToPorts()  {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Return_to_Port__c');
	}

	@AuraEnabled
	static public List<avs_PicklistUtil.PicklistValue> getVehicleDeliveryStatuses()  {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		return utilities.getPicklistValues('Case', 'Vehicle_Delivery_Status__c');
	}
}