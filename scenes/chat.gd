extends Node

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$ChatEntry.text_submitted.connect(func(new_text: String):
		
		send_message.rpc(new_text, false)
		$ChatEntry.text = ""
	)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(msg: String, is_system_message: bool):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	if is_system_message:
		$ChatMessages.text += "\n[color=yellow]" + msg + "[/color]"
	else:
		var sender_username = Network.client_node.id_to_username[multiplayer.get_remote_sender_id()]
		$ChatMessages.text += "\n[color=gray]<" + sender_username + ">[/color] " + msg
