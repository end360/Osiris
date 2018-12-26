local PANEL = {}
local hover_color_closed = Color( 0, 200, 0 )
local hover_color_opened = Color( 200, 0, 0 )

local function DermaQueryPaint(self,w,h)
    surface.SetDrawColor(25,25,25,250)
    surface.DrawRect(0,0,w,h)
end

function PANEL:Init()

    self:DockPadding(0, 50, 0, 0)
    self.list = self:Add("DListView")
    self.list:Dock(TOP)

    self:AddColumn("Group")
    self:AddColumn("Limit")

    self.list:SetSize(490, 200)
    self.list.OnClickLine = function() end

    function self.list.OnRowRightClick(a,id, line)
        self:OnRowRightClick(id, line)
    end

    self.add = self:Add("DButton")
    self.add:SetText("Add Group")
    self.add:SetMinimumSize(0, 40)
    self.add:Dock(BOTTOM)
    function self.add.DoClick()
        self:AddDoClick()
    end

    self.add:SetFont("Osiris_Config_UI_Link_Font")
    self.add:SetTextColor(color_white)

    function self.add:Paint(w,h)
        surface.SetDrawColor(25, 25, 25)
        surface.DrawRect(0, 0, w, h)

        if self:IsHovered() then
            self:SetTextColor(hover_color_closed)
        else
            self:SetTextColor(color_white)
        end
    end

    self:SetText("")

    self:SetExpanded(false)
    self.changes = {}
    self.title = "Group Prop Limits"
end

function PANEL:AddColumn(name)
    local col = self.list:AddColumn(name)
    col.Header.Paint = self.PaintColumn
    col.Header:SetTextColor(color_white)
end

function PANEL:MouseInPos()
    local mx, my = self:ScreenToLocal(gui.MousePos())
    local x, y   = self:GetPos()
    local w      = self:GetSize()
    local h      = 50
    return (mx >= 0 and mx <= w) and (my >= 0 and my <= h)-- shitty hack because im lazy
end

function PANEL:Paint( w, h )
    if self:IsHovered() and self:MouseInPos() then
        surface.SetDrawColor(0, 0, 0, 255)
    else
        surface.SetDrawColor(25, 25, 25, 255)
    end
    surface.DrawRect(0, 0, w, 50)

    surface.SetFont("Osiris_Config_UI_Link_Font")
    --surface.SetTextColor(self:IsHovered() and self:MouseInPos() and (self.expanded and hover_color_opened or hover_color_closed) or color_white)
    surface.SetTextColor(255,255,255)

    local tw, th = surface.GetTextSize(self.title)
    surface.SetTextPos(w/2-tw/2, 25-th/2)
    surface.DrawText(self.title)
end

function PANEL:PaintLine(w, h)
    surface.SetDrawColor(255, 255, 255, 255)
    if self.unsaved then
        surface.SetDrawColor(255,255,0,255)
    end
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PaintColumn(w, h)
    surface.SetDrawColor(100, 100, 100, 255)
    surface.DrawRect(0,0,w,h)
end

function PANEL:DoClick()
    if not self:MouseInPos() then return end
    self:SetExpanded( not self.expanded )
end

function PANEL:SetExpanded( tf )
    self.expanded = tf
    if not tf then
        self.add:SetVisible(false)
        self:SizeTo(490, 50, 0.3, 0, -1, function()
            if IsValid(self) then
                self.list:SetVisible(false)
            end
        end)
    else
        self.list:SetVisible(true)
        self:SizeTo(490, 250 + self.add:GetTall(), 0.3, 0, -1, function() if IsValid(self) then self.add:SetVisible(true) end end)

    end
end

function PANEL:UpdateGroups( t )
    self.list:Clear()
    self.changes = {}

    for k, v in pairs(t) do
        local l = self.list:AddLine(k, v)
        l.Paint = self.PaintLine
    end
end

function PANEL:SaveChanges()
    for k, v in pairs(self.changes) do
        net.Start("OsirisGroupRestrict")
            net.WriteString(k)
            net.WriteDouble(v)
        net.SendToServer()
    end
end

function PANEL:OnRowRightClick(id, line)

    local m = vgui.Create("DMenu")
    m:SetPos( gui.MousePos() )

    m:AddOption("Edit")
    m:AddOption("Delete")
    m:AddSpacer()
    m:AddOption("Cancel")

    function m.OptionSelected(a,option, text)
        local group = line:GetColumnText(1)
        if text == "Edit" then
            Derma_StringRequest("Prop Limit", "Prop limit for group `" .. group .. "`.", "0", function(str)
                amt = tonumber(str) or 0
                self.changes[group] = amt
                line:SetValue(2, amt)
                line.unsaved = true
            end).Paint = DermaQueryPaint
        elseif text == "Delete" then
            Derma_Query("Are you sure?","Delete Prop Limit for " .. group, "Delete", function()
                self.changes[group] = -360
                self.list:RemoveLine(id)
            end, "Cancel", function() end).Paint = DermaQueryPaint
        end
    end
    m:MakePopup()
end

function PANEL:AddDoClick()
    local group, amt = "", 0
    Derma_StringRequest("Group Name", "Enter the name of the group.", "user", function(str)
        group = str
        Derma_StringRequest("Prop Limit", "Prop limit for group `" .. group .. "`.", "0", function(str)
            amt = tonumber(str) or 0
            self.changes[group] = amt
            local l = self.list:AddLine(group, amt)
            l.Paint = self.PaintLine
            l.unsaved = true
        end).Paint = DermaQueryPaint
    end).Paint = DermaQueryPaint
end

vgui.Register("OsirisGroupLimit", PANEL, "DButton")

local PANEL2 = {}

function PANEL2:Init()
    for k, v in ipairs(self.list.Columns) do v:Remove() self.list.Columns[k] = nil end

    self:AddColumn("Group")
    self:AddColumn("Tool")

    self.add:SetText("Block Tool")
    self.title = "Tool Restrictions"

    self.changes = {}
end

function PANEL2:OnRowRightClick(id, line)

    local m = vgui.Create("DMenu")
    m:SetPos( gui.MousePos() )

    m:AddOption("Delete")
    m:AddSpacer()
    m:AddOption("Cancel")

    function m.OptionSelected(a,option, text)
        local group = line:GetColumnText(1)
        if not self.changes[group] then self.changes[group] = {} end
        local str   = line:GetColumnText(2)
        if text == "Delete" then
            Derma_Query("Are you sure?","Delete tool restriction `" .. line:GetColumnText(2) .. " for " .. group, "Delete", function()
                if line.unsaved then
                    self.changes[group][str] = nil
                else
                    self.changes[group][str] = false
                end
                self.list:RemoveLine(id)
            end, "Cancel", function() end).Paint = DermaQueryPaint
        end
    end
    m:MakePopup()
end

function PANEL2:AddDoClick()
    Derma_StringRequest("Group Name", "Enter the name of the group.", "user", function(str)
        local group = str

        Derma_StringRequest("Tool name", "Tool restriction for group `" .. group .. "`.", "0", function(str)
            local groups = string.Split(group, ",")
            for k, group in pairs(groups) do
                group = string.Trim(group)
                if not self.changes[group] then self.changes[group] = {} end
                self.changes[group][str] = true

                local l = self.list:AddLine(group, str)
                l.Paint = self.PaintLine
                l.unsaved = true
            end
        end).Paint = DermaQueryPaint
    end).Paint = DermaQueryPaint
end

function PANEL2:UpdateGroups( t )
    self.list:Clear()
    self.changes = {}
    for group, v in pairs(t) do
        self.changes[group] = {}
        for tool, a in pairs(v) do
            self.list:AddLine(group, tool)
        end
    end
end

function PANEL2:SaveChanges()
    for group, v in pairs(self.changes) do
        for tool, tf in pairs(v) do
            net.Start("OsirisToolRestrict")
                net.WriteString(group)
                net.WriteString(tool)
                net.WriteBool(tf)
            net.SendToServer()
        end
    end
end
vgui.Register("OsirisToolRestrict", PANEL2, "OsirisGroupLimit")
