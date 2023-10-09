@isTest
private class SET_TestWorkingHoursPage {

    static testMethod void TestWorkHoursCtl() {
        PageReference pageRef = Page.SET_WorkHourPage; 
        Test.setCurrentPage(pageRef);
        Account acctRec = TestClientUtils.createAccount();
        insert acctRec;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acctRec);
        SET_WorkingHoursController WorkHrCtl=new SET_WorkingHoursController(sc);
        WorkHrCtl.selectedDepartment='Sales';
        LIST<SelectOption> depList=new LIST<SelectOption>();
        depList=WorkHrCtl.departmentList;
        WorkHrCtl.bEnterHours=true;
        
        WorkHrCtl.newHours();
        WorkHrCtl.newHrsOfOps=new Hours_of_Operation__c();
        WorkHrCtl.newHrsOfOps.Start_Time__c='09.00 AM';
        WorkHrCtl.newHrsOfOps.End_Time__c='09.00 PM';
        WorkHrCtl.newHrsOfOps.Day_of_Week__c='Monday';
        WorkHrCtl.newHrsOfOps.Dealer__c=acctRec.Id;
        
        
        WorkHrCtl.saveNew();
        WorkHrCtl.newHours();
        WorkHrCtl.newHrsOfOps=new Hours_of_Operation__c();
        WorkHrCtl.newHrsOfOps.Start_Time__c='09.00 AM';
        WorkHrCtl.newHrsOfOps.End_Time__c='09.00 PM';
        WorkHrCtl.newHrsOfOps.Day_of_Week__c='Tuesday';
        WorkHrCtl.newHrsOfOps.Dealer__c=acctRec.Id;
        
        WorkHrCtl.saveNew();
        //below one for exception condition on start time later than end time
        WorkHrCtl.newHours();
        WorkHrCtl.newHrsOfOps=new Hours_of_Operation__c();
        WorkHrCtl.newHrsOfOps.Start_Time__c='10.00 PM';
        WorkHrCtl.newHrsOfOps.End_Time__c='09.00 PM';
        WorkHrCtl.newHrsOfOps.Day_of_Week__c='Monday';
        WorkHrCtl.newHrsOfOps.Dealer__c=acctRec.Id;
        
        WorkHrCtl.saveNew();
        //below one for exception condition on duplicate records
        WorkHrCtl.newHours();
        WorkHrCtl.newHrsOfOps=new Hours_of_Operation__c();
        WorkHrCtl.newHrsOfOps.Start_Time__c='10.00 AM';
        WorkHrCtl.newHrsOfOps.End_Time__c='09.00 PM';
        WorkHrCtl.newHrsOfOps.Day_of_Week__c='Monday';
        WorkHrCtl.newHrsOfOps.Dealer__c=acctRec.Id;
        
        WorkHrCtl.saveNew();
        WorkHrCtl.CloseMsg();
        
        Hours_of_Operation__c hrsOps=[Select ID,Department__c,Dealer__c,Start_Time__c,End_Time__c,Day_of_Week__c from Hours_of_Operation__c where Dealer__c=:acctRec.Id and Day_of_Week__c='Monday'];
        //hrsOps.Start_Time__c='10.00 AM';
        WorkHrCtl.hourOpId=hrsOps.Id;
        WorkHrCtl.updateRecord();
        WorkHrCtl.newHrsOfOps.Start_Time__c='10.00 AM';
        WorkHrCtl.saveNew();
        WorkHrCtl.newHrsOfOps.Start_Time__c='10.00 PM';
        WorkHrCtl.saveNew();
        WorkHrCtl.newHrsOfOps.Start_Time__c='10.00 AM';
        WorkHrCtl.newHrsOfOps.Day_of_Week__c='Tuesday';
        
        WorkHrCtl.doDelete();
        WorkHrCtl.doCancel();
        WorkHrCtl.displayWorkHours();
        for (Hours_of_Operation__c hrOps:WorkHrCtl.hoursOpsList){
            system.debug(hrOps);
        }
    }
}