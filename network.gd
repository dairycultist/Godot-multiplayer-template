extends Node

# This script provides helpers for hosting, joining, and leaving a server.

# To get information about the network connection, use the "multiplayer"
# property local to a given node (since one Network can have both a client
# and server with different network connection properties).
# For example, "multiplayer.is_server()" and "multiplayer.get_unique_id()"

# To get information about the network game logic, use "Network.server_node"
# and "Network.client_node".
# For example, "Network.client_node.local_username"

var server := ENetMultiplayerPeer.new()
var client := ENetMultiplayerPeer.new()

var server_node: Server
var client_node: Client

func host_server(username: String, port: int) -> Error:

	# create a local server
	var result := server.create_server(port, 8)
	
	if result != Error.OK:
		return result
	
	# create a client to connect to the local server
	result = client.create_client("127.0.0.1", port)
	
	if result != Error.OK:
		server.close()
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	
	server_node = get_tree().current_scene.get_node("Server")
	client_node = get_tree().current_scene.get_node("Client")
	
	client_node.local_username = username
	
	return Error.OK

func join_server(username: String, address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	
	get_tree().current_scene.get_node("Server").queue_free()
	client_node = get_tree().current_scene.get_node("Client")
	
	client_node.local_username = username
	
	return Error.OK

func leave_server(reason: String = "") -> void:
	
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await get_tree().scene_changed
	
	client.close()
	server.close()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	server_node = null
	client_node = null
	
	get_tree().current_scene.get_node("DisconnectReasonLabel").text = reason
