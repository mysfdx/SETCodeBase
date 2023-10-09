/* Name:  SETDOTWeeklyContactReportCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class SETDOTWeeklyContactReportCon
{
    public String datename { get; set; }
    public String StrActivity { get; set; }
    public String StrDay { get; set; }
    public String StrStatus { get; set; }
    public String StrDateOfVisit { get; set; }
    public String StrDistrict { get; set; }
    public String StrArea { get; set; }
    public Task NewTask { get; set; }
    public Task secondTask { get; set; }
    public String StrSubcategory { get; set; }    
    public transient List<ReportWrapper> LstReportWrapper {get; set;}
    //public List<ReportWrapper> XlsReportWrapper {get; set;}
    public Date startDateNew {get; set;}
    public Date endDateNew {get; set;}
    string CompletedStatus = 'Completed';
    public transient LIST<ReportList> ReportListData{get;set;} 
    public string dateRange {get;set; }
    public string dateValue {get;set; }
    public string strActivityType = '';
    public SETDOTWeeklyContactReportCon()
    {
        NewTask = new Task();
        secondTask = new Task();
    }
    
    public void Init()
    {
        if(ApexPages.currentPage().getParameters().get('startDate') != null)
            NewTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('startDate'));
        
        if(ApexPages.currentPage().getParameters().get('endDate')!=null){
            secondTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('endDate'));
        }
        //Kishore added on 2/9
        if(ApexPages.currentPage().getParameters().get('activityType')!=null){
            strActivityType  = ApexPages.currentPage().getParameters().get('activityType');
        }

        /*else {
            secondTask.SET_Date_of_Visit__c =system.Today().toStartOfWeek();
        }*/
        
        system.debug('NewTask===='+NewTask);
        system.debug('secondTask===='+secondTask);
        fetchActivity();
    }
    
    public PageReference fetchActivity()
    {      
        list<string> setSubCategoryType=new List<string>();
        setSubCategoryType = System.Label.SET_DOT_Weekly_Subcategory.split(';');
         
         String query = 'Select SET_SORT_AREA__c, SET_SORT_DISTRICT__c, Activity_Type__c, Activity_Type_Sub_Category__c, Status, Date_Completed__c, Description, Owner.Name, SET_Date_of_Visit__c, SET_Day_of_Visit__c, OwnerId, What.Name, Is_Attachment_Present__c, SET_Number_of_days_since_task_creation__c from Task where SET_Number_of_days_since_task_creation__c <= 120';
        
         Date date1 = NewTask.SET_Date_of_Visit__c;
         Date date2 = secondTask.SET_Date_of_Visit__c;
         
         if(date1 !=null && date2 !=null){
            
         dateRange=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy')+' - ' +datetime.newInstance(date2.year(),date2.month(),date2.day()).format('MMMM-d-yyyy');
         dateValue=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy');
         
         }
        
         // kishore added on 2/9         
         if (strActivityType == 'TDMC URL')
             query += ' AND Activity_Type_Sub_Category__c IN (\''+strActivityType+'\')';        
         else
             query += ' AND Activity_Type_Sub_Category__c IN :setSubCategoryType AND SET_Date_of_Visit__c >=: date1 AND SET_Date_of_Visit__c <=:date2';        

         
         if(String.isNotBlank(StrArea) && StrArea != '--None--')
             query += ' AND SET_SORT_AREA__c =:StrArea';
             
         if(String.isNotBlank(StrDistrict) && StrDistrict != '--None--')
             query += ' AND SET_SORT_DISTRICT__c  = ' + Integer.valueOf(StrDistrict.trim());                         
             
         if(String.isNotBlank(StrDay) && StrDay != '--None--')
             query += ' AND SET_Day_of_Visit__c =\''+StrDay+'\'';
             
         if(String.isNotBlank(StrStatus) && StrStatus != '--None--')
             query += ' AND Status =\''+StrStatus+'\'';
             
         if(String.isNotBlank(StrDateOfVisit) && StrDateOfVisit!= '--None--')
             query += ' AND SET_Date_of_Visit__c=\''+StrDateOfVisit+'\'';      
         
         if(String.isNotBlank(StrActivity) && StrActivity != '--None--')
             query += ' AND Activity_Type__c = \'' + StrActivity + '\'';

        if(String.isNotBlank(StrSubcategory) && StrSubcategory != '[--None--]' && StrSubcategory != '[]' ){
             StrSubcategory=StrSubcategory.replace('[','(\'');
             StrSubcategory=StrSubcategory.replace(']','\')');
             StrSubcategory=StrSubcategory.replace(', ','\',\'');
             
             query += ' AND Activity_Type_Sub_Category__c includes ' + StrSubcategory;
         }
         
         //query += ' Order By Status, SET_SORT_AREA__c, SET_SORT_DISTRICT__c, What.Name, Owner.Name DESC';
         query += ' Order By Status DESC , SET_SORT_DISTRICT__c, What.Name, Owner.Name DESC limit 4000';
         system.debug('StrSubcategory:'+StrSubcategory);      
         system.debug('query:'+query);
         system.debug('query===='+query);
         system.debug('StrArea===='+StrArea);
         system.debug('StrDistrict===='+StrDistrict);
         system.debug('StrDay===='+StrDay);
         system.debug('StrActivity===='+StrActivity);
         system.debug('StrStatus===='+StrStatus);
         system.debug('StrDateOfVisit===='+StrDateOfVisit);
         transient List<Task> lstActivityInfo = Database.query(query);
          LstReportWrapper = new List<ReportWrapper>();
          //XlsReportWrapper = new List<ReportWrapper>();
         system.debug('lstActivityInfo===='+lstActivityInfo);
           ReportWrapper newReportWrapper;
         system.debug('setSubCategoryType===='+setSubCategoryType);
                                        
        if(!lstActivityInfo.isEmpty())
        {
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
                
                String area = string.isNotBlank(newTask.SET_SORT_AREA__c)? newTask.SET_SORT_AREA__c: '-';
                String districtNew = (newTask.SET_SORT_DISTRICT__c != null)? string.valueOf(newTask.SET_SORT_DISTRICT__c): '-';
                String dfom = string.isNotBlank(newTask.Owner.Name)? newTask.Owner.Name: '-';
                String dealerName = string.isNotBlank(newTask.What.Name)? newTask.What.Name: '-';
                String day = (newTask.SET_Day_of_Visit__c != null && newTask.SET_Day_of_Visit__c != 'Error')? string.valueOf(newTask.SET_Day_of_Visit__c): '-';
                String activityType = string.isNotBlank(newTask.Activity_Type__c)? newTask.Activity_Type__c: '-';
                String contact = string.isNotBlank(newTask.Description)? newTask.Description: '-';
                String attachment = (newTask.Is_Attachment_Present__c != null)? string.valueOf(newTask.Is_Attachment_Present__c): '-';
                String subcategory = string.isNotBlank(newTask.Activity_Type_Sub_Category__c)? newTask.Activity_Type_Sub_Category__c: '-';
                String status = string.isNotBlank(newTask.Status)? newTask.Status: '-';
                String dateOfVisit = (newTask.SET_Date_of_Visit__c != null)? string.valueOf(newTask.SET_Date_of_Visit__c): '-';
                
                               
                
                
                newReportWrapper = new ReportWrapper(area, districtNew, dfom, dealerName, day, activityType, contact, attachment, subcategory, status, dateOfVisit);
                LstReportWrapper.add(newReportWrapper);
                lstRepWrapper.add(newReportWrapper);
                //XlsReportWrapper.add(newReportWrapper);
            }
            
            ReportList reporttListCls=new ReportList(dist,lstRepWrapper, true);
                ReportListData.add(reporttListCls);
        }
        else {
         LstReportWrapper=null;
        }
        
        return null;
    }
    
    public PageReference exportXls()
    {
        return page.SETDOTWeeklyContactReportXls;
    }
    
    public List<SelectOption> getActivityOptions()
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
    
    
        public List<SelectOption> getSubcategoryOptions()
    {
        Schema.DescribeFieldResult fieldResult = Task.Activity_Type_Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> lstPickLstEntry = fieldResult.getPicklistValues();
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        
        for(Schema.PicklistEntry value :lstPickLstEntry)
        {
            lstOptions.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return lstOptions;
    }
    
    public List<SelectOption> getStatusOptions()
    {
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> lstPickLstEntry = fieldResult.getPicklistValues();
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        
        for(Schema.PicklistEntry value :lstPickLstEntry)
        {
            lstOptions.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return lstOptions;
    }
        
    
    public List<SelectOption> getLstArea()
    {
        
        LIST<string> areaList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').Area_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strArea:areaList){
            lstOptions.add(new SelectOption(strArea,strArea));
        }
        return lstOptions;
    }
    
        public List<SelectOption> getLstDistrict()
    {
        
        LIST<string> districtList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').District_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strDistrict:districtList){
            lstOptions.add(new SelectOption(strDistrict,strDistrict));
        }
        return lstOptions;
    }
    
        public List<SelectOption> getLstDay()
    {
        
        LIST<string> dayList=SET_DFOM_Picklists__c.getInstance('SET Picklist Values').Day_Picklist__c.split(';');
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        for (string strDay:dayList){
            lstOptions.add(new SelectOption(strDay,strDay));
        }
        return lstOptions;
    }    
    
    public class ReportWrapper
    {
        public string Area {get; set;}
        public string District {get; set;}
        public string DFOM {get; set;}
        public string DealerName {get; set;}
        public string Day {get; set;}
        public string ActivityType {get; set;}
        public string Contact {get; set;}
        public string Attachment {get; set;}
        public string Subcategory {get; set;}
        public string Status {get; set;}
        public string DateOfVisit {get; set;}
        
        public ReportWrapper(String area, String district, String dfom, String dealerName, String day, String activityType, String contact, String attachment, String subcategory, String status, String dateOfVisit )
        {
            this.Area = area;
            this.District = district;
            this.DFOM = dfom;
            this.DealerName = dealerName;
            this.Day = day;
            this.ActivityType = activityType;
            this.Contact = contact;
            this.Attachment = attachment;
            this.Status = status;
            this.DateOfVisit = dateOfVisit;
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