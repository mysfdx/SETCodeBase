/* Created By:  Neha Agrawal
Created Date:  2020-10-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-10-31
Description: To update the latest Update Date/time on incentive challenge type cases  
*/

trigger FeedCommentTrigger on FeedComment (After insert, after update) {
    if ( bypassExecution_Content__c.getInstance().TR_JMA_FeedCommentTrigger__c ) 
        return;
    set<id> Caseid=new Set<id>();
    List<Case> CasestoUpdate=new List<Case>();
    String ProfileName = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ][0].Name;
    if(ProfileName=='Dealer User Community Profile 1'){
        for(FeedComment fc: trigger.new){
            if(fc.ParentId.getSObjectType() == Case.SObjectType){
                caseid.add(fc.ParentId);
            }
        }
        for(Case c: [Select id, Form_Name__c, latest_Comment_date_time__c from Case where id in: Caseid]){
            if(c.Form_Name__c=='Incentives Challenge'){
                CasestoUpdate.add(new case(id=c.Id, latest_Comment_date_time__c=system.Now()));
            }
        }
        if(CasestoUpdate.size()>0){
            update CasestoUpdate;
        }
    }
}