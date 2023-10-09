@isTest
public class DeactivateUserScheduleTest {
    @isTest static void executeTest(){
        SchedulableContext sc = null;
		DeactivateUserSchedule dus = new DeactivateUserSchedule();
        dus.execute(sc);
    }


}