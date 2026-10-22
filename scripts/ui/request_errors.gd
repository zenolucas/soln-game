class_name RequestErrors
extends RefCounted
## Plain-language messages for failed HTTP requests, shown to students instead of
## printing to the console.

static func describe(result: int, response_code: int, host: String) -> String:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			if response_code == 401:
				return "Your login has expired. Log in again."
			return "The server answered with an error (code %d). Try again." % response_code
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "Can't find the server at %s. Check the address." % host
		HTTPRequest.RESULT_CANT_CONNECT, HTTPRequest.RESULT_CONNECTION_ERROR, HTTPRequest.RESULT_NO_RESPONSE:
			return "Can't reach the server at %s. Check the address and your connection." % host
		HTTPRequest.RESULT_TIMEOUT:
			return "The server took too long to answer. Try again."
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "Couldn't make a secure connection to the server at %s." % host
		_:
			return "Couldn't reach the server (error %d). Try again." % result

## True when the request worked and the server answered 200.
static func ok(result: int, response_code: int) -> bool:
	return result == HTTPRequest.RESULT_SUCCESS and response_code == 200
