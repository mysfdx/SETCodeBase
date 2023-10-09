/* Name:  TimeWorkedTriggerHandler
Created By:  Magulan Duraipandian
Created Date:  2017-06-08
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class TimeWorkedTriggerHandler {
    
    public static void onBeforeUpdate(List < DS_Time_Worked__c > listNewTimeWorked, Map < Id, DS_Time_Worked__c > oldMap) {
        updateTotalTimeWorked(listNewTimeWorked, oldMap);
    }
    
    private static void updateTotalTimeWorked(List < DS_Time_Worked__c > listNewTimeWorked, Map < Id, DS_Time_Worked__c > oldMap) {
        for ( DS_Time_Worked__c objTimeWrkd : listNewTimeWorked ) {
            if ( objTimeWrkd.Name != oldMap.get(objTimeWrkd.Id).Name ) {
                objTimeWrkd.DS_Total_time_worked__c = Decimal.valueOf(objTimeWrkd.Name.replaceAll('[^0-9]', '')) / 60;
            }
        }
    }
}