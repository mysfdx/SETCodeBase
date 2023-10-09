/******************************************************************************************************************
* Author:  Alekya Gurram
* Process: Case
* Purpose: Override DS Case's edit page with custom page and auto populate/assign the multiple fields values from Case parent obj 
*          i.e Product,subProduct and dealer.
* Notes:   NA       
*******************************************************************************************************************/
public class DS_CaseEditController { 
    
    Public Case cse {get;set;}
    Public String CreatedByUser {get;set;}
    //public Blob att {get; set;}//
    public blob file {get; set;}
    Public String productCaseurl {get;set;}
    Public String CustomerCaseurl {get;set;}
    Public String productCase {get;set;}
    Public String CustomerCase {get;set;}
    Public String productLinksUrl {get;set;}
    public String minutes {get; set;}
    //public Attachment myDoc = new Attachment();
    //public ContentVersion cv = new ContentVersion();
    public ContentVersion cv {get;set;}
    //Public String attName {get;set;}
    Public String title {get;set;}
    Public String Type {get;set;}
    Public String fN {get;set;}
    Public String CustEmail;
    Public String CustPhone;
    Public String CustDesc;
    Public String custName;
    Public Decimal TotalTime;
    public ApexPages.StandardController stdController;
    
    public DS_CaseEditController(ApexPages.StandardController stdController) { 
        this.cse = (Case)stdController.getRecord(); 
        this.stdController = stdController;
        custName = cse.DS_Customer_Name_cust__c;
        minutes ='10';
        TotalTime = 0;
        Case c= New Case();
        c=[Select Id,DS_Total_Time_Spent_In_Hours__c from Case where Id=:cse.Id ];
        if(c.DS_Total_Time_Spent_In_Hours__c != null)
            TotalTime = c.DS_Total_Time_Spent_In_Hours__c;
        cv = new ContentVersion(); 
        DS_Vendor_Product__c vdp = new DS_Vendor_Product__c();
        DS_Product__c vdproduct = new DS_Product__c();
        vdproduct =[select Id,name,Phone__c,DS_Critical_App__c,Email__c,
                    DS_Business_Owner__c,DS_Internal_Support_Email__c,DS_Internal_Support_group__c from DS_Product__c where Id =:cse.DS_Vendor_Product_cust__c];
        productCaseurl ='/apex/DS_RecentProductCases?id='+ vdproduct.Id;
        CustomerCaseurl ='/apex/DS_RecentCustomerCases?id='+cse.DS_Customer_Name__c;
        productLinksUrl ='/apex/DS_ProductLinksPage?id='+ vdproduct.Id;
    } 
    /*******************************************************************
Purpose: Calls required methods to process before update functionalities.Here creates Time worked and Customer details records. 
Parameters: case
Returns: Pagereference
Throws : N/A                                                    
********************************************************************/  
    Public Pagereference mySave(){
        Decimal timeinMinutes;
        if(minutes != '--None--')
            cse.DS_Time_Spent_In_Minutes__c = Decimal.valueOf(minutes);
        if(cse.DS_Time__c != null){
            TotalTime = TotalTime+Decimal.valueOf(cse.DS_Time__c);
            timeinMinutes = Decimal.valueOf(cse.DS_Time__c)*60;
            
        }
        //cse.DS_Total_Time_Spent_In_Hours__c += Decimal.valueOf(cse.DS_Time__c);
        DS_Time_Worked__c tc = new DS_Time_Worked__c();
        if(minutes == '--None--'){       
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Time Entry(Hrs/Min)'));
            return null;
        }
        cse.DS_Time_Spent_In_Minutes__c = Decimal.valueOf(minutes );
        DS_Customer_Details__c cust = new DS_Customer_Details__c(); 
        cust.Name = cse.DS_Customer_Name_cust__c;
        cust.DS_Customer_Email__c = cse.DS_Cust_Customer_Email__c;
        cust.DS_Customer_Phone__c = cse.DS_Cust_Customer_Phone__c;          
        
        if(cse.DS_Time_Spent_In_Minutes__c != 0 && cse.DS_Time_Spent_In_Minutes__c != null && minutes !='--None--' ){              
            Decimal timeSpent = cse.DS_Time_Spent_In_Minutes__c;
            
            if(TotalTime != 0 && TotalTime != null){
                cse.DS_Total_Time_Spent_In_Hours__c = TotalTime + (timeSpent / 60);
                //cse.DS_Total_Time_Spent_In_Hours__c = TotalTime + timeSpent;
            }
            
            else
                cse.DS_Total_Time_Spent_In_Hours__c = timeSpent/60 ;
            
            //tc.Name= cse.DS_Time_Spent_In_Minutes__c+' Minutes'; 
            if(timeinMinutes != 0 && timeinMinutes != null)
                tc.Name= timeinMinutes + timeSpent +' Minutes';
            
            else
                tc.Name=timeSpent + ' Minutes';            
            cse.DS_Time_Spent_In_Minutes__c = 0;
            cse.DS_Time__c = '';
        }
        //update cse;
        tc.DS_Time_Case__c = cse.Id;
        tc.DS_Total_time_worked__c = cse.DS_Total_Time_Spent_In_Hours__c;
        cust.DS_Customer_Name__c = cse.id;
        if(custName != cse.DS_Customer_Name_cust__c)
            insert cust;
        insert tc;
        
        /*update cse;
PageReference pr = New Pagereference('/'+cse.Id);
if(myDoc.Name != null){
Attachment a = new Attachment();
a.parentId = cse.Id;
a.name=myDoc.name;
a.body = myDoc.body;
insert a;
}*/
        
        update cse;
        PageReference pr = New Pagereference('/'+cse.Id);
        if(!string.isEmpty(fn)){
            ContentVersion cv = new ContentVersion();
            cv.versionData = file;
            cv.title = fn;
            cv.FirstPublishLocationId = cse.Id;
            cv.pathOnClient =fN;
            insert cv;
            //return new PageReference('/' + cse.Id);
        }
            
        
        
        return new PageReference('/' + cse.Id);    
        return pr;
    }
    
    Public Pagereference Cancel(){
        PageReference pr = New Pagereference('/'+cse.Id);
        return pr;
    }
    
    /*public PageReference upload() {
        ContentVersion cv = new ContentVersion();
        cv.versionData = file;
        cv.title = fn;
        cv.FirstPublishLocationId = cse.Id;
        cv.pathOnClient =fN;
        insert cv;
        return new PageReference('/' + cse.Id);
    } */      
    
}