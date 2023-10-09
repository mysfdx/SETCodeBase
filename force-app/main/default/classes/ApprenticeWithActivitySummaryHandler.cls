/*
Created By: Neha Agrawal-- ENHC0012046
Created Date: 11th Aug 2020
Description: Trigger handler which runs before insert and update of Apprentice record for autopopulating some fields

Change logs

Modified Date -- Modified By -- Purpose
27th June 2022 -- Neha Agrawal -- Now Apprentice's SPIN are not unique, two apprentice can have same SPINs
*/


public class ApprenticeWithActivitySummaryHandler {
    static Set<String> DealerDistrict=new Set<String>();
    static List<string> newSpinSet = new List<string>();
    
    static set<string> newPhaseSet = new set<string>();
    
    static List<string> dbSpinSet = new List<string>();
    
    static set<string> dbPhaseSet = new set<string>();
    
    Public static void onBeforeInsert(List<Apprentice__c> Act ){
        
        for (Apprentice__c apprentice : Act) {
            DealerDistrict.add(apprentice.Dealer_District__c);
            //newSpinSet.add(apprentice.Apprentice_SPIN_New__c);
            //newPhaseSet.add(apprentice.Phase__c);
        }
        
        /*for (Apprentice__c tr: [Select id, Apprentice_SPIN_New__c, phase__c from Apprentice__c where 
                                Apprentice_SPIN_New__c in:newSpinSet]){
                                    
                                    dbSpinSet.add(tr.Apprentice_SPIN_New__c);
                                    dbPhaseSet.add(tr.Phase__c);                    
                                }*/
        
        
        List<Activity_Summary__c> ActivityList = [SELECT id, Name FROM Activity_Summary__c WHERE Name IN :DealerDistrict];
        
        Map<String, Activity_Summary__c> DistrictToActivitySummary = new Map<String, Activity_Summary__c>();
        
        for (Activity_Summary__c ats : ActivityList) {
            DistrictToActivitySummary.put(ats.Name, ats);
        }
        for (Apprentice__c appr : Act) {
            if (appr.Dealer_District__c != null) {
                appr.Activity_Summary__c = DistrictToActivitySummary.get(appr.Dealer_District__c).id;
                appr.DistrictSharing__c=appr.Dealer_District__c;
            }
           // if(dbSpinSet.contains(appr.Apprentice_SPIN_New__c) && dbPhaseSet.Contains(appr.Phase__c))
                
                //appr.addError('You are inserting Duplicate Record');
        }
        
    }
    Public static void onBeforeUpdate(List<Apprentice__c> Act ){
        for (Apprentice__c apprentice : Act) {
            DealerDistrict.add(apprentice.Dealer_District__c);
            
        }
        
        List<Activity_Summary__c> ActivityList = [SELECT id, Name FROM Activity_Summary__c WHERE Name IN :DealerDistrict];
        
        Map<String, Activity_Summary__c> DistrictToActivitySummary = new Map<String, Activity_Summary__c>();
        
        for (Activity_Summary__c ats : ActivityList) {
            DistrictToActivitySummary.put(ats.Name, ats);
        }
        for (Apprentice__c appr : Act) {
            if (appr.Dealer_District__c != null) {
                appr.Activity_Summary__c = DistrictToActivitySummary.get(appr.Dealer_District__c).id;
                appr.DistrictSharing__c=appr.Dealer_District__c;
            }
            
        }
        
    }
    
}