/* Name:  setd_IncAchAuthorizationController
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_IncAchAuthorizationController {
	
	@AuraEnabled
	public static setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('INC ACH Authorization');
		return caseInfoObject;
	}
    
    @AuraEnabled
	public static List<avs_PicklistUtil.PicklistValue> getPaymentOptions() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		List<avs_PicklistUtil.PicklistValue> results = utilities.getPicklistValues('Case', 'Change_Account_For__c');
		return results;
	}
}