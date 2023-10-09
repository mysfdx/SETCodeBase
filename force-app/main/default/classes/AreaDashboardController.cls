public with sharing class AreaDashboardController {
	
	public string area{get;set;}
	public string district{get;set;}
	public AreaDashboardController()
	{
		try{area = [select Id, Area__c from District_Area_Ownership_Mapping__c 
		         where Area__c = :ApexPages.currentPage().getParameters().get('area') 
		           and District__c = null
		         limit 1].Area__c;
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'NO DATA FOUND FOR THE SELECTED AREA'));
			area = '';
		}
	}

    public list<SelectOption> getDistricts()
    { 
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('', '--None--'));
    	for(District_Area_Ownership_Mapping__c d : [Select District__c, Name
    	                                              from District_Area_Ownership_Mapping__c 
    	                                             where Area__c = :area 
    	                                               and District__c != null
    	                                              order by District__c])
    	   options.add(new SelectOption(d.District__c, 'District '+d.District__c));
    	   
    	return options;
    }    
}