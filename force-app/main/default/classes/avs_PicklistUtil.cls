/* Name:  avs_PicklistUtil
Created By:  SET Salesforce System Admin
Created Date:  2019-10-16
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class avs_PicklistUtil {

	public List<PicklistValue> getPicklistValues(String sobjectName, String fieldName) {
		PicklistWrapper wrapper = new PicklistWrapper(Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues());
		return wrapper.values;
	}

	public List<PicklistValue> getPicklistValuesByRecordType(String sobjectName, String fieldName, String recordTypeName) {
		String recordTypeId = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		String endpoint = Url.getOrgDomainUrl().toExternalForm() + '/services/data/v44.0/ui-api/object-info/' + sobjectName + '/picklist-values/' + recordTypeId + '/' + fieldName;

		HttpCalloutService service = new HttpCalloutService();
		HttpResponse response = service.get(endpoint, new Map<String, String> { 'Authorization' => 'Bearer ' + UserInfo.getSessionId() });
		PicklistWrapper wrapper = (PicklistWrapper) JSON.deserialize(response.getBody(), PicklistWrapper.class);
		return wrapper.values;
	}

	public class PicklistWrapper {
		public List<PicklistValue> values { get; set; }

		public PicklistWrapper(List<Schema.PicklistEntry> picklistEntries) {
			List<SelectOption> options = createSelectOptions(picklistEntries);
			options.sort();
			this.values = new List<PicklistValue> ();
			for(SelectOption option : options) {
				this.values.add(new PicklistValue(option.getValue(), option.getLabel()));
			}
		}

		public PicklistWrapper(List<SelectOption> options) {
			options.sort();
			this.values = new List<PicklistValue> ();
			for(SelectOption option : options) {
				this.values.add(new PicklistValue(option.getValue(), option.getLabel()));
			}
		}

		private List<SelectOption> createSelectOptions(List<Schema.PicklistEntry> picklistEntries) {
			List<SelectOption> options = new List<SelectOption> ();
			for (Schema.PicklistEntry entry : picklistEntries) {
				options.add(new SelectOption(entry.getValue(), entry.getLabel()));
			}
			return options;
		}
	}

	public class PicklistValue {
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public String label { get; set; }

		public PicklistValue(String value, String label) {
			this.value = value;
			this.label = label;
		}
	}
}