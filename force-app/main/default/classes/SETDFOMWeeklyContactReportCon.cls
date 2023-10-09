public class SETDFOMWeeklyContactReportCon
{
    public String datename { get; set; }
    public String StrActivity { get; set; }
    public String StrDay { get; set; }
    public String StrDistrict { get; set; }
    public String StrArea { get; set; }
    public Task NewTask { get; set; }
    public Task secondTask { get; set; }
    public String StrSubcategory { get; set; }    
    public transient List<ReportWrapper> LstReportWrapper {get; set;}
//    public transient List<ReportWrapper> XlsReportWrapper {get; set;}
    public Date startDateNew {get; set;}
    public Date endDateNew {get; set;}
    string CompletedStatus = 'Completed';
    public transient LIST<ReportList> ReportListData{get;set;} 
    public string dateRange {get;set; }
    public string dateValue {get;set; }
    public string scheduledActType = 'All'; 
    public SETDFOMWeeklyContactReportCon()
    {
        NewTask = new Task();
        secondTask = new Task();
    }
    
    public void Init()
    {
        //NewTask.SET_Date_of_Visit__c = Date.Today().toStartOfWeek() - 6;
        //secondTask.SET_Date_of_Visit__c = Date.Today().toStartOfWeek();
        NewTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('startDate'));
        
        if(ApexPages.currentPage().getParameters().get('ActivityType')!=null){
            scheduledActType = ApexPages.currentPage().getParameters().get('ActivityType');
        }
        
        if(ApexPages.currentPage().getParameters().get('endDate')!=null){
            secondTask.SET_Date_of_Visit__c = Date.valueOf(ApexPages.currentPage().getParameters().get('endDate'));
        }
        else {
            secondTask.SET_Date_of_Visit__c =system.Today().toStartOfWeek();
        }
        
        system.debug('NewTask===='+NewTask);
        system.debug('secondTask===='+secondTask);
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
         
         String query = 'Select SET_SORT_AREA__c, SET_SORT_DISTRICT__c, Activity_Type__c, Activity_Type_Sub_Category__c, Description, Owner.Name, SET_Date_of_Visit__c, SET_Day_of_Visit__c, OwnerId, What.Name, Is_Attachment_Present__c ';
         //query += ' From Task Where Activity_Type__c IN :setActivityType AND Status =\''+ CompletedStatus+ '\' AND SET_Date_of_Visit__c >=: startDateNew AND SET_Date_of_Visit__c <=: endDateNew';
         Date date1 = NewTask.SET_Date_of_Visit__c;
         Date date2 = secondTask.SET_Date_of_Visit__c;
         
         if(date1 !=null && date2 !=null){
            
         dateRange=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy')+' - ' +datetime.newInstance(date2.year(),date2.month(),date2.day()).format('MMMM-d-yyyy');
         dateValue=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-d-yyyy');
         
         }
        
        if (scheduledActType == 'Accessory') {
            query += ' From Task Where Activity_Type__c = \''+ scheduledActType +'\' AND Status =\''+ CompletedStatus+ '\' AND SET_Date_of_Visit__c >=: date1 AND SET_Date_of_Visit__c <=:date2';        
        }
        else if (scheduledActType == 'All') {
            query += ' From Task Where Activity_Type__c IN :setActivityType AND Status =\''+ CompletedStatus+ '\' AND SET_Date_of_Visit__c >=: date1 AND SET_Date_of_Visit__c <=:date2';        
        } 
         
         system.debug('Scheduled Activity Type ===='+scheduledActType) ;        

        if(String.isNotBlank(StrArea) && StrArea != '--None--')
            query += ' AND SET_SORT_AREA__c =:StrArea';
             
        if(String.isNotBlank(StrDistrict) && StrDistrict != '--None--')
            query += ' AND SET_SORT_DISTRICT__c = ' + Integer.valueOf(StrDistrict.trim());    
            
        if(String.isNotBlank(StrDay) && StrDay != '--None--')
             query += ' AND SET_Day_of_Visit__c =\''+StrDay+'\''; 
         
        if(String.isNotBlank(StrActivity) && StrActivity != '--None--')
             query += ' AND Activity_Type__c = \'' + StrActivity + '\'';

        if(String.isNotBlank(StrSubcategory) && StrSubcategory != '[--None--]' && StrSubcategory != '[]' ){
             StrSubcategory=StrSubcategory.replace('[','(\'');
             StrSubcategory=StrSubcategory.replace(']','\')');
             StrSubcategory=StrSubcategory.replace(', ','\',\'');
             
             query += ' AND Activity_Type_Sub_Category__c includes ' + StrSubcategory;
         }
                  
         query += ' AND Activity_Type_Sub_Category__c != \'DOT Reg\'';
         
         query += ' Order By SET_SORT_AREA__c, SET_SORT_DISTRICT__c, SET_Date_of_Visit__c, Owner.Name, What.Name DESC limit 4000';
         system.debug('StrSubcategory:'+StrSubcategory);      
         
         system.debug('date1===='+date1) ;        
         system.debug('date2===='+date2);
         
         
         system.debug('query===='+query);
         system.debug('StrArea===='+StrArea);
         system.debug('StrDistrict===='+StrDistrict);
         system.debug('StrDay===='+StrDay);
         system.debug('StrActivity===='+StrActivity);
         Transient List<Task> lstActivityInfo = Database.query(query);
         LstReportWrapper = new List<ReportWrapper>();
         // XlsReportWrapper = new List<ReportWrapper>();
         system.debug('lstActivityInfo===='+lstActivityInfo);
         ReportWrapper newReportWrapper;
         system.debug('setActivityType===='+setActivityType);
         setActivityType = null;                               
        if(!lstActivityInfo.isEmpty())
        {
           ReportListData=new LIST<ReportList>();
            LIST<ReportWrapper> lstRepWrapper=new LIST<ReportWrapper>();
            string dist = string.valueOf(lstActivityInfo[0].SET_SORT_DISTRICT__c);
  
            
            for(Task newTask :lstActivityInfo)
            {
                if(dist != string.valueOf(newTask.SET_SORT_DISTRICT__c))
                {
                    newReportWrapper = new ReportWrapper(null, null, null, null, null, null, null, null, null);
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
                
                newReportWrapper = new ReportWrapper(area, districtNew, dfom, dealerName, day, activityType, contact, attachment, subcategory);
                LstReportWrapper.add(newReportWrapper);
                lstRepWrapper.add(newReportWrapper);
                //XlsReportWrapper.add(newReportWrapper);
            }
                //lstActivityInfo  = null;
                ReportList reporttListCls=new ReportList(dist,lstRepWrapper, true);
                ReportListData.add(reporttListCls);
                //ReportListData = null;
                //lstRepWrapper = null;
        }
        else {
         LstReportWrapper=null;
        }
        
        //system.debug('ReportListData===='+ReportListData);
        //LstReportWrapper=null;

        return null;
    }
    
    public PageReference exportXls()
    {
        return page.SETDFOMWeeklyContactReportXls;
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
            if(value.getValue() != 'DOT Reg')
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
        
        public ReportWrapper(String area, String district, String dfom, String dealerName, String day, String activityType, String contact, String attachment, String subcategory)
        {
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