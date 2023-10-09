/*
Name: IncentiveScheduleTest
Purpose: Test class for covering ScheduleIncentiveCaseUpdateBatch
Author: Neha Agrawal
Date: 9/25/2020

ChangeLog

Author--             Date--                       Purpose--
Neha Agrawal        6/16/2021          to cover the ScheduleIncentiveActionCaseBatch as well

*/

@istest
Private class IncentiveScheduleTest {
    
    static testMethod void testScheduleIncentiveCaseUpdate() {
        Test.StartTest();
        ScheduleIncentiveCaseUpdateBatch testsche = new ScheduleIncentiveCaseUpdateBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    static testMethod void testScheduleIncentiveActionCase() {
        Test.StartTest();
        ScheduleIncentiveActionCaseBatch testsche = new ScheduleIncentiveActionCaseBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    
}