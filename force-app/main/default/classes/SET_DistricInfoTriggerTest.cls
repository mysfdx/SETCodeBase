@isTest
public with sharing class SET_DistricInfoTriggerTest {
    static testMethod void SETDistTest() {
        SET_DISTRICT_INFO__c setDistInfo = TestClientUtils.createDistrictInfo(true);
        Account acct = TestClientUtils.createAccount();
        acct.SET_DISTRICT_INFO__c = setDistInfo.Id;
        insert acct;
        List < Case > listCases = TestClientUtils.createCases(new List < Account > {acct}, 1, true);
        setDistInfo.FTS__c = UserInfo.getUserId();
        setDistInfo.Account_Owner__c = UserInfo.getUserId();
        setDistInfo.Customer_Response__c = UserInfo.getUserId();
        Test.startTest();
        update setDistInfo;
        Test.stopTest();
    }    
}