--[[---------------------------------------------------------------------------
Config UI
---------------------------------------------------------------------------]]

util.AddNetworkString("Osiris_Config_UI")
util.AddNetworkString("AccessDenied")

hook.Add("PlayerSay", "Open_Osiris_Config_UI", function(ply, text)
    if (string.sub(text, 1, 7) == "!osiris") then
		if !table.HasValue( OSIRIS_CONFIG.ConfigAccess, ply:GetUserGroup() ) then
			net.Start( "AccessDenied" )
			net.Send( ply )
			return ""
		end
        net.Start("Osiris_Config_UI")
        net.Send(ply)
        return ""
    end
end)