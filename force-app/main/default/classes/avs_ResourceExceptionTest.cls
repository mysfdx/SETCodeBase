@IsTest
private class avs_ResourceExceptionTest {

	@IsTest
	private static void constructor_MockException() {
		avs_ResourceException testException = new avs_ResourceException('type', 'error', 'stacktrace');
		
		System.assertEquals('type', testException.getExceptionName(), 'Incorrect type returned');
		System.assertEquals('error', testException.getErrorMessage(), 'Incorrect error returned');
		System.assertEquals('stacktrace', testException.getStackTrace(), 'Incorrect stacktrace string returned');
	}
}