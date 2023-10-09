/*
Change Log
9/10/2020 - Neha Agrawal - used Challengex__c field in getChallenges method to reduce the number of challenges on Launch
Challenge Form. Updated picklist Api values in getRequiredDocuments method.

12/15/2022 - Neha Agrawal - Added No Match Challenge Year and Months method

03/2/2023- Neha Agrawal - Added previous year for No Match Challenge Year.
03/22/2023- Neha Agrawal - Added documents for Storm and Presold
04/20/2023- Neha Agrawal - Added duplicate No Match cases method.
*/


public without sharing class setd_IncentivesChallengeController {
    
    
    @AuraEnabled
    public static setd_CaseInfo.CaseInfo getCaseInfo() {
        setd_CaseInfo caseInfo = new setd_CaseInfo();
        setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('Incentives Challenge');
        
        setd_Utilities utilities = new setd_Utilities();
        caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
        caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
        return caseInfoObject;
    }
    
    @AuraEnabled
    public static List<String> getChallengeRequirements(String challenge) {
        return getRequiredDocuments(challenge);
    }
    
    @AuraEnabled
    public static List<Case> duplicateCases(String vin, String chalngType){
        List<Case> dupNoMatch = New List<Case>();
        List<Id> caseIds = New List<Id>();
        List<CaseShare> caseShareList  = new List<CaseShare>();
        List<UserRecordAccess> accessIds= New List<UserRecordAccess>();
        dupNoMatch =[SELECT Id,RTP_Contact_Name__c,Challenge__c,SET_VIN__c,CaseNumber, CreatedBy.Name,CreatedDate
                     FROM Case WHERE Challenge__c =: chalngType AND SET_VIN__c=:vin AND
                     CreatedDate=THIS_MONTH ORDER BY CreatedDate DESC LIMIT 10];
        system.debug('current user Id '+ UserInfo.getUserId());
        If(!dupNoMatch.isEmpty()){
            For(Case c:dupNoMatch){
                caseIds.add(c.Id);
            }  
            accessIds=[SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() 
                       AND RecordId IN :caseIds LIMIT 200];
            
            For(UserRecordAccess u:accessIds){
                 system.debug('HasReadAccess '+u.HasReadAccess); 
                If(!u.HasReadAccess){
                    CaseShare CaseShareRecord=new CaseShare();
                    CaseShareRecord.CaseId=u.RecordId;
                    CaseShareRecord.RowCause='Manual';
                    CaseShareRecord.CaseAccessLevel='Read';
                    CaseShareRecord.UserOrGroupId=UserInfo.getUserId();
                    caseShareList.add(CaseShareRecord);
                }  
            }
            If(!caseShareList.isEmpty()){
                insert caseShareList;
            }
        }
        return dupNoMatch;
        
    }
    
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getChallenges() {
        avs_PicklistUtil utilities = new avs_PicklistUtil();
        system.debug('Testing size of values. '+utilities.getPicklistValues('Case', 'Challengex__c').Size());
        return utilities.getPicklistValues('Case', 'Challengex__c');
    }
    
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getchallengemonth() {
        Referral_Source__c incDetails=Referral_Source__c.getInstance('IncentiveMonthsYears');
        List<avs_PicklistUtil.PicklistValue> incMonthList=new List<avs_PicklistUtil.PicklistValue>();
        if(incDetails.January__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('01','January'));  
        }
        if(incDetails.February__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('02','February'));  
        }
        if(incDetails.March__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('03','March'));  
        }
        if(incDetails.April__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('04','April'));  
        }
        if(incDetails.May__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('05','May'));  
        }
        if(incDetails.June__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('06','June'));  
        }
        if(incDetails.July__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('07','July'));  
        }
        if(incDetails.August__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('08','August'));  
        }
        if(incDetails.September__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('09','September'));  
        }
        if(incDetails.October__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('10','October'));  
        }
        
        if(incDetails.November__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('11','November'));  
        }
        if(incDetails.December__c){
            incMonthList.add(new avs_PicklistUtil.PicklistValue('12','December'));  
        } 
        return incMonthList;
    }
    
    @AuraEnabled
    public static List<avs_PicklistUtil.PicklistValue> getchallengeyear() {
        Referral_Source__c incDetails=Referral_Source__c.getInstance('IncentiveMonthsYears');
        List<avs_PicklistUtil.PicklistValue> incYearList=new List<avs_PicklistUtil.PicklistValue>();
        Integer currentYr=System.Today().year();
        If(incDetails.Last_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr-1),String.valueOf(currentYr-1)));  
        }
        If(incDetails.First_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr),String.valueOf(currentYr)));  
        }
        If(incDetails.Second_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr+1),String.valueOf(currentYr+1)));  
        }
        If(incDetails.Third_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr+2),String.valueOf(currentYr+2)));  
        }
        If(incDetails.Fourth_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr+3),String.valueOf(currentYr+3)));  
        }
        If(incDetails.Fifth_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr+4),String.valueOf(currentYr+4)));  
        }
        If(incDetails.Sixth_Year__c){
            incYearList.add(new avs_PicklistUtil.PicklistValue(String.valueOf(currentYr+5),String.valueOf(currentYr+5)));  
        }
        
        return incYearList;
    }
    
    private static List<String> getRequiredDocuments(String challenge) {
        List<String> requiredDocuments = new List<String> ();
        Map<String, List<String>> challengeRequirements = new Map<String, List<String>> {
            'Signed Associate Worksheet' => new List<String> {'ASSOCIATE_PURCHASE'},
                'Signed bill of sale' => new List<String> {'CH_SET_CHALLENGE','Storm', 'DEALER_EMPLOYEE_PURCHASE', 'FRIEND_NEIGHBOR','FC_TCUV_FLAT_CANCEL_CHALLENGE','SETF_PROGRAM_AUDIT','FC_TCUV_Challenge', 'GROUND_STOCK', 'Lease_Loyalty', 'OTHER', 'SALES_AUDIT', 'TC_TMS_Challenge'},
                    'Dealer Invoice' => new List<String> {'DEALER_EMPLOYEE_PURCHASE'}, 
                        'Signed finance or lease contract' => new List<String> {'CH_SET_CHALLENGE', 'Storm','DEALER_EMPLOYEE_PURCHASE', 'FRIEND_NEIGHBOR','FC_TCUV_FLAT_CANCEL_CHALLENGE','SETF_PROGRAM_AUDIT','GROUND_STOCK', 'Lease_Loyalty', 'OTHER', 'SALES_AUDIT', 'TC_TMS_Challenge'},   
                            'Signed Friends & Neighbors Form' => new List<String> {'FRIEND_NEIGHBOR'},
                                'Signed storm relief program form' => new List<String> {'Storm'}, 
                                    'Insurance claim documentation' => new List<String> {'Storm'},    
                                        'Signed and Initialed SET Dealer’s Employee Purchase Reimbursement Form' => new List<String> {'DEALER_EMPLOYEE_PURCHASE'},
                                            'Final registration with tag number/Title Work' => new List<String> {'CH_SET_CHALLENGE','FC_TCUV_Challenge', 'GROUND_STOCK', 'SETF_PROGRAM_AUDIT','OTHER', 'SALES_AUDIT', 'TC_TMS_Challenge'},
                                                'Include TC06 contract or JMA Invoice' => new List<String> {'FC_TCUV_FLAT_CANCEL_CHALLENGE'},
                                                    'Copy of cash receipt(s) if any' => new List<String> {'CH_SET_CHALLENGE', 'SETF_PROGRAM_AUDIT', 'FC_TCUV_Challenge', 'GROUND_STOCK','OTHER', 'SALES_AUDIT', 'TC_TMS_Challenge'},
                                                        'Any additional document you feel applicable/support to your challenge' => new List<String> {'CH_SET_CHALLENGE', 'SETF_PROGRAM_AUDIT','FC_TCUV_Challenge', 'GROUND_STOCK', 'OTHER', 'SALES_AUDIT', 'TC_TMS_Challenge'},
                                                            'Buyer\'s Order or Finance/Lease Contract'=> new List<String> {'NO_MATCH'},
                                                                'Signed Buyers order or Finance Contract '=> new List<String> {'EXPORT'},
                                                                    'Final Registration'=> new List<String> {'NO_MATCH','EXPORT'},
                                                                        'Title Work'=> new List<String> {'NO_MATCH'},
                                                                            'Driver\'s License'=> new List<String> {'EXPORT'},  
                                                                                'MSO front & back'=> new List<String> {'EXPORT'}, 
                                                                                    'No paperwork required if the vehicle is a qualifying series and is reported as pre-sold to the name on the challenge request and the ultimate retail consumer.'=> new List<String> {'Presold'},
                                                                                        'Signer\'s association to the company which authorizes them to purchase on behalf of the business.'=> new List<String> {'EXPORT'} 
            
        };
            for (String key : challengeRequirements.keySet()) {
                if (challengeRequirements.get(key).contains(challenge)) {
                    requiredDocuments.add(key);
                }
            }
        system.debug('Size of Required Doc '+ requiredDocuments.size());
        return requiredDocuments;
    }
    
}