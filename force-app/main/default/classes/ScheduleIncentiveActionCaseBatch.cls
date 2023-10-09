/*
Name: ScheduleIncentiveActionCaseBatch
Purpose: This Schedule class has been used for setting the schedule of IncentiveActionRequiredCaseBatch
to execute every 1st and 3rd Monday of Month.
Author: Neha Agrawal
Date: 6/16/2021


ChangeLog

Author--             Date--                       Purpose--
*/


global class ScheduleIncentiveActionCaseBatch implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        
        IncentiveActionRequiredCaseBatch batch=new IncentiveActionRequiredCaseBatch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,50);
        }
        
    }

}