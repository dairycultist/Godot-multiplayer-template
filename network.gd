extends Node

# This script provides helpers for hosting, joining, and leaving a server.
# DON'T use this to get information about the network; use the local
# "multiplayer" property instead (because the host has both the server and
# the client, and this property tells you which one a given node is).

# The server and client code focus on game logic.

var server := ENetMultiplayerPeer.new()
var client := ENetMultiplayerPeer.new()

# clientside this is the local client's username
# serverside this is the host client's username
var local_username: String

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
	
	local_username = username
	
	return Error.OK

func join_server(username: String, address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/empty_networked_scene.tscn")
	await get_tree().scene_changed
	
	local_username = username
	
	return Error.OK

func leave_server(reason: String = "") -> void:
	
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await get_tree().scene_changed
	
	client.close()
	server.close()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	local_username = ""
	
	get_tree().current_scene.get_node("DisconnectReasonLabel").text = reason
