/*
Name: ScheduleIncentiveCaseUpdateBatch
Purpose: This Schedule class has been used for setting the schedule of IncentiveCaseUpdateBatch using cron expression
to execute every hour Mon-Fri between 9 AM-5 PM.
Author: Neha Agrawal
Date: 9/25/2020
*/


global class ScheduleIncentiveCaseUpdateBatch implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        
        IncentiveCaseUpdateBatch batch=new IncentiveCaseUpdateBatch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,20);
        }
        
    }

}