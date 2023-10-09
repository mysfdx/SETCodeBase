/* Name:  SET_Hours_of_Operation_triggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class SET_Hours_of_Operation_triggerHandler {
    public static void validateHours(LIST<Hours_of_Operation__c> HoursOfOperations) {
        
        for (Hours_of_Operation__c hrsOfOpps:HoursOfOperations){
            if(!hrsOfOpps.Closed__c && hrsOfOpps.start_time__c!=null && hrsOfOpps.end_time__c!=null){
            	string startime=SET_Hours_of_Operation_triggerHandler.parseTime(hrsOfOpps.start_time__c);
            	string endtime=SET_Hours_of_Operation_triggerHandler.parseTime(hrsOfOpps.end_time__c);
            	system.debug('********Start Time*****'+startime);
            	system.debug('********End Time*****'+endtime);
            	if (startime.substring(4,6)=='AM' &&  startime.substring(0,2)=='12'){
                // Cobverting 12 AM to 00 so that calculation done correctly.
                	startime='00'+startime.substring(2,6);
            	}
            	if(startime.substring(4,6)==endtime.substring(4,6) && integer.valueOf(startime.substring(0,4)) >= integer.valueOf(endtime.substring(0,4)) && !startime.startsWith('12') ){
                	hrsOfOpps.addError('Start Time Should be Earlier than End Time.');
            	}
            	else if(startime.substring(4,6)!=endtime.substring(4,6) && startime.substring(4,6)=='PM' ) {
                	hrsOfOpps.addError('Start Time Should be Earlier than End Time.');
            	}
            	else { //Timings are correct, now calculating the diference
                	hrsOfOpps.Start_Time__c=startime.substring(0,2)+'.'+startime.substring(2,4) + ' '+startime.substring(4,6);
                	hrsOfOpps.End_Time__c=endtime.substring(0,2)+'.'+endtime.substring(2,4) + ' '+endtime.substring(4,6);
                	if(startime.substring(0,2)=='00') {
                   //changing 00 back to midnight 12 AM, so that time difference calculation done.
                    	startime='12'+startime.substring(2,6);
                	}
                	system.debug('****startime****'+startime);
                	system.debug('****endtime****'+endtime);
                	
                	
                	datetime stDt=datetime.parse('01/01/2014 '+startime.substring(0,2)+':'+startime.substring(2,4) + ' '+startime.substring(4,6));
                	datetime EndDt=datetime.parse('01/01/2014 '+endtime.substring(0,2)+':'+endtime.substring(2,4) + ' '+endtime.substring(4,6));
                	decimal durationHr=((EndDt.getTime())/1000/60/60)-((stDt.getTime())/1000/60/60);
                
                
                	hrsOfOpps.duration__c=string.valueOf(durationHr) + ' hours';
            	}
            }
        }
        
    }
    
    public static string parseTime(string inputTime) {
        
        string outTime='';
        system.debug('****parseTime Method*****');
        if(inputTime.length()==7){
                		inputTime='0'+inputTime;
          }
        system.debug('****inputTime*****'+inputTime);
        system.debug('****inputTime.substring(0,2)*****'+inputTime.substring(0,2));
        system.debug('****inputTime.substring(3,5)*****'+inputTime.substring(3,5));
        outTime=inputTime.substring(0,2)+inputTime.substring(3,5)+inputTime.substring(6,8);
        return outTime;
        
    }
}