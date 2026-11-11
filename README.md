# pvp-shooter

Multiplayer game made in Godot.

basically a gmod clone (customize the game experience before creating the server)

debug texture https://mindlessdev.itch.io/prototypegrid

sky https://godotengine.org/asset-library/asset/579

a tiling (as opposed to rigidbody) structure system would be cool so it's easy to make forts and mazes (client RPCs server to spawn it)

remember the send message RPC can lookup the sender's ID rather than have the username parameter, and the register_username_for_id doesn't need an id parameter similarly

generic architecture to reference https://x.com/ArkaSerezh/status/2107486316518912415?s=20

## Setting up a server

If you don't want to configure your router to port forward, you can use playit.gg.
You should set up your playit.gg tunnel to forward to the local address/port
`127.0.0.1:19132`. Then, you give other people the address/port of your playit.gg
tunnel to connect to.

---

https://fixvx.com/RoUtilityNews/status/2112958707353133472

my multiplayer thing could lowk surpass roblox...

like when you create a server you can paste in code

can't use custom assets, but spawning built-in assets would be possible
