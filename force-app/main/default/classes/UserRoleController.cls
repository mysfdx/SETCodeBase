/* Name:  UserRoleController
Created By:  Neha Agrawal
Created Date:  2020-06-01
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-07-28
Description:   
*/

public class UserRoleController {

    public String UserRole{get;set;}
    public boolean pb2Rendered{get;set;}
    
   // public String email{get;set;}
    //public String role{get;set;}
    public Integer usercount{get;set;}
    public List<SelectOption> getUsers() {
        List<SelectOption> UserRolelist = new List<SelectOption>();
        
        UserRolelist.add(new SelectOption('','-None-'));
       List<userrole> names= [select name from userrole where PortalRole<>'Worker'];
        For(userrole n: names)
        {
            UserRolelist.add(new SelectOption(n.Name,n.Name));
        }
        
            
        return UserRolelist;
    }
    public UserRoleController(){
        pb2Rendered=false;
    }
    public pageReference showRecords(){
        if(UserRole==null)
        {
            pb2Rendered=False;
            //system.debug('profile'+ UserName+'render value '+ pb2Rendered);
        }
        else
        {
            /*User u1=[select email,userrole.name from user where IsActive=true and name=:UserName and profile.name <>'Dealer User Community Profile 1' limit 1];
            role=u1.userrole.name;
            email=u1.Email;*/
            usercount=[SELECT count() FROM User
             WHERE userrole.Name=:UserRole and isactive=True];
            pb2Rendered=true;
        }
        return null;
    }
    public List<User> getRecords(){
        List<User> Records;
        //user u=[Select Profile.name,id from user where name=:UserName limit 1];
        //string profilename=u.profile.name;
        list<User> UserDetails =
            [SELECT name, username, email, profile.name, userrole.name,lastlogindate FROM User
             WHERE userrole.Name=:UserRole and isactive=True];
        
        if(UserDetails.size()!=0){
            Records = new list<User>();
        }
        for(user p: UserDetails){
            //date dt=p.lastlogindate.date();
            
            Records.add(p);
        }
        return records;
    }
    
}