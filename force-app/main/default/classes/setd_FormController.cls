/* Name:  setd_FormController
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_FormController {
	
	@AuraEnabled
	public static Case insertForm(String formObject) {
        system.debug('formObject is '+formObject);
		setd_FormSubmission formSubmission = (setd_FormSubmission) JSON.deserializeStrict(formObject, setd_FormSubmission.class);
		return formSubmission.submitFormObject();
	}
}