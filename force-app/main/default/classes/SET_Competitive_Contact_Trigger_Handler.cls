/************************************************************************************************************
Intital Creation History
Created By: Jay B
Created On: 5/19/2014
Purpose: this is used to populate Name field from First and Last Name.
	    
	   
**************************************************************************************************************/	 

public with sharing class SET_Competitive_Contact_Trigger_Handler {
	public static void populateCCName(list<Competitive_Contact__c> compContactList){
		
		for (Competitive_Contact__c comContactRec:compContactList){
			if (comContactRec.First_Name__c !=null && comContactRec.Last_Name__c !=null){
				comContactRec.Name=comContactRec.First_Name__c+' '+ comContactRec.Last_Name__c;
				
			}
		}
		
	}
}