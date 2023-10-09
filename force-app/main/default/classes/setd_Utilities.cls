/* Name:  setd_Utilities
Created By:  SET Salesforce System Admin
Created Date:  2019-10-16
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class setd_Utilities {

	public String getFieldValue(SObject record, String fieldName) {
		String fieldValue;
		if (record != null) {
			String value = String.valueOf(record.get(fieldName));
			if (value != null) {
				if (fieldName == 'Phone') {
					value = formatPhoneNumber(value);
				}
				fieldValue = value;
			}
		}
		return fieldValue;
	}
	
	public String formatPhoneNumber(String phoneNumber) {
		return phoneNumber.replaceAll('[^0-9]', '');
	}
}