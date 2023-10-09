public class avs_ResourceException extends Exception {
	String name;
	String errorMessage;
	String stackTrace;
	
	public avs_ResourceException(String name, String errorMessage, String stackTrace) {
		this.name = name;
		this.errorMessage = errorMessage;
		this.stackTrace = stackTrace;
	}
	
	public String getExceptionName() {
		return this.name;
	}
	
	public String getErrorMessage() {
		return this.errorMessage;
	}
	
	public String getStackTrace() {
		return this.stackTrace;
	}
}