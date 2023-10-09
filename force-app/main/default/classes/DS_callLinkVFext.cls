/* Name:  DS_callLinkVFext
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_callLinkVFext {
    private final SObject parent;

    
    public DS_callLinkVFext(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        
    }
      
    public PageReference callVFPg() {
       
        pageReference pgref=new pageReference('/apex/DS_LinkPg?aId='+parent.id);
        pgref.setRedirect(true);
        return pgref;
    }
    }