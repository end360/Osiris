--[[
   ____                    __   _
  / ___|   ___    _ __    / _| (_)   __ _
 | |      / _ \  | '_ \  | |_  | |  / _` |
 | |___  | (_) | | | | | |  _| | | | (_| |
  \____|  \___/  |_| |_| |_|   |_|  \__, |
                                    |___/
]]--

OSIRIS_CONFIG = {}

--[[

Example of Config Access Config:

OSIRIS_CONFIG.ConfigAccess = { "superadmin" }

]]

OSIRIS_CONFIG.ConfigAccess = { "superadmin" }

-- Edit this with the ingame config, otherwise they may not save

OSIRIS_CONFIG.BlacklistEnabled = true
OSIRIS_CONFIG.Ghosting = true
OSIRIS_CONFIG.Unfreeze = true
OSIRIS_CONFIG.VehicleNocollide = true
OSIRIS_CONFIG.PhysgunDropFreeze = true
OSIRIS_CONFIG.AntiSpam = true
OSIRIS_CONFIG.AS_Delete_All = true
OSIRIS_CONFIG.GroupRestrictions = true
OSIRIS_CONFIG.RemovePlayerLeave = 120
OSIRIS_CONFIG.DisableFPP = true

OSIRIS_CONFIG.OsirisSeeOwner   = "superadmin"
OSIRIS_CONFIG.OsirisTouchWorld = "superadmin"
OSIRIS_CONFIG.GravgunWorldProps = "superadmin"
--[[

NOTICE

DO NOT EDIT PASS THIS LINE!!!

]]
OSIRIS_CONFIG.ToolRestrictions = {}
OSIRIS_CONFIG.GroupLimits = {}
OSIRIS_CONFIG.PropBlacklistModels = {} -- group: {blacklisted_tool=true, ...}

local function OsirisRestoreDefaultBlacklist()
    local default = {
        "models/cranes/crane_frame.mdl",
        "models/items/item_item_crate.mdl",
        "models/props/cs_militia/silo_01.mdl",
        "models/props/cs_office/microwave.mdl",
        "models/props/de_train/biohazardtank.mdl",
        "models/props_buildings/building_002a.mdl",
        "models/props_buildings/collapsedbuilding01a.mdl",
        "models/props_buildings/project_building01.mdl",
        "models/props_buildings/row_church_fullscale.mdl",
        "models/props_c17/consolebox01a.mdl",
        "models/props_c17/oildrum001_explosive.mdl",
        "models/props_c17/paper01.mdl",
        "models/props_c17/trappropeller_engine.mdl",
        "models/props_canal/canal_bridge01.mdl",
        "models/props_canal/canal_bridge02.mdl",
        "models/props_canal/canal_bridge03a.mdl",
        "models/props_canal/canal_bridge03b.mdl",
        "models/props_combine/combine_citadel001.mdl",
        "models/props_combine/combine_mine01.mdl",
        "models/props_combine/combinetrain01.mdl",
        "models/props_combine/combinetrain02a.mdl",
        "models/props_combine/combinetrain02b.mdl",
        "models/props_combine/prison01.mdl",
        "models/props_combine/prison01c.mdl",
        "models/props_industrial/bridge.mdl",
        "models/props_junk/garbage_takeoutcarton001a.mdl",
        "models/props_junk/gascan001a.mdl",
        "models/props_junk/glassjug01.mdl",
        "models/props_junk/trashdumpster02.mdl",
        "models/props_phx/amraam.mdl",
        "models/props_phx/ball.mdl",
        "models/props_phx/cannonball.mdl",
        "models/props_phx/huge/evildisc_corp.mdl",
        "models/props_phx/misc/flakshell_big.mdl",
        "models/props_phx/misc/potato_launcher_explosive.mdl",
        "models/props_phx/mk-82.mdl",
        "models/props_phx/oildrum001_explosive.mdl",
        "models/props_phx/torpedo.mdl",
        "models/props_phx/ww2bomb.mdl",
        "models/props_wasteland/cargo_container01.mdl",
        "models/props_wasteland/cargo_container01.mdl",
        "models/props_wasteland/cargo_container01b.mdl",
        "models/props_wasteland/cargo_container01c.mdl",
        "models/props_wasteland/depot.mdl",
        "models/xqm/coastertrack/special_full_corkscrew_left_4.mdl"
    }

    local f = file.Open("osiris_blacklist.txt", "wb", "DATA")
    for k, v in pairs(default) do
        OSIRIS_CONFIG.PropBlacklistModels[string.lower(v)] = true
    end
    for k, v in pairs(OSIRIS_CONFIG.PropBlacklistModels) do
        f:Write(string.lower(k))
        f:Write("\n")
    end
    f:Close()
end

if file.Exists("osiris_blacklist.txt", "DATA") then
    local str = file.Read("osiris_blacklist.txt")
    for k, v in pairs(string.Split(str, "\n")) do
        v = string.lower( string.Trim(v,"\r") )
        OSIRIS_CONFIG.PropBlacklistModels[v] = true
    end
end

if file.Exists("osiris_config.txt", "DATA") then
    local t = util.JSONToTable(file.Read("osiris_config.txt"))
    for k, v in pairs(t) do
        OSIRIS_CONFIG[k] = v
    end
end

if not file.Exists("osiris_blacklist.txt", "DATA") then
    OsirisRestoreDefaultBlacklist()
end

concommand.Add("osiris_default_blacklist",function(ply)
    if IsValid(ply) then ply:ChatPrint("This can only be run from RCon") return end
    OsirisRestoreDefaultBlacklist()
end)

hook.Add("OsirisConfigChanged", "FPPDisable",function()
    if FPP and FPP.Settings then
        if OSIRIS_CONFIG.DisableFPP then
            if OSIRIS_FPP_OLD then return end
            OSIRIS_FPP_OLD = table.Copy(FPP.Settings)

            for k, v in pairs(FPP.Settings) do
                for _, a in pairs(v) do
                    FPP.Settings[k][_] = 0
                end
            end

        elseif OSIRIS_FPP_OLD then
            FPP.Settings = OSIRIS_FPP_OLD
            OSIRIS_FPP_OLD = nil
        end
    end
end)
timer.Simple(1, function()
hook.Call("OsirisConfigChanged")
end)
Msg("Osiris config loaded\n")
