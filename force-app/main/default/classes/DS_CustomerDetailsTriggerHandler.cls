/* Name:  DS_CustomerDetailsTriggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CustomerDetailsTriggerHandler {
    public static void onAfterInsert(List < DS_Customer_Details__c > listCustDetails) {
		createTimeWorked(listCustDetails);
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/28/2016
    Purpose      : To create Time Worked records
    */
    
    public static void createTimeWorked(List < DS_Customer_Details__c > listCustDetails) {
        List < DS_Time_Worked__c > listTimeWorked = new List < DS_Time_Worked__c >();
        Decimal TotalTime = 0;
        for ( DS_Customer_Details__c CD : listCustDetails ) {       		
	    	DS_Time_Worked__c tc = new DS_Time_Worked__c();  
            tc.Name = '1 Minute';      
            tc.DS_Time_Case__c = CD.DS_Customer_Name__c;
            tc.DS_Total_time_worked__c = 0.01;
            listTimeWorked.add(tc);  
        }
        if ( listTimeWorked.size() > 0 ) 
            insert listTimeWorked;
    }    
}