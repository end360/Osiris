--[[---------------------------------------------------------------------------
Prop Protection
---------------------------------------------------------------------------]]

net.Receive("PropBlacklist", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "This prop is on the blacklist!" )
end)

net.Receive("PropCoolDownStart", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "You are thought to have been spaming! A temporary cooldown has been put in place on your prop spawning!" )
end)

net.Receive("PlayerSpaming", function()
	local ply = net.ReadEntity()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), string.format( "A player is thought to have been caught spamming! Their name is: ".."%s!", ply:Name() ) )
end)

net.Receive("PropCoolDownOver", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "Your prop spawn cooldown has ended." )
end)

net.Receive("PlayerCloseMsg", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "Your prop was spawned too close to a player!" )
end)

net.Receive("FreezeInPlayerMsg", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "Your prop was frozen too close to a player!" )
end)

net.Receive("AccessDenied", function()
	chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "You do not have access to do this!" )
end)

net.Receive("OsirisPropLimit", function()
    chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), "You've hit your prop limit! (" .. net.ReadDouble() .. ")" )
end)

net.Receive("OsirisMessage", function()
    chat.AddText( Color( 200, 0, 0 ), "| ", Color( 175, 175, 175 ), net.ReadString() )
end)
