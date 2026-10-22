class_name RequestErrorsTest
extends GdUnitTestSuite

func test_unreachable_server_names_the_host() -> void:
	var message := RequestErrors.describe(HTTPRequest.RESULT_CANT_CONNECT, 0, "10.0.0.5")
	assert_str(message).contains("10.0.0.5")

func test_server_error_mentions_the_code() -> void:
	assert_str(RequestErrors.describe(HTTPRequest.RESULT_SUCCESS, 500, "x")).contains("500")

func test_ok_needs_success_and_200() -> void:
	assert_bool(RequestErrors.ok(HTTPRequest.RESULT_SUCCESS, 200)).is_true()
	assert_bool(RequestErrors.ok(HTTPRequest.RESULT_SUCCESS, 401)).is_false()
	assert_bool(RequestErrors.ok(HTTPRequest.RESULT_TIMEOUT, 0)).is_false()
