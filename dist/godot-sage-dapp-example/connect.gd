# Javascript Bridge based on:
# https://docs.godotengine.org/en/stable/tutorials/platform/web/javascript_bridge.html#doc-web-javascript-bridge

extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_pressed() -> void:
	var window = JavaScriptBridge.get_interface("window")
	if window:
		window.gd_useWalletConnect("connect")
