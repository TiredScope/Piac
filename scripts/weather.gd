extends Node

@onready var weather: Label = $MarginContainer/VBoxContainer/WetterIcon
@onready var temp: Label = %OutTemp

func _ready() -> void:
	# Create an HTTP request node and connect its completion signal.
	var time: Dictionary  = Time.get_time_dict_from_system()

	print(time) # {day:X, dst:False, hour:xx, minute:xx, month:xx, second:xx, weekday:x, year:xxxx}
	print("%02d:%02d:%02d" % [time.hour, time.minute, time.second])
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var lat: float = 49.9323655
	var lon: float = 11.5882801 
	
	var error : Error = http_request.request("https://api.brightsky.dev/current_weather?lat=%f&lon=%f"%[lat, lon])
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		print(error_string(error))

# Called when the HTTP request is completed.
func _http_request_completed(_result:int, _response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void:
	var json : JSON = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response:Variant = json.get_data()
	temp.text = str(response.weather.temperature)
	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(body.get_string_from_utf8())
	
	
