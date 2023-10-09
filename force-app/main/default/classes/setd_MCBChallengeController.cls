/* Name:  setd_MCBChallengeController
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_MCBChallengeController {
	
	@AuraEnabled
	public static setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('ACCT MCB Challenge');
		
		setd_Utilities utilities = new setd_Utilities();
		caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
		caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
		return caseInfoObject;
	}
}