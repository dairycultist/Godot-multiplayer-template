extends Node
class_name Client

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
			$CanvasLayer/Chat/ChatEntry.release_focus()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$EscapeMenu.visible = true
			$CanvasLayer/Chat/ChatEntry.grab_focus()

@rpc("any_peer", "call_local", "reliable", 0)
func spawn_player(id: int, username: String):
	
	var player = load("res://player/player.tscn").instantiate()
	player.name = "Player" + str(id)
	player.player_id = id
	player.player_username = username
	$Players.add_child(player, true)

func _on_peer_connected(id: int):
	
	# send our username to the newly connected user
	$CanvasLayer/Chat.register_id_to_username.rpc_id(id, multiplayer.get_unique_id(), Network.local_username)
	
	# tell them to spawn our player locally
	spawn_player.rpc_id(id, multiplayer.get_unique_id(), Network.local_username)

func _on_peer_disconnected(id: int):
	
	# forget their username
	$CanvasLayer/Chat.deregister_id(id)
	
	# despawn their player locally
	$Players.get_node("Player" + str(id)).queue_free()

func _on_connected_to_server():
	_connected = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/Chat.visible = true
	$AwaitingServerMenu.queue_free()
	
	# spawn our player locally
	spawn_player(multiplayer.get_unique_id(), Network.local_username)

func _on_connection_failed():
	Network.leave_server("Server did not respond.")

func _on_server_disconnected():
	Network.leave_server("Server shut down by itself.")
