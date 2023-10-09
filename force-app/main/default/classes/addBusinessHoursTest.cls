@isTest 
global class addBusinessHoursTest 
{
    @isTest static void check_NextBusinessDate() 
    {
        
        Profile sysadminprofile = [select Id, name from profile where Name='System administrator' limit 1];
        User adminUser = [select Id,Name from user where profileId= :sysadminprofile.Id and isactive=true limit 1];
        BusinessHours bhoursId = [select Id from BusinessHours where Name='SET Business Hours' limit 1];
        System.runAs(adminUser)
        {
            List<addBusinessHours.request> inputparams = new List<addBusinessHours.request>();
            //record 1
            addBusinessHours.request pf = new addBusinessHours.request();
            pf.startDateTime = Datetime.now();
            pf.businessHoursId = bhoursId.Id;
            pf.intervalMilliseconds = 3600000;
            inputparams.add(pf);       
            Test.startTest();
            List<addBusinessHours.response> response = addBusinessHours.getUpdatedBusinessDate(inputparams);
            Test.stopTest();
            System.assertEquals(Datetime.now().date(),response[0].updatedBusinessDate.Date());
            
        }
    }	
}