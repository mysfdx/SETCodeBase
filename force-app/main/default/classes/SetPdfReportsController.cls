/* Name:  SetPdfReportsController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class SetPdfReportsController {
    
public string SelectedDistrictLevel{get;set;}
public string SelectedDistrictReport{get;set;}
public string RetrieveDistrictUrl{get;set;}

public string SelectedDealerDistrictLevel{get;set;}
public string SelectedDealer{get;set;}
public string SelectedDealerReport{get;set;}
public string RetrieveDealerUrl{get;set;}

public string getbody{get;set;}
public string errormsg{get;set;}

String remoteSiteUrl = 'https://dp-ftmobile.jmfamily.com/SalesForce%20Reports/';

public SetPdfReportsController() {
  SelectedDistrictLevel = 'None';
  SelectedDealerDistrictLevel = 'None';
  SelectedDealer = 'None';  
}
public List<SelectOption> getDistrictLevelList() {
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('None','--- None ---'));     
  for(integer i=1;i<15;i++) {
    string getnumber=(i<=9?'0'+string.valueof(i):string.valueof(i));
    options.add(new SelectOption('D'+getnumber,'District'+getnumber));
  }
  return options;
} 
    
public List<SelectOption> getDistrictReportList()
{
  List<SelectOption> options = new List<SelectOption>();
  if(SelectedDistrictLevel != 'None') {
    options.add(new SelectOption('None','--- None ---'));
    options.add(new SelectOption('AS00016 - Accessory One Page for Current Month by District.pdf', 'Accessory One Page for Current Month by District'));
    options.add(new SelectOption('AS00013 - Accessory Purchase Analysis.pdf','Accessory Purchase Analysis'));
    options.add(new SelectOption('AS00028 - Dealer Accessory Dividend Report.pdf','Dealer Accessory Dividend Report'));
    options.add(new SelectOption('AS00032 - Dealer Accessory Programs - Allocated Not Wholesaled.pdf','Dealer Accessory Programs - Allocated Not Wholesaled'));
    options.add(new SelectOption('AS00027 - District Accessory Dividend Report.pdf','District Accessory Dividend Report'));
    options.add(new SelectOption('PS00038 - District Performance vs LY.pdf','District Performance vs LY'));
    options.add(new SelectOption('GS00001 - District Sales Report.pdf','District Sales Report'));
    options.add(new SelectOption('PS00058 - P&A Purchase Report.pdf','P&A Purchase Report'));
    }
  else {
    options.add(new SelectOption('None','--- None ---'));
  }
  return options;
}

public List<SelectOption> getDealerList() {
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('None','--- None ---'));
  string districtvalue = '';
  System.debug('********55*******'+SelectedDistrictLevel);
  if(SelectedDistrictLevel != 'None') {
    districtvalue = SelectedDistrictLevel.substring(1,SelectedDistrictLevel.length());
      System.debug('********55*******'+districtvalue );
    integer districtnumber = integer.valueof(districtvalue);
          System.debug('********55*******'+districtnumber );
    districtvalue = string.valueof(districtnumber);
    RecordType r = [SELECT Id FROM RecordType where Name ='Dealership'];
    if(r != null) {
          System.debug('********64*******'+districtnumber );
      for(Account d:[select id, name, Dealer_Code__c from account where Dealer_Code__c != null and District__c = :districtvalue and Active_Dealer__c = TRUE and RecordTypeId = :r.Id order by name asc ]) {
        options.add(new SelectOption(d.Dealer_Code__c,d.name));
      }
    }
    }
    return options;
} 

public List<SelectOption> getDealerReportList() {

    List<SelectOption> options = new List<SelectOption>();
    if(SelectedDealer!='None')
    {
    options.add(new SelectOption('AS00016 - Accessory One Page for Current Month CP.pdf','Accessory One Page for Current Month CP'));
    options.add(new SelectOption('AS00013 - Accessory Purchase Analysis CP.pdf','Accessory Purchase Analysis CP'));
    options.add(new SelectOption('AS00028 - Dealer Accessory Dividend Report CP.pdf','Dealer Accessory Dividend Report CP'));
    options.add(new SelectOption('AS00032 - Dealer Accessory Programs CP.pdf','Dealer Accessory Programs CP'));
  }
  else {
    options.add(new SelectOption('None','--- None ---'));
  }
  return options;
}

public void retrieveDistrict() {

  RetrieveDistrictUrl='';
  if(SelectedDistrictLevel =='None') {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the District Level and Reports'));
  } 
  else{
   If(SelectedDistrictLevel =='True'|| SelectedDistrictReport =='None')
   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the District Reports'));
    else {
    String reportFileName = 'DIS'+SelectedDistrictLevel .substring(1,SelectedDistrictLevel .length())+'_SETCV-'+SelectedDistrictReport;
    retrieveDistrictUrl=remoteSiteUrl+'Districts/'+reportFileName;
    String finalurl= RetrieveDistrictUrl.replaceall(' ','%20'); // should be able to encode
    RetrieveDistrictUrl=RetrieveReport(reportFileName,finalurl);
    if(RetrieveDistrictUrl.trim().length() <= 0 || RetrieveDistrictUrl.trim() == '') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormsg));
    }
  }
}
}
public void retrieveDealer() {

  RetrieveDealerUrl='';
  if(SelectedDealer == 'None' || SelectedDealerReport == 'None') {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Dealer and Reports'));
  }
    else {
    String reportFileName = SelectedDealer+'_SETCR-'+SelectedDealerReport;
    RetrieveDealerUrl=remoteSiteUrl+'Dealers/'+reportFileName;
    string finalurl= RetrieveDealerUrl.replaceall(' ','%20'); // should be able to encode
    RetrieveDealerUrl=retrieveReport(reportFileName,finalurl);
    if(RetrieveDealerUrl.trim().length()<=0 || RetrieveDealerUrl.trim()=='') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormsg));
    }
    }
}
public string retrieveReport(String docName, String URL) {
  string returnURL='';
  errormsg='';
  HttpRequest req = new HttpRequest();
  HttpResponse res = new HttpResponse();
  Http http = new Http();
  req.setEndpoint(URL);
  req.setMethod('GET');
  req.setHeader('Content-Type', 'application/pdf');
  String fid;
  String pdf;
  User u=[Select FederationIdentifier from User where id =:Userinfo.getUserId()];
  fid=u.FederationIdentifier;
  if (fid!=null) {
    Blob headerValue = Blob.valueOf(fid);
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    req.setHeader('Authorization', authorizationHeader );
    res = http.send(req);
    if(res.getStatusCode()==200) {
      Folder DocFolder = [SELECT id FROM Folder WHERE Name = 'System Temporary Documents'];
      document d1=new document(name=docName, body=res.getBodyAsBlob(), folderid=DocFolder.id);
      insert d1;
      returnURL='/apex/SetPdfReportsDisplayPdf?id='+d1.id;
      }
      else {
      errormsg=res.getbody();
    }
  }
    else {
    errormsg='Your user record is missing the federation identifier. Please submit a ServiceNow ticket to the Salesforce team to get this resolved';
  }
  return returnURL;
}
}