extends Node
class_name Client

@export var player_scene: PackedScene

var _connected := false

var local_username: String
var id_to_username: Dictionary[int, String]

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$CanvasLayer/Chat/ChatEntry.text_submitted.connect(
		func(text: String):
			
			text = text.strip_edges()
			
			if text.length() != 0:
				send_message.rpc(text, false)
				$CanvasLayer/Chat/ChatEntry.text = ""
	)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(msg: String, is_system_msg: bool):
	
	if is_system_msg:
		$CanvasLayer/Chat/ChatMessages.text += "\n[color=yellow]" + msg + "[/color]"
	else:
		var sender_username = Network.client_node.id_to_username[multiplayer.get_remote_sender_id()]
		$CanvasLayer/Chat/ChatMessages.text += "\n[color=gray]<" + sender_username + ">[/color] " + msg

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
			$CanvasLayer/Chat/ChatEntry.release_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true
			$CanvasLayer/Chat/ChatEntry.grab_focus()

@rpc("any_peer", "call_local", "reliable", 0)
func spawn_player(username: String):
	
	var id = multiplayer.get_remote_sender_id()
	
	# spawn player
	var player = player_scene.instantiate()
	player.name = "Player" + str(id)
	player.player_id = id
	player.player_username = username
	$Players.add_child(player, true)
	
	# remember their username
	if id != multiplayer.get_unique_id():
		send_message(username + " joined", true)
	id_to_username.set(id, username)

func _on_peer_connected(id: int):
	
	# tell the newly connected user about our username and to spawn our player locally
	spawn_player.rpc_id(id, local_username)

func _on_peer_disconnected(id: int):
	
	# forget their username
	send_message(id_to_username.get(id) + " left", true)
	id_to_username.erase(id)
	
	# despawn their player locally
	$Players.get_node("Player" + str(id)).queue_free()

func _on_connected_to_server():
	_connected = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/Chat.visible = true
	$AwaitingServerMenu.queue_free()
	
	# spawn our player locally
	spawn_player.rpc_id(multiplayer.get_unique_id(), local_username)

func _on_connection_failed():
	Network.leave_server("Server did not respond.")

func _on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
