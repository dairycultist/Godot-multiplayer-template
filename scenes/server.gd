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

@rpc("any_peer", "call_local", "reliable", 0)
func spawn_player(_id: int, _username: String):
	pass # need to consume the spawn_player that clients send to other clients

func _on_peer_connected(_id: int):
	pass

func _on_peer_disconnected(id: int):
	
	# despawn their player locally
	$Players.get_node("Player" + str(id)).queue_free()
