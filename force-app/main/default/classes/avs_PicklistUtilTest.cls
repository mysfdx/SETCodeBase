@IsTest
private class avs_PicklistUtilTest {

	@IsTest
	private static void getPicklistValues_MockSetup_OrderedList() {
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		List<avs_PicklistUtil.PicklistValue> picklistResults = utilities.getPicklistValues('Case', 'Status');

		System.assert(!picklistResults.isEmpty(), 'Incorrect number of picklist values was returned');
	}

	@IsTest
	private static void getPicklistValuesByRecordType_MockCallout_3PickListEntries() {
		Test.setMock(HttpCalloutMock.class, new avs_PicklistUtilTest.MockSuccessfulHttpCallout());
		avs_PicklistUtil utilities = new avs_PicklistUtil();
		List<avs_PicklistUtil.PicklistValue> picklistResults = utilities.getPicklistValuesByRecordType('Case', 'Status', 'Case');

		System.assertEquals(3, picklistResults.size(), 'Incorrect number of picklist entries were returned');
		System.assertEquals('label A', picklistResults.get(0).label, 'Incorrect picklist order was returned');
		System.assertEquals('label B', picklistResults.get(1).label, 'Incorrect picklist order was returned');
		System.assertEquals('label C', picklistResults.get(2).label, 'Incorrect picklist order was returned');
	}

	public class MockSuccessfulHttpCallout implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			System.assertEquals('GET', request.getMethod(), 'Request had method set incorrectly');
			System.assertEquals(true, request.getHeader('Authorization').startsWith('Bearer '), 'Header was set incorrectly');

			HttpResponse response = new HttpResponse();
			response.setBody('{"values":[{"label":"label A","value":"value1"},{"label":"label B","value":"value2"},{"label":"label C","value":"value3"}]}');
			response.setStatusCode(200);
			return response;
		}
	}
}