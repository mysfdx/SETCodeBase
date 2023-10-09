/* Name:  setd_IncAchTermsInstrController
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_IncAchTermsInstrController {
	
	@AuraEnabled
	public static setd_CaseInfo.CaseInfo getCaseInfo() {
		setd_CaseInfo caseInfo = new setd_CaseInfo();
		setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('INC ACH TERMS/INS');
		return caseInfoObject;
	}
	
	@AuraEnabled
	public static String getCommunityDomain() {
		String urlDomain = [SELECT Domain FROM Domain LIMIT 1].Domain;
		String networkUrl = [SELECT UrlPathPrefix FROM Network WHERE Name = 'Forms'].UrlPathPrefix;
		return urlDomain + '/' + networkUrl;
	}
}