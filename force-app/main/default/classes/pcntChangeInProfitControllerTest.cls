@isTest
public with sharing class pcntChangeInProfitControllerTest {    

    @TestSetup
    static void setupdata() {
        Account acct = new Account(Name = 'Dealer Dashboard Rollup Account');
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('District/Area/SET Rollup').getRecordTypeId();
        insert acct;
        Dealer_Dash_Rollup_Account__c objDealerDashBrd = new Dealer_Dash_Rollup_Account__c(Account_ID__c = acct.Id, Name__c = 'Dealer Dashboard Rollup Account');
        objDealerDashBrd.SetupOwnerId = UserInfo.getOrganizationId();
        insert objDealerDashBrd;
    }
    
    static testmethod void testThisClass() {
        Test.startTest();
            Id masterAccountId = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
            //Create the Account used for the test cases
            Account acc = testClientUtils.createAccount();
            Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
            acc.RecordTypeId=rtByName.getRecordTypeId();
            insert acc;
            
            list<SET_Dealer_Performance_Metrics__c> sList = new list<SET_Dealer_Performance_Metrics__c>();
            //create the SET Metrics record used for the metrics reports in this class
            SET_Dealer_Performance_Metrics__c s = testClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s.YTD_Profit_Current_Year__c  = 1000;
            s.YTD_Profit_Previous_Year__c = 1000;
            s.MTD_Profit_Current_Year__c  = 1000;
            s.MTD_Profit_Previous_Year__c = 1000;
            s.Level__c = 'Region';
            sList.add(s);
            
            SET_Dealer_Performance_Metrics__c s2 = testClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s2.YTD_Profit_Current_Year__c  = 1000;
            s2.YTD_Profit_Previous_Year__c = 1000;
            s2.MTD_Profit_Current_Year__c  = 1000;
            s2.MTD_Profit_Previous_Year__c = 1000;
            s2.Level__c = 'Area';
            s2.Area__c ='0';
            s2.District__c ='1';
            sList.add(s2);
            
            SET_Dealer_Performance_Metrics__c s3 = testClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s3.YTD_Profit_Current_Year__c  = 1000;
            s3.YTD_Profit_Previous_Year__c = 1000;
            s3.MTD_Profit_Current_Year__c  = 1000;
            s3.MTD_Profit_Previous_Year__c = 1000;
            s3.Level__c = 'District';
            s3.Area__c ='0';
            s3.District__c ='1';
            sList.add(s3);
            
            insert sList;
            
            SET_Dealer_Performance_Metrics__c s4 = testClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
            s4.YTD_Profit_Current_Year__c  = 1000;
            s4.YTD_Profit_Previous_Year__c = 1000;
            s4.MTD_Profit_Current_Year__c  = 1000;
            s4.MTD_Profit_Previous_Year__c = 1000;
            s4.Area__c ='0';
            s4.District__c ='1';
            s.Market_Share_As_of_Date__c = System.Today();
            insert s4;
            
            pcntChangeInProfitController ctl = new pcntChangeInProfitController();
            ctl.AccountId = acc.Id;
            //ctl.getChartAsOfDate();
            pcntChangeInProfitController.retrieveData(acc.Id,null, null);
            ctl.getChartData();
            
            District_Area_Ownership_Mapping__c damap = testClientUtils.createDistrictAreaOwnershipMapping('0', '1', UserInfo.getUserId(), 'Area');
            insert damap;
            
            ctl.AccountId = null;
            ctl.district = '1';
            pcntChangeInProfitController.retrieveData(null,null, '1');
            ctl.getChartData();
            
            ctl.AccountId = null;
            ctl.district = '';
            ctl.area = '0';
            pcntChangeInProfitController.retrieveData(null,'0', null);
            ctl.getChartData();    
        Test.stopTest();    
    }       
}