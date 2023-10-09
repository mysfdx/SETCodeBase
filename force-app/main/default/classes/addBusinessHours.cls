global class addBusinessHours {
    global class request
    {
        @InvocableVariable (label='Start Date' required = true)
        global DateTime startDateTime;
        @InvocableVariable (label='Business Hours Id' required = true)
        global String businessHoursId;
        @InvocableVariable (label='Interval To Add (Milliseconds)' required = true)
        global Long intervalMilliseconds;
    }
    global class response
    {
        @InvocableVariable (label='Next Business Date')
        global DateTime updatedBusinessDate;
    }
    @InvocableMethod(label='Add Business Hours' description='Adds an interval of time from a start Datetime traversing business hours only. Returns the result Datetime in the local time zone.')
    global static List<response> getUpdatedBusinessDate (List<request> inputParams)
    {
        List<response> responseList = new List<response>();
        DateTime updatedDate;
        if(inputParams != null && inputParams.size()> 0)
        {
            for(request pf : inputParams){
                updatedDate = BusinessHours.add(pf.businessHoursId, pf.startDateTime, pf.intervalMilliseconds);
                response rs = new response();
                rs.updatedBusinessDate = updatedDate;
                responseList.add(rs);
            }
        }
        return responseList;
    }
}