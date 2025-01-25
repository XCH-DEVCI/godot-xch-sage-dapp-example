extends Control

var _is_wallet_connected = false
var _callback_chainId = JavaScriptBridge.create_callback(_on_receive_chainId)
var _callback_nfts = JavaScriptBridge.create_callback(_on_receive_nfts)
var network = null
var http_request: HTTPRequest
var backpack = {}
var window = JavaScriptBridge.get_interface("window")
var console = JavaScriptBridge.get_interface("console")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Status/disconnect.visible = false
	$Status/disconnect.disabled = true
	_close_boxes()

func _close_boxes() -> void:
	$Game/box0_entrance.visible = false
	$Game/box1_options.visible = false
	$Game/box2_send_xch.visible = false
	$Game/box3_fetch_nft.visible = false

func _process(delta: float) -> void:
	_check_connection()

func _check_connection() -> void:
	if window:
		var _is_wallet_connect_session_exist = await window.gd_useWalletConnect("session;")
		if _is_wallet_connect_session_exist:
			var _new_connection_status = true
			if _new_connection_status != _is_wallet_connected:
				_is_wallet_connected = true
				_update_ui(_is_wallet_connected)
				window.gd_useWalletConnect("chainId;").then(_callback_chainId)
				_close_boxes()
			$Game/box1_options.visible = true
		else:
			var _new_connection_status = false
			if _new_connection_status != _is_wallet_connected:
				_is_wallet_connected = false
				_update_ui(_is_wallet_connected)
			_close_boxes()
			$Game/box0_entrance.visible = true

# Update the UI elements based on connection status
func _update_ui(connected: bool) -> void:
	var light_signal = $Status/light_signal
	var connected_style = load("res://connected_style.tres")
	var disconnected_style = load("res://disconnected_style.tres")
	if connected:
		$Status/connect.visible = false
		$Status/connect.disabled = true
		$Status/disconnect.visible = true
		$Status/disconnect.disabled = false
		light_signal.add_theme_stylebox_override("panel", connected_style)
	else:
		$Status/connect.visible = true
		$Status/connect.disabled = false
		$Status/disconnect.visible = false
		$Status/disconnect.disabled = true
		light_signal.add_theme_stylebox_override("panel", disconnected_style)

		
func _on_connect_pressed() -> void:
	if window:
		window.gd_useWalletConnect("connect;")
		console.log("Godot attempts to connect!")


func _on_disconnect_pressed() -> void:
	if window:
		window.gd_useWalletConnect("disconnect;")
		console.log("Godot attempts to disconnect!")


func _on_send_xch_pressed() -> void:
	var address = $Game/box2_send_xch/input1.text + ";" # TextEdit
	var number = str(float($Game/box2_send_xch/input2.text)/0.000000000001) + ";"
	var fee = "0;"
	var network = $Status/networkID.text + ";"
	var command = "send;" + address + number + fee + network
	var window = JavaScriptBridge.get_interface("window")
	if window:
		window.gd_useWalletConnect(command)


func _on_receive_chainId(values):
	var value = values[0]
	network = str(value)
	$Status/networkID.text = str(value)


func _on_receive_nfts(nfts):
	nfts = nfts[0]
	var json = JSON.new()
	var parse_result = json.parse_string(nfts)
	if parse_result:
		nfts = parse_result
		var id = 0
		for nft in nfts:
			id += 1
			var nft_id = nft["launcherId"]
			var img_link =  nft["dataUris"][0]
			var metadata = nft["metadataUris"][0]
			$Game/box3_fetch_nft/output.text += "THIS IS OUTPUT OF A NFTS AT " + str(id) + "\n"
			$Game/box3_fetch_nft/output.text += "NFT ID: " + str(nft_id) + "\n"
			$Game/box3_fetch_nft/output.text += "Data URI: " + str(img_link) + "\n"
			$Game/box3_fetch_nft/output.text += "Metadata URI: " + str(metadata) + "\n"
			if nft_id not in backpack:
				backpack[nft_id] = {
					"nft_id": nft_id,
					"img_link": img_link,
					"metadata": metadata
				}
				http_request = HTTPRequest.new()
				add_child(http_request)
				http_request.request_completed.connect(self._on_request_completed)
				http_request.request(img_link)
	else:
		print("Failed to parse JSON: ", json.get_error_message())


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var image = Image.new()
		if image.load_jpg_from_buffer(body) == OK or image.load_png_from_buffer(body) == OK:
			var texture = ImageTexture.create_from_image(image)
			
			# Create a new TextureRect
			var new_nft = TextureRect.new()
			new_nft.texture = texture
			
			# Set size and stretch mode
			# new_nft.stretch_mode = TextureRect.STRETCH_SCALE
			new_nft.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
			
			# Add the new TextureRect to the HBoxContainer
			$Game/box3_fetch_nft/nft_container/nft_display.add_child(new_nft)
		else:
			print("Failed to load image from buffer.")
	else:
		print("Failed to load image, response code: {response_code}")


func _on_go_to_box_2_pressed() -> void:
	_close_boxes()
	$Game/box1_options.visible = true
	$Game/box2_send_xch.visible = true


func _on_go_to_box_3_pressed() -> void:
	_close_boxes()
	$Game/box1_options.visible = true
	$Game/box3_fetch_nft.visible = true
	var window = JavaScriptBridge.get_interface("window")
	if window:
		window.gd_useWalletConnect("fetch_nfts;").then(_callback_nfts)
