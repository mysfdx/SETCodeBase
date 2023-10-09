@isTest
class DealerDashboardControllerTest {

    @TestSetup
    static void setupData() {
        Send_Email_Info__c objSendEmail = new Send_Email_Info__c(Name = 'Competitive Contact Email Information', replace_field_in_template__c = '##TaskRecord##', Email_template_to_use__c='Competitive_Contact_Task_Completed');
        insert objSendEmail;
    }

    static testmethod void testThisClass() {
        //COE_JMA_TestClientUtils.bypassExecution_TerritoryManagement();
        Test.startTest();            
            Account acc = TestClientUtils.createAccount();
            
            Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
            acc.RecordTypeId=rtByName.getRecordTypeId();
            insert acc;
            list<Contact> conList = new list<Contact>();
            Contact con = TestClientUtils.createContact(acc.Id);
            con.Termination_Date__c = null;
            con.Role__c = 'General Manager';
            conList.add(con);
            
            Contact c2 = TestClientUtils.createContact(Acc.Id);
            c2.Role__c = 'Acting General Manager';
            c2.Termination_Date__c = null;
            conList.add(c2);
            
            Contact c3 = TestClientUtils.createContact(Acc.Id);
            c3.Role__c = 'Dealer Principal/Owner';
            c3.Termination_Date__c = null;
            conList.add(c3);
            
            Contact c4 = TestClientUtils.createContact(Acc.Id);
            c4.Role__c = 'Authorized Signer';
            c4.Termination_Date__c = null;
            conList.add(c4);
            
            insert conList;
            System.debug('::::::conList:::::----->'+conList);
            
            //create the SET Metrics record used for the metrics reports in this class
            SET_Dealer_Performance_Metrics__c s = TestClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
            s.YTD_Profit_Current_Year__c = 1000;
            s.YTD_NP_of_Sales__c = 50;
            s.MTD_Profit_Current_Year__c = 2000;
            s.MTD_NP_of_Sales__c = 45;
            s.NWC_Guide__c = 60;
            s.DPR_As_of_Date__c = System.Today() - 1;
            s.Financial_As_of_Date__c= System.Today() - 1;
            s.Market_Share_As_of_Date__c= System.Today() - 1;
            s.Retention_As_of_Date__c= System.Today() - 1;
            s.Required_Actual_Sales_As_of_Date__c= System.Today() - 1;
            s.Sales_As_of_Date__c= System.Today() - 1;
            s.SSI_SPSI_As_of_Date__c= System.Today() - 1;
            s.YTD_Sales_Current_Year__c = 1000000000;
            s.MTD_Sales_Current_Year__c = 2000000;
            s.SSI_Score_Rolling_12_Mo__c = 65;
            s.SSI_Bottom_10_of_Nation__c = true;
            s.SPSI_Score_Rolling_12_Mo__c = 300000;
            s.SPSI_Bottom_10_of_Nation__c = true;
            s.DPR_Status__c = 'Really good!';
            s.Months_on_DPR__c = 12;
            s.DPR_Score__c = 25;
            s.Svc_Cust_Ret_Target__c = 60;
            insert s;
            
            Facility__c fac = TestClientUtils.createFacility(acc.Id);
            insert fac;
            
            Task t = TestClientUtils.createTask(acc.Id, null);
            insert t;
            
            Task t2 = TestClientUtils.createTask(acc.Id, null);
            t2.Status = 'Completed';
            t2.ActivityDate = system.today() -1;
            insert t2;
            
            Task t3 = TestClientUtils.createTask(acc.Id, null);
            t3.Status = 'Completed';
            t3.ActivityDate=null;
            insert t3;
            
            
            Event e = TestClientUtils.createEvent(acc.Id, null);
            e.ActivityDateTime = System.now().addDays(5);
            e.EndDateTime = System.now().addDays(5).addMinutes(60);
            insert e;
            
            Event e2 = TestClientUtils.createEvent(acc.Id, null);
            e2.ActivityDateTime = System.now().addDays(-1);
            insert e2;
            
                        
            Toyota_Dealer_Agreements__c tda = TestClientUtils.createToyotaDealerAgreements(acc.Id);
            tda.Expiration_Date__c = System.today().addDays(5);
            tda.Extended_To__c = System.today().addDays(25);
            
            insert tda;
            
            Packages__c  pkg = TestClientUtils.createPackages(acc.Id, tda.Id);
            pkg.Status__c = 'Out for Dealer Signature';
            
            insert pkg;
            
            PageReference pageref=Page.DealerDashboard;
            Test.setCurrentPage(pageref);
            ApexPages.currentPage().getParameters().put('Id',acc.id);
            
            LIST<Facility__c> FacilityList=new LIST<Facility__c>();
            Facility__c facrec=new Facility__c(Building_Actual_Sq_Ft__c=100,Building_Required_Sq_Ft__c=90,
                                    Developed_Land_Actual_Sq_Ft__c=200,Developed_Land_Req__c=220,Stalls_Actual__c=50,Stall_Req__c=60,Account__c=acc.id,
                                    Scion__c='Yes',Overall_Status__c='Construction Documents',IUSA_Sign_Status__c='Image USA I',IUSA_Building_Status__c='Image USA I');
                                    
            FacilityList.add(facrec);
                        
           
            insert FacilityList;
            
            DealerDashboardController ctl = new DealerDashboardController();
            ctl.AccountId = acc.Id;
            ctl.getDealerContacts();
            ctl.getChartAsOfDate();
            ctl.getDealerMetrics();
     
            ctl.getDealershipAgreement();
            ctl.getActivitySummary();
            ctl.getDpr();
            ctl.getFacilities();
            ctl.getVss();
            ctl.getDashboardMetrics();
            ctl.getAreaDistrictFacilities();
            ctl.getAggregateCSIData();
            
            //area and district methods
            ctl.AccountId = null;
            ctl.area = '0';
            ctl.getAreaDistrictFacilities();
            ctl.getDpr();
            ctl.getAggregateCSIData();
            
            ctl.area = null;
            ctl.district = '1';
            ctl.getAreaDistrictFacilities();
            //ctl.getDpr();
            //ctl.getAggregateCSIData();
            string retval=ctl.getChartContext();            
                            
           // ctl.setFacilityStopLights();            
        Test.stopTest(); 
    }
    
}