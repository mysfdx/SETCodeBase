/* Name:  SET_UserTrigger_Handler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public  class SET_UserTrigger_Handler {

	public void onBeforeUpdate(MAP<ID,User> newUserMap){
      //Convert map to list
      populateSETAreaDistrictforUser(newUserMap.values());
  }
	public void onBeforeInsert(LIST<User> userList){
      populateSETAreaDistrictforUser(userList);
  }

	public void populateSETAreaDistrictforUser(LIST<User> userList){
		
		string SETDISTRICT=System.Label.SET_District;
		string SETAREA=System.Label.SET_Area;
		
		LIST<ID> UserRoleIDs=new LIST<ID>();
		LIST<User> setUserList=new LIST<User>();
		for (User usrRec:userList){
			usrRec.SET_District__c=null;
			usrRec.SET_Area__c=null;
			if(usrRec.LOB__c!=null && usrRec.LOB__c.toupperCase()=='SET' ){
				if(usrRec.UserRoleId!=null){
					UserRoleIDs.add(usrRec.UserRoleId);
					setUserList.add(usrRec);
				}
			}
			
		}
		
		MAP<ID,string> userRoleDistrictMap=new MAP<ID,string>();
		MAP<ID,string> userRoleAreaMap=new MAP<ID,string>();
		MAP<ID,ID> setDistrictAreaMap=new MAP<ID,ID> ();
		
		LIST<UserRole> userRoleList=new LIST<UserRole>();
		for (UserRole uroleRec: [Select Name,ID,ParentRoleId from UserRole where ID in :UserRoleIDs and (Name like :SETDISTRICT+'%' or Name like :SETAREA+'%')]) {
			if (uroleRec.Name.toupperCase().startswith('SET DISTRICT')){
				userRoleDistrictMap.put(uroleRec.ID,uroleRec.Name);
				setDistrictAreaMap.put(uroleRec.ID,uroleRec.ParentRoleId);
			}
			
			if (uroleRec.Name.toupperCase().startswith('SET AREA')){
				userRoleAreaMap.put(uroleRec.ID,uroleRec.Name);
			}
		}
		//Getting Roles for Parent roleIDs
		for (UserRole uroleParent:[Select ID,Name from UserRole where id in :setDistrictAreaMap.values()]){
			userRoleAreaMap.put(uroleParent.ID,uroleParent.Name);
		}
		string areaStr =SETAREA.replace(' ','');
		string distStr=SETDISTRICT.replace(' ','');
		integer districtLen=distStr.length();
		integer areaLen=areaStr.length();
		for (User userRec:setUserList){
			   //below part populates District Name. If Role says SET District 01, it populates 01 to field. Removes preceeding string
				if(userRoleDistrictMap.containsKey(userRec.UserRoleId)){
					string districtName=userRoleDistrictMap.get(userRec.UserRoleId).replace(' ','');
					userRec.SET_District__c=districtName.substring(districtLen,districtName.length());
				}
				
				 //below part populates Area Name. If Role says SET Area A, it populates A to field. Removes preceeding string
				 else if (userRoleAreaMap.containsKey(userRec.UserRoleId)){
					string areaName=userRoleAreaMap.get(userRec.UserRoleId).replace(' ','');
					userRec.SET_Area__c=areaName.substring(areaLen,areaName.length());
				}
				
				if(setDistrictAreaMap.containsKey(userRec.UserRoleId) && userRoleAreaMap.containsKey(setDistrictAreaMap.get(userRec.UserRoleId))){
					string areaName=userRoleAreaMap.get(setDistrictAreaMap.get(userRec.UserRoleId)).replace(' ','');
					userRec.SET_Area__c=areaName.substring(areaLen,areaName.length());
				}					
			
		}
			
			
			
		
	}
	

}