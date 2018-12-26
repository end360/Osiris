--[[---------------------------------------------------------------------------
CPPI Intergration
---------------------------------------------------------------------------]]

if SERVER then AddCSLuaFile() end
CPPI = CPPI or {}
CPPI.CPPI_DEFER = 696969
CPPI.CPPI_NOTIMPLEMENTED = 69966996

function CPPI:GetName()
    return "Osiris prop protection"
end

function CPPI:GetVersion()
    return "universal.1"
end

function CPPI:GetInterfaceVersion()
    return 1.3
end

function CPPI:GetNameFromUID(uid)
    return CPPI.CPPI_NOTIMPLEMENTED
end

local PLAYER = FindMetaTable("Player")
function PLAYER:CPPIGetFriends()
    if CLIENT then return CPPI.CPPI_NOTIMPLEMENTED end
    if not self.Buddies then return CPPI.CPPI_DEFER end
    local t = {}

    for k, v in pairs(player.GetHumans()) do
        if self.Buddies[v:SteamID()] then
            t[#t+1] = v
            if #t == 64 then return t end
        end
    end

    return t
end

function PLAYER:OsirisIsFriends(ply)
    if not self.Buddies then return false end
    if not IsValid(ply) then return false end

    return self.Buddies[ply:SteamID()] ~= nil
end

function PLAYER:OsirisFriendCanDo(ply, k)
    if not self:OsirisIsFriends(ply) then return false end
    if not self.Buddies[ply:SteamID()][k] then return false end
    return true
end

local ENTITY = FindMetaTable("Entity")
ENTITY.oGetOwner = ENTITY.oGetOwner or ENTITY.GetOwner
function ENTITY:CPPIGetOwner()
    local Owner = self:GetNWEntity("cppiOwner")
    if not IsValid(Owner) or not Owner:IsPlayer() then return SERVER and Owner or nil, self:GetNWString("cppiOwnerID") end
    return Owner, Owner:UniqueID()
end

function ENTITY:GetOwner()
    local o = self:CPPIGetOwner()
    if IsValid(o) then return o end
    return self:oGetOwner()
end

if SERVER then
    function ENTITY:CPPISetOwner(ply)
        if ply == self:GetNWEntity("cppiOwner") then return end

        local valid = IsValid(ply) and ply:IsPlayer()
        local steamId = valid and ply:SteamID() or nil
        local canSetOwner = hook.Run("CPPIAssignOwnership", ply, self, valid and ply:UniqueID() or ply)

        if canSetOwner == false then return false end
        ply = canSetOwner ~= nil and canSetOwner ~= true and canSetOwner or ply
        self:SetNWEntity("cppiOwner", ply)
        self:SetNWString("cppiOwnerID", steamId)

        return true
    end

    function ENTITY:CPPISetOwnerUID(UID)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPICanTool(ply, tool)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "tool"))
    end

    function ENTITY:CPPICanPhysgun(ply)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "phys"))
    end

    function ENTITY:CPPICanPickup(ply)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "use"))
    end

    function ENTITY:CPPICanPunt(ply)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "grav"))
    end

    function ENTITY:CPPICanUse(ply)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "use"))
    end

    function ENTITY:CPPICanDamage(ply)
        local owner = self:CPPIGetOwner()
        return ply:IsSuperAdmin() or owner == ply or (IsValid(owner) and owner:IsPlayer() and owner:OsirisFriendCanDo(ply, "dng"))
    end

    function ENTITY:CPPIDrive(ply)
        return ply:IsSuperAdmin() or self:CPPIGetOwner() == ply
    end

    function ENTITY:CPPICanProperty(ply, property)
        return ply:IsSuperAdmin() or self:CPPIGetOwner() == ply
    end

    function ENTITY:CPPICanEditVariable(ply, key, val, editTbl)
        return self:CPPICanProperty(ply, "editentity")
    end

    local function SetOwnerGeneric(ply, mdl, ent)
        if not IsValid(ent) or not IsValid(ply) then return end
        ent:CPPISetOwner(ply)
    end
    local function SetOwnerGeneric2(ply, ent)
        if not IsValid(ply) or not IsValid(ent) then return end
        ent:CPPISetOwner(ply)
    end
    hook.Add("PlayerSpawnedProp", "CPPIOwnership", SetOwnerGeneric)
    hook.Add("PlayerSpawnedRagdoll", "CPPIOwnership", SetOwnerGeneric)
    hook.Add("PlayerSpawnedSENT", "CPPIOwnership", SetOwnerGeneric)
    hook.Add("PlayerSpawnedVehicle", "CPPIOwnership", SetOwnerGeneric2)
    hook.Add("PlayerSpawnedSWEP", "CPPIOwnership", SetOwnerGeneric2)
    hook.Add("PlayerSpawnedNPC", "CPPIOwnership", SetOwnerGeneric2)
    hook.Add("PlayerSpawnedEffect", "CPPIOwnership", SetOwnerGeneric)
end

if CLIENT then
    hook.Add("HUDPaint", "CPPIOwnership", function()
        if not OSIRIS_CONFIG then return end
        if not OSIRIS_CONFIG.OsirisSeeOwner then return end

        if OSIRIS_CONFIG.OsirisSeeOwner == "superadmin" then
            if not LocalPlayer():IsSuperAdmin() then return end
        elseif OSIRIS_CONFIG.OsirisSeeOwner == "admin" then
            if not LocalPlayer():IsSuperAdmin() and not LocalPlayer():IsSuperAdmin() then return end
        elseif OSIRIS_CONFIG.OsirisSeeOwner == "none" then return end


        local ent   = LocalPlayer():GetEyeTrace().Entity
        if not IsValid(ent) then return end
        local owner = ent:CPPIGetOwner()
        local str   = "world"

		if not IsValid(ent:GetOwner()) or ent:GetOwner():IsWorld() then return end
        if IsValid(owner) then
            str = owner:IsPlayer() and owner:Nick() or owner:GetClass()
        end

        surface.SetFont("HudHintTextLarge")
        surface.SetTextColor(255,255,240)
        local tw, th = surface.GetTextSize(str)

        surface.SetDrawColor(36,36,36,240)
        surface.DrawRect(ScrW() - tw-8, ScrH() * 0.4 - 4, tw + 8, th + 8)

        surface.SetTextPos(ScrW() - tw-4, ScrH() * 0.4)
        surface.DrawText(str)

    end)
end
