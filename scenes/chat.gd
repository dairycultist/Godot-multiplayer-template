extends Node

func _ready() -> void:
	
	if multiplayer.is_server():
		return
	
	$ChatEntry.text_submitted.connect(
		func(text: String):
			
			text = text.strip_edges()
			
			if text.length() != 0:
				send_message.rpc(text, false)
				$ChatEntry.text = ""
	)

@rpc("any_peer", "call_local", "reliable", 0)
func send_message(msg: String, is_system_msg: bool):
	
	if multiplayer.is_server():
		return # the server needs a node to consume the RPC
	
	if is_system_msg:
		$ChatMessages.text += "\n[color=yellow]" + msg + "[/color]"
	else:
		var sender_username = Network.client_node.id_to_username[multiplayer.get_remote_sender_id()]
		$ChatMessages.text += "\n[color=gray]<" + sender_username + ">[/color] " + msg
