/* Name:  MarketShareController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class MarketShareController {
	global Id AccountId{get;set;}
	public String area{get;set;}
	public String district{get;set;}
   	String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;//'001K000000KX8Bp';
   	public SET_Dealer_Performance_Metrics__c MasterMarketShare{get;set;}
   	public SET_Dealer_Performance_Metrics__c DealerMarketShare{get;set;}
   	public SET_Dealer_Performance_Metrics__c DistrictMarketShare{get;set;}
   	public SET_Dealer_Performance_Metrics__c AreaMarketShare{get;set;}
   	public SET_Dealer_Performance_Metrics__c RegionMarketShare{get;set;}
   	public String masterLabel{get;set;}
   	
   	
   	public class marketShareRow
   	{
   		public string col1Label{get;set;}
   		public string col2Label{get;set;}
   		public Double col1Value{get;Set;}
   		public Double col2Value{get;Set;}
   		
   	}
   	
   	public list<marketShareRow> subMarkets{get;set;}

   	
   	public MarketShareController()
   	{
   		AccountId = ApexPages.currentPage().getParameters().get('Id');
   		district = ApexPages.currentPage().getParameters().get('district');
   		area = ApexPages.currentPage().getParameters().get('area');
   		getData();
   	}
   	
   	public string getChartAsOfDate()
   	{
   		Date maxAsOfDate = DashboardUtils.getMaxAsOfDate(AccountId, area, district, null);
       	if(maxAsOfDate != null)
       	   return maxAsOfDate.format();
       	else
       	   return '[Date Not Available]';
   	}
   	
	public void getData()
	{
		subMarkets = new list<marketShareRow>();
		DealerMarketShare = new SET_Dealer_Performance_Metrics__c(Retail_Market_Share__c = 0);
		Date maxAsOfDate;
       	
       	//get the most recent date first
       	for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, area, district, null))
	    {
	    		MasterMarketShare = s;
	    		if(AccountId != null)
       			{	
		    		district = s.District__c;
	    		}
	    		area = s.Area__c;
		    		
       	}
    	//return DealerMarketShare;
	
		DistrictMarketShare = new SET_Dealer_Performance_Metrics__c(Retail_Market_Share__c = 0);
       	
       	//get the most recent date first
      	for(SET_Dealer_Performance_Metrics__c s :DashboardUtils.getStatData(null, null, district, null))
    	{
    		DistrictMarketShare = s;
    	}
    	
		AreaMarketShare = new SET_Dealer_Performance_Metrics__c(Retail_Market_Share__c = 0);
		
       	for(SET_Dealer_Performance_Metrics__c s :DashboardUtils.getStatData(null, area, null, null))
    	{
    		AreaMarketShare = s;
    	}
	
		RegionMarketShare = new SET_Dealer_Performance_Metrics__c(Retail_Market_Share__c = 0);
       	
       	//get the most recent date first
      	for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(null, null, null, 'Region'))
    	{
    		RegionMarketShare = s;
    	}
    	
    	//load the sub-market array
    	
    	if(AccountId != null)
    	{
    		masterLabel = 'Dealer';
    		marketShareRow shareRow = new marketShareRow();
    		shareRow.col1Label = 'District';
    		shareRow.col2Label = 'Area';
    		shareRow.col1Value = DistrictMarketShare.Retail_Market_Share__c;
    		shareRow.col2Value = AreaMarketShare.Retail_Market_Share__c;
    		subMarkets.add(shareRow);
    		
    		marketShareRow shareRow2 = new marketShareRow();
    		shareRow2.col1Label = 'Region';
    		shareRow2.col2Label = '';
    		shareRow2.col1Value = DistrictMarketShare.Retail_Market_Share__c;
    		shareRow2.col2Value = null;
    		subMarkets.add(shareRow2);
    		
    	}
    	if(AccountId == null && district != null)
    	{
    		masterLabel = 'District';
    		marketShareRow shareRow = new marketShareRow();
    		shareRow.col1Label = 'Area';
    		shareRow.col2Label = 'Region';
    		shareRow.col1Value = AreaMarketShare.Retail_Market_Share__c;
    		shareRow.col2Value = RegionMarketShare.Retail_Market_Share__c;
    		subMarkets.add(shareRow);   		    		
    	}
    	if((district == null || district == '') && area != null && area != '')
    	{
    		masterLabel = 'Area';
    		Integer colCnt = 3;
    		Integer rowCnt = 1;
    		marketShareRow shareRow;
    		list<SET_Dealer_Performance_Metrics__c> dList = DashboardUtils.getAreaDistrictStatData(area);
    		for(SET_Dealer_Performance_Metrics__c s : dList)
	    	{
	    		if(colCnt > 2)
	    		{
		    		colCnt = 1;
		    		shareRow = new marketShareRow();
		    		shareRow.col1Label = 'District-'+s.District__c;
		    		shareRow.col1Value = s.Retail_Market_Share__c;
		    		if(rowCnt == dList.size())
		    		{
		    		 	subMarkets.add(shareRow);
		    		 	break;
		    		}
		    		  
	    		}
	    		else if(colCnt == 2)
	    		{
	    			shareRow.col2Label = 'District-'+s.District__c;
		    		shareRow.col2Value = s.Retail_Market_Share__c;
		    		subMarkets.add(shareRow);
	    		}
		    	colCnt ++;
		    	rowCnt ++;
	    	}
	    	if(colCnt == 1)
	    	{
	    		marketShareRow r = subMarkets.get(subMarkets.size()-1);
	    		r.col2Label = 'Region';
	    		r.col2Value = RegionMarketShare.Retail_Market_Share__c;
	    	}
	    	else
	    	{
	    		marketShareRow r = new marketShareRow();
	    		r.col1Label = 'Region';
	    		r.col1Value = RegionMarketShare.Retail_Market_Share__c;
	    		subMarkets.add(r);
	    		
	    	}   	    	
    	}    	
	}
}