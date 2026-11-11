extends Node
class_name Server

func _enter_tree() -> void:
	
	if Network.server.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		# no local server
		queue_free()
		return
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.server
	
	api.peer_connected.connect(_on_peer_connected)
	api.peer_disconnected.connect(_on_peer_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	get_tree().set_multiplayer(api, get_path())

func _on_peer_connected(_id: int):
	pass

func _on_peer_disconnected(_id: int):
	pass

# need to consume RPCs clients send between each other even if we do nothing with them
@rpc("any_peer", "call_local", "reliable", 0)
func send_message(_msg: String, _is_system_msg: bool):
	pass

@rpc("any_peer", "call_local", "reliable", 0)
func spawn_player(_username: String):
	pass
