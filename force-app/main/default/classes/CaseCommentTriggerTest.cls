@isTest
public with sharing class CaseCommentTriggerTest {
    static testMethod void casComTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(10, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 10, true);
        Test.startTest();
        List < CaseComment > listCaseComments = TestClientUtils.createCaseComments(listCases, 10, true);
        Test.stopTest();
    }
}