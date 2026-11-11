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

func _on_peer_connected(id: int):
	
	# spawn the player
	var player = load("res://player/player.tscn").instantiate()
	
	player.name = "Player" + str(id)
	
	$Players.add_child(player, true)

func _on_peer_disconnected(id: int):
	
	# despawn the player
	$Players.get_node("Player" + str(id)).queue_free()
