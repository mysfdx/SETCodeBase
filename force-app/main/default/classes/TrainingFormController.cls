/*
Created By: Neha Agrawal-- ENHC0012046
Created Date: 11th Aug 2020
Description: Training Form Controller for TACT form VF page


Changelog 

Author--             Date--                       Purpose--
Neha Agrawal        12/16/2020          Added few new fields CHG0040513
Neha Agrawal        7/12/2021          To rename Training Expense plan to Rewards and Recognition and added 
fields Jira reference SS1SP-72, SS1SP-111, SS1SP-115
Neha Agrawal        8/26/2021         To move attachment, program criteria and notes to Dealer level
Neha Agrawal        7/15/2022        added new date fields like program start date and group number.
Neha Agrawal        9/19/2022        Made changes to group number, removed group from group number.
Neha Agrawal        10/20/2022       Changes to Program Start Date, added custom setting.
*/

public with sharing class TrainingFormController {
    
    public Apprentice__c appr{get;set;}
    Public boolean ifRecordExist{get;set;}
    public boolean displayPopup {get; set;}
    public boolean timer {get; set;}
    public boolean recordAvailable {get; set;}
    public Integer fileCounter{get; set;}
    public List<FileInfo> tactFiles{get; set;}
    transient List<ContentVersion> fileList;
    Public String title {get;set;}
    public List<SelectOption> dateList{get;set;}
    public String selectedDateString{get;set;}
    public SelectOption firstStartDate{get;set;}	
    public SelectOption secondStartDate{get;set;}	
    public SelectOption thirdStartDate{get;set;}
    public Referral_Source__c tactDates;
    
    public TrainingFormController(ApexPages.StandardController controller){
        dateList = new List<SelectOption>();
        this.appr=new Apprentice__c();
        ifRecordExist=false;
        fileCounter=0;
        String fisrtFile = '';
        Blob firstBlob = Blob.valueof(fisrtFile);
        tactFiles=new List<FileInfo>();
        tactFiles.add(new FileInfo(fisrtFile,fileCounter=fileCounter+1,firstBlob));
        fileList=new List<ContentVersion>();
        tactDates= Referral_Source__c.getInstance('TACTProgramStartDates');
        if(!(tactDates.FirstDate__c && tactDates.SecondDate__c && tactDates.ThirdDate__c)){
           timer=true;	
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Due to closed enrollment, few program start dates are disabled')); 
        }
        system.debug('Filelist in standard Controller '+fileList);
        
        date myDate = Date.today();
        //date myDate = date.newinstance(2022,7,1 );
        System.debug('Todays date is '+myDate);
        Integer myMonth=myDate.month();
        Integer myDay = myDate.day();
        Date fisrtDate;
        if((myMonth>0 && myMonth<7) || (myMonth==7 && myDay==1)){
            
            fisrtDate=date.newinstance(myDate.Year(),1,1 );
            System.debug('First date: ' + String.valueOf(fisrtDate).removeEnd(' 00:00:00'));
            System.debug('First date Format: ' + fisrtDate.format());
            
            
        }
        else{
            fisrtDate=date.newinstance(myDate.Year(),7,1 );
            System.debug('First date: ' + String.valueOf(fisrtDate).removeEnd(' 00:00:00'));
            System.debug('First date Format: ' + fisrtDate.format());
        }
        
        /*for(Integer i=0; i<3;i++){
            fisrtDate=fisrtDate.addMonths(6);
            System.debug('fisrtDate: ' + String.valueOf(fisrtDate).removeEnd(' 00:00:00'));
            System.debug('First date Format: ' + fisrtDate.format());
            dateList.add(new SelectOption(fisrtDate.format(),fisrtDate.format()));
        }
        Referral_Source__c tactDates=
        Referral_Source__c.getInstance('TACTProgramStartDates');
        if(!(tactDates.FirstDate__c || tactDates.SecondDate__c || tactDates.ThirdDate__c)){
           timer=true;	
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Due to closed enrollment, few program start dates are disabled')); 
        }*/
        
        fisrtDate=fisrtDate.addMonths(6);	
        firstStartDate=new SelectOption(fisrtDate.format(),fisrtDate.format(),!tactDates.FirstDate__c);	
        fisrtDate=fisrtDate.addMonths(6);	
        secondStartDate=new SelectOption(fisrtDate.format(),fisrtDate.format(), !tactDates.SecondDate__c);	
        fisrtDate=fisrtDate.addMonths(6);	
        thirdStartDate=new SelectOption(fisrtDate.format(),fisrtDate.format(),!tactDates.ThirdDate__c);	
        
        
    }
    
    public void showPopup() { 
        
        displayPopup = true;
        
    }
    
    
    public void save() { 
        
        try {
            appr.Program_Start_Date__c=date.parse(selectedDateString);
            Date a = Date.newInstance(2022,7,1);
            Date b = appr.Program_Start_Date__c;
            Integer monthDiff = a.monthsBetween(b);
            Integer grpNum;
            if(monthDiff>=6){
                grpNum=4+(monthDiff/6);
            }
            //appr.Group_Number__c='Group ' +String.valueOf(grpNum);
            appr.Group_Number__c=String.valueOf(grpNum);
            System.debug(grpNum);
            insert appr;
            recordAvailable=true;
            timer=true;
            
            
            
            if( ifRecordExist==false)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record Created'));
            }
            
            /*if( ifRecordExist==true)
{
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record Updated'));   
}*/
            
            if(tactFiles.size()>0){
                upload();
            }
            
            
        }
        catch(DMLException de) {
            timer=true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, de.getDmlMessage(0)));
            
        }
        
        
        
    } 
    
    public pageReference proceed(){
        system.debug('Apprentice id is '+ appr.Id);
        PageReference pg = new PageReference('/'+appr.Id);
        
        return pg;
    }
    /*public Void CriteriaCheck(){
integer onboard=0;
integer career=0;
integer pay=0;
integer strategy=0;
integer expense=0;
integer SML=0;
integer ML=0;
integer CriteriaMet=0;

if(appr.On_Boarding_Plan__c=='Yes')
onboard=1;
if(appr.Career_Path__c=='Yes')
career=1;
if(appr.Pay_Progression_Plan__c=='Yes')
pay=1;
if(appr.MentorApprentice_Strategy__c=='Yes')
strategy=1;
if(appr.Rewards_Recognition_Strategy__c=='Yes')
expense=1;

CriteriaMet=expense+strategy+pay+career+onboard;
appr.Criteria_Met__c=CriteriaMet;
}*/
    
    Public pagereference SearchRecord(){
        system.debug('Record is '+appr.Apprentice_SPIN_New__c+' '+appr.Phase__c+' '+appr.Dealer__c+' '+appr.name+' ' +appr.Mentor__c);
        Apprentice__c app;
        /*try{

app=[Select id, Dealer__c,Apprentice_SPIN_New__c,  name,Mentor__c, Contact_Date__c, Phase__c, Enrollment__c, 
Phase_1__c, Phase_2__c, Phase_3__c,Apprentice_Cell_Phone__c,Mentor_Cell_Phone__c,
Apprentice_Email_Address__c,Mentor_Email_Address__c,Mentor_SPIN__c,Mentor_Shirt_Size__c,
Apprentice_Shirt_Size__c,Program_Start_Date__c,Apprentice_Program_Termination_Date__c,
Termination_Status__c,Graduation_Date__c,Reason_for_Termination__c
from Apprentice__c  where Apprentice_SPIN_New__c=Null limit 1 ];
}
catch(exception e){
system.debug('Record not found');
}
if(app!=null)
{
appr=app;
ifRecordExist=true;

}

else{*/
        
        appr=new Apprentice__c(dealer__c=appr.Dealer__c);
        
        //appr.Total_Criteria__c=7;
        
        ifRecordExist=false;
        //}
        return null;
        
    }
    public void closePopup() {        
        displayPopup = false;    
    }   
    
    public pagereference AddCVs() {
        String myString = '';
        Blob myBlob = Blob.valueof(myString);
        tactFiles.add(new FileInfo(myString,fileCounter=fileCounter+1,myBlob));
        system.debug('File counter is add method '+fileCounter);
        return null;
    }
    
    
    public PageReference upload() {
        fileList =new List<ContentVersion>();
        if(!tactFiles.isEmpty()){
            for(FileInfo f:tactFiles){
                if(f.fileBody.size()>0){
                    ContentVersion cv=new ContentVersion();
                    cv.versionData = f.fileBody;
                    cv.title = f.fileName;
                    cv.FirstPublishLocationId = appr.Dealer__c;
                    cv.pathOnClient =f.fileName;
                    system.debug('filelist is '+fileList);
                    fileList.add(cv);
                }
            }
            
            
        }        
        
        
        try {
            insert fileList;
        } 
        catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } 
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, fileList.size() +' File(s) uploaded successfully'));
        return null;
    }
    
    
    public void clearMessage()
    {
        ApexPages.getMessages().clear();
        timer=false;
        system.debug('testing clear');
    }
    public class FileInfo{
        public String fileName { get; set; }
        public Integer fileNumber { get; set; }
        public Blob fileBody { get; set; }
        
        Public FileInfo(String fileName,Integer fileNumber,Blob fileBody){
            this.fileName=fileName;
            this.fileNumber=fileNumber;
            this.fileBody=fileBody;
        }
    }
    
}