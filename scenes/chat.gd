extends Node

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$ChatEntry.text_submitted.connect(func(new_text: String):
		
		send_message.rpc(new_text, Network.local_username)
		
		$ChatEntry.text = ""
	)

@rpc("any_peer", "call_remote", "reliable", 0)
func register_id_to_username(id: int, username: String):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	send_message(username + " joined")
	Network.id_to_username.set(id, username)

func deregister_id(id: int):
	
	send_message(Network.id_to_username.get(id) + " left")
	Network.id_to_username.erase(id)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(msg: String, username: String = ""):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	if username:
		$ChatMessages.text += "\n[color=gray]<" + username + ">[/color] " + msg
	else:
		$ChatMessages.text += "\n[color=yellow]" + msg + "[/color]"
