--[[---------------------------------------------------------------------------
Property Menu Intergration
---------------------------------------------------------------------------]]
function OsirisShouldBotherEntity( ent )
    if not OSIRIS_CONFIG.EntityWhiteList then return true end
    if not IsValid(ent) then return end

    return not OSIRIS_CONFIG.EntityWhiteList[ent:GetClass()]
end
properties.Add( "blacklist", {
    MenuLabel = "Add to Blacklist",
    Order = 2000,
    MenuIcon = "icon16/world_add.png",
    PrependSpacer = true,
    Filter = function( self, ent, ply )
        return ent:GetModel() != ""
    end,

    Action = function( self, ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end,

    Receive = function( self, length, ply )

        local ent = net.ReadEntity()
        if ( !IsValid( ent ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        OSIRIS_CONFIG.PropBlacklistModels[ent:GetModel()] = true
    end

} )

properties.Add( "blacklist2", {
    MenuLabel = "Remove from Blacklist",
    Order = 2001,
    MenuIcon = "icon16/world_delete.png",

    Filter = function( self, ent, ply )
        return ent:GetModel() != ""
    end,

    Action = function( self, ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end,

    Receive = function( self, length, ply )

        local ent = net.ReadEntity()
        if ( !IsValid( ent ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        OSIRIS_CONFIG.PropBlacklistModels[ent:GetModel()] = nil
    end

} )

hook.Add("PhysgunPickup", "OsirisWorldPhysgun", function(ply, ent)
    if not OSIRIS_CONFIG or not OSIRIS_CONFIG.OsirisTouchWorld then return end
    if not OsirisShouldBotherEntity( ent ) then return end
    if IsValid(ent:CPPIGetOwner()) and (SERVER and not ent:CPPICanPhysgun(ply)) then return false end
    if IsValid(ent:CPPIGetOwner()) then return end

    if OSIRIS_CONFIG.OsirisTouchWorld == "superadmin" then
        if not ply:IsSuperAdmin() then return false end
    elseif OSIRIS_CONFIG.OsirisTouchWorld == "admin" then
        if not ply:IsAdmin() then return false end
    elseif OSIRIS_CONFIG.OsirisTouchWorld == "none" then
        return false
    end

end)

hook.Add("CanTool", "OsirisToolBlock", function(ply, tr, tool)
    if OSIRIS_CONFIG.ToolRestrictions then
        if (OSIRIS_CONFIG.ToolRestrictions[ply:GetUserGroup()] and OSIRIS_CONFIG.ToolRestrictions[ply:GetUserGroup()][tool])
           or
           (OSIRIS_CONFIG.ToolRestrictions["*"] and OSIRIS_CONFIG.ToolRestrictions["*"][tool])
           then
            if SERVER then
                net.Start("OsirisMessage")
                    net.WriteString("You cannot use \"" .. tool .. "\".")
                net.Send(ply)
            end
            return false
        end
    end
    if not OsirisShouldBotherEntity( ent ) then return end

    local owner = tr.Entity:CPPIGetOwner()
    if not IsValid(owner) then owner = tr.Entity:GetOwner() end
    if not ply:IsSuperAdmin() and ( not tr.Entity:IsWorld() and (not IsValid(owner) or not owner:IsPlayer()) ) then
        if SERVER then
            net.Start("OsirisMessage")
                net.WriteString("Only superadmins can toolgun world props.")
            net.Send(ply)
        end
        return false
    end
end)

hook.Add("GravGunPunt", "OsirisGravgunWP", function(ply, ent)
    if OSIRIS_CONFIG.GravgunWorldProps and not OsirisShouldBotherEntity( ent ) then
        if OSIRIS_CONFIG.GravgunWorldProps == "superadmin" then
            if not ply:IsSuperAdmin() then return false end
        elseif OSIRIS_CONFIG.GravgunWorldProps == "admin" then
            if not ply:IsAdmin() then return false end
        elseif OSIRIS_CONFIG.GravgunWorldProps == "none" then
            return false
        end
    end
end)
