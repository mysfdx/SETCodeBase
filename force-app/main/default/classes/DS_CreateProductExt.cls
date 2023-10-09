/* Name:  DS_CreateProductExt
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateProductExt {
    String vendorId;
    String accId;
    String recordTypeId;
    public String VendorName {get; set;}
    public String RecordTypeName {get; set;}
    DS_Product__c dsProduct;
    public Boolean IsAppServices {get; set;}    
    public Boolean IsDataConnection {get; set;}
    public Boolean IsHardware {get; set;}
    public String BtnLabel {get; set;}
    public List<SelectOption> LstTypeOptions {get; set;}
    public String ProdName;
	public String subprod = 'no';
    
    public DS_CreateProductExt(ApexPages.StandardController controller) {
        dsProduct = (DS_Product__c)controller.getRecord();
        BtnLabel = 'Save'; 
        ProdName = Apexpages.currentPage().getParameters().get('pname');
        if(ApexPages.currentPage().getParameters().containsKey('vid'))
        {
            vendorId = ApexPages.currentPage().getParameters().get('vid');
            List<DS_Vendor__c> lstVendor = [Select Name from DS_Vendor__c where Id =:vendorId];
            VendorName = lstVendor[0].Name;
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('type'))
        {
            LstTypeOptions = new List<SelectOption>();
            recordTypeId = ApexPages.currentPage().getParameters().get('type');
            List<RecordType> lstRecordType = [Select Name from RecordType where id =:recordTypeId];
            RecordTypeName = lstRecordType[0].Name;
            LstTypeOptions.add(new SelectOption('--None--', '--None--'));
            if(RecordTypeName == 'Data Connection')
            {
                IsDataConnection = true;
                IsHardware = false;
                IsAppServices = false;
                LstTypeOptions.add(new SelectOption('Private', 'Private'));
                LstTypeOptions.add(new SelectOption('Internet', 'Internet'));
                LstTypeOptions.add(new SelectOption('Other', 'Other')); 
                dsProduct.Status__c = 'Active'; 
                dsProduct.DS_Vendor_name__c = VendorName; 
                dsProduct.Date_Added__c = Date.today();
                if(prodName != null)
                dsProduct.Name =prodName;
                dsProduct.DS_Critical_Data_Connection__c ='No';
                dsProduct.DS_Month_End_Critical_Connection__c ='No';
                dsProduct.DS_Potential_Revenue_Impact_if_down__c ='No';
                dsProduct.DS_Potential_Impacted_if_down__c = '0';  
                             
            }
            else if(RecordTypeName == 'Hardware')
            {
                IsDataConnection = false;
                IsHardware = true;
                IsAppServices = false;
                LstTypeOptions.add(new SelectOption('Network', 'Network'));
                LstTypeOptions.add(new SelectOption('PC', 'PC'));
                LstTypeOptions.add(new SelectOption('Phone', 'Phone'));
                LstTypeOptions.add(new SelectOption('Server', 'Server'));
                LstTypeOptions.add(new SelectOption('Other', 'Other'));
                dsProduct.Status__c = 'Active'; 
                dsProduct.DS_Vendor_name__c =   VendorName; 
                dsProduct.Date_Added__c = Date.today(); 
                dsProduct.DS_Critical_Hardware__c ='No';
                dsProduct.DS_Month_End_Critical_Hardware__c ='No';
                dsProduct.DS_Potential_Revenue_Impact_if_down__c ='No';
                dsProduct.DS_Potential_Impacted_if_down__c = '0';
                if(prodName != null)
                dsProduct.Name =prodName ;
                dsProduct.OEM_Cert_Brands__c ='Toyota';
                
            }
            else if (RecordTypeName == 'Apps Services')
            {
                IsDataConnection = false;
                IsHardware = false;
                IsAppServices = true;
                LstTypeOptions.add(new SelectOption('CRM', 'CRM'));
                LstTypeOptions.add(new SelectOption('DMS', 'DMS'));
                LstTypeOptions.add(new SelectOption('Other', 'Other'));   
                dsProduct.Status__c = 'Active'; 
                dsProduct.DS_Vendor_name__c =   VendorName; 
                dsProduct.Date_Added__c = Date.today();
                if(prodName != null)
                dsProduct.Name =prodName; 
                dsProduct.DS_Potential_Revenue_Impact_if_down__c ='No';
                dsProduct.DS_Potential_Impacted_if_down__c = '0';
                dsProduct.DS_Critical_App__c ='No';
                dsProduct.DS_Month_End_Critical_App__c ='No';

            }
        }
        
        if ( ApexPages.currentPage().getParameters().containsKey('subprod') ) {
            subProd = ApexPages.currentPage().getParameters().get('subprod');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('aid'))
        {
            accId = ApexPages.currentPage().getParameters().get('aid');
        }
    }
    
    public Pagereference next()
    {
       /* if(String.isBlank(dsProduct.Type__c) || dsProduct.Type__c == '--None--')
        {
            ApexPages.Message newMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a value for Type.');
            ApexPages.addMessage(newMsg);
            return null;
        }*/
        //dsProduct.Vendor__c = vendorId;
        List<DS_Product__c> lstProductInfo = [Select Id From DS_Product__c Where Name =:dsProduct.Name];
        if(!lstProductInfo.isEmpty())
        {
            ApexPages.Message newMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This Product Name already exists.');
            ApexPages.addMessage(newMsg);
            return null;
        }
        
        dsProduct.RecordTypeId = recordTypeId;
        insert dsProduct;
         
        DS_Vendor_Product__c vendorProduct = new DS_Vendor_Product__c();
        vendorProduct.Product__c = dsProduct.Id;
        vendorProduct.Vendor__c = vendorId;
        vendorProduct.Name = dsProduct.Name+ ' ' +VendorName;
        insert vendorProduct;
        
        Pagereference page;
        
        if ( subProd == 'yes' ) {
        	if(String.isNotBlank(accId))
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +dsProduct.Id+ '&vid=' + vendorId + '&id='+accId + '&subprod=yes');
            else
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +dsProduct.Id+ '&vid=' + vendorId + '&subprod=yes');
        } else if(dsProduct.Type__c == 'CRM' || dsProduct.Type__c == 'DMS')
        {
            if(String.isNotBlank(accId))
                page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +dsProduct.Id+ '&vid=' +vendorId+ '&aid='+accId);
            else
                page = new Pagereference('/apex/DS_CreateSubCategory?pId=' +dsProduct.Id+ '&vid=' +vendorId);
        }
        else
        {
            if(String.isNotBlank(accId))
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +dsProduct.Id+ '&vid=' +vendorId+ '&id='+accId);
            else
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +dsProduct.Id+ '&vid=' +vendorId);
        }
        
        return page;
    }
    
    public Pagereference prev() {
        String url = '/apex/DS_SelectProductType?vid='+vendorId;
        Pagereference page;
        if ( subProd == 'yes' )
        	url += '&subprod=yes';
    	page = new Pagereference(url);
        return page;
    }
}