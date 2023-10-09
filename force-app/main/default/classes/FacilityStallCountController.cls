/*
Name:FacilityStallCountController
Purpose:This has been used to display facility stall table on lightning page.
Author: Neha Agrawal
Date: 09/02/2022

Change Log
Date-- Changedby-- Purpose--
*/


public class FacilityStallCountController {
    
     @AuraEnabled
    static public List<FacilitySumInfo> getFacilityInfo() {
        List<Facility__c> facilityList=[SELECT Id, Flats__c, Stall_Audit_Total__c, Lifts__c, Alignment__c, 
                                        Detail__c, Car_Wash__c, Photobooth__c FROM Facility__c];
        Integer liftSum=0;
        Integer flatSum=0;
        Integer alignmentSum=0;
        Integer detailSum=0;
        Integer carWashSum=0;
        Integer photoBoothSum=0;
        For(Facility__c fac: facilityList){
            if(fac.Lifts__c<>null){
                liftSum+=integer.valueOf(fac.Lifts__c);
            }
            if(fac.Flats__c<>null){
                 flatSum+=integer.valueOf(fac.Flats__c);
            }
            if(fac.Alignment__c<>null){
                alignmentSum+=integer.valueOf(fac.Alignment__c);
            }
            if(fac.Detail__c<>null){
              detailSum+=integer.valueOf(fac.Detail__c);   
            }
            if(fac.Car_Wash__c<>null){
              carWashSum+=integer.valueOf(fac.Car_Wash__c);  
            }
            if(fac.Photobooth__c<>null){
                photoBoothSum+=integer.valueOf(fac.Photobooth__c);
            }
            
        }
        Integer StallsAuditTotals=liftSum+flatSum+alignmentSum+detailSum+carWashSum;
        List<FacilitySumInfo> FacilitySumInfoList=New List<FacilitySumInfo>();
        FacilitySumInfo sumF= new FacilitySumInfo();
        sumF.Lifts=liftSum;
        sumF.Flats=flatSum;
        sumF.Alignment=alignmentSum;
        sumF.Detail=detailSum;
        sumF.CarWash=carWashSum;
        sumF.Photobooth=photoBoothSum;
        sumF.StallTotal=StallsAuditTotals;
        FacilitySumInfoList.add(sumF);
        FacilitySumInfo prcntF= new FacilitySumInfo();
        prcntF.Lifts=((sumF.Lifts*100)/sumF.StallTotal);
        System.Debug('sumF.Lifts '+sumF.Lifts);
        System.Debug('sumF.StallTotal '+sumF.StallTotal);
        system.debug('prcntF.Lifts '+prcntF.Lifts);
        prcntF.Flats=((sumF.Flats*100)/sumF.StallTotal);
        prcntF.Alignment=((sumF.Alignment*100)/sumF.StallTotal);
        prcntF.Detail=((sumF.Detail*100)/sumF.StallTotal);
        prcntF.CarWash=((sumF.CarWash*100)/sumF.StallTotal);
        //prcntF.Photobooth=;
        prcntF.StallTotal=100;
        FacilitySumInfoList.add(prcntF);
        
        return FacilitySumInfoList;
        
    }
    
    Public class FacilitySumInfo{
        
        @AuraEnabled
        public Integer Lifts {get;set;}
        @AuraEnabled
        public Integer Flats {get;set;}
        @AuraEnabled
        public Integer Alignment {get;set;}
        @AuraEnabled
        public Integer Detail {get;set;}
        @AuraEnabled
        public Integer CarWash {get;set;}
        @AuraEnabled
        public Integer Photobooth {get;set;}
        @AuraEnabled
        public Integer StallTotal {get;set;}
    }

}