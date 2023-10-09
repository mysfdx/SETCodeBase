@IsTest
private class HttpCalloutServiceTest {

	@IsTest
	private static void post_MockData_Success() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpSuccessPOSTCallout());

		HttpCalloutService testService = new HttpCalloutService();
		HttpResponse result = testService.post('post_endpoint', new Map<String, String> { 'post_header' => 'post_header' }, 'post_body');

		System.assertEquals(200, result.getStatusCode(), 'Incorrect status code was returned');
	}

	@IsTest
	private static void put_MockData_Success() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpSuccessPUTCallout());

		HttpCalloutService testService = new HttpCalloutService();
		HttpResponse result = testService.put('put_endpoint', new Map<String, String> { 'put_header' => 'put_header' }, 'put_body');

		System.assertEquals(200, result.getStatusCode(), 'Incorrect status code was returned');
	}

	@IsTest
	private static void get_MockData_Success() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpSuccessGETCallout());

		HttpCalloutService testService = new HttpCalloutService();
		HttpResponse result = testService.get('get_endpoint', new Map<String, String> { 'get_header' => 'get_header' });

		System.assertEquals(200, result.getStatusCode(), 'Incorrect status code was returned');
	}

	@IsTest
	private static void post_MockData_Error() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpErrorCallout());
		String exceptionThrown;

		try {
			HttpCalloutService testService = new HttpCalloutService();
			HttpResponse result = testService.post('post_endpoint', new Map<String, String> { 'post_header' => 'post_header' }, 'post_body');
		} catch (Exception e) {
			exceptionThrown = e.getTypeName();
		}

		System.assertNotEquals(null, exceptionThrown, 'Exception was thrown incorrectly');
		System.assertEquals('HttpCalloutService.HttpErrorStatusException', exceptionThrown, 'Exception was thrown incorrectly');
	}

	@IsTest
	private static void put_MockData_Error() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpErrorCallout());
		String exceptionThrown;

		try {
			HttpCalloutService testService = new HttpCalloutService();
			HttpResponse result = testService.put('put_endpoint', new Map<String, String> { 'put_header' => 'put_header' }, 'put_body');
		} catch (Exception e) {
			exceptionThrown = e.getTypeName();
		}

		System.assertNotEquals(null, exceptionThrown, 'Exception was thrown incorrectly');
		System.assertEquals('HttpCalloutService.HttpErrorStatusException', exceptionThrown, 'Exception was thrown incorrectly');
	}

	@IsTest
	private static void get_MockData_Error() {
		Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceTest.MockHttpErrorCallout());
		String exceptionThrown;

		try {
			HttpCalloutService testService = new HttpCalloutService();
			HttpResponse result = testService.get('get_endpoint', new Map<String, String> { 'get_header' => 'get_header' });
		} catch (Exception e) {
			exceptionThrown = e.getTypeName();
		}

		System.assertNotEquals(null, exceptionThrown, 'Exception was thrown incorrectly');
		System.assertEquals('HttpCalloutService.HttpErrorStatusException', exceptionThrown, 'Exception was thrown incorrectly');
	}

	public class MockHttpSuccessPOSTCallout implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			System.assertEquals('POST', request.getMethod(), 'Incorrect method was set on request');
			System.assertEquals('post_endpoint', request.getEndpoint(), 'Incorrect endpoint was set on request');
			System.assertEquals('post_header', request.getHeader('post_header'), 'Incorrect header was set on request');
			System.assertEquals('post_body', request.getBody(), 'Incorrect body was set on request');

			HttpResponse response = new HttpResponse();
			response.setStatusCode(200);
			return response;
		}
	}

	public class MockHttpSuccessPUTCallout implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			System.assertEquals('PUT', request.getMethod(), 'Incorrect method was set on request');
			System.assertEquals('put_endpoint', request.getEndpoint(), 'Incorrect endpoint was set on request');
			System.assertEquals('put_header', request.getHeader('put_header'), 'Incorrect header was set on request');
			System.assertEquals('put_body', request.getBody(), 'Incorrect body was set on request');

			HttpResponse response = new HttpResponse();
			response.setStatusCode(200);
			return response;
		}
	}

	public class MockHttpSuccessGETCallout implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			System.assertEquals('GET', request.getMethod(), 'Incorrect method was set on request');
			System.assertEquals('get_endpoint', request.getEndpoint(), 'Incorrect endpoint was set on request');
			System.assertEquals('get_header', request.getHeader('get_header'), 'Incorrect header was set on request');

			HttpResponse response = new HttpResponse();
			response.setBody('get_body');
			response.setStatusCode(200);
			return response;
		}
	}

	public class MockHttpErrorCallout implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = new HttpResponse();
			response.setBody('error_body');
			response.setStatusCode(404);
			return response;
		}
	}
}