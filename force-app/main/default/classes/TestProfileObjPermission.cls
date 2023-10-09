@isTest
private class TestProfileObjPermission {

    static testMethod void TestProfileObjPermissionmethod()
    {
        
        ProfileObjPermission pro=new ProfileObjPermission();
        apexpages.currentpage().getparameters().put('ProfileNames','Mulesoft API');
        ProfileObjPermission pro1=new ProfileObjPermission();
        
        //system.assertEquals(46, pro1.Records.size());
   
    }
    
}