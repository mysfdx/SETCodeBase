@IsTest
private class setd_IncentivesChallengeControllerTest {
    
    @testSetup
    static void setupData(){
        Referral_Source__c rf=new Referral_Source__c();
        rf.Name='IncentiveMonthsYears';
        rf.Last_Year__c=True;
        rf.First_Year__c=True;
        rf.Second_Year__c=True;
        rf.Third_Year__c=True;
        rf.January__c=True;
        rf.February__c=True;
        rf.March__c=True;   
        rf.April__c=True;
        rf.May__c=True;
        rf.June__c=True;
        rf.July__c=True;
        rf.August__c=True;
        rf.September__c=True;
        rf.October__c=True;
        rf.November__c=True;
        rf.December__c=True; 
        insert rf;
        
    }

	@IsTest
	private static void getCaseInfo_NoArguments_NoExceptions() {
		String exceptionCaught;
		setd_CaseInfo.CaseInfo caseInfo;
		
		try {
			caseInfo = setd_IncentivesChallengeController.getCaseInfo();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
		}

		System.assertEquals(null, exceptionCaught, 'Exception was thrown unexpectedly');
		System.assertEquals('Incentives Challenge', caseInfo.caseObject.Form_Name__c, 'Form name was set incorrectly');
	}
	
	/*@IsTest
	private static void getChallengeRequirements_Coupon_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('PAL_Coupon');
		
		System.assertEquals(7, results.size(), 'Incorrect list of required documents was returned');
	}
	@IsTest
	private static void getChallengeRequirements_College_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('College');
		
		System.assertEquals(3, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_ConsumerCash_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('Consumer_Cash');
		
		System.assertEquals(6, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_TCUVChallenge_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('FC_TCUV_Challenge');
		
		System.assertEquals(6, results.size(), 'Incorrect list of required documents was returned');
	}*/
	
	@IsTest
	private static void getChallengeRequirements_SalesAudit_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('SALES_AUDIT');
		
		System.assertEquals(5, results.size(), 'Incorrect list of required documents was returned');
	}
	
	/*@IsTest
	private static void getChallengeRequirements_TMSChallenge_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('TC_TMS_Challenge');
		
		System.assertEquals(7, results.size(), 'Incorrect list of required documents was returned');
	}*/
	
	@IsTest
	private static void getChallengeRequirements_Export_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('EXPORT');
		
		System.assertEquals(5, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_AssociatePurchase_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('ASSOCIATE_PURCHASE');
		
		System.assertEquals(1, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_GroundStock_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('GROUND_STOCK');
		
		System.assertEquals(5, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_FCTCUV_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('FC_TCUV_FLAT_CANCEL_CHALLENGE');
		
		System.assertEquals(3, results.size(), 'Incorrect list of required documents was returned');
	}
    @IsTest
    private static void getNoMatchChallengeYears(){
        List<avs_PicklistUtil.PicklistValue> picklistValues = setd_IncentivesChallengeController.getchallengeyear();
    }
    @IsTest
    private static void getNoMatchChallengeMonths(){
        List<avs_PicklistUtil.PicklistValue> picklistValues = setd_IncentivesChallengeController.getchallengemonth();
    }
	
	@IsTest
	private static void getChallengeRequirements_NoMatch_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('NO_MATCH');
		
		System.assertEquals(3, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_EmployeePurchase_ListRequiredDocuments() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('DEALER_EMPLOYEE_PURCHASE');
		
		System.assertEquals(4, results.size(), 'Incorrect list of required documents was returned');
	}
	
	@IsTest
	private static void getChallengeRequirements_EmtpyString_EmptyList() {
		List<String> results = setd_IncentivesChallengeController.getChallengeRequirements('');
		
		System.assertEquals(0, results.size(), 'List returned was not empty');
	}
	
	@IsTest
	private static void getChallenges_NoArguments_NoExceptions() {
		Test.setMock(HttpCalloutMock.class, new setd_IncentivesChallengeControllerTest.MockHttpPicklistCallout());
		String exceptionCaught;
		String errorMessage = '';
		try {
			List<avs_PicklistUtil.PicklistValue> picklistValues = setd_IncentivesChallengeController.getChallenges();
		} catch(Exception e) {
			exceptionCaught = e.getTypeName();
			errorMessage = e.getMessage() + '; ' + e.getStackTraceString();
		}
		System.assertEquals(null, exceptionCaught, errorMessage);
	}

	public class MockHttpPicklistCallout implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setBody('{"values":[{"label":"label1","value":"value1"},{"label":"label2","value":"value2"},{"label":"label3","value":"value3"}]}');
			response.setStatusCode(200);
			return response;
		}
	}
}