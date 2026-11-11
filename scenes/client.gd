extends Node
class_name Client

var username: String
var _connected := false

func _enter_tree() -> void:
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.client
	
	api.peer_connected.connect(_on_peer_connected)
	api.peer_disconnected.connect(_on_peer_disconnected)
	api.connected_to_server.connect(_on_connected_to_server)
	api.connection_failed.connect(_on_connection_failed)
	api.server_disconnected.connect(_on_server_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	get_tree().set_multiplayer(api, get_path())

func _process(_delta: float) -> void:
	
	if not _connected:
		return
	
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$EscapeMenu.visible = false
			$Chat/ChatEntry.release_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true
			$Chat/ChatEntry.grab_focus()

func _on_peer_connected(id: int):
	
	# send our username to the newly connected user
	$Chat.register_id_to_username.rpc_id(id, multiplayer.get_unique_id(), username)

func _on_peer_disconnected(id: int):
	$Chat.deregister_id(id)

func _on_connected_to_server():
	_connected = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Chat.visible = true
	$AwaitingServerMenu.queue_free()

func _on_connection_failed():
	Network.leave_server("Server did not respond.")

func _on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
