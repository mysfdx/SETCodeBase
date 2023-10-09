@isTest
public with sharing class TimeWorkedTriggerTest {
    
    static testMethod void timeWrkdTest() {
        List < Account > listAccounts = TestClientUtils.createAccounts(2, true);
        List < Case > listCases = TestClientUtils.createCases(listAccounts, 2, true);
        List < DS_Time_Worked__c > listCustDetails = TestClientUtils.createTimeWorked(listCases, 2, true);
        for ( DS_Time_Worked__c objTW : listCustDetails )
            objTW.Name = '20 Minutes';
        update listCustDetails;
    }
    
}