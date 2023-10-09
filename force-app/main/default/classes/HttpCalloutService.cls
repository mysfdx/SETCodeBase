/* Name:  HttpCalloutService
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class HttpCalloutService {

	Http http;

	public HttpCalloutService() {
		this.http = new Http();
	}

	public HttpResponse put(String endpoint, Map<String, String> headers, String body) {
		HttpRequest request = buildHttpRequest('PUT', endpoint, headers, body);
		return sendHttpRequest(request);
	}

	public HttpResponse post(String endpoint, Map<String, String> headers, String body) {
		HttpRequest request = buildHttpRequest('POST', endpoint, headers, body);
		return sendHttpRequest(request);
	}

	public HttpResponse get(String endpoint, Map<String, String> headers) {
		HttpRequest request = buildHttpRequest('GET', endpoint, headers, null);
		return sendHttpRequest(request);
	}

	private HttpRequest buildHttpRequest(String methodType, String endpoint, Map<String, String> headers, String body) {
		HttpRequest request = new HttpRequest();
		request.setMethod(methodType);
		request.setEndpoint(endpoint);
		for (String key : headers.keySet()) {
			request.setHeader(key, headers.get(key));
		}
		if (String.isNotBlank(body)) {
			request.setBody(body);
		}
		return request;
	}

	private HttpResponse sendHttpRequest(HttpRequest request) {
		HttpResponse response = this.http.send(request);
		if (response.getStatusCode() >= 300) {
			throw new HttpErrorStatusException('Error ' + String.valueOf(response.getStatusCode()) +' : ' + response.getStatus() + '; ' + response.getBody());
		}
		return response;
	}

	public class HttpErrorStatusException extends Exception { }
}