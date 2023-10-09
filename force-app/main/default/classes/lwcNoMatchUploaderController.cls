public class lwcNoMatchUploaderController {
    
    @AuraEnabled
    public static List<No_Match__c> saveFile(String base64Data) {
        String data    = JSON.deserializeUntyped(base64Data).toString();
        list<No_Match__c> lstCCToInsert = new list<No_Match__c>();
        Map<No_Match__c,String> noMatchDlrCd= New Map<No_Match__c,String>();
        list<String> lstCSVLines = data.split('\n');
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            No_Match__c nm = new No_Match__c();
            String trimDlrCd;
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            system.debug('csvLine is '+csvLine);
            system.debug('csvLine.indexOf '+csvLine.indexOf('"') );
            while(csvLine.indexOf('"') > -1){
                
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                    system.debug('Start index csv line '+ csvLine);
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                        system.debug('end index csv line '+ csvLine);
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                    system.debug('Both index csv line '+ csvLine);
                }
            }
            
            List<String> csvRowData = new List<String>();
            
            
            for(String column : csvLine.split(',')){
                
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                
                csvRowData.add(column);
                
                
            }
            
            If(!String.isBlank(csvRowData[1])){
                //throw new AuraHandledException('Check format and required columns in row number '+ String.valueOf(i+1)
                //+' and other rows as well.');
                
                nm.REC__c = csvRowData[1];
                If(csvRowData[2].Trim().length()<4 || !(csvRowData[2].Trim().isNumeric())){
                    throw new AuraHandledException('In Model, only 4 digits are allowed');
                }
                else
                {
                    nm.Model__c = csvRowData[2]; 
                }
                If(csvRowData[3].Trim().length()<>17){
                    throw new AuraHandledException('In VIN, only 17 characters are allowed');
                }
                else
                {
                    nm.Serial__c = csvRowData[3].Trim();
                }
                
                
                if(!String.isBlank(csvRowData[4])){
                    nm.CC__c=Decimal.valueOf(csvRowData[4]);
                }
                If(csvRowData[5].Trim().length()<>5){
                    throw new AuraHandledException('In VDS, only 5 characters are allowed');
                }
                else
                {
                    nm.VDS__c= csvRowData[5].Trim();
                }
                if(!String.isBlank(csvRowData[6])){
                    nm.Name__c=csvRowData[6];
                }
                if(!String.isBlank(csvRowData[7])){
                    nm.Name1__c=csvRowData[7];
                }
                if(!String.isBlank(csvRowData[8])){
                    nm.REGMO_Y__c= System.date.parse(csvRowData[8]);
                }
                
                if(!String.isBlank(csvRowData[9])){
                    nm.Activity_Date__c=System.date.parse(csvRowData[9]);
                }
                if(!String.isBlank(csvRowData[10])){
                    nm.Retail_Date__c=System.date.parse(csvRowData[10]);
                }
                
                if(!String.isBlank(csvRowData[11])){
                    nm.Type_Sale__c=Decimal.valueOf(csvRowData[11]); 
                }
                if(!String.isBlank(csvRowData[14])){
                    nm.Series_Name__c=csvRowData[14].Trim();
                }
                if(!String.isBlank(csvRowData[12])){
                    String sellRegex = '\\d{3}-\\d{5}';
                    Pattern sellPattern = Pattern.compile(sellRegex);
                    Matcher sellMatcher = sellPattern.matcher(csvRowData[12].trim());
                    if(sellMatcher.matches())
                    {
                        nm.Dealer_Selling__c=csvRowData[12].trim();
                    }
                    else{
                        throw new AuraHandledException('In DEALER SELLING, only this format is allowed: 500-09108');
                    }
                }
                if(!String.isBlank(csvRowData[13])){
                    system.debug('Dealer Code not blank');
                    trimDlrCd=csvRowData[13].Trim();
                    If(trimDlrCd.length()<4 || trimDlrCd.length()>5 || !(trimDlrCd.isNumeric())){
                        throw new AuraHandledException('In SET DEALER codes, only a maximum of '+
                                                       '4 or 5 digits are allowed');
                    }
                    else if(trimDlrCd.length()==4){
                        
                        noMatchDlrCd.put(nm,'0'+trimDlrCd);
                    }
                    else{
                        noMatchDlrCd.put(nm,trimDlrCd);
                    }
                }
                else{
                    system.debug('Dealer Code blank');
                    lstCCToInsert.add(nm);
                }
                
            }
            
        }
        
        Map<ID, Account> accMap = new Map<ID, Account>([SELECT Id, Dealer_Code__c FROM Account WHERE 
                                                        Dealer_Code__c in:noMatchDlrCd.values()]);
        For(No_Match__c n: noMatchDlrCd.keySet()){
            For(Id accId: accMap.keySet()){
                system.debug('no Match Dealer Code '+noMatchDlrCd.get(n));
                    if((noMatchDlrCd.get(n)==accMap.get(accId).Dealer_Code__c) && noMatchDlrCd.get(n)<>null){
                        n.Dealer_Name__c=accId;
                    }
            }
            lstCCToInsert.add(n);
        }
        try{
            insert lstCCToInsert;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return [Select Id,Name, REC__c,Model__c, Serial__c,VDS__c,Name__c, REGMO_Y__c, 
                Dealer_Selling__c,Set_Dealer__c From No_Match__c Where CreatedDate>=:Date.TODAY()];
    }
    
    
    
}