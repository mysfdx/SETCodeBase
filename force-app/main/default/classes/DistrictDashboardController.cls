/* Name:  DistrictDashboardController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DistrictDashboardController {
	public District_Area_Ownership_Mapping__c district{get;set;}
	public DistrictDashboardController()
	{
		try{
			district = [select Id, District__c, Area__c from District_Area_Ownership_Mapping__c where District__c = :ApexPages.currentPage().getParameters().get('district')];
		}
		catch(Exception e)
		{
			district = new District_Area_Ownership_Mapping__c();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'NO DATA FOUND FOR THE SELECTED DISTRICT'));
		}
	}
	
	public list<SelectOption> getDealers()
    { 
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('', '--None--'));
    	for(Account d : [Select Id, Name
                           from Account 
                          where District__c = :district.District__c
                            and District__c != null
                            and Active_Dealer__c = true
                          order by Name])
    	   options.add(new SelectOption(d.Id, d.Name));
    	   
    	return options;
    }
}