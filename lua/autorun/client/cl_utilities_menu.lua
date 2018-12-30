local BuddiesPanel
local MakeBuddies
OSIRIS_BUDDIES = OSIRIS_BUDDIES or {}

do
    if file.Exists("osiris_buddies.txt", "DATA") then
        local temp = util.JSONToTable(file.Read("osiris_buddies.txt"))

        for steamid, t in pairs(temp) do
            OSIRIS_BUDDIES[steamid] = t
        end
    end
end

local function SaveBuddies()
    file.Write("osiris_buddies.txt", util.TableToJSON(OSIRIS_BUDDIES))
    local n = table.Count(OSIRIS_BUDDIES)
    net.Start("OsirisBuddies")
        net.WriteUInt(n, 16)
        for sid, data in pairs(OSIRIS_BUDDIES) do
            net.WriteString(sid)
            net.WriteBool(data.phys and true or false)
            net.WriteBool(data.grav and true or false)
            net.WriteBool(data.tool and true or false)
            net.WriteBool(data.use  and true or false)
            net.WriteBool(data.dmg  and true or false)
        end
    net.SendToServer()
end

local function AddVar(parent, title, default)
    local check = parent:Add("DCheckBoxLabel")
    check:SetText(title)
    check:SetValue( default or 0 )
    check:Dock(TOP)

    return check
end

local function EditBuddy( steamid, name, data )
    local frame = vgui.Create("DFrame")
    frame:SetSize(120, 130)
    frame:SetTitle(name)
    frame:Center()
    frame:ShowCloseButton(false)
    if not data then
        data = {
            phys = 0,
            grav = 0,
            tool = 0,
            use  = 0,
            dmg  = 0,
        }
    end

    local phys = AddVar(frame, "Physgun", data.phys or 0)
    local grav = AddVar(frame, "Gravgun", data.grav or 0)
    local tool = AddVar(frame, "Toolgun", data.tool or 0)
    local use  = AddVar(frame, "Use",     data.use  or 0)
    local dmg  = AddVar(frame, "Damage",  data.dmg  or 0)

    local save = frame:Add("DButton")
    save:SetSize(40, 20)
    save:SetText("Save")
    save:Dock(BOTTOM)

    function save:DoClick()

        data.phys    = phys:GetChecked() and 1 or 0
        data.grav    = grav:GetChecked() and 1 or 0
        data.tool    = tool:GetChecked() and 1 or 0
        data.use     = use :GetChecked() and 1 or 0
        data.dmg     = dmg :GetChecked() and 1 or 0
        data.nick    = name
        data.steamid = steamid

        OSIRIS_BUDDIES[steamid] = data
        frame:Close()

        MakeBuddies(BuddiesPanel)
    end

    frame:MakePopup()
end

local function IsValidSteamID( id )
    if not isstring(id) then return false end
    if #id < 11 then return false end

    local m = string.match(id, "STEAM_[012345]:%d:%d+")
    return m == id
end

local function AddBuddyMenuSteamID()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Add a Buddy")
    frame:SetSize(200, 100)
    frame:Center()

    local inp = frame:Add("DTextEntry")
    inp:SetPlaceholderText("STEAM_0:0:0")
    inp:Dock(TOP)

    local add = frame:Add("DButton")
    add:SetText("Add Buddy")
    add:SetEnabled(false)
    add:Dock(BOTTOM)

    function add:DoClick()
        if IsValidSteamID( inp:GetValue() ) then
            EditBuddy(inp:GetValue(), "")
            frame:Close()
        end
    end

    inp.OnEnter = add.DoClick
    function inp:OnChange()
        if IsValidSteamID(self:GetValue()) then
            add:SetEnabled(true)
        else
            add:SetEnabled(false)
        end
    end
    frame:MakePopup()
end

local function AddBuddyMenuOnline()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Add a Buddy")
    frame:SetSize(300, 200)
    frame:Center()

    local scroller = frame:Add("DScrollPanel")
    scroller:Dock(FILL)

    local lines = {}

    for k, v in pairs(player.GetHumans()) do
        if v == LocalPlayer() then continue end
        local line = scroller:Add("EditablePanel")
        line:SetSize(300, 16)
        line:Dock(TOP)

        line.Paint = function() end

        local name = line:Add("DLabel")
        name:SetText(v:Nick())
        name:Center()

        local button = line:Add("DButton")
        local sid, name = v:SteamID(), v:Nick()
        function button:DoClick()
            EditBuddy(sid, name)
            if IsValid(frame) then frame:Close() end
        end
        button:SetSize(32, 16)
        button:SetPos(300-48, 0)
        button:SetText("Add")

    end

    frame:MakePopup()
end

MakeBuddies = function( Panel )
    Panel:ClearControls()
    BuddiesPanel = Panel
    if not IsValid(BuddiesPanel) then return end

    Panel:Clear()

    Panel:AddControl("Label", {
        Text = "Your buddies will transfer to any server with Osiris prop protection.\n\nRight click a buddy to edit or delete them."
    })

    local blist = vgui.Create("DListView")
    blist:AddColumn("SteamID")
    blist:AddColumn("Name")
    blist:SetTall(300)
    blist:SetMultiSelect(false)

    Panel:AddPanel(blist)

    for steamid, data in pairs(OSIRIS_BUDDIES) do
        blist:AddLine(steamid, data.nick)
    end

    function blist:OnRowRightClick( id, line )
        local sid, name = line:GetValue(1), line:GetValue(2)
        local menu = vgui.Create("DMenu")
        menu:AddOption("Edit")
        menu:AddOption("Remove")
        menu:AddOption("Cancel")
        menu:SetPos( gui.MousePos() )
        menu:MakePopup()

        function menu:OptionSelected( option, otext )
            if otext == "Edit" then
                EditBuddy(sid, name, OSIRIS_BUDDIES[sid])
            elseif otext == "Remove" then
                Derma_Query("Remove buddy \"" .. name .. "\"?", "Are you sure?", "Remove", function()
                    OSIRIS_BUDDIES[sid] = nil
                    SaveBuddies()
                    MakeBuddies(BuddiesPanel)
                end, "Cancel")
            end
        end
    end

    local add = vgui.Create("DButton")
    add:SetText("Add Buddy")

    function add:DoClick()
        local m = vgui.Create("DMenu")
        m:AddOption("Add by SteamID")
        m:AddOption("Add online player")
        m:SetPos( gui.MousePos() )
        m:MakePopup()

        function m:OptionSelected( a, text )
            if text == "Add by SteamID" then
                AddBuddyMenuSteamID()
            else
                AddBuddyMenuOnline()
            end
        end
    end

    Panel:AddPanel(add)
end


local function makeMenus()
    spawnmenu.AddToolMenuOption( "Utilities", "Osiris", "Buddies", "Buddies", "", "", MakeBuddies)
end
hook.Add("PopulateToolMenu", "OsirisUtilitiesMenu", makeMenus)
