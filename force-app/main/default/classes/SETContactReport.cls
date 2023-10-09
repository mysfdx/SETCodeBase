/*
Name: SETContactReport
Created By: Joshua Hunt
Created Date: 21st Feb 2021
Description: Contact Report VF page controller


Changelog 

Author--             Date--                       Purpose--
Neha Agrawal        9/13/2021          added search phrase to enhance the search functionality.
                                       https://jmfamily.atlassian.net/browse/SS1SP-212
*/


public class SETContactReport
{
   public task tsk { get; set; }
    
   
//    public String datename { get; set; }
    public String StrDay { get; set; }
    public String searchPhrase { get; set; }
    //public Boolean districtDisabled { get; set; }
    public String StrDistrict { get; set; }
    public String StrDealer { get; set; }
    //public List<SelectOption> districtList { get; set; }
    public String StrArea { get; set; }
    public Task NewTask { get; set; }
    public Task secondTask { get; set; }
    public String StrSubcategory { get; set; }  
    
    public transient List<ReportWrapper> LstReportWrapper {get; set;}
//    public transient List<ReportWrapper> XlsReportWrapper {get; set;}
//    public Date startDateNew {get; set;}
//    public Date endDateNew {get; set;}
    //string CompletedStatus = 'Completed';
    public transient LIST<ReportList> ReportListData{get;set;} 
    public String StrActivity { get; set; }
    public String StrStatus { get; set; }    
    public string dateRange {get;set; }
    public string dateValue {get;set; }
    public boolean displayText {get;set; }
    public boolean dprExist {get;set; }
    public boolean dprSearch {get;set; }
    public Transient List<DPR__c> lstDPR{get;set; }
    public List<SelectOption> LstDistrict{get;set; }
    public List<SelectOption> LstDealer{get;set; }
    
   /*public SETContactReport() {
        NewTask = new Task();
        secondTask = new Task();
       system.debug('Simple controller');
    }*/
    
     public SETContactReport(ApexPages.StandardController stdController) {
        this.tsk = new Task();
         NewTask = new Task();
         secondTask = new Task();
         lstDPR=new List<DPR__c>();
         displayText=false;
         LstDistrict=new List<SelectOption>();
         LIST<string> districtList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').District_Picklist__c.split(';');
         LstDistrict.add(new SelectOption('--None--', '--None--'));
        for (string strDistrict:districtList){
            if (strDistrict != '13' && strDistrict != '14') {
                
                LstDistrict.add(new SelectOption(strDistrict,strDistrict));
            }
        }
         List<Account> accList =[Select id, name from Account where Active_Dealer__c=True order by Name];
         LstDealer=new List<SelectOption>();
         LstDealer.add(new SelectOption('--None--', '--None--'));
         for(Account a:accList){
             LstDealer.add(new SelectOption(a.Id,a.Name));
         }
        system.debug('Standard controller');
    } 
    
    public void Init() {
        //NewTask.SET_Date_of_Visit__c = Date.Today().toStartOfWeek() - 6;
        //secondTask.SET_Date_of_Visit__c = Date.Today().toStartOfWeek();
    /*        
        NewTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('startDate'));
        
        if(ApexPages.currentPage().getParameters().get('endDate')!=null){
            secondTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('endDate'));
        }
        else {
            secondTask.SET_Date_of_Visit__c =system.Today().toStartOfWeek();
        }
        
        system.debug('NewTask===='+NewTask);
        system.debug('secondTask===='+secondTask);
        */
        fetchActivity();
    }
    
    public PageReference fetchActivity()
    {   
        /*List<Task> lstActivityInfo = [Select SET_SORT_AREA__c, SET_SORT_DISTRICT__c, Activity_Type__c, Description, Owner.Name, SET_Date_of_Visit__c, SET_Day_of_Visit__c, OwnerId, What.Name
                                        From Task 
                                        Where Activity_Type__c IN :setActivityType 
                                        AND Status = 'Completed' AND SET_Date_of_Visit__c >=:startDateNew
                                        AND SET_Date_of_Visit__c <=:endDateNew 
                                        AND SET_SORT_AREA__c =:StrArea
                                        OR SET_SORT_DISTRICT__c =:StrDistrict 
                                        OR SET_Day_of_Visit__c =:StrDay
                                        OR Activity_Type__c =:StrActivity 
                                        Order By SET_SORT_DISTRICT__c, SET_Date_of_Visit__c, Owner.Name, What.Name DESC];
         */
         
        list<string> setActivityType=new List<string>();
        setActivityType = System.Label.SET_DFOM_Weekly_Activity_Types.split(';');
         
         String query = 'SELECT Subject, SET_SORT_AREA__c, Status , SET_SORT_DISTRICT__c, Activity_Type__c, Activity_Type_Sub_Category__c, Description, Owner.Name, SET_Date_of_Visit__c, SET_Day_of_Visit__c, OwnerId, What.Name, Is_Attachment_Present__c from task where IsArchived = FALSE ';
         //query += ' From Task Where Activity_Type__c IN :setActivityType AND Status =\''+ CompletedStatus+ '\' AND SET_Date_of_Visit__c >=: startDateNew AND SET_Date_of_Visit__c <=: endDateNew';
         Date date1 = NewTask.SET_Date_of_Visit__c;
         Date date2 = secondTask.SET_Date_of_Visit__c;
         
         if(date1 !=null && date2 !=null){
            
         dateRange=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy')+' - ' +datetime.newInstance(date2.year(),date2.month(),date2.day()).format('MMMM-d-yyyy');
         dateValue=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy');
         
         }
         if (date1 != null)
             query += ' AND SET_Date_of_Visit__c >=: date1 ';        
         if (date2 != null)
             query += ' AND SET_Date_of_Visit__c <=:date2';        

         
         if(String.isNotBlank(StrArea) && StrArea != '--None--')
             query += ' AND SET_SORT_AREA__c =:StrArea';
             
         if(String.isNotBlank(StrDistrict) && StrDistrict != '--None--')
             
             query += ' AND SET_SORT_DISTRICT__c ='+ Integer.valueOf(StrDistrict.trim());
        //Added for Dealer search
        if(String.isNotBlank(StrDealer) && StrDealer != '--None--')
            // DPR change
        {   
            lstDPR=[Select id,name,DPR_End_Date__c,DPR_Start_Date__c,
                                 DPR_Status__c, Months_on_DPR__c, Escalation__c, Business_Unit__c, Account__r.name
                                 from DPR__c where Account__c=:StrDealer];
            if(!lstDPR.isEmpty()){
                dprExist=true;
                 String[] tmp1 = New String[]{}; 
                 String idString;
                tmp1.add(StrDealer);
              
                   for(DPR__c d:lstDPR){
                       tmp1.add(d.id);
                   }
                idString = '(\'' + String.join(tmp1, '\',\'') + '\')';
                query += ' AND WhatId in '+idString; 
            }
            else{
                dprExist=false;
                query += ' AND WhatId =\''+StrDealer+'\''; 
            }
  
        }
             
             
         if(String.isNotBlank(StrDay) && StrDay != '--None--')
             query += ' AND SET_Day_of_Visit__c =\''+StrDay+'\''; 

        if(String.isNotBlank(tsk.Activity_Type__c) && tsk.Activity_Type__c != '[--None--]') {
                          query += ' AND Activity_Type__c =\''+tsk.Activity_Type__c+'\'';
         }
        system.debug('tsk.Activity_Type__c is '+tsk.Activity_Type__c);
         if(String.isNotBlank(StrStatus) && StrStatus != '[--None--]' && StrStatus != '[]') {
             StrStatus=StrStatus.replace('[','(\'');
             StrStatus=StrStatus.replace(']','\')');
             StrStatus=StrStatus.replace(', ','\',\'');
             query += ' AND Status IN ' + StrStatus ;
         }
   
        if(String.isNotBlank(tsk.Activity_Type_Sub_Category__c)){
            String[] subCategoryOptions=tsk.Activity_Type_Sub_Category__c.split(';');
             system.debug('Subcategory is ' + string.join(subCategoryOptions,','));
             query += ' AND Activity_Type_Sub_Category__c includes (\'' + string.join(subCategoryOptions,',')+ '\')';
         }
         system.debug('tsk.Activity_Type_Sub_Category__c is '+tsk.Activity_Type_Sub_Category__c);
         query += ' Order By SET_SORT_AREA__c, SET_SORT_DISTRICT__c, SET_Date_of_Visit__c, Owner.Name, What.Name DESC limit 4000';
         
         system.debug('query===='+query);
         system.debug('date1===='+date1+'---date2===='+date2);
         system.debug('StrSubcategory:'+StrSubcategory);      
         system.debug('Activity Status===='+StrStatus);
         system.debug('StrDistrict===='+StrDistrict);
         system.debug('StrDay===='+StrDay);
         system.debug('StrActivityType===='+StrActivity);
        system.debug('SearchPhrase===='+searchPhrase);
        Transient List<Task> lstActivityInfo = Database.query(query);
         system.debug('lstActivityInfo Size 1===='+lstActivityInfo.size());
        List<Task> listWithPhrase=new List<Task>();
        if(String.isNotBlank(searchPhrase) && lstActivityInfo.size()>0){
            if(searchPhrase.containsIgnoreCase('DPR')){
                dprSearch=true;
            }
            else
            {
               dprSearch=false; 
            }
            for(Task t: lstActivityInfo){
                System.debug('T.description is '+ T.Description);
                if(t.Description!=null && string.isNotBlank(t.Description)){
                    if(t.Description.containsIgnoreCase(searchPhrase)){
                        listWithPhrase.add(t);
                    }
                }
                
            }
            if(listWithPhrase.size()>0){
              
                 system.debug('listWithPhrase Size===='+listWithPhrase.size());
                lstActivityInfo.clear();
                 system.debug('lstActivityInfo Size 2===='+lstActivityInfo.size());
                lstActivityInfo.addall(listWithPhrase);
                system.debug('lstActivityInfo Size 3===='+lstActivityInfo.size());
            }
            else{
                lstActivityInfo.clear();
            }
            
            
        }
        else
            dprSearch=false;
          LstReportWrapper = new List<ReportWrapper>();
        system.debug('LstReportWrapper size is '+ LstReportWrapper.size());
          //XlsReportWrapper = new List<ReportWrapper>();
         system.debug('lstActivityInfo===='+lstActivityInfo.size());
           ReportWrapper newReportWrapper;
       
        
        system.debug(' displayText is '+displayText);   
        if(!lstActivityInfo.isEmpty())
        {
            displayText=false;
           ReportListData=new LIST<ReportList>();
            LIST<ReportWrapper> lstRepWrapper=new LIST<ReportWrapper>();
            string dist = string.valueOf(lstActivityInfo[0].SET_SORT_DISTRICT__c);
  
            
            for(Task newTask :lstActivityInfo)
            {
                if(dist != string.valueOf(newTask.SET_SORT_DISTRICT__c))
                {
                    newReportWrapper = new ReportWrapper(null, null, null, null, null, null, null, null, null, null, null);
                    LstReportWrapper.add(newReportWrapper);
                    
                    ReportList reporttListCls=new ReportList(dist,lstRepWrapper, false);
                    ReportListData.add(reporttListCls);
                    lstRepWrapper=new LIST<ReportWrapper>();
                    dist = string.valueOf(newTask.SET_SORT_DISTRICT__c);
                }
                String activityId = newTask.Id;
                String sub = newTask.Subject;
                String area = string.isNotBlank(newTask.SET_SORT_AREA__c)? newTask.SET_SORT_AREA__c: '-';
                String districtNew = (newTask.SET_SORT_DISTRICT__c != null)? string.valueOf(newTask.SET_SORT_DISTRICT__c): '-';
                String dfom = string.isNotBlank(newTask.Owner.Name)? newTask.Owner.Name: '-';
                String dealerName = string.isNotBlank(newTask.What.Name)? newTask.What.Name: '-';
                String day = (newTask.SET_Day_of_Visit__c != null && newTask.SET_Day_of_Visit__c != 'Error')? string.valueOf(newTask.SET_Day_of_Visit__c): '-';
                String activityType = string.isNotBlank(newTask.Activity_Type__c)? newTask.Activity_Type__c: '-';
                String contact = string.isNotBlank(newTask.Description)? newTask.Description: '-';
                String attachment = (newTask.Is_Attachment_Present__c != null)? string.valueOf(newTask.Is_Attachment_Present__c): '-';
                String subcategory = string.isNotBlank(newTask.Activity_Type_Sub_Category__c)? newTask.Activity_Type_Sub_Category__c: '-';
                
                newReportWrapper = new ReportWrapper(activityId, sub, area, districtNew, dfom, dealerName, day, activityType, contact, attachment, subcategory);
                LstReportWrapper.add(newReportWrapper);
                lstRepWrapper.add(newReportWrapper);
                //XlsReportWrapper.add(newReportWrapper);
            } //end for loop
            lstActivityInfo  = null;
            ReportList reporttListCls=new ReportList(dist,lstRepWrapper, true);
            ReportListData.add(reporttListCls);
        }
        else {
         LstReportWrapper=null;
            displayText=true;
        }
        
        //system.debug('ReportListData===='+ReportListData);
        
        return null;
    }
    
    public PageReference exportXls()
    {
        return page.SETAllContactReportXlsReport;
    }

    public List<SelectOption> getActivityStatus()
    {
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> lstStatusValues = fieldResult.getPicklistValues();
        List<SelectOption> lstStatusOptions = new List<SelectOption>();
        lstStatusOptions.add(new SelectOption('--None--', '--None--'));
        
        for(Schema.PicklistEntry value :lstStatusValues)
        { 
            if(value.getValue() != 'Unable to Complete')        
                lstStatusOptions.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return lstStatusOptions;
    }
        
    /*public List<SelectOption> getActivityOptions()
    {
        Schema.DescribeFieldResult fieldResult = Task.Activity_Type__c.getDescribe();
        List<Schema.PicklistEntry> lstPickLstEntry = fieldResult.getPicklistValues();
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        
        for(Schema.PicklistEntry value :lstPickLstEntry)
        {
            lstOptions.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return lstOptions;
    }
    
    
    public List<SelectOption> getSubcategoryOptions() {
        Schema.DescribeFieldResult fieldResult = Task.Activity_Type_Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> lstPickLstEntry = fieldResult.getPicklistValues();
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        
        for(Schema.PicklistEntry value :lstPickLstEntry)
        {
            //if(value.getValue() != 'DOT Reg')
            lstOptions.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return lstOptions;
    }*/
    
    public List<SelectOption> getLstArea() {        
        LIST<string> areaList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').Area_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strArea:areaList){
            lstOptions.add(new SelectOption(strArea,strArea));
        }
        return lstOptions;
    }
    
    /*public List<SelectOption> getchangedLstDistrict() {
        
        LIST<string> districtList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').District_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strDistrict:districtList){
            if (strDistrict != '13' && strDistrict != '14') {
                
                lstOptions.add(new SelectOption(strDistrict,strDistrict));
            }
        }
        return lstOptions;
    }*/
    
    public List<SelectOption> getLstDay() {
        
        LIST<string> dayList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').Day_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strDay:dayList){
            lstOptions.add(new SelectOption(strDay,strDay));
        }
        return lstOptions;
    }    
    public void setDistrictList(){
        LstDistrict=new List<SelectOption>();
        LstDistrict.add(new SelectOption('--None--', '--None--'));
        if(StrArea != '--None--'){
            
            if(StrArea=='A'){
                LstDistrict.add(new SelectOption('01', '01'));
                LstDistrict.add(new SelectOption('02', '02'));
                LstDistrict.add(new SelectOption('03', '03'));
                LstDistrict.add(new SelectOption('04', '04'));
                LstDistrict.add(new SelectOption('05', '05'));
                LstDistrict.add(new SelectOption('06', '06'));
                
            }
            if(StrArea=='B'){
                LstDistrict.add(new SelectOption('07', '07'));
                LstDistrict.add(new SelectOption('08', '08'));
                LstDistrict.add(new SelectOption('09', '09'));
                LstDistrict.add(new SelectOption('10', '10'));
                LstDistrict.add(new SelectOption('11', '11'));
                LstDistrict.add(new SelectOption('12', '12'));
   
            }
            
        }
        else{
            LIST<string> districtList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').District_Picklist__c.split(';');
         
        for (string strDistrict:districtList){
            if (strDistrict != '13' && strDistrict != '14') {
                
                LstDistrict.add(new SelectOption(strDistrict,strDistrict));
            }
        }
        }
        
    }
    public class ReportWrapper {
        public Id activityId {get;set;}
        public string sub {get; set;}
        public string Area {get; set;}
        public string District {get; set;}
        public string DFOM {get; set;}
        public string DealerName {get; set;}
        public string Day {get; set;}
        public string ActivityType {get; set;}
        public string Contact {get; set;}
        public string Attachment {get; set;}
        public string Subcategory {get; set;}
        
        public ReportWrapper(Id activityId, String sub, String area, String district, String dfom, String dealerName, String day, String activityType, String contact, String attachment, String subcategory) {
            this.activityId = activityId;
            this.sub = sub;
            this.Area = area;
            this.District = district;
            this.DFOM = dfom;
            this.DealerName = dealerName;
            this.Day = day;
            this.ActivityType = activityType;
            this.Contact = contact;
            this.Attachment = attachment;
            if(subcategory!=null && subcategory!='-'){
            for (string strSubCat:subcategory.split(';')){
                if(this.Subcategory ==null){
                    this.Subcategory=strSubCat+' / ';
                }
                else {
                    this.Subcategory +=strSubCat+' / ';
                }
            }
            
        }

         else if (subcategory == '-'){
            this.Subcategory = subcategory;
         }
            
        }
    }
    
    public class ReportList
    {
        public string District {get; set;}
        public boolean lastRecord{get;set;}
        public LIST<ReportWrapper> lstRepWrap {get {
            if(lstRepWrap==null){
                lstRepWrap=new LIST<ReportWrapper>();
                return lstRepWrap;
            }
            else {
                return lstRepWrap;
            }   
            
        }
            set;}
       public  ReportList(string distName,LIST<ReportWrapper> lstRepWrapper, boolean lstRec){
            //Area=areaname;
            District=distName;
            lstRepWrap=lstRepWrapper;
            lastRecord=lstRec;
       }    
    }
}