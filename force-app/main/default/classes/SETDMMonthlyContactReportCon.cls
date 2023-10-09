/* Name:  SETDMMonthlyContactReportCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class SETDMMonthlyContactReportCon
{
    //Set<String> setActivityType = new Set<String>{'DFOM ME Recap'};
    public transient List<ReportWrapper> LstReportWrapper {get; set;}
    //public List<ReportWrapper> XlsReportWrapper {get; set;}
    public Date startDateNew {get; set;}
    public Date endDateNew {get; set;}
    public String StrMonth { get; set; }
    public String StrDistrict { get; set; }
    public String StrArea { get; set; }
    public Task NewTask { get; set; }
    public Task secondTask { get; set; }
    public string monthRange {get;set; }
    public string tskStatus {get;set;}
    public static string testrun{get;set;}
    public List<SelectOption> statusList{ get {
     List<SelectOption> statLst=new List<SelectOption>();
     statLst.add(new SelectOption('Not Started','Not Started'));
     statLst.add(new SelectOption('In Progress','In Progress'));
     statLst.add(new SelectOption('Completed','Completed'));
     return statLst;
    }
    
    }
    
    string CompletedStatus;
    
    
    public SETDMMonthlyContactReportCon(){
        NewTask = new Task();
        secondTask = new Task();
    
        StrMonth=ApexPages.currentPage().getParameters().get('forMonth');
        
        
        if(strMonth!=null){
            startDateNew=null;
            endDateNew=null;
            StrArea='--None--';
            StrDistrict='--None--';
            fetchActivity();
        }
    }
    
    
    //public List<ReportWrapper> getLstActivity()
    public PageReference fetchActivity()
    {
       /* List<Task> lstActivityInfo = [Select SET_SORT_AREA__c, SET_SORT_DISTRICT__c, Description, Owner.Name, SET_Date_of_Visit__c,SET_Month_of_Visit__c 
                                        From Task 
                                        Where Activity_Type__c IN :setActivityType 
                                        AND Status = 'Completed' AND SET_Date_of_Visit__c >=:startDateNew
                                        AND SET_Date_of_Visit__c <=:endDateNew 
                                        Order By SET_SORT_DISTRICT__c, SET_Month_of_Visit__c, Owner.Name, SET_Dealer_Name__c DESC];
       */


         list<string> setActivityType=new List<string>();
         
         setActivityType = System.Label.SET_DM_Activity_Types.split(';');
        
         if(tskStatus!=null){
             CompletedStatus=tskStatus;
           }
           else {
             CompletedStatus='Completed';
           }
             
       
         String query = 'Select SET_SORT_AREA__c, SET_SORT_DISTRICT__c, Description, Owner.Name, SET_Date_of_Visit__c, SET_Month_of_Visit__c, Is_Attachment_Present__c';
         //query += ' From Task Where Activity_Type__c IN :setActivityType AND Status =\''+ CompletedStatus+ '\' AND SET_Date_of_Visit__c >=: startDateNew AND SET_Date_of_Visit__c <=: endDateNew';
         Date date1;
          Date date2;
         if(testrun==null){
             date1 = NewTask.SET_Date_of_Visit__c;
             date2 = secondTask.SET_Date_of_Visit__c;
             }
         else {
         
             date1 = system.today().addDays(-1);
             date2 = system.today().addDays(2);
         
         }    
          system.debug('testrun:'+testrun);
         system.debug('date1:'+date1);
         system.debug('date2:'+date2);
         if(date1 !=null && date2 !=null){
            
            //datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
            
            string fromMonth=datetime.newInstance(date1.year(),date1.month(),date1.day()).format('MMMM-yyyy');
            string endMonth=datetime.newInstance(date2.year(),date2.month(),date2.day()).format('MMMM-yyyy');
            monthRange=fromMonth+' - '+endMonth;
         
         }
         
         
         query += ' From Task Where Activity_Type__c IN :setActivityType AND Status =\''+ CompletedStatus+ '\' AND CreatedDate >=: date1 AND CreatedDate <=: date2';
         
        /* if(StrMonth !='--None--') {
                query += ' AND SET_Month_of_Visit__c=\''+StrMonth+'\'';
                monthRange=StrMonth;
         }
         */
         if(StrArea != '--None--')
             query += ' AND SET_SORT_AREA__c =:StrArea';
             
         if(String.isNotBlank(StrDistrict) && StrDistrict != '--None--')
         {
             //Decimal district = Decimal.valueOf(StrDistrict);
             query += ' AND SET_SORT_DISTRICT__c ='+ Integer.valueOf(StrDistrict.trim());                
             //query += ' AND SET_SORT_DISTRICT__c =:StrDistrict'; 
         }
             
         query += ' Order By SET_SORT_AREA__c, SET_SORT_DISTRICT__c, SET_Date_of_Visit__c DESC limit 4000';
                        
         system.debug('query===='+query);
         transient List<Task> lstActivityInfo = Database.query(query);
         lstReportWrapper = new List<ReportWrapper>();
         //XlsReportWrapper = new List<ReportWrapper>();
         ReportWrapper newReportWrapper;
           system.debug('lstActivityInfo.size:'+lstActivityInfo.size());                             
        if(!lstActivityInfo.isEmpty())
        { 
            
            ReportListData=new LIST<ReportList>();
            LIST<ReportWrapper> lstRepWrapper=new LIST<ReportWrapper>();
            string dist = string.valueOf(lstActivityInfo[0].SET_SORT_DISTRICT__c);
            string areaPop = lstActivityInfo[0].SET_SORT_AREA__c;
            
            for(Task newTask :lstActivityInfo)
            {
                if(dist != string.valueOf(newTask.SET_SORT_DISTRICT__c))
                {
                    newReportWrapper = new ReportWrapper(null, null, null, null, null, null);
                    lstReportWrapper.add(newReportWrapper);
                    
                    ReportList reporttListCls=new ReportList(areaPop,dist,lstRepWrapper,false);
                    ReportListData.add(reporttListCls);
                    lstRepWrapper=new LIST<ReportWrapper>();
                    dist = string.valueOf(newTask.SET_SORT_DISTRICT__c);
                    areaPop=newTask.SET_SORT_AREA__c;
                }
                
                system.debug('====newTask.SET_SORT_AREA__c= '+newTask.SET_SORT_AREA__c);
                
                String area = string.isNotBlank(newTask.SET_SORT_AREA__c)? newTask.SET_SORT_AREA__c: '-';
                String districtNew = (newTask.SET_SORT_DISTRICT__c != null)? string.valueOf(newTask.SET_SORT_DISTRICT__c): '-';
                String dfom = string.isNotBlank(newTask.Owner.Name)? newTask.Owner.Name: '-';
                String month = (newTask.SET_Month_of_Visit__c != null)? string.valueOf(newTask.SET_Month_of_Visit__c): '-';
                String contact = string.isNotBlank(newTask.Description)? newTask.Description: '-';
                String attachment = (newTask.Is_Attachment_Present__c != null)? string.valueOf(newTask.Is_Attachment_Present__c): '-';
                //String ngp = string.isNotBlank(newTask.SET_NGP__c)? newTask.SET_NGP__c: '-';
                //String tires = string.isNotBlank(newTask.SET_Tires__c)? newTask.SET_Tires__c: '-';
                
                newReportWrapper = new ReportWrapper(area, districtNew, dfom, month, contact, attachment);
                lstReportWrapper.add(newReportWrapper);
                lstRepWrapper.add(newReportWrapper);
                //XlsReportWrapper.add(newReportWrapper);
            }
            
                ReportList reporttListCls=new ReportList(areaPop,dist,lstRepWrapper,true);
                ReportListData.add(reporttListCls);
        }
        else {
            lstReportWrapper=null;
        }            
        return null;
    }
    
        public PageReference exportXls()
    {
        return page.SETDMMonthlyContactReportXls;
    }
    
    public class ReportWrapper
    {
        public string Area {get; set;}
        public string District {get; set;}
        public string DFOM {get; set;}
        public string Month {get; set;}
        public string Contact {get; set;}
        public string Attachment {get; set;}
        //public string NGP {get; set;}
        //public string Tires {get; set;}
        
        public ReportWrapper(String area, String district, String dfom, String month, String contact, String attachment)
        {
            this.Area = area;
            system.debug('====ReportWrapper = '+area);
            this.District = district;
            this.DFOM = dfom;
            this.Month = month;
            this.Contact = contact;
            this.Attachment = attachment;
            //this.NGP = ngp;
            //this.Tires = tires;
        }
    }
    
    public class ReportList
    {
        public string Area {get; set;}
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
       public  ReportList(string areaname,string distName,LIST<ReportWrapper> lstRepWrapper, boolean lstRec){
            Area=areaname;
            District=distName;
            lstRepWrap=lstRepWrapper;
            lastRecord=lstRec;
       }    
    }
    
    public LIST<ReportList> ReportListData{get;set;} 
     
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
     
     
     public List<SelectOption> getLstMonth()
    {
        List<SelectOption> lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('--None--', '--None--'));
        string currentDate=system.now().format('MMMM-d-yyyy');
        integer iMonLen=currentDate.indexof('-');
        
        string currMonth=currentDate.substring(0,iMonLen);
        integer iYearlen=currentDate.lastindexof('-');
        string curryear=currentDate.substring(iYearlen+1,currentDate.length());
        
        lstOptions.add(new SelectOption(currMonth+'-'+curryear, currMonth+'-'+curryear));
        
        //it is going for last 6 months. To make it flexible, later we could put number of months back in custom setting, if needed.
        for(integer iprev=1;iprev<=6;iprev++) {
         integer iLastMonth=iprev * (-1);
         //date prevDate=system.today().addMonths(iLastMonth);
        // string prevMonth=prevDate.month()+'/'+prevDate.year();
        // lstOptions.add(new SelectOption(prevMonth, prevMonth));
         
        string PrevDate=system.now().addMonths(iLastMonth).format('MMMM-d-yyyy');
        integer iPrevMonLen=PrevDate.indexof('-');
        
        string prevMonth=PrevDate.substring(0,iPrevMonLen);
        integer iprevYearlen=PrevDate.lastindexof('-');
        string prevYear=PrevDate.substring(iprevYearlen+1,PrevDate.length());
        lstOptions.add(new SelectOption(prevMonth+'-'+prevYear, prevMonth+'-'+prevYear));
        
        }
       
        return lstOptions;
    }

}