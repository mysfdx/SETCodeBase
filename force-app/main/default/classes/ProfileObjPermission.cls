/* Name:  ProfileObjPermission
Created By:  Neha Agrawal
Created Date:  2020-05-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-06-04
Description:   
*/

public with sharing class ProfileObjPermission {
    /*public String UserName{get;set;}
    public boolean pb2Rendered{get;set;}
    public String email{get;set;}
    public String role{get;set;}*/
    public String ProfileName{get;set;}
     Public List<ObjectPermissions> Records{get;set;}
    /*public List<SelectOption> getUsers() {
        List<SelectOption> Userlist = new List<SelectOption>();
        
        Userlist.add(new SelectOption('','-None-'));
       List<User> names= [select name from user where IsActive=true and profile.name <>'Dealer User Community Profile 1'];
        For(user n: names)
        {
            Userlist.add(new SelectOption(n.Name,n.Name));
        }
        
            
        return Userlist;
    }*/
    public ProfileObjPermission(){
        //pb2Rendered=false;
        ProfileName = System.currentPagereference().getParameters().get('ProfileNames');
        Records =
            [SELECT Parent.profile.Name,SobjectType, PermissionsRead, PermissionsCreate, PermissionsDelete, 
             PermissionsEdit, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions
             WHERE Parent.profile.Name=:ProfileName];
    }
    /*public pageReference showRecords(){
        if(UserName==null)
        {
            pb2Rendered=False;
            system.debug('profile'+ UserName+'render value '+ pb2Rendered);
        }
        else
        {
            User u1=[select email,userrole.name from user where IsActive=true and name=:UserName and profile.name <>'Dealer User Community Profile 1' limit 1];
            role=u1.userrole.name;
            email=u1.Email;
            pb2Rendered=true;
        }
        return null;
    }
    public List<ObjectPermissions> getRecords(){
        List<ObjectPermissions> Records;
        user u=[Select Profile.name,id from user where name=:UserName limit 1];
        //string profilename=u.profile.name;
        list<ObjectPermissions> objpermission =
            [SELECT Parent.profile.Name,SobjectType, PermissionsRead, PermissionsCreate, PermissionsDelete, 
             PermissionsEdit FROM ObjectPermissions
             WHERE Parent.profile.Name=:u.profile.name];
        if(objpermission.size()!=0){
            Records = new list<ObjectPermissions>();
        }
        for(ObjectPermissions p:objpermission){
            Records.add(p);
        }
        return records;
    }*/
    
}