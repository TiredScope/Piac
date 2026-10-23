extends Node

func _ready() -> void:
	# Create an HTTP request node and connect its completion signal.
	var time: Dictionary  = Time.get_time_dict_from_system()

	print(time) # {day:X, dst:False, hour:xx, minute:xx, month:xx, second:xx, weekday:x, year:xxxx}
	print("%02d:%02d:%02d" % [time.hour, time.minute, time.second])
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var error : Error = http_request.request("https://httpbin.org/get")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		print(error_string(error))
	
	# New Stuff
	var error_2: Error = http_request.request("https://brightsky.dev/current_weather?wmo_station_id", )

# Called when the HTTP request is completed.
func _http_request_completed(_result:int, _response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void:
	var json : JSON = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response:Variant = json.get_data()

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(response.headers["User-Agent"])
	
