@isTest
public with sharing class MarketShareControllerTest {    
    
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
            
            Account acc = TestClientUtils.createAccount();
            Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');            
            acc.RecordTypeId=rtByName.getRecordTypeId();            
            insert acc;
            
            list<SET_Dealer_Performance_Metrics__c> sList = new list<SET_Dealer_Performance_Metrics__c>();
            //create the SET Metrics record used for the metrics reports in this class
            SET_Dealer_Performance_Metrics__c s = TestClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s.Retail_Market_Share__c = 1000;
            s.Level__c = 'Region';
            sList.add(s);
            
            SET_Dealer_Performance_Metrics__c s2 = TestClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s2.Retail_Market_Share__c = 1000;
            s2.Level__c = 'Area';
            s2.Area__c ='0';
            s2.District__c ='1';
            sList.add(s2);
            
            SET_Dealer_Performance_Metrics__c s3 = TestClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s3.Retail_Market_Share__c = 1000;
            s3.Level__c = 'District';
            s3.Area__c ='0';
            s3.District__c ='1';
            sList.add(s3);
            
            SET_Dealer_Performance_Metrics__c s3_1 = TestClientUtils.createSetDealerPerformanceMetrics(masterAccountId, System.Today());
            s3_1.Retail_Market_Share__c = 2000;
            s3_1.Level__c = 'District';
            s3_1.Area__c ='0';
            s3_1.District__c ='2';
            sList.add(s3_1);
            
            insert sList;
            
            SET_Dealer_Performance_Metrics__c s4 = TestClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
            s4.Retail_Market_Share__c = 1000;
            s4.Area__c ='0';
            s4.District__c ='1';
            s.Market_Share_As_of_Date__c = System.Today();
            insert s4;
            
            District_Area_Ownership_Mapping__c damap = TestClientUtils.createDistrictAreaOwnershipMapping('0', '1', UserInfo.getUserId(), 'Area');
            insert damap;
            
            PageReference pageref=Page.DistrictDashboard;
            Test.setCurrentPage(pageref);
            ApexPages.currentPage().getParameters().put('area','0');
            ApexPages.currentPage().getParameters().put('id',acc.id);
            ApexPages.currentPage().getParameters().put('district','1');
            
            MarketShareController ctl = new MarketShareController();
            ctl.AccountId = acc.Id;
            ctl.getChartAsOfDate();
            ctl.getData();
            
            //area context
            ctl.AccountId = null;
            ctl.district = '';
            ctl.area = '0';
            ctl.getChartAsOfDate();
            ctl.getData();
            
            //district context
            ctl.AccountId = null;
            ctl.area = null;
            ctl.district = '1';
            ctl.getChartAsOfDate();
            ctl.getData();    
        Test.stopTest();               
    }    
    
}