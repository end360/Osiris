local PANEL = {}
local hover_color_closed = Color( 0, 200, 0 )
local hover_color_opened = Color( 200, 0, 0 )

function PANEL:Init()
    self.changes = {}
    self:DockPadding(0, 50, 0, 0)
    self.list = self:Add("DIconLayout")
    self.list:Dock(TOP)

    self:SetText("")

    self:SetExpanded(false)
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

    surface.SetFont("Osiris_Config_UI_Main_Font")
    --surface.SetTextColor(self:IsHovered() and self:MouseInPos() and (self.expanded and hover_color_opened or hover_color_closed) or color_white)
    surface.SetTextColor(255,255,255)

    local tw, th = surface.GetTextSize("Blocked Models")
    surface.SetTextPos(w/2-tw/2, 25-th/2)
    surface.DrawText("Blocked Models")
end

function PANEL:DoClick()
    if not self:MouseInPos() then return end
    self:SetExpanded( not self.expanded )
end

function PANEL:SetExpanded( tf )
    self.expanded = tf
    if not tf then
        self:SizeTo(490, 50, 0.3, 0, -1, function()
            if IsValid(self) then
                self.list:SetVisible(false)
            end
        end)
    else
        self.list:SetVisible(true)

        self:SizeTo(490, 50 + self.list:GetTall(), 0.3)

    end
end

function PANEL:UpdateModels( t )
    for k, v in pairs(self.list:GetChildren()) do
        v:Remove()
    end
    for mdl, _ in pairs(t) do
        local icon = self.list:Add("SpawnIcon")

        icon:SetModel(mdl)
        icon.DoRightClick = function(_)
            local dmenu = vgui.Create("DMenu")
            dmenu:AddOption("Remove"):SetIcon("icon16/cancel.png")
            dmenu:AddSpacer()
            dmenu:AddOption("Copy Path")
            dmenu:AddOption("Cancel")
            dmenu:SetPos(gui.MousePos())
            dmenu.OptionSelected = function(_, option, text)
                if text == "Remove" then
                    self.changes[mdl] = 0
                    if IsValid(icon) then
                        icon:Remove()
                    end
                elseif text == "Copy Path" then
                    SetClipboardText(mdl)
                end
            end

            dmenu:MakePopup()
        end
    end
end

function PANEL:SaveChanges()
    for k, v in pairs(self.changes) do
        net.Start("ModifyPropBlacklist")
            net.WriteUInt(v, 8)
            net.WriteString(k)
        net.SendToServer()
    end
end

vgui.Register("OsirisBlacklist", PANEL, "DButton")
