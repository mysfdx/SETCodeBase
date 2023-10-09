/* Name:  MTD_YTDProfitController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class MTD_YTDProfitController {
	
	global class dataRecord
	{
		global String year{get;set;}
		global Double amount{get;set;}
		global String asOfDate{get;set;}
	}
	public Id AccountId{get;set;}
	public String area{get;set;}
	public String district{get;set;}
	
	@RemoteAction
    global static list<dataRecord> retrieveMTDData(string accountId, string area, string district)
    {
      /* Select the MTD Profit Current Year, MTD Profit Previous Year from the Key Metrics record 
       * associated with the Dealership, Area or District with the most recent As of Date.
       */
       list<dataRecord> data = new list<dataRecord>();
       
       for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, area, district, null))//:accountId])// and As_of_Date__c = :maxAsOfDate])
       {
       	  System.Debug('::::::MTD:::::'+s);
       	  dataRecord d = new dataRecord();
       	  d.year = String.ValueOf(s.As_of_Date__c.Year() - 1);
       	  d.amount = s.MTD_Profit_Previous_Year__c;
       	  if(s.Financial_As_of_Date__c != null)
       	     d.asOfDate = s.Financial_As_of_Date__c.format();
       	  data.add(d);
       	  
       	  dataRecord d2 = new dataRecord();
       	  d2.year = String.ValueOf(s.As_of_Date__c.Year());
       	  d2.amount = s.MTD_Profit_Current_Year__c;
       	  if(s.Financial_As_of_Date__c != null)
       	     d.asOfDate = s.Financial_As_of_Date__c.format();
       	  data.add(d2);
       	  
       }
       
       return data;
    }
    
    @RemoteAction
    global static list<dataRecord> retrieveYTDData(string accountId, string area, string distric)
    {
      /* Select the MTD Profit Current Year, MTD Profit Previous Year from the Key Metrics record 
       * associated with the Dealership with the most recent As of Date.
       */
       
       list<dataRecord> data = new list<dataRecord>();
       
       for(SET_Dealer_Performance_Metrics__c s :DashboardUtils.getStatData(accountId, area, distric, null))//:accountId])// and As_of_Date__c = :maxAsOfDate])
       {
       	  System.Debug('::::::YTD:::::'+s);
       	  dataRecord d = new dataRecord();
       	  d.Year = String.ValueOf(s.As_of_Date__c.Year() - 1);
       	  d.amount = s.YTD_Profit_Previous_Year__c;
       	  data.add(d);
       	  
       	  dataRecord d2 = new dataRecord();
       	  d2.Year = String.ValueOf(s.As_of_Date__c.Year());
       	  d2.amount = s.YTD_Profit_Current_Year__c;
       	  data.add(d2);
       	  
       }
       
       return data;
    }
    
    
    public string getChartAsOfDate()
   	{
   		Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(AccountId, area, district, null);
    	
       	if(maxAsOfDate != null)
       	   return maxAsOfDate.format();
       	else
       	   return '[Date Not Available]';
   	}
}