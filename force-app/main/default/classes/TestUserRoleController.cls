@isTest
Private class TestUserRoleController {
    static testMethod void TestUserRoleControllermethod()
    {
        UserRoleController u= new UserRoleController();
        u.UserRole='Enterprise';
        //u.usercount=3;
        
        
        List<SelectOption> options=u.getUsers();
        //system.assertEquals(32,options.size());
        pageReference p=u.showRecords();
        //system.assertEquals(3,u.usercount);
        List<User> user1=u.getRecords();
        
        //system.assertEquals(3,user1.size());
        
    }

}