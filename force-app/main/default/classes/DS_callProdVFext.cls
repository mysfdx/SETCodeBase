/* Name:  DS_callProdVFext
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_callProdVFext {
    private final SObject parent;

    
    public DS_callProdVFext(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        
    }
      
    public PageReference callVFPg() {
       
        //theCase.accountId = parent.id;
        pageReference pgref=new pageReference('/apex/DS_AllVendorInfo?id='+parent.id + '&prod=yes');
        pgref.setRedirect(true);
        return pgref;
    }
    }