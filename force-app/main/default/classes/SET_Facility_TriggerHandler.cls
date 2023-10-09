/**********************************************************************************************************************************

Created On:3/11/2015
Created By: Jay B
Purpose: TKT0544571 - requirement 3C. Need to propagate Otehr manfucturer field value to Account object. Called from Facility object trigger

Change Log
Date - Changed by - Change Description
10/08/2021 - Neha Agrawal - Added updateAvgAssessScore method to calculate the avg Dealer Assessmnet Score
***********************************************************************************************************************************/
public class SET_Facility_TriggerHandler {

  static Set<Id> facilityProcessed=new Set<Id>();
    
  public void onAfterUpdate(LIST<Facility__c> FacilityList){
  	 
  	 populateAccountFields(FacilityList);
      updateAvgAssessScore();
  	 
  }
  
  public void onAfterInsert(LIST<Facility__c> FacilityList){
  	
  	populateAccountFields(FacilityList);
      updateAvgAssessScore();
  	
  }
  
    public void updateAvgAssessScore() {
        system.debug('facilityProcessed size is '+ facilityProcessed.size());
        List<Facility__c> facilityToUpdate=new List<Facility__c>();
        List<Facility__c> lstFacility=[SELECT id,Assessment_Score__c, Avg_Assessment_Dealer_Score__c,
                                       Active_Facility__c FROM Facility__c WHERE Active_Facility__c=true AND 
                                       Account__r.Active_Dealer__c=true AND Assessment_Score__c<>null];
        if(!lstFacility.isEmpty()){
            decimal assessmentSum=0;
            for(Facility__c f:lstFacility){
                assessmentSum=assessmentSum+f.Assessment_Score__c;
            }
            decimal assessmentAvg=assessmentSum/lstFacility.Size();
            for(Facility__c f:lstFacility){
                if(!facilityProcessed.contains(f.Id) && f.Avg_Assessment_Dealer_Score__c<>assessmentAvg){
                    f.Avg_Assessment_Dealer_Score__c=assessmentAvg;
                    facilityToUpdate.add(f);
                    facilityProcessed.add(f.Id);
                }
            }
            if(!facilityToUpdate.isEmpty()){
                update facilityToUpdate;
            }
            
        }
        
    }
    
  public void populateAccountFields(LIST<Facility__c> FacilityList) {
  	
  	MAP<ID,string> accountOtherMfcMap=new MAP<ID,string>();
  	LIST<Account> acctList=new LIST<Account>();
  	LIST<ID> acctIDList=new LIST<ID>();
  	
  	
  	for(Facility__c facilityRec:FacilityList){
  		acctIDList.add(facilityRec.Account__c);
  	}
  	
  	
  	
  	
  	for (Facility__c facilityRec:[Select ID,Dualed__c,Other_Manufacturer__c,Account__c from Facility__c where Account__c in :acctIDList order by createddate]) {
  		if(facilityRec.Dualed__c==false){
  			accountOtherMfcMap.put(facilityRec.Account__c,null);
  		}
  		else {
  			string OtherMfg=facilityRec.Other_Manufacturer__c;
  			
  			if(accountOtherMfcMap.containsKey(facilityRec.Account__c)){
  				LIST<string> othmfc=new LIST<string>();
  				othmfc=accountOtherMfcMap.get(facilityRec.Account__c).split(';');
  				LIST<string> othmfcCurrRec=new LIST<string>();
  				othmfcCurrRec=facilityRec.Other_Manufacturer__c.split(';');
  				for(string strExistRec:othmfc){
  					MAP<string,string> existrecMap=new MAP<string,string>();
  					for(string strCurrRec:othmfcCurrRec){
  						if(strExistRec==strCurrRec){
  							existrecMap.put(strExistRec,'Found');
  						}
  					}
  					if(!existrecMap.containsKey(strExistRec)){
  						OtherMfg +=';'+strExistRec;
  					}
  				}
  				
  			}
  			accountOtherMfcMap.put(facilityRec.Account__c,OtherMfg);
  		}
  	}
  	
  	for (Account acctRec:[Select ID,SET_Dualed__c,SET_Other_Manufacturer__c from Account where ID in :accountOtherMfcMap.keySet()]){
  		if(accountOtherMfcMap.get(acctRec.ID)!=null && (acctRec.SET_Other_Manufacturer__c==null||acctRec.SET_Other_Manufacturer__c!=accountOtherMfcMap.get(acctRec.ID))){
  			acctRec.SET_Dualed__c=true;
  			acctRec.SET_Other_Manufacturer__c=accountOtherMfcMap.get(acctRec.ID);
  			acctList.add(acctRec);
  			
  		}
  		else if(accountOtherMfcMap.get(acctRec.ID)==null && acctRec.SET_Other_Manufacturer__c !=null){
  			acctRec.SET_Dualed__c=false;
  			acctRec.SET_Other_Manufacturer__c=null;
  			acctList.add(acctRec);
  		}
  	}
  	
  	if(acctList.size()>0){
  		update acctList;
  	}
  }

}