/* Name:  FormRequestDomain
Created By:  Neha Agrawal
Created Date:  2020-02-28
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-03-17
Description:   
*/

public class FormRequestDomain {

	public FormRequest deserializeFormRequest(FormRequest.FormName formName, String jsonRequest) {
		String data = jsonRequest.trim();
		
		FormRequest request;
		try {
			request = (FormRequest)JSON.deserializeStrict(data, FormRequest.class);
			request.formType = formName;
		} catch(Exception e) {
			throw new InvalidRequestException('Invalid json request');
		}
		return request;
	}
	
	public class InvalidRequestException extends Exception { }
}