/* Name:  setd_AcctAchPtsTermsInsController
Created By:  SET Salesforce System Admin
Created Date:  2019-10-16
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_AcctAchPtsTermsInsController {

	@AuraEnabled
	public static setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		return caseInfo.createCaseInfoByFormName('ACCT ACH PTS TERMS/INS');
	}
}