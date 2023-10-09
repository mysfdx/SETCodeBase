/* Name:  avs_ReturnToPortResource
Created By:  Ad Victorium
Created Date:  2/28/2020
Last Modified By:  Neha Agrawal
Last Modified Date: 12/09/2022
Description: 

ChangeLog:
Changes by Neha Agrawal on 12/09/2022 to Add 2 new APIs ETA and VFT Distribution case types. 
*/


@RestResource(urlMapping='/forms/distribution-case/*')
global class avs_ReturnToPortResource {
    
    @HttpPost
    global static String postMethod() {
        RestResponse response = RestContext.response;
        String caseType = RestContext.request.requestURI.substring(
            RestContext.request.requestURI.lastIndexOf('/')+1);
        system.debug('caseType is '+caseType);
        try {
            FormRequest request;
            Case caseRecord;
            FormRequestDomain domain = new FormRequestDomain();
            avs_ResourceSubmission submission = new avs_ResourceSubmission();
            if(caseType=='return-to-port'){
                request = domain.deserializeFormRequest(FormRequest.FormName.RETURN_TO_PORT, RestContext.request.requestBody.toString());
                caseRecord = submission.submitForm(request, 'DD Forms');
                response.statusCode = 201;
                return String.valueOf(new SalesforceResponse(caseRecord));
            } else if(caseType=='eta'){
                request = domain.deserializeFormRequest(FormRequest.FormName.ETA, RestContext.request.requestBody.toString());
                caseRecord = submission.submitForm(request, 'SET Distribution Case');
                response.statusCode = 201;
                return String.valueOf(new SalesforceResponse(caseRecord));
            } else if(caseType=='void-for-trade'){
                request = domain.deserializeFormRequest(FormRequest.FormName.VOID_FOR_TRADE, RestContext.request.requestBody.toString());
                caseRecord = submission.submitForm(request, 'SET Distribution Case');
                response.statusCode = 201;
                return String.valueOf(new SalesforceResponse(caseRecord));
            }else if(caseType=='sold-order'){
                request = domain.deserializeFormRequest(FormRequest.FormName.SOLD_ORDER, RestContext.request.requestBody.toString());
                caseRecord = submission.submitForm(request, 'SET Distribution Case');
                response.statusCode = 201;
                List<ContentVersion> cVersinLst=New List<ContentVersion>();
                ContentVersion buyerOrder = new ContentVersion();
                buyerOrder.PathOnClient = request.buyersOrderFileName;//File name with extention
                buyerOrder.Title = request.buyersOrderFileName.substringBefore('.');//Name of the file
                buyerOrder.VersionData = EncodingUtil.base64Decode(request.buyerOrderVersionData);//File content
                cVersinLst.add(buyerOrder);
                ContentVersion license = new ContentVersion();
                license.PathOnClient = request.driverLicenseFileName;//File name with extention
                license.Title = request.driverLicenseFileName.substringBefore('.');//Name of the file
                license.VersionData = EncodingUtil.base64Decode(request.driverLicenseVersionData);//File content
                cVersinLst.add(license);
                Insert cVersinLst;
                //After saved the Content Verison, get the ContentDocumentId
                List<ContentVersion> conDocIdLst = [SELECT ContentDocumentId FROM 
                                                    ContentVersion WHERE Id IN:cVersinLst];
                
                //Insert ContentDocumentLink
                List<ContentDocumentLink> cDocLinkLst=New List<ContentDocumentLink>();
                For(ContentVersion cvId:conDocIdLst){
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = cvId.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = caseRecord.Id;//Add attachment parentId
                    cDocLinkLst.add(cDocLink);
                }
                
                Insert cDocLinkLst;
                
                return String.valueOf(new SalesforceResponse(caseRecord));
            }else{
                response.statusCode = 500;
                insert new API_Error_Log__c(Exception_Type__c = 'Incorrect Form Name', Error_Message__c = 'Incorrect/Blank Form Name is,'+' '+caseType+ 'please review your request or contact support.');
                return String.valueOf(new SalesforceResponse(false, 'Incorrect Form Name'));
            }
            
            
        } catch(avs_ResourceException e) {
            response.statusCode = 400;
            insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());
            return String.valueOf(new SalesforceResponse(false, e.getErrorMessage()));
        } catch(Exception e) {
            response.statusCode = 500;
            insert new API_Error_Log__c(Exception_Type__c = e.getTypeName(), Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString());
            return String.valueOf(new SalesforceResponse(false, e.getMessage()));
        }
    }
    
    public class SalesforceResponse {
        Boolean success { get; set; }
        String message { get; set; }
        String caseRecord { get; set; }
        
        public SalesforceResponse(Case caseRecord) {
            this.success = true;
            this.caseRecord = String.valueOf(caseRecord);
        }
        
        public SalesforceResponse(Boolean isSuccessful, String message) {
            this.success = isSuccessful;
            this.message = message;
        }
    }
}