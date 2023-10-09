/* Name:  pcntChangeInProfitController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global with sharing class pcntChangeInProfitController {
	
	global Id AccountId{get;set;}
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
    global static list<chartData> retrieveData(string accountId, string area, string district) 
    {
    	String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
    	list<chartData> data = new list<chartData>();
       	
       	chartData ytd = new chartData();
       	chartData mtd = new chartData();
       //	string district = '';
       //	string area = '';
       	//================
       	// The Key Metrics record associated with the Dealership with the most recent As of Date
       	if(accountId != null)
       	{
	       	for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, null, null, null))
	    	{
			    //MTD
			    mtd.dateContext = 'MTD';
			    mtd.dealer = s.Change_in_MTD_Profit__c/100;
	    		//YTD
	    		ytd.dateContext = 'YTD';
			    ytd.dealer = s.Change_in_YTD_Profit__c/100;
			    district = s.Dealership__r.District__c;
			    area = s.Dealership__r.Area__c;
	       	  	if(s.Financial_As_of_Date__c != null)
	       	       mtd.asOfDate = s.Financial_As_of_Date__c.format();
	    	}
       	}
    	
    	
		
		//================
       	// the Key Metrics District level record for that Dealership’s District with the most recent As of Date
       	if((district != null && district != '') )
       	{
	       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, null, district, null))
	    	{
			    //MTD
			    mtd.dateContext = 'MTD';
			    mtd.district = ar.Change_in_MTD_Profit__c/100;
			    area = ar.Area__c;
	    		//YTD
	    		ytd.dateContext = 'YTD';
			    ytd.district =ar.Change_in_YTD_Profit__c/100;
			    
			    
	       	  	if(ar.Financial_As_of_Date__c != null)
	       	       mtd.asOfDate = ar.Financial_As_of_Date__c.format();
	    	}
       	}
       	else
       	{
       		list<chartData> mtdDistricts = new list<chartData>();
       		list<chartData> ytdDistricts = new list<chartData>();
       		for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getAreaDistrictStatData(area))
	    	{
			    //MTD
			    mtd.dateContext = 'MTD';
			    mtd.district = ar.Change_in_MTD_Profit__c/100;
			    ///districtColumns = (districtColumns==null ? '' : (districtColumns+'\n'))+'data.addColumn("number", "District");';
	    		//YTD
	    		mtd.dateContext = 'YTD';
			    mtd.district =ar.Change_in_YTD_Profit__c/100;
			    
			    data.add(ytd);
    	        data.add(mtd);
			    
			    
	    	}
	    	
       	}
    	
    	
    	//================
       	// Key Metrics Area level record for that Dealership’s Area with the most recent As of Date
       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, area, null, null))
       	{
		    //MTD
		    mtd.dateContext = 'MTD';
		    mtd.area = ar.Change_in_MTD_Profit__c/100;
    		//YTD
    		ytd.dateContext = 'YTD';
		    ytd.area = ar.Change_in_YTD_Profit__c/100;
    	}
    	//================
       	// the Key Metrics Region level record with the most recent As of Date
       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, null, null, 'Region'))
    	{
		    //MTD
		    mtd.dateContext = 'MTD';
		    mtd.region = ar.Change_in_MTD_Profit__c/100;
    		//YTD
    		ytd.dateContext = 'YTD';
		    ytd.region = ar.Change_in_YTD_Profit__c/100;
    	}
    	
    	data.add(ytd);
    	data.add(mtd);
		
        return data;
    }
    
    public string getfinancialAsOfDate()
   	{
   		for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, area, district, null))
   		{
   			if(s.Financial_As_of_Date__c != null)
	       	   return s.Financial_As_of_Date__c.format();
   		}
   		
   		return '[Date Not Available]';
   	}
   	
   	
   	//===========================
   	//Retur the Chart data in JSON format
   	public string getChartData()
   	{
   		
   		String masterAccount = Dealer_Dash_Rollup_Account__c.getInstance().Account_ID__c;
    	list<chartData> data = new list<chartData>();
       	
       	chartData ytd = new chartData();
       	chartData mtd = new chartData();
       //	string district = '';
       //	string area = '';
       	//================
       	// The Key Metrics record associated with the Dealership with the most recent As of Date
       	if(accountId != null)
       	{
	       	for(SET_Dealer_Performance_Metrics__c s : DashboardUtils.getStatData(accountId, null, null, null))
	    	{
			    //MTD
			    mtd.dateContext = 'MTD';
			    mtd.dealer = s.Change_in_MTD_Profit__c/100;
	    		//YTD
	    		ytd.dateContext = 'YTD';
			    ytd.dealer = s.Change_in_YTD_Profit__c/100;
			    district = s.Dealership__r.District__c;
			    area = s.Dealership__r.Area__c;
	    	}
       	}
		
		//================
       	// the Key Metrics District level record for that Dealership’s District with the most recent As of Date
       	String districtColumns = '';
       	if((district != null && district != '') )
       	{
	       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, null, district, null))
	    	{
			    //MTD
			    mtd.dateContext = 'MTD';
			    mtd.district = ar.Change_in_MTD_Profit__c/100;
			    area = ar.Area__c;
	    		//YTD
	    		ytd.dateContext = 'YTD';
			    ytd.district =ar.Change_in_YTD_Profit__c/100;
			    
	    	}
       	}
       	else
       	{
       		list<chartData> mtdDistricts = new list<chartData>();
       		list<chartData> ytdDistricts = new list<chartData>();
       		
       		for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getAreaDistrictStatData(area))
	    	{
			    chartData ytda = new chartData();
       			chartData mtda = new chartData();
			    //MTD
			    mtda.dateContext = 'MTD';
			    mtda.district = ar.Change_in_MTD_Profit__c/100;
			    districtColumns = (districtColumns==null ? '' : districtColumns) +',"District-'+ar.District__c+'"';
	    		//YTD
	    		ytda.dateContext = 'YTD';
			    ytda.district =ar.Change_in_YTD_Profit__c/100;
			    
			    ytdDistricts.add(ytda);
    	        mtdDistricts.add(mtda);
			    
	    	}
	    	
	    	ytd.areaDistricts = ytdDistricts;
	    	mtd.areaDistricts = mtdDistricts;
	    	
       	}
    	
    	
    	//================
       	// Key Metrics Area level record for that Dealership’s Area with the most recent As of Date
       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, area, null, null))
       	{
		    //MTD
		    mtd.dateContext = 'MTD';
		    mtd.area = ar.Change_in_MTD_Profit__c/100;
    		//YTD
    		ytd.dateContext = 'YTD';
		    ytd.area = ar.Change_in_YTD_Profit__c/100;
		    
    	}
    	
    	//================
       	// the Key Metrics Region level record with the most recent As of Date
       	for(SET_Dealer_Performance_Metrics__c ar : DashboardUtils.getStatData(null, null, null, 'Region'))
    	{
		    //MTD
		    mtd.dateContext = 'MTD';
		    mtd.region = ar.Change_in_MTD_Profit__c/100;
    		//YTD
    		ytd.dateContext = 'YTD';
		    ytd.region = ar.Change_in_YTD_Profit__c/100;
		    
		    
       	  	/*if(ar.Financial_As_of_Date__c != null)
       	       financialAsOfDate = ar.Financial_As_of_Date__c.format();*/
    	}
    	
    	data.add(mtd);
    	data.add(ytd);
    	
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