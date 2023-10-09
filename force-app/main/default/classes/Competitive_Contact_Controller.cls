/* Name:  Competitive_Contact_Controller
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public  class Competitive_Contact_Controller {
    Id CompContactID;
    
    
    
    public Competitive_Contact_Controller(ApexPages.StandardController stdController){
        CompContactID=stdController.getId();
    }
    
    public pageReference showStandardPage(){
        string msg='System Managed Field';
        pageReference pgRef=new pageReference('/a0C/e?nooverride=1&Name='+msg+'&retURL=%2Fa0C%2Fo');
        pgRef.setRedirect(true);
        return pgRef;
        
    } 

}