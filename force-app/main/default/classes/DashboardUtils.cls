global with sharing class DashboardUtils {
  
  global static Date getMaxAsOfDate(string accountId, string area, string district, string region)
     {
       Date d;
       String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
       if(accountId != null && accountId != '')
      {
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                     From SET_Dealer_Performance_Metrics__c s
                                    where s.Dealership__c = :AccountId])
           {
              d = (Date)ar.get('maxDate');
           }
      }
      else if(area != null && area != '')
      {
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                     From SET_Dealer_Performance_Metrics__c s
                                    where s.Area__c = :area
                                      and Level__c = 'Area'
                                 and Dealership__c = :masterAccount])
           {
              d =  (Date)ar.get('maxDate');
           }
      }
      else if(district != null && district != '')
      {
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                     From SET_Dealer_Performance_Metrics__c s
                                    where s.District__c = :district
                                      and Level__c = 'District'
                                 and Dealership__c = :masterAccount])
           {
              d = (Date)ar.get('maxDate');
           }
      }
      else if(region != null && region != '')
      {
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                     From SET_Dealer_Performance_Metrics__c s
                                    where Dealership__c = :masterAccount
                                      and Level__c = 'Region'])
           {
              d = (Date)ar.get('maxDate');
           }
      }
      System.Debug('::::::::DATE:::::::'+d);
         return d;
     }
     
     global static list<SET_Dealer_Performance_Metrics__c> getStatData(string accountId, string area, string district, string region)
    {
      String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
      Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(accountId, area, district, region);
      System.Debug('>>>>>>Area: '+area);
      System.Debug('>>>>>>maxAsOfDate: '+maxAsOfDate);
      
        if(accountId != null && accountId != '')
      {
        return  [ Select s.YTD_Profit_Previous_Year__c
                           , s.YTD_Profit_Current_Year__c
                           , s.MTD_Profit_Previous_Year__c
                           , s.MTD_Profit_Current_Year__c
                           , s.YTD_Sales_Previous_Year__c
                           , s.YTD_Sales_Current_Year__c
                           , s.MTD_Sales_Previous_Year__c
                           , s.MTD_Sales_Current_Year__c
                  , s.Sales_Efficiency_Car__c
                  , s.Sales_Efficiency_Lt_Truck__c
                  , s.Sales_Efficiency_Total__c
                           , s.District__c
                  , s.Dealership__c
                  , s.Change_in_YTD_Sales__c
                  , s.Change_in_YTD_Profit__c
                  , s.Change_in_MTD_Sales__c
                  , s.Change_in_MTD_Profit__c
                  , s.As_of_Date__c
                  , s.Sales_As_of_Date__c
                  , s.Area__c 
                  , s.Dealership__r.District__c
                  , s.Dealership__r.Area__c
                   , s.Financial_As_of_Date__c
                           , s.Retail_Market_Share__c
                           , s.Market_Share_As_of_Date__c
                            , Service_Cust_Retention__c
                           , Svc_Cust_Ret_Target__c
                           , Retention_As_of_Date__c
                           , Service_Cust_Ret_Var_to_Objective__c 
                           , SSI_Bottom_10_of_Nation__c
                           , SPSI_Bottom_10_of_Nation__c 
                           , SSI_Score_Rolling_12_Mo__c
                           , SPSI_Score_Rolling_12_Mo__c 
                        From SET_Dealer_Performance_Metrics__c s
                       where Dealership__c = :accountId
                         and As_of_Date__c = :maxAsOfDate
                       limit 1];
      }
      else if(area != null && area != '')
      {
        return  [ Select s.YTD_Profit_Previous_Year__c
                           , s.YTD_Profit_Current_Year__c
                           , s.MTD_Profit_Previous_Year__c
                           , s.MTD_Profit_Current_Year__c
                           , s.YTD_Sales_Previous_Year__c
                           , s.YTD_Sales_Current_Year__c
                           , s.MTD_Sales_Previous_Year__c
                           , s.MTD_Sales_Current_Year__c
                  , s.Sales_Efficiency_Car__c
                  , s.Sales_Efficiency_Lt_Truck__c
                  , s.Sales_Efficiency_Total__c
                  , s.Sales_As_of_Date__c
                           , s.District__c
                  , s.Dealership__c
                  , s.Change_in_YTD_Sales__c
                  , s.Change_in_YTD_Profit__c
                  , s.Change_in_MTD_Sales__c
                  , s.Change_in_MTD_Profit__c
                  , s.As_of_Date__c
                  , s.Area__c 
                  , s.Dealership__r.District__c
                  , s.Dealership__r.Area__c
                           , s.Financial_As_of_Date__c
                           , s.Retail_Market_Share__c
                           , s.Market_Share_As_of_Date__c
                            , Service_Cust_Retention__c
                           , Svc_Cust_Ret_Target__c
                           , Retention_As_of_Date__c
                           , Service_Cust_Ret_Var_to_Objective__c 
                           , SSI_Bottom_10_of_Nation__c
                           , SPSI_Bottom_10_of_Nation__c 
                           , SSI_Score_Rolling_12_Mo__c
                           , SPSI_Score_Rolling_12_Mo__c
                        From SET_Dealer_Performance_Metrics__c s
                       where Level__c = 'Area'
                         and Area__c = :area
                         and As_of_Date__c = :maxAsOfDate
                         and Dealership__c = :masterAccount
                         limit 1];
      }
      else if(district != null && district != '')
      {
        return  [ Select s.YTD_Profit_Previous_Year__c
                           , s.YTD_Profit_Current_Year__c
                           , s.MTD_Profit_Previous_Year__c
                           , s.MTD_Profit_Current_Year__c
                           , s.YTD_Sales_Previous_Year__c
                           , s.YTD_Sales_Current_Year__c
                           , s.MTD_Sales_Previous_Year__c
                           , s.MTD_Sales_Current_Year__c
                  , s.Sales_Efficiency_Car__c
                  , s.Sales_Efficiency_Lt_Truck__c
                  , s.Sales_Efficiency_Total__c
                  , s.Sales_As_of_Date__c
                           , s.District__c
                  , s.Dealership__c
                  , s.Change_in_YTD_Sales__c
                  , s.Change_in_YTD_Profit__c
                  , s.Change_in_MTD_Sales__c
                  , s.Change_in_MTD_Profit__c
                  , s.As_of_Date__c
                  , s.Area__c 
                  , s.Dealership__r.District__c
                  , s.Dealership__r.Area__c
                           , s.Financial_As_of_Date__c
                           , s.Retail_Market_Share__c
                           , s.Market_Share_As_of_Date__c
                            , Service_Cust_Retention__c
                           , Svc_Cust_Ret_Target__c
                           , Retention_As_of_Date__c
                           , Service_Cust_Ret_Var_to_Objective__c 
                           , SSI_Bottom_10_of_Nation__c
                           , SPSI_Bottom_10_of_Nation__c 
                           , SSI_Score_Rolling_12_Mo__c
                           , SPSI_Score_Rolling_12_Mo__c
                        From SET_Dealer_Performance_Metrics__c s
                       where Level__c = 'District'
                         and District__c = :district
                         and As_of_Date__c = :maxAsOfDate
                         and Dealership__c = :masterAccount
                        limit 1];
      }
      else if(region != null && region != '')
      {
        return  [ Select s.YTD_Profit_Previous_Year__c
                           , s.YTD_Profit_Current_Year__c
                           , s.MTD_Profit_Previous_Year__c
                           , s.MTD_Profit_Current_Year__c
                           , s.YTD_Sales_Previous_Year__c
                           , s.YTD_Sales_Current_Year__c
                           , s.MTD_Sales_Previous_Year__c
                           , s.MTD_Sales_Current_Year__c
                  , s.Sales_Efficiency_Car__c
                  , s.Sales_Efficiency_Lt_Truck__c
                  , s.Sales_Efficiency_Total__c
                  , s.Sales_As_of_Date__c
                           , s.District__c
                  , s.Dealership__c
                  , s.Change_in_YTD_Sales__c
                  , s.Change_in_YTD_Profit__c
                  , s.Change_in_MTD_Sales__c
                  , s.Change_in_MTD_Profit__c
                  , s.As_of_Date__c
                  , s.Area__c 
                  , s.Dealership__r.District__c
                  , s.Dealership__r.Area__c
                           , s.Financial_As_of_Date__c
                           , s.Retail_Market_Share__c
                           , s.Market_Share_As_of_Date__c
                            , Service_Cust_Retention__c
                           , Svc_Cust_Ret_Target__c
                           , Retention_As_of_Date__c
                           , Service_Cust_Ret_Var_to_Objective__c 
                           , SSI_Bottom_10_of_Nation__c
                           , SPSI_Bottom_10_of_Nation__c 
                           , SSI_Score_Rolling_12_Mo__c
                           , SPSI_Score_Rolling_12_Mo__c
                        From SET_Dealer_Performance_Metrics__c s
                       where Level__c = 'Region'
                         and As_of_Date__c = :maxAsOfDate
                         and Dealership__c = :masterAccount
                        limit 1];
      }
      
      return new list<SET_Dealer_Performance_Metrics__c>();
    }
    
    global static list<SET_Dealer_Performance_Metrics__c> getAreaDistrictStatData(string area)
    {
      String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
      Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(null, area, null, null);
      list<SET_Dealer_Performance_Metrics__c> metrics = new list<SET_Dealer_Performance_Metrics__c>();
      list<Integer> districts = new list<Integer>();
      for(SET_Dealer_Performance_Metrics__c s : [   Select s.YTD_Profit_Previous_Year__c
                                           , s.YTD_Profit_Current_Year__c
                                           , s.MTD_Profit_Previous_Year__c
                                           , s.MTD_Profit_Current_Year__c
                                           , s.YTD_Sales_Previous_Year__c
                                           , s.YTD_Sales_Current_Year__c
                                           , s.MTD_Sales_Previous_Year__c
                                           , s.MTD_Sales_Current_Year__c
                                  , s.Sales_Efficiency_Car__c
                                  , s.Sales_Efficiency_Lt_Truck__c
                                  , s.Sales_Efficiency_Total__c
                                  , s.Sales_As_of_Date__c
                                           , s.District__c
                                  , s.Dealership__c
                                  , s.Change_in_YTD_Sales__c
                                  , s.Change_in_YTD_Profit__c
                                  , s.Change_in_MTD_Sales__c
                                  , s.Change_in_MTD_Profit__c
                                  , s.As_of_Date__c
                                  , s.Area__c 
                                  , s.Dealership__r.District__c
                                  , s.Dealership__r.Area__c
                                           , s.Financial_As_of_Date__c
                                           , s.Retail_Market_Share__c
                                           , s.Market_Share_As_of_Date__c
                                            , Service_Cust_Retention__c
                                           , Svc_Cust_Ret_Target__c
                                           , Retention_As_of_Date__c
                                           , Service_Cust_Ret_Var_to_Objective__c 
                                           , SSI_Bottom_10_of_Nation__c
                                           , SPSI_Bottom_10_of_Nation__c 
                                           , SSI_Score_Rolling_12_Mo__c
                                           , SPSI_Score_Rolling_12_Mo__c
                                        From SET_Dealer_Performance_Metrics__c s
                                       where Level__c = 'District'
                                         and Area__c = :area
                                         and As_of_Date__c = :maxAsOfDate
                                         and Dealership__c = :masterAccount
                                    order by District__c])
             {
                 metrics.add(s);
                 districts.add(Integer.valueOf(s.District__c));
             }
             //sort by district
             list<SET_Dealer_Performance_Metrics__c> sortedMetrics = new list<SET_Dealer_Performance_Metrics__c>();
             districts.sort();
             for(Integer d : districts)
             {
               for(SET_Dealer_Performance_Metrics__c s : metrics)
               {
                   if( Integer.valueOf(s.District__c) == d)
                     sortedMetrics.add(s);
               }
             }
             return sortedMetrics;
    }
    
    public class AggregateCSIData
    {
      public Decimal SSI_Score_Rolling_12_Mo{get;set;}
      public Decimal SPSI_Score_Rolling_12_Mo{get;set;}
      public Boolean SPSI_Bottom_10_of_Nation{get;set;}
      public Boolean SSI_Bottom_10_of_Nation{get;set;}
      
      public AggregateCSIData(Decimal ssi, Decimal spsi, Boolean spsiBottom, Boolean ssiBottom)
      {
        SSI_Score_Rolling_12_Mo = ssi;
          SPSI_Score_Rolling_12_Mo = spsi;
          SPSI_Bottom_10_of_Nation = spsiBottom;
          SSI_Bottom_10_of_Nation = ssiBottom;
      }
      
      public AggregateCSIData()
      {
        
      }
    }
      
    public static list<AggregateCSIData> getAggregateCSIData(string accountId, string area, string district, string region)
    {
      list<AggregateCSIData> aggregatedata = new list<AggregateCSIData>();
      Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(accountId, area, district, region);
      if(accountId != null)
      {
        for(SET_Dealer_Performance_Metrics__c s : getStatData(accountId, null, null, null))
        {
          aggregatedata.add(new AggregateCSIData(s.SSI_Score_Rolling_12_Mo__c, s.SPSI_Score_Rolling_12_Mo__c, s.SPSI_Bottom_10_of_Nation__c, s.SSI_Bottom_10_of_Nation__c));
        }
      }
      else if(area != null)
      {
        AggregateCSIData acsi = new AggregateCSIData();
        for(AggregateResult s : [Select count(SSI_Score_Rolling_12_Mo__c) ssiCnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where SSI_Bottom_10_of_Nation__c = true
                                        and Level__c = 'Dealer'
                                        and Area__c = :area
                                        and As_of_Date__c = :maxAsOfDate])
          {
            acsi.SSI_Score_Rolling_12_Mo = Double.ValueOf(s.get('ssiCnt'));
          }
          for(AggregateResult s : [Select count(SPSI_Score_Rolling_12_Mo__c) ssiCnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where SPSI_Bottom_10_of_Nation__c = true
                                        and Level__c = 'Dealer'
                                        and Area__c = :area
                                        and As_of_Date__c = :maxAsOfDate])
          {
            acsi.SPSI_Score_Rolling_12_Mo = Double.ValueOf(s.get('ssiCnt'));
          }
          aggregatedata.add(acsi);
      }
      else if(district != null)
      {
        AggregateCSIData acsi = new AggregateCSIData(0,0,false,false);
        for(AggregateResult s : [Select count(SSI_Score_Rolling_12_Mo__c) ssiCnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where SSI_Bottom_10_of_Nation__c = true
                                        and Level__c = 'Dealer'
                                        and District__c = :district
                                        and As_of_Date__c = :maxAsOfDate])
          {
            acsi.SSI_Score_Rolling_12_Mo = Double.ValueOf(s.get('ssiCnt'));
          }
          for(AggregateResult s : [Select count(SPSI_Score_Rolling_12_Mo__c) ssiCnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where SPSI_Bottom_10_of_Nation__c = true
                                        and Level__c = 'Dealer'
                                        and District__c = :district
                                        and As_of_Date__c = :maxAsOfDate])
          {
            acsi.SPSI_Score_Rolling_12_Mo = Double.ValueOf(s.get('ssiCnt'));
          }
          aggregatedata.add(acsi);
      }
      
      
      return aggregatedata;
      
      
    }
    
    public class AggregateDPRData
    {
      public String DPR_Status{get;set;}
      public Decimal Months_on_DPR{get;set;}
      public Decimal DPR_Score{get;set;}
      public Decimal DealersOnWarning{get;set;}
      public Decimal DealersOnProgram{get;set;}
      public Date DPR_As_of_Date{get;set;}
      
      public AggregateDPRData(String status, Decimal months, Decimal score, Decimal onProgram, Decimal onWarning, Date dDate)
      {
        DPR_Status = status;
          Months_on_DPR = months;
          DPR_Score = score == null ? 0 : score;
          DealersOnWarning = onWarning;
          DealersOnProgram = onProgram;
          DPR_As_of_Date = dDate;
      }
      
      public AggregateDPRData()
      {
        
      }
    }
      
    public static list<AggregateDPRData> getAggregateDprData(string accountId, string area, string district, string region)
    {
      list<AggregateDPRData> dprData = new list<AggregateDPRData>();
      Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(accountId, area, district, region);
      if(accountId != null)
      {
          for(SET_Dealer_Performance_Metrics__c s : [Select s.DPR_Status__c
                                                           , s.Months_on_DPR__c
                                                           , s.DPR_Score__c
                                                From SET_Dealer_Performance_Metrics__c s
                                               where Dealership__c = :accountId
                                                 and As_of_Date__c = :maxAsOfDate])//:accountId])// and As_of_Date__c = :maxAsOfDate])
         {
             
             dprData.add(new AggregateDPRData(s.DPR_Status__c, s.Months_on_DPR__c, s.DPR_Score__c, null,null, maxAsOfDate));
         }
      }
      else if(area != null)
      {
        AggregateDPRData ad = new AggregateDPRData(null, null, null,0,0, maxAsOfDate);
        for(AggregateResult ar : [select count(Id) cnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where DPR_Status__c = 'In Program'
                                        and Level__c = 'Dealer'
                                        and Area__c = :area
                                        and As_of_Date__c = :maxAsOfDate])
          {
            ad.DealersOnProgram = Integer.ValueOf(ar.get('cnt'));
          }
          
          
          for(AggregateResult ar : [select count(Id) cnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where DPR_Status__c = 'Warning'
                                        and Level__c = 'Dealer'
                                        and Area__c = :area
                                        and As_of_Date__c = :maxAsOfDate])
          {
            ad.DealersOnWarning = Integer.ValueOf(ar.get('cnt'));
          }
          dprData.add(ad);
      }
      else if(district != null)
      {
        AggregateDPRData ad = new AggregateDPRData(null, null, null,0,0, maxAsOfDate);
        for(AggregateResult ar : [select count(Id) cnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where DPR_Status__c = 'In Program'
                                        and Level__c = 'Dealer'
                                        and District__c = :district
                                        and As_of_Date__c = :maxAsOfDate])
          {
            ad.DealersOnProgram = Integer.ValueOf(ar.get('cnt'));
          }
          
          
          for(AggregateResult ar : [select count(Id) cnt
                                       from SET_Dealer_Performance_Metrics__c
                                      where DPR_Status__c = 'Warning'
                                        and Level__c = 'Dealer'
                                        and District__c = :district
                                        and As_of_Date__c = :maxAsOfDate])
          {
            ad.DealersOnWarning = Integer.ValueOf(ar.get('cnt'));
          }
          dprData.add(ad);
      }
      return dprData;
    }
    
    public class AggregateFacilitiesData
    {
      public Double USAScionStatus{get;set;}
      public Double enrolled{get;set;}
      public Double complete{get;set;}
      public Double underConstruction{get;set;}
      public Double scionComplete{get;set;}
    }
      
    public static AggregateFacilitiesData getAggregateFacilitiesData(string accountId, string area, string district, string region)
    {
      AggregateFacilitiesData facilitiesData = new AggregateFacilitiesData();
      Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(accountId, area, district, region);
      
      map<Id,DateTime> facilityCreatedDates = new map<Id,DateTime>();
      
      if(area != null)
      {
        for(AggregateResult ar : [Select Account__c, max(CreatedDate) maxDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.Area__c = :area
                                   group by Account__c])
            facilityCreatedDates.put((String)ar.get('Account__c'), (DateTime)ar.get('maxDate'));
        
        Integer activeAreaDealerships = 1;
        
        /*for(AggregateResult ar : [Select count(Id)cnt
                                    from Account 
                                   where RecordType.Name = 'Dealership'
                                     and Active_Dealer__c = true
                                     and Area__c = :area])
            activeAreaDealerships = Integer.ValueOf(ar.get('cnt'));
        if(activeAreaDealerships == 0)*/
           activeAreaDealerships = 1;
        /**
         *Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where IUSA Building Status = Image USA II.  If there are multiple facilities on a Dealership, 
       *  evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the 
       *  Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen].
       */
        Double enrolledCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.Area__c = :area
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and IUSA_Building_Status__c = 'Image USA II'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            enrolledCnt ++;
        }
        facilitiesData.enrolled = enrolledCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where (IUSA Building Status = Image USA II OR Overall Status = Project Complete).  If there are multiple 
       *  facilities on a Dealership, evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in 
       *  the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]
         */
        Double completeCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.Area__c = :area
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and (IUSA_Building_Status__c = 'Image USA II' or Overall_Status__c = 'Project Completed')
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            completeCnt ++;
        }
        facilitiesData.complete = completeCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where Overall Status = Under Construction.  If there are multiple facilities on a Dealership, evaluate 
       *  the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the Area (Record Type = Dealership 
       *  AND Active Dealer = TRUE and Area = [Area Chosen]
         */
        Double constructionCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.Area__c = :area
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and Overall_Status__c = 'Under Construction'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            constructionCnt ++;
        }
        facilitiesData.underConstruction = constructionCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where Scion = Yes.  If there are multiple facilities on a Dealership, evaluate the one with the MAX Created Date.  
       *  Divide this by the Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE 
       *  and Area = [Area Chosen]
         */
        Double scionCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.Area__c = :area
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and Scion__c = 'Yes'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            scionCnt ++;
        }
        facilitiesData.scionComplete = scionCnt/activeAreaDealerships;
        
        /**
         * Percentage Formula:
       * Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       * that have a Facility where  IUSA Sign Status = Image USA II.  If there are multiple facilities on a Dealership, 
       * evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the 
       * Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]
             */
        Double signCnt = 0;
        for(Facility__c f : [ Select Account__c, CreatedDate
                                from Facility__c 
                               where Account__r.RecordType.Name = 'Dealership'
                                 and Account__r.Active_Dealer__c = true
                                 and Account__r.Area__c = :area
                                 and CreatedDate in :facilityCreatedDates.values()
                                 and IUSA_Sign_Status__c = 'Image USA II'
                                 ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            signCnt ++;
        }
        facilitiesData.USAScionStatus = signCnt/activeAreaDealerships;
        
      }
      else if(district != null)
      {
        for(AggregateResult ar : [Select Account__c, max(CreatedDate) maxDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.District__c = :district
                                   group by Account__c])
            facilityCreatedDates.put((String)ar.get('Account__c'), (DateTime)ar.get('maxDate'));
        
        Integer activeAreaDealerships = 1;
        
        /*for(AggregateResult ar : [Select count(Id)cnt
                                    from Account 
                                   where RecordType.Name = 'Dealership'
                                     and Active_Dealer__c = true
                                     and District__c = :district])
            activeAreaDealerships = Integer.ValueOf(ar.get('cnt'));*/
        
        activeAreaDealerships = 1;
        /**
         *Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where IUSA Building Status = Image USA II.  If there are multiple facilities on a Dealership, 
       *  evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the 
       *  Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen].
       */
        Double enrolledCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.District__c = :district
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and IUSA_Building_Status__c = 'Image USA II'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            enrolledCnt ++;
        }
        facilitiesData.enrolled =  enrolledCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where (IUSA Building Status = Image USA II OR Overall Status = Project Complete).  If there are multiple 
       *  facilities on a Dealership, evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in 
       *  the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]
         */
        Double completeCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.District__c = :district
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and (IUSA_Building_Status__c = 'Image USA II' or Overall_Status__c = 'Project Complete')
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            completeCnt ++;
        }
        facilitiesData.complete = completeCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where Overall Status = Under Construction.  If there are multiple facilities on a Dealership, evaluate 
       *  the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the Area (Record Type = Dealership 
       *  AND Active Dealer = TRUE and Area = [Area Chosen]
         */
        Double constructionCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.District__c = :district
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and Overall_Status__c = 'Under Construction'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            constructionCnt ++;
        }
        facilitiesData.underConstruction = constructionCnt/activeAreaDealerships;
        
        /* Percentage Formula:
       *  Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       *  that have a Facility where Scion = Yes.  If there are multiple facilities on a Dealership, evaluate the one with the MAX Created Date.  
       *  Divide this by the Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE 
       *  and Area = [Area Chosen]
         */
        Double scionCnt = 0;
        for(Facility__c f : [Select Account__c, CreatedDate
                                    from Facility__c 
                                   where Account__r.RecordType.Name = 'Dealership'
                                     and Account__r.Active_Dealer__c = true
                                     and Account__r.District__c = :district
                                     and CreatedDate in :facilityCreatedDates.values()
                                     and Scion__c = 'Yes'
                                     ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            scionCnt ++;
        }
        facilitiesData.scionComplete = scionCnt/activeAreaDealerships;
        
        /**
         * Percentage Formula:
       * Count the # of Active Dealerships in the Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]) 
       * that have a Facility where  IUSA Sign Status = Image USA II.  If there are multiple facilities on a Dealership, 
       * evaluate the one with the MAX Created Date.  Divide this by the Count the # of Active Dealerships in the 
       * Area (Record Type = Dealership AND Active Dealer = TRUE and Area = [Area Chosen]
             */
        Double signCnt = 0;
        for(Facility__c f : [ Select Account__c, CreatedDate
                                from Facility__c 
                               where Account__r.RecordType.Name = 'Dealership'
                                 and Account__r.Active_Dealer__c = true
                                 and Account__r.District__c = :district
                                 and CreatedDate in :facilityCreatedDates.values()
                                 and IUSA_Sign_Status__c = 'Image USA II'
                                 ])
        {
          if(f.CreatedDate == facilityCreatedDates.get(f.Account__c))
            signCnt ++;
        }
        facilitiesData.USAScionStatus = signCnt/activeAreaDealerships;
      }
      return facilitiesData;
    }
    
    

}