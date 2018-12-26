--[[---------------------------------------------------------------------------
Prop Protection
---------------------------------------------------------------------------]]

--------------------
//  Prop Blacklist
--------------------
local function OsirisSaveConfig()
    local t = {}
    for k, v in pairs(OSIRIS_CONFIG) do
        if k ~= "PropBlacklistModels" and k ~= "ConfigAccess" then
            t[k] = v
        end
    end
    file.Write("osiris_config.txt", util.TableToJSON(t))
end

local function HasConfigAccess(ply)
    if !table.HasValue( OSIRIS_CONFIG.ConfigAccess, ply:GetUserGroup() ) then
        net.Start( "AccessDenied" )
        net.Send( ply )
        return false
    end
    return true
end

util.AddNetworkString("OsirisGroupRestrict")
util.AddNetworkString("OsirisToolRestrict")
util.AddNetworkString("OsirisPropLimit")
util.AddNetworkString("OsirisMessage")

net.Receive("OsirisGroupRestrict", function(len, ply)
    if not HasConfigAccess(ply) then return end

    local group, limit = net.ReadString(), net.ReadDouble()
    if group ~= "__request__" then
        if limit ~= -360 then
            OSIRIS_CONFIG.GroupLimits[group] = limit
        else
            OSIRIS_CONFIG.GroupLimits[group] = nil
        end
        OsirisSaveConfig()
    end

    net.Start("OsirisGroupRestrict")
        net.WriteTable(OSIRIS_CONFIG.GroupLimits)
    net.Send(ply)
    hook.Call("OsirisConfigChanged")
end)

net.Receive("OsirisToolRestrict", function(len,ply)
    if not HasConfigAccess(ply) then return end

    local group, tool = net.ReadString(), net.ReadString()
    if group ~= "__request__" then
        local addrem = net.ReadBool()
        if not OSIRIS_CONFIG.ToolRestrictions[group] then OSIRIS_CONFIG.ToolRestrictions[group] = {} end

        if addrem then
            OSIRIS_CONFIG.ToolRestrictions[group][tool] = true
        else
            OSIRIS_CONFIG.ToolRestrictions[group][tool] = nil
        end
        OsirisSaveConfig()
    end
    net.Start("OsirisToolRestrict")
        net.WriteTable(OSIRIS_CONFIG.ToolRestrictions)
    net.Send(ply)
    hook.Call("OsirisConfigChanged")
end)

hook.Add("PlayerAuthed", "OsirisNetworking", function(ply)
    net.Start("OsirisConfigVar")
        net.WriteString("OsirisSeeOwner")
        net.WriteType(OSIRIS_CONFIG.OsirisSeeOwner)
    net.Send(ply)
    net.Start("OsirisConfigVar")
        net.WriteString("OsirisTouchWorld")
        net.WriteType(OSIRIS_CONFIG.OsirisTouchWorld)
    net.Send(ply)
end)

util.AddNetworkString("PropBlacklist")
util.AddNetworkString("GetPropBlacklist")
util.AddNetworkString("ModifyPropBlacklist")
util.AddNetworkString("OsirisConfigVar")

hook.Add("PlayerSpawnProp", "OsirisPropLimit", function(ply, model)
    if OSIRIS_CONFIG.GroupRestrictions and OSIRIS_CONFIG.GroupLimits[ply:GetUserGroup()] and OSIRIS_CONFIG.GroupLimits[ply:GetUserGroup()] >= 0 and ply:GetCount("props") >= OSIRIS_CONFIG.GroupLimits[ply:GetUserGroup()] then
        net.Start("OsirisPropLimit")
            net.WriteDouble(OSIRIS_CONFIG.GroupLimits[ply:GetUserGroup()])
        net.Send(ply)
        return false
    end
end)

hook.Add("PlayerSpawnProp", "OsirisPropBlacklist", function(ply, mdl)
	if OSIRIS_CONFIG.BlacklistEnabled and OSIRIS_CONFIG.PropBlacklistModels[string.lower(mdl)] then
		net.Start("PropBlacklist")
        net.Send(ply)
        return false
    end
end)

net.Receive("GetPropBlacklist", function(l, ply)
    if not HasConfigAccess(ply) then return end
    net.Start("OsirisConfig")
        net.WriteTable(OSIRIS_CONFIG)
    net.Send(ply)
--[[
    local cached_blacklist = table.GetKeys(OSIRIS_CONFIG.PropBlacklistModels)

    local size = #cached_blacklist
    local blocks = math.ceil(size / 100)
    for I=1, blocks do
        net.Start("GetPropBlacklist")
            net.WriteUInt(I, 32)
            net.WriteUInt(blocks, 32)
            local Y = 0
            for Y=(I-1)*100+1, (I+1)*100 do
                local str = cached_blacklist[Y]
                if not str then break end
                if str == "" then continue end -- would break sending

                net.WriteString(str)
            end
        net.Send(ply)
    end
    ]]--
end)

net.Receive("ModifyPropBlacklist", function(l, ply)
    local action = net.ReadUInt(8)

    if action == 0 then -- remove
        if not HasConfigAccess() then return end
        local mdl = net.ReadString()
        OSIRIS_CONFIG.PropBlacklistModels[mdl] = nil
        timer.Create("OSIRIS_BLACKLIST_SAVE", 30, 1, function()
            if not file.Exists("osiris_blacklist.txt", "DATA") then file.Write("osiris_blacklist.txt", "") end
            local f = file.Open("osiris_blacklist.txt", "wb", "DATA")
            for k, v in pairs(OSIRIS_CONFIG.PropBlacklistModels) do
                f:Write(k)
                f:Write("\n")
            end
            f:Close()
        end)
        hook.Call("OsirisConfigChanged")
    end
end)

--------------------
//      Config
--------------------

hook.Add("ShutDown", "OsirisSaveConfig", function()
    if not file.Exists("osiris_blacklist.txt", "DATA") then file.Write("osiris_blacklist.txt", "") end
    local f = file.Open("osiris_blacklist.txt", "wb", "DATA")
    for k, v in pairs(OSIRIS_CONFIG.PropBlacklistModels) do
        f:Write(string.lower(k))
        f:Write("\n")
    end
    f:Close()

    OsirisSaveConfig()
    Msg("Osiris config saved\n")
end)

util.AddNetworkString("OsirisConfig")

net.Receive("OsirisConfig", function(l, ply)
    if not HasConfigAccess(ply) then return end

    local var = net.ReadString()

    OSIRIS_CONFIG[var] = net.ReadType()

    if var == "OsirisSeeOwner" then
        net.Start("OsirisConfigVar")
            net.WriteString(var)
            net.WriteType(OSIRIS_CONFIG[var])
        net.Broadcast()
    elseif var == "OsirisTouchWorld" then
        net.Start("OsirisConfigVar")
            net.WriteString(var)
            net.WriteType(OSIRIS_CONFIG.OsirisTouchWorld)
        net.Send(ply)
    end

    timer.Create("OSIRIS_SAVE_CONFIG", 2, 1, function()
        OsirisSaveConfig()
    end)

    hook.Call("OsirisConfigChanged")
end)

--------------------
//   Prop Count
--------------------

--{ Antispam }--

util.AddNetworkString("PropCoolDownStart")
util.AddNetworkString("PlayerSpaming")
util.AddNetworkString("PropCoolDownOver")

local function AntiSpam(ply, ent, isdupe)
    if not OSIRIS_CONFIG.AntiSpam or isdupe then return end

    ply.PropsSpawned = (ply.PropsSpawned or 0) + 1

    timer.Create("Osiris_Antispam_" .. ply:SteamID(), 12, 1, function()
        ply.PropsSpawned = 0
    end)

    if ply.PropsSpawned >= 24 and not ply.OnTimer then
        net.Start("PropCoolDownStart")
        net.Send(ply)
        net.Start("PlayerSpaming")
        net.WriteEntity( ply )
        net.Broadcast()
        ply.OnTimer = true
        timer.Simple(30, function()
            ply.OnTimer = false
            net.Start("PropCoolDownOver")
            net.Send(ply)
        end)
    end

    if ply.OnTimer then
        if OSIRIS_CONFIG.AS_Delete_All then
            for _,ent in pairs(ents.FindByClass("prop_physics")) do
                if (ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()) == ply then ent:Remove() end
            end
        end
        ent:Remove()
        return false
    end
end

OSIRIS_CLEANUP_ADD = OSIRIS_CLEANUP_ADD or cleanup.Add

function cleanup.Add(ply, type, ent)
    if not IsValid(ply) or not IsValid(ent) then return OSIRIS_CLEANUP_ADD(ply, type, ent) end

    if OSIRIS_CONFIG.AntiSpam and type ~= "constraints" and type ~= "stacks" and type ~= "AdvDupe2" and (not ent.IsVehicle or not ent:IsVehicle()) and ent:GetClass() == "prop_physics" then
        AntiSpam(ply, ent, type == "duplicates")
    end
    return OSIRIS_CLEANUP_ADD(ply, type, ent)
end

--------------------
//  Prop Spawning
--------------------

local function GhostProp( ent )
    if not OSIRIS_CONFIG.Ghosting then return end
	if not ent:GetClass() == "prop_physics" then return end
    ent.OldColor = ent.OldColor or ent:GetColor()
    ent.OldCGroup = ent.OldCGroup or ent:GetCollisionGroup()
    local phy = ent:GetPhysicsObject()
    if IsValid(phy) then
        ent.OldMotion = ent.OldMotion or phy:IsMotionEnabled()
    end

    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, 190 ))
    ent.ghosted = true
    ent:GetPhysicsObject():EnableMotion(false)
end

local function UnGhostProp( ent )
    if not OSIRIS_CONFIG.Ghosting then return end
	if not ent:GetClass() == "prop_physics" then return end
    if ent.OldColor then
        ent:SetColor(ent.OldColor)
        ent.OldColor = nil
    end

    if ent.OldCGroup then
        ent:SetCollisionGroup(ent.OldCGroup)
        ent.OldCGroup = nil
    end

    ent.ghosted = nil
end

--{ Prop Spawned }--

util.AddNetworkString("PlayerCloseMsg")

hook.Add("PlayerSpawnedProp", "OsirisPropGhosting", function(ply, model, ent)
    if OSIRIS_CONFIG.BlacklistEnabled and OSIRIS_CONFIG.PropBlacklistModels[ model ] then
        ent:Remove()
        return
    end
    if OSIRIS_CONFIG.Ghosting then
        for _,v in pairs(ents.GetAll()) do

            if v:IsVehicle() and ent:GetPos():DistToSqr( v:GetPos() ) < 6400  then
                GhostProp(ent)
                return
            end
        end

        for _, v in pairs(player.GetAll()) do
            if not v:Alive() or not v:GetPhysicsObject():IsCollisionEnabled() then continue end -- nobody cares about dead/noclippers
            if v:GetPos():DistToSqr( ent:GetPos() ) < 6400  then
                GhostProp(ent)
                net.Start("PlayerCloseMsg")
                net.Send(ply)
                return
            end
        end
        ent:GetPhysicsObject():EnableMotion(false)
    end
end)

--{ Prop Unfreezing }--

hook.Add("CanPlayerUnfreeze", "OsirisUnfreeze", function(ply, ent, phys)
    if OSIRIS_CONFIG.Unfreeze then
        return false
    end
end)

--------------------
//   Car Spawning
--------------------

--{ Car No Collide with Players }--

hook.Add("OnEntityCreated", "OsirisCarNoCollide", function(ent)
    if OSIRIS_CONFIG.VehicleNocollide and ent:IsVehicle() then
        timer.Simple(0, function()
	       ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end)
    end
end)

--------------------
// Physgun Ghosting
--------------------

--{ Physgun Pickup }--

hook.Add("PhysgunPickup", "OsirisNoCollideOnPickup", function(ply, ent)
	if ent:IsPlayer() then
		return
	end
	if ent:IsNPC()  then
		return
	end

	if string.find(ent:GetClass(), "door")  then
		return
	end

	if ent:IsVehicle() then
        if OSIRIS_CONFIG.VehicleNocollide then
            ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end

        return
    end

    GhostProp(ent)
end)

--{ Freeze Prop and No Collide In Player and Car }--

util.AddNetworkString("FreezeInPlayerMsg")

hook.Add("PhysgunDrop", "OsirisNoCollideNearPlayer", function(ply, ent)
    if OSIRIS_CONFIG.VehicleNocollide and ent:IsVehicle() then
        return ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

	if ent:IsPlayer() then
        return
    end

	if OSIRIS_CONFIG.BlacklistEnabled and OSIRIS_CONFIG.PropBlacklistModels[ent:GetModel()] then
		return
	end

    if OSIRIS_CONFIG.Ghosting then
        for _,v in pairs(ents.GetAll()) do
            if v:IsVehicle() and ent:GetPos():DistToSqr( v:GetPos() ) < 6400 then
                return GhostProp(ent)
            end
        end

		for _, v in pairs(player.GetAll()) do
            if v:GetPos():DistToSqr( ent:GetPos() ) < 6400 then
                GhostProp(ent)
                net.Start("FreezeInPlayerMsg")
                net.Send(ply)
                return
            end
        end

        if ent.ghosted then UnGhostProp(ent) end
    end

    if OSIRIS_CONFIG.PhysgunDropFreeze then
        ent:GetPhysicsObject():EnableMotion(false)
    end
end)


hook.Add("PlayerDisconnected", "OsirisRemoveLeavers", function(ply)
    if OSIRIS_CONFIG.RemovePlayerLeave or OSIRIS_CONFIG.RemovePlayerLeave < 0 then return end
    local sid = ply:SteamID()

    timer.Create("osiris_remove_leaver_" .. sid, OSIRIS_CONFIG.RemovePlayerLeave, 1, function()
        if not IsValid(player.GetBySteamID(sid)) then
            for k, v in pairs(ents.GetAll()) do
                if not IsValid(v) then continue end
                local owner, id = v:CPPIGetOwner()
                if owner == nil and id == sid then
                    v:Remove()
                end
            end
        end
    end)
end)
