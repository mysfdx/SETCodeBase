/* Name:  SalesEfficiencyController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class SalesEfficiencyController {
  global Id AccountId{get;set;}
  global Double amount{get;set;}
  global String asOfDate{get;set;}
  global String area{get;set;}
  global String district{get;set;}
  global String formatColumns{get;set;}
  
  global class chartData
  {
    global string dateContext{get;set;}
    global Double pcntChange{get;set;}
    global Double dealer{get;set;}
    global Double district{get;set;}
    global Double area{get;set;}
    global Double region{get;set;}
    global String asOfDate{get;set;}
    list<chartData> areaDistricts{get;set;}
  }
  @RemoteAction 
    global static list<chartData> retrieveData(string accountId) 
    {
      String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
      Date maxAsOfDate;
         list<chartData> data = new list<chartData>();
         //get the most recent date first
        for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                   From SET_Dealer_Performance_Metrics__c s
                                  where s.Dealership__c = :AccountId])
         {
            maxAsOfDate = (Date)ar.get('maxDate');
         }
         chartData car = new chartData();
         chartData truck = new chartData();
         chartData total = new chartData();
         string district = '';
         string area = '';
         //================
         // The Key Metrics record associated with the Dealership with the most recent As of Date
         for(SET_Dealer_Performance_Metrics__c s : [Select s.District__c
                                  , s.Dealership__c
                                  , s.Sales_Efficiency_Car__c
                                  , s.Sales_Efficiency_Lt_Truck__c
                                  , s.Sales_Efficiency_Total__c
                                  , s.As_of_Date__c
                                  , s.Area__c 
                                              , s.Sales_As_of_Date__c
                                From SET_Dealer_Performance_Metrics__c s
                                             where s.Dealership__c = :accountId
                                               and As_of_Date__c = :maxAsOfDate])
      {
        //CAR
        car.dateContext = 'Car';
        car.dealer = s.Sales_Efficiency_Car__c/100;
        //TRUCK
        truck.dateContext = 'Truck';
        truck.dealer = s.Sales_Efficiency_Lt_Truck__c/100;
        //TOTAL
        total.dateContext = 'Total';
        total.dealer = s.Sales_Efficiency_Total__c/100;
        
             if(s.Sales_As_of_Date__c != null)
                car.asOfDate = s.Sales_As_of_Date__c.format();
        
        district = s.District__c;
        area = s.Area__c;
      }
      
      for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                   From SET_Dealer_Performance_Metrics__c s
                                  where s.Level__c = 'District'
                                   and District__c = :district 
                                   and Dealership__c = :masterAccount])
         {
            maxAsOfDate = (Date)ar.get('maxDate');
         }
    
    //================
         // the Key Metrics District level record for that Dealership’s District with the most recent As of Date
         for(SET_Dealer_Performance_Metrics__c s : [  Select Sales_Efficiency_Total__c
                                                  , Sales_Efficiency_Car__c
                                      , Sales_Efficiency_Lt_Truck__c
                               From SET_Dealer_Performance_Metrics__c s
                                            where s.Dealership__c = :masterAccount
                                               and s.Level__c = 'District'
                                               and District__c = :district
                                       and As_of_Date__c = :maxAsOfDate])
      {
        //CAR
        car.dateContext = 'Car';
        car.district = s.Sales_Efficiency_Car__c/100;
        //TRUCK
        truck.dateContext = 'Truck';
        truck.district = s.Sales_Efficiency_Lt_Truck__c/100;
        //TOTAL
        total.dateContext = 'Total';
        total.district = s.Sales_Efficiency_Total__c/100;
      }
      
      for(AggregateResult ar : [Select max(s.As_of_Date__c) maxDate 
                                   From SET_Dealer_Performance_Metrics__c s
                                  where s.Level__c = 'Area'
                                   and Area__c = :area
                                   and Dealership__c = :masterAccount])
         {
            maxAsOfDate = (Date)ar.get('maxDate');
         }
      
      //================
         // Key Metrics Area level record for that Dealership’s Area with the most recent As of Date
         for(SET_Dealer_Performance_Metrics__c s : [  Select Sales_Efficiency_Total__c
                                                  , Sales_Efficiency_Car__c
                                      , Sales_Efficiency_Lt_Truck__c
                               From SET_Dealer_Performance_Metrics__c s
                                            where s.Dealership__c = :masterAccount
                                               and  s.Level__c = 'Area'
                                               and Area__c = :area
                                       and As_of_Date__c = :maxAsOfDate])
      {
        //CAR
        car.dateContext = 'Car';
        car.area = s.Sales_Efficiency_Car__c/100;
        //TRUCK
        truck.dateContext = 'Truck';
        truck.area = s.Sales_Efficiency_Lt_Truck__c/100;
        //TOTAL
        total.dateContext = 'Total';
        total.area = s.Sales_Efficiency_Total__c/100;
      }
      
      data.add(car);
      data.add(truck);
      data.add(total);
    
        return data;
    }
    
    public string getChartAsOfDate()
     {
       Date maxAsOfDate = DashboardUtils.getMaxAsOfDate( accountId,  area,  district, null);
       
         for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, area, district, null))
      {
         if(s.Sales_As_of_Date__c != null)
              return s.Sales_As_of_Date__c.format();
      }
            return '[Date Not Available]';
     }
     
     /*====================================
        Retur the Chart data in JSON format
       ====================================*/
     public string getChartData()
     {
       String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
      list<chartData> data = new list<chartData>();
         
         chartData car = new chartData();
         chartData truck = new chartData();
         chartData total = new chartData();
       
         //================
         // The Key Metrics record associated with the Dealership with the most recent As of Date
         if(accountId != null)
         {
           for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, null, null, null))
        {
          car.dateContext = 'Car';
          car.dealer = s.Sales_Efficiency_Car__c/100;
          //TRUCK
          truck.dateContext = 'Truck';
          truck.dealer = s.Sales_Efficiency_Lt_Truck__c/100;
          //TOTAL
          total.dateContext = 'Total';
          total.dealer = s.Sales_Efficiency_Total__c/100;
          
               if(s.Sales_As_of_Date__c != null)
                  car.asOfDate = s.Sales_As_of_Date__c.format();
          
          district = s.District__c;
          area = s.Area__c;
        }
         }
    
    //================
         // the Key Metrics District level record for that Dealership’s District with the most recent As of Date
         String districtColumns = '';
         if((district != null && district != '') )
         {
           for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, null, district, null))
        {
          car.dateContext = 'Car';
          car.district = ar.Sales_Efficiency_Car__c/100;
          //TRUCK
          truck.dateContext = 'Truck';
          truck.district = ar.Sales_Efficiency_Lt_Truck__c/100;
          //TOTAL
          total.dateContext = 'Total';
          total.district = ar.Sales_Efficiency_Total__c/100;
          
          if(ar.Sales_As_of_Date__c != null)
                  car.asOfDate = ar.Sales_As_of_Date__c.format();
          area = ar.Area__c;
        }
         }
         else
         {
           list<chartData> carDistricts = new list<chartData>();
           list<chartData> truckDistricts = new list<chartData>();
           list<chartData> totalDistricts = new list<chartData>();
           
           for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getAreaDistrictStatData(area))
        {
          chartData cara = new chartData();
             chartData trucka = new chartData();
             chartData totala = new chartData();
          //Car
          cara.dateContext = 'Car';
          cara.district = ar.Sales_Efficiency_Car__c/100;
          districtColumns = (districtColumns==null ? '' : districtColumns) +',"District-'+ar.District__c+'"';
          //Truck
          trucka.dateContext = 'Truck';
          trucka.district =ar.Sales_Efficiency_Lt_Truck__c/100;
          //Total
          totala.dateContext = 'Total';
          totala.district =ar.Sales_Efficiency_Total__c/100;
          
          
          carDistricts.add(cara);
              truckDistricts.add(trucka);
              totalDistricts.add(totala);
          
        }
        
        car.areaDistricts = carDistricts;
        truck.areaDistricts = truckDistricts;
        total.areaDistricts = totalDistricts;
        
         }
      
      
      //================
         // Key Metrics Area level record for that Dealership’s Area with the most recent As of Date
         for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(null, area, null, null))
         {
        car.dateContext = 'Car';
        car.area = s.Sales_Efficiency_Car__c/100;
        //TRUCK
        truck.dateContext = 'Truck';
        truck.area = s.Sales_Efficiency_Lt_Truck__c/100;
        //TOTAL
        total.dateContext = 'Total';
        total.area = s.Sales_Efficiency_Total__c/100;
          
             if(s.Sales_As_of_Date__c != null)
                car.asOfDate = s.Sales_As_of_Date__c.format();
      }
      
      //================
         // the Key Metrics Region level record with the most recent As of Date
         for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(null, null, null, 'Region'))
      {
        car.dateContext = 'Car';
        car.region = s.Sales_Efficiency_Car__c/100;
        //TRUCK
        truck.dateContext = 'Truck';
        truck.region = s.Sales_Efficiency_Lt_Truck__c/100;
        //TOTAL
        total.dateContext = 'Total';
        total.region = s.Sales_Efficiency_Total__c/100;
      }
      
      data.add(car);
      data.add(truck);
      data.add(total);
      
      //=================
      // construct the chart's data table
      String dataHeader = '[["Context"';
      String acctId = ApexPages.currentPage().getParameters().get('id');
      formatColumns = '';
       Integer x = 1;
       if(acctId != null)
       {
            dataHeader += ',"Dealer"';
            formatColumns = 'formatter.format(data, '+x+');+\n';
           x++;
       }
       dataHeader += ',"Area"';
       formatColumns += 'formatter.format(data, '+x+');\n';
       x++;
       if((district == null || district == '') )
         {
             dataHeader += districtColumns;
             list<string> colList = districtColumns.split(',');
             for(Integer i = 1; i< colList.size(); i++)
             {
               formatColumns += 'formatter.format(data, '+x+');\n';
              x++;
             }
             
         }
         else
         {
           dataHeader += ',"District"';
            formatColumns += 'formatter.format(data, '+x+');\n';
            x++;
         }
         
         dataHeader += ',"Region"]\n';
        formatColumns += 'formatter.format(data, '+x+');\n';//region
        
         string dataRow = '';
         
         for(chartData c : data)
         {
           dataRow += ',["'+c.dateContext+'",';
           if(acctId != null)
              dataRow += c.dealer+',';
              
            dataRow += c.area+',';
            
            if((district == null || district == '') )
            {
               for(chartData cd : c.areaDistricts)
               {
                    dataRow += cd.district+',';
               }
            }
            else
            {
             dataRow += c.district+',';
            }
            dataRow += c.region+']\n';
            
         }
        dataRow+= ']';
        
        return dataHeader + dataRow;
      
     }
}