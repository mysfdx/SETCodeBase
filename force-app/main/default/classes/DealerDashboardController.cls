/* Name:  DealerDashboardController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class DealerDashboardController {
    
    global string AccountId{get;set;}
    global String area{get;set;}
    global String district{get;set;}
    
    public boolean isImageInrolledRed{get;set;}   
    public boolean isImageCompleteRed{get;set;}
    public boolean isScionRed{get;set;}
    public boolean isIusaRed{get;set;}
    
    global DealerDashboardController()
    {
        isImageInrolledRed = false;   
        isImageCompleteRed = false;
        isScionRed = false;
        isIusaRed = false;
        
        setFacilityStopLights();
        
    }  
    
    
    
    global class ActivitySummary
    {
        global String Subject{get;set;}
        global String activityDateString{get;set;}
        global Date activityDate{get;set;}
        global String Id{get;set;}
        global String link{get;set;}
        global boolean isOpen{get;set;}
        global Date psudoDate{get;set;}
    }
    
    /**
     * @name retrieveActivitySummary
     * @author Nathan Shinn
     * @description Remote method called fromjavascript to retrieve activity history.
     */
    public list<ActivitySummary> getActivitySummary()
    {
        list<ActivitySummary> summaries = new list<ActivitySummary>();
        set<Date> dateSet = new set<Date>();
        //get the tasks associated with the dealer (Account)
        list<Task> completedTasks = new list<Task>();
        
        //if(Test.IsRunning)
        map<Id,Id> activityMap = new map<Id,Id>();
        for(Task t : [Select Id, Subject, ActivityDate,CreatedDate
                        from Task 
                       where (AccountId = :AccountId  OR whatId = :AccountId)
                         and Status != 'Completed'
                    ])
        {
            ActivitySummary s = new ActivitySummary();
            s.Subject = t.Subject;
            if(t.ActivityDate != null)
            {
              s.activityDateString = t.ActivityDate.month()+'/' +t.ActivityDate.day() + '/' + t.ActivityDate.year();
              s.activityDate = t.ActivityDate;
            }
            else 
               s.activityDate = Date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day());
            s.isOpen = true;
            s.psudoDate = s.ActivityDate;
            dateset.add(s.ActivityDate);
            s.Id = t.Id;
            summaries.add(s);
            activityMap.put(t.Id, t.Id);
        }
        for(Task t : [Select Id, Subject, ActivityDate, CreatedDate 
                        from Task 
                       where (AccountId = :AccountId  OR whatId = :AccountId) 
                         and Status = 'Completed'
                    ])
        {
            ActivitySummary s = new ActivitySummary();
            s.Subject = t.Subject;
            if(t.ActivityDate != null)
            {
              s.activityDateString = t.ActivityDate.month()+'/' +t.ActivityDate.day() + '/' + t.ActivityDate.year();
              s.activityDate = t.ActivityDate;
            }
            else
               s.activityDate = Date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day());
            s.isOpen = false;
            s.Id = t.Id;
            s.psudoDate = s.ActivityDate;
            dateset.add(s.ActivityDate);
            summaries.add(s);
            activityMap.put(t.Id, t.Id);
        }
        
        for(Event t : [Select Id, Subject, StartDateTime , ActivityDate, CreatedDate
                         from Event 
                        where AccountId = :AccountId 
                          and EndDateTime >= :System.Today()
                       //order by ActivityDate desc,CreatedDate desc
                       // limit 3
                        ])
        {
            ActivitySummary s = new ActivitySummary();
            s.Subject = t.Subject;
            if(t.ActivityDate != null)
            {
              s.activityDateString = t.ActivityDate.month()+'/' +t.ActivityDate.day() + '/' + t.ActivityDate.year();
              s.activityDate = t.ActivityDate;
            }
            else
               s.activityDate = Date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day());
               
            s.isOpen = true;
            s.psudoDate = s.ActivityDate;
            s.Id = t.Id;
            dateset.add(Date.newInstance(t.StartDateTime.year(), t.StartDateTime.month(),t.StartDateTime.day()  ));
            summaries.add(s);
            activityMap.put(t.Id, t.Id);
        }
        
        for(Event t : [Select Id, Subject, StartDateTime , ActivityDate, CreatedDate
                         from Event 
                        where AccountId = :AccountId 
                          and EndDateTime < :System.Today()
                       ])
        {
            ActivitySummary s = new ActivitySummary();
            s.Subject = t.Subject;
            if(t.ActivityDate != null)
            {
              s.activityDateString = t.ActivityDate.month()+'/' +t.ActivityDate.day() + '/' + t.ActivityDate.year();
              s.activityDate = t.ActivityDate;
            }
            else
               s.activityDate = Date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day());
               
            s.isOpen = false;
            s.psudoDate = s.ActivityDate;
            s.Id = t.Id;
            dateset.add(Date.newInstance(t.StartDateTime.year(), t.StartDateTime.month(),t.StartDateTime.day()  ));
            summaries.add(s);
            activityMap.put(t.Id, t.Id);
        }
        
        for(Account a : [Select Id,(SELECT id,Subject, ActivityDate, CreatedDate,IsClosed FROM ActivityHistories order by  ActivityDate DESC, LastModifiedDate DESC limit 500) from account where Id = :AccountId])
        {
            for(ActivityHistory t : a.ActivityHistories)
            {
                if(activityMap.containsKey(t.Id))
                  continue;
                ActivitySummary s = new ActivitySummary();
                s.Subject = t.Subject;
                if(t.ActivityDate != null)
                {
                  s.activityDateString = t.ActivityDate.month()+'/' +t.ActivityDate.day() + '/' + t.ActivityDate.year();
                  s.activityDate = t.ActivityDate;
                }
                else
                   s.activityDate = Date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day());
                if(t.IsClosed)
                   s.isOpen = false;
                else
                  s.isOpen = true;
                s.Id = t.Id;
                s.psudoDate = s.ActivityDate;
                dateset.add(s.ActivityDate);
                summaries.add(s);
            }
        }
        
        
        
        //put the records in order of activity date, merged
        list<ActivitySummary> sortedSummaries = new list<ActivitySummary>();
        Integer openCnt = 0;
        Integer closedCnt = 0;
        list<Date> dateList = new list<Date>();
        dateList.addAll(dateSet);
        dateList.sort();
        for(Integer i = dateList.size()-1; i >=0; i --)
        {
            for(ActivitySummary s : summaries)
            {
                /*if(s.psudoDate == dateList[i] && (s.isOpen == false && closedCnt <8))
                {
                   sortedSummaries.add(s);
                   closedCnt ++;
                }*/
                if(s.psudoDate == dateList[i] && (s.isOpen == true && openCnt <=8))
                {
                   sortedSummaries.add(s);
                   openCnt ++;
                }
                if(openCnt >= 8)
                  break;
                
            }
        }
        Integer closedStop = 8-openCnt;
        for(Integer i = dateList.size()-1; i >=0; i --)
        {
            for(ActivitySummary s : summaries)
            {
                if(s.psudoDate == dateList[i] && (s.isOpen == false && closedCnt <closedStop))
                {
                   sortedSummaries.add(s);
                   closedCnt ++;
                }
                if(closedCnt >= closedStop)
                  break;
                
            }
        }
        
        return sortedSummaries;
         
    }
    
    /*
     * Dealer Info Object
     */
    global class DealerContacts
    {
        global string principalName{get;set;}
        global Id principalId{get;set;}
        
        global string authorizedSignerName{get;set;}
        global Id authorizedSignerId{get;set;}
        
        global string gmName{get;set;}
        global Id gmId{get;set;}
        
        global string opsMgr{get;set;}
        global Id opsMgrID{get;set;}
    }
    
    public DealerContacts getDealerContacts()
    {
        /*
         * Select the Name (Salutation + “ “ + First Name + “ “+ Last Name) from the Contacts related to the Dealership 
             where the Termination Date = [blank] and Role = Principal/Owner, General Manager, or Acting General Manager (respectively).
         */
         
         DealerContacts dc = new DealerContacts();
         for(Contact c : [Select c.Termination_Date__c, c.Salutation, c.Role__c, c.Included_on_TDA__c, c.FirstName , c.LastName, Name  
                            From Contact c 
                           where AccountId = :AccountId
                             //and Role__c in ('General Manager', 'Dealer Principal/Owner')
                             ])
         {
            if(c.Included_on_TDA__c == 'General Manager' )
            {
                dc.gmName = c.Name; //(c.Salutation == null ? '' : (c.Salutation+ ' '))+c.Name;
                dc.gmId = c.Id;
            }
            
            if(c.Included_on_TDA__c == 'Dealer')
            {
                dc.principalName = c.Name; //(c.Salutation == null ? '' : (c.Salutation+ ' '))+c.Name;
                dc.principalId = c.Id;
            }
           
         }
         for (Contact c : [Select c.Termination_Date__c, c.Salutation, c.Role__c, c.Included_on_TDA__c, c.FirstName , c.LastName, Name  
                            From Contact c 
                           where Termination_Date__c = null
                             and AccountId = :AccountId
                             //and Role__c in ('Authorized Signer','Acting General Manager',)
                             ])
            {
              if(c.Role__c == 'Operational Manager')
               {
                dc.opsMgr= c.Name; //(c.Salutation == null ? '' : (c.Salutation+ ' '))+c.Name;
                dc.opsMgrID = c.Id;
              }
              if(c.Role__c == 'Authorized Signer')
              {
                dc.authorizedSignerName = c.Name; //(c.Salutation == null ? '' : (c.Salutation+ ' '))+c.Name;//c.Salutation + ' ' + c.FirstName + ' '+ c.LastName;
                dc.authorizedSignerId = c.Id;
               }
            }
         
         return dc;
    }
    
    /*
     * Dealer Agreement Information
     * 
     * Agreement Expires, Extension To and Duration of Extension (Months): Select the Expiration Date, Extended To, Months Extended (respectively) 
     * for the Toyota Dealership Agreement record associated with the Dealership where Active = TRUE.  
     *
     * Packages Out for Signature: Count the # of Packages where Status = Out for Dealer Signature.  (Package has a master-detail relationship to Dealership)
     *
     */
     public class DealershipAgreement
     {
        public Date ExpirationDate{get;set;}
        public Date ExtendedTo{get;set;}
        public Decimal MonthsExtended{get;set;}
        public Integer PackagesOutForSignature{get;set;}
     }
     public DealershipAgreement getDealershipAgreement()
     {
        DealershipAgreement tda = new DealershipAgreement();
        for (Toyota_Dealer_Agreements__c a : [Select t.Term__c, t.Months_Extended__c, t.Has_6_yr_Term__c
                                                   , t.Has_48_mo_Term__c, t.Has_36_mo_Term__c, t.Has_24_mo_Term__c
                                                   , t.Has_12_mo_Term__c, t.Extended_To__c, t.Expiration_Date__c
                                                   , t.Agreement_Date__c, t.Active__c, t.Account__c 
                                                From Toyota_Dealer_Agreements__c t
                                               where Account__c = :AccountId
                                                 and Active__c = true])
        {
           tda.ExpirationDate = a.Expiration_Date__c;
           tda.ExtendedTo = a.Extended_To__c;
           tda.MonthsExtended = a.Months_Extended__c;
        }
        tda.PackagesOutForSignature = 0;
        for(AggregateResult ar : [Select count(Id) cnt
                                    From Packages__c 
                                   where Status__c = 'Out for Dealer Signature'
                                     and Account__c = :AccountId])
        {
            tda.PackagesOutForSignature = Integer.ValueOf(ar.get('cnt'));
        }
          
        return tda;  
     }
     
     global SET_Dealer_Performance_Metrics__c getDealerMetrics()
     {
            Date maxAsOfDate;
           //get the most recent date first
           for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                       From SET_Dealer_Performance_Metrics__c s
                                      where s.Dealership__c = :accountId])
           {
               maxAsOfDate = (Date)ar.get('maxDate');
           }
         
         
         
           SET_Dealer_Performance_Metrics__c dp = new SET_Dealer_Performance_Metrics__c();
           for(SET_Dealer_Performance_Metrics__c s : [Select s.YTD_Profit_Current_Year__c
                                                           , s.YTD_NP_of_Sales__c 
                                                           , s.MTD_Profit_Current_Year__c
                                                           , s.MTD_NP_of_Sales__c 
                                                           , s.NWC_Guide__c
                                                           , s.DPR_As_of_Date__c
                                                           , s.Financial_As_of_Date__c
                                                           , s.Market_Share_As_of_Date__c
                                                           , s.Retention_As_of_Date__c
                                                           , s.Required_Actual_Sales_As_of_Date__c
                                                           , s.Sales_As_of_Date__c
                                                           , s.SSI_SPSI_As_of_Date__c
                                                           , s.YTD_Sales_Current_Year__c
                                                           , s.Change_in_YTD_Sales__c    
                                                           , s.MTD_Sales_Current_Year__c
                                                           , s.Change_in_MTD_Sales__c    
                                                           , s.SSI_Score_Rolling_12_Mo__c
                                                           , s.SSI_Bottom_10_of_Nation__c
                                                           , s.SPSI_Score_Rolling_12_Mo__c
                                                           , s.SPSI_Bottom_10_of_Nation__c
                                                           , s.DPR_Status__c
                                                           , s.Months_on_DPR__c
                                                           , s.DPR_Score__c
                                                           , s.Svc_Cust_Ret_Target__c
                                                        From SET_Dealer_Performance_Metrics__c s
                                                       where Dealership__c = :accountId
                                                         and As_of_Date__c = :maxAsOfDate])//:accountId])// and As_of_Date__c = :maxAsOfDate])
           {
              
              dp = s;
           }
           
           return dp;
     }
     
     /**
      * Global method for retrieving metric data for dealer, area and district
      */
     public SET_Dealer_Performance_Metrics__c getDashboardMetrics()
     {
         SET_Dealer_Performance_Metrics__c dp = new SET_Dealer_Performance_Metrics__c();
         for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(AccountId, area, district, null))
         {
            dp = s;
         }
         
         return dp;
     }
     
     /**
      * Aggregate data
      */
    public DashboardUtils.AggregateCSIData getAggregateCSIData()
    { 
        for(DashboardUtils.AggregateCSIData ad : DashboardUtils.getAggregateCSIData(AccountId, area, district, null))
           return ad;
        
         return new DashboardUtils.AggregateCSIData();
    }
     
     public String getChartContext()
     {
        if(AccountId != null)
          return 'Dealer';
        if(area != null)
          return 'Area';
        if(district != null)
          return 'District';
          
        return '';
     }

     global Facility__c getFacilities(){
        
        Facility__c facility = new Facility__c();
        
        for(Facility__c f : [Select f.of_TMS_Guide_for_Stalls__c
                                  , f.of_TMS_Guide_for_Land__c
                                  , f.of_TMS_Guide_for_Building__c
                                  , f.Scion__c
                                  , f.Overall_Status__c
                                  , f.IUSA_Sign_Status__c
                                  , f.IUSA_Building_Status__c
                                  , f.Account__c 
                               From Facility__c f
                              where Account__c = :AccountId
                             order by CreatedDate desc limit 1])
         {
            facility = f;
         }                   
     
         return facility;
      }
      
      public void setFacilityStopLights()
      {
            
         for(Facility__c f : [Select f.of_TMS_Guide_for_Stalls__c
                                   , f.of_TMS_Guide_for_Land__c
                                   , f.of_TMS_Guide_for_Building__c
                                   , f.Scion__c
                                   , f.Overall_Status__c
                                   , f.IUSA_Sign_Status__c
                                   , f.IUSA_Building_Status__c
                                   , f.Account__c 
                                From Facility__c f
                               where Account__c = :ApexPages.currentPage().getParameters().get('Id')
                              order by CreatedDate desc limit 1])
        {
            /* Image II Enrolled
               -    Red light if:  "IUSA Building status" ≠ Image USA II AND Overall Status = Not Enrolled, Project Stalled-Dealer, Project Stalled-Not Enrolled
               -    Green light for all other "IUSA Building statuses" and "Overall Statuses"
             */
            
            if(f.IUSA_Building_Status__c != 'Image USA II' 
               && (f.Overall_Status__c == 'Not Enrolled'|| f.Overall_Status__c == 'Project Stalled-Dealer'|| f.Overall_Status__c == 'Project Stalled-Not Enrolled' ))
              isImageInrolledRed = true;
            else
              isImageInrolledRed = false;   
              
            /* Image II Complete:
                    o   Green light if: USA Building Status = Image USA II OR Overall Status = Project Complete
                    o   Red light for all other "IUSA Building Statuses" and "Overall Statuses".
                
             */
            if(f.IUSA_Building_Status__c == 'Image USA II' || f.Overall_Status__c == 'Project Complete')  
                isImageCompleteRed = false;
            else
                isImageCompleteRed = true;
                
            /* Scion Complete
                 o  Green light if: True
                 o  Red light if: False
             */
            if(f.Scion__c == 'Yes')
               isScionRed = false;
            else
               isScionRed = true;
            
            /* IUSA Sign Status:
                o   Green light if IUSA Sign Status = Image USA II
                o   Red light for all other IUSA Sign Statuses
    
             */
             if(f.IUSA_Sign_Status__c == 'Image USA II')
                isIusaRed = false;
             else
               isIusaRed = true;
        }
      }
      
      public DashboardUtils.AggregateFacilitiesData getAreaDistrictFacilities()
      {
          return DashboardUtils.getAggregateFacilitiesData(null, area, district, null);
      }
      
      global list<VSS__c> getVss(){
        
        Facility__c facility = new Facility__c();
        
        for(Facility__c f : [Select Id
                               From Facility__c f
                              where Account__c = :AccountId
                             order by CreatedDate desc limit 1])
         {
            facility = f;
         }
         list<VSS__c> vss = new list<VSS__c>();
         for(VSS__c v : [Select v.VSS_Taken__c, v.VSS_Remaining_Units__c, v.VSS_Due_Date__c, v.Name, v.Eligible_Spent__c 
                           From VSS__c v
                         where Facility__c = :facility.Id])                 
            vss.add(v);
         
         return vss;
      }
      /*
     global SET_Dealer_Performance_Metrics__c getCustomerService()
     {
            Date maxAsOfDate;
           //get the most recent date first
           for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                       From SET_Dealer_Performance_Metrics__c s
                                      where s.Dealership__c = :accountId])
           {
               maxAsOfDate = (Date)ar.get('maxDate');
           }
           
         
           SET_Dealer_Performance_Metrics__c cs = new SET_Dealer_Performance_Metrics__c();
           for(SET_Dealer_Performance_Metrics__c s : [Select s.SSI_Score_Rolling_12_Mo__c
                                                           , s.SSI_Bottom_10_of_Nation__c
                                                           , s.SPSI_Score_Rolling_12_Mo__c
                                                           , s.SPSI_Bottom_10_of_Nation__c
                                                        From SET_Dealer_Performance_Metrics__c s
                                                       where Dealership__c = :accountId
                                                         and As_of_Date__c = :maxAsOfDate])//:accountId])// and As_of_Date__c = :maxAsOfDate])
           {
              
              cs = s;
           }
           
           return cs;
     }
     */
     public DashboardUtils.AggregateDPRData getDpr()
     {
           DashboardUtils.AggregateDPRData cs = new DashboardUtils.AggregateDPRData();
           
           for(DashboardUtils.AggregateDPRData d : DashboardUtils.getAggregateDprData(accountId, area, district, null))
              cs = d;
              
           return cs;
     }
     
    public string getChartAsOfDate()
    {
        Date maxAsOfDate;
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                   From SET_Dealer_Performance_Metrics__c s
                                  where s.Dealership__c = :AccountId])
        {
           maxAsOfDate = (Date)ar.get('maxDate');
        }
        if(maxAsOfDate != null)
           return maxAsOfDate.format();
        else
           return '[Date Not Available]';
    }
    
    /*
    //================================
    // Test Client
    static testmethod void testThisClass()
    {
        COE_JMA_TestClientUtils.bypassExecution_TerritoryManagement();
        Test.startTest();
            //Create the Account used for the test cases
            Account acc = testClientUtils.createAccount();
            
            Schema.DescribeSObjectResult DesRes = acc.getSObjectType().getDescribe();   
            Map<String,Schema.RecordTypeInfo> rtMapByName = DesRes.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get('Dealership');
            
            acc.RecordTypeId=rtByName.getRecordTypeId();
            insert acc;
            list<Contact> conList = new list<Contact>();
            Contact con = testClientUtils.createContact(acc.Id);
            con.Termination_Date__c = null;
            con.Role__c = 'General Manager';
            conList.add(con);
            
            Contact c2 = testClientUtils.createContact(Acc.Id);
            c2.Role__c = 'Acting General Manager';
            c2.Termination_Date__c = null;
            conList.add(c2);
            
            Contact c3 = testClientUtils.createContact(Acc.Id);
            c3.Role__c = 'Dealer Principal/Owner';
            c3.Termination_Date__c = null;
            conList.add(c3);
            
            Contact c4 = testClientUtils.createContact(Acc.Id);
            c4.Role__c = 'Authorized Signer';
            c4.Termination_Date__c = null;
            conList.add(c4);
            
            insert conList;
            System.debug('::::::conList:::::----->'+conList);
            
            //create the SET Metrics record used for the metrics reports in this class
            SET_Dealer_Performance_Metrics__c s = testClientUtils.createSetDealerPerformanceMetrics(acc.Id, System.Today());
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
            
            Facility__c fac = testClientUtils.createFacility(acc.Id);
            insert fac;
            
            Task t = testClientUtils.createTask(acc.Id, null);
            insert t;
            
            Task t2 = testClientUtils.createTask(acc.Id, null);
            t2.Status = 'Completed';
            t2.ActivityDate=system.today() -1;
            insert t2;
            
            Task t3 = testClientUtils.createTask(acc.Id, null);
            t3.Status = 'Completed';
            t3.ActivityDate=null;
            insert t3;
            
            
            Event e = testClientUtils.createEvent(acc.Id, null);
            e.ActivityDateTime = System.now().addDays(5);
            e.EndDateTime = System.now().addDays(5).addMinutes(60);
            insert e;
            
            Event e2 = testClientUtils.createEvent(acc.Id, null);
            e2.ActivityDateTime = System.now().addDays(-1);
            insert e2;
            
                        
            Toyota_Dealer_Agreements__c tda = testClientUtils.createToyotaDealerAgreements(acc.Id);
            tda.Expiration_Date__c = System.today().addDays(5);
            tda.Extended_To__c = System.today().addDays(25);
            
            insert tda;
            
            Packages__c  pkg = testClientUtils.createPackages(acc.Id, tda.Id);
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
            ctl.getDpr();
            ctl.getAggregateCSIData();
            string retval=ctl.getChartContext();

            
                            
            ctl.setFacilityStopLights();
            

        Test.stopTest();
        
        
    }
    */
}