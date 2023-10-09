/************************************************************************************************************************
* Author:  Alekya Gurram
* Process: Case
* Purpose: Makes the New and Edit buttons redirects to case Standrad and overide page layouts based on Record Types

* Notes:   NA    

Modified By - Modified Date - Purpose
Neha Agrawal - 06/05/2023 - Changed the case creation page for Dealer Services based on RT id.
*************************************************************************************************************************/


Public class DS_CaseoverridePage {
    Public Case cse {get;set;}
    
    public DS_CaseoverridePage(ApexPages.StandardController stdController) {
        this.cse= (Case)stdController.getRecord();
    }
    
    public PageReference redirectToPage() {
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        system.debug('Cse record type '+cse.RecordTypeId);
        if(PROFILE[0].Name == 'JMSC - Dealer Services') {
            if(cse.RecordTypeId ==(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SET_DS_Case').getRecordTypeId())){
               return Page.DS_Case_OverridePage.setRedirect(True); 
            }
            else{
                PageReference pageRef2 = new PageReference('/500/e?retURL=%2F'+'&RecordType='+cse.RecordTypeId+'&ent=Case&nooverride=1');
                
                return pageRef2;
            }
            
        }
        else if(PROFILE[0].Name == 'SET- Parts Technical') {
            return Page.SET_Parts_Case_OverridePage.setRedirect(True);
        }
        else {
            String urlstr = ApexPages.currentPage().getUrl().replace('.override=1', '.override=0').replace('apex/DS_CaseRedirect', '500/e').remove('&save_new=1');
            system.debug('URL is ' + urlstr);
            PageReference p = new PageReference(urlstr);
            p.getParameters().put('nooverride','1');
            p.setRedirect(true);
            return p;
        }       
    }
}