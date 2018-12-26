local PANEL = {}

local enabled_color  = Color(0, 200, 0)
local disabled_color = Color(200, 0, 0)
local w = 490

function PANEL:Init()
    self:DockMargin(2, 5, 2, 2)
    self:Dock(TOP)

    self.mLabel = self:Add("DLabel")
    self.mLabel:SetFont("Osiris_Config_UI_Link_Font")
    self.mLabel:Dock(LEFT)

    self.mLabel:SetWide(w/2)

    self.mSlider = self:Add("DButton")
    self.mSlider:SetText("")
    self.mSlider:SetIsToggle(true)
    self.mSlider.Paint = self.PaintSlider
    self.mSlider:Dock(RIGHT)
    self.mSlider:SetIsToggle(true)
    self.mSlider.DoClick = function()self:DoClick()end
    self:SetSliderSize( 60, 30 )

    self.changes = {}
end

function PANEL:SetText( ... )
    self.mLabel:SetText( ... )
    return self
end

function PANEL:SetSliderSize( w, h )
    self.mSlider:SetSize(w, h)
    return self
end

function PANEL:SetVar(a)
    self.var = a
    return self
end

function PANEL:SetToggle(...)
    self.mSlider:SetToggle(...)
    return self
end

function PANEL:GetSliderSize()
    return self.sliderw, self.sliderh
end

function PANEL:DoClick()
    if not self.var then return end

    self.mSlider:Toggle()

    self.changes[self.var] = self.mSlider:GetToggle()
end

function PANEL:SaveChanges()
    for k, v in pairs(self.changes) do
        net.Start("OsirisConfig")
            net.WriteString(k)
            net.WriteType(v)
        net.SendToServer()
    end
end

function PANEL:Paint( w, h )
end

function PANEL:PaintSlider( w, h ) -- self refers to mSlider
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)

    local sw = w * 0.95
    if self:GetToggle() then
        surface.SetDrawColor(enabled_color)
        surface.DrawRect(w/2 - w * 0.025, h*0.05, sw/2, h*0.9)
    else
        surface.SetDrawColor(disabled_color)
        surface.DrawRect(w * 0.05, h*0.05, sw/2, h*0.9)
    end
end

vgui.Register("OsirisConfigToggle", PANEL, "EditablePanel")

local PANEL2 = {}

function PANEL2:Init()
    self:DockMargin(3, 0, 0, 0)
    self.label = self:Add("DLabel")
    self.label:SetSize(300, 30)

    self.label:SetFont("Osiris_Config_UI_Link_Font")
    self.label:Dock(LEFT)

    self.combo = self:Add("DComboBox")
    self.combo:SetSortItems(false)
    self.combo:SetSize(100, 30)

    self.combo:Dock(RIGHT)

end

function PANEL2:ChooseOptionID( id )
    self.combo:ChooseOptionID( id )
end

function PANEL2:SetTitle( str, font, color )
    self.label:SetText(str)
    if font then self.label:SetFont(font) end
    if color then self.label:SetTextColor(color) end
    return self
end

function PANEL2:AddChoice( choice, value )
    self.combo:AddChoice(choice, value)
    return self
end

function PANEL2:SetVar( v )
    self.var = v
    return self
end

function PANEL2:SaveChanges()
    if not self.var then return end

    net.Start("OsirisConfig")
        net.WriteString(self.var)
        net.WriteType( select(2, self.combo:GetSelected()) )
    net.SendToServer()
end

vgui.Register("OsirisConfigSeeOwner", PANEL2, "EditablePanel")

surface.CreateFont("Osiris_Config_UI_Small_Font", {
    font = "DebugFixed",
    size =  20,
    weight = 500
})

local PANEL3 = {}

function PANEL3:Init()
    self:DockPadding(4, 0,0,0)
    self.title = self:Add("DLabel")
    self.title:Dock(LEFT)
    self.title:SetFont("Osiris_Config_UI_Small_Font")
    self.title:SetSize(400, 30)

    self.slider = self:Add("DNumberWang")
    self.slider:Dock(RIGHT)

    self:SetClamp(-1, 9999)
end

function PANEL3:SetClamp( x, y )
    if x then
        self.slider:SetMin(x)
    end
    if y then
        self.slider:SetMax(y)
    end
    return self
end

function PANEL3:SetTitle( str )
    self.title:SetText(str)
    return self
end

function PANEL3:SetVar(str)
    self.var = str
    return self
end

function PANEL3:UpdateValue( v )
    self.slider:SetValue(v)
    return self
end

function PANEL3:SaveChanges()
    if not self.var then return end
    net.Start("OsirisConfig")
        net.WriteString(self.var)
        net.WriteType(self.slider:GetValue())
    net.SendToServer()
end

vgui.Register("OsirisConfigNumber", PANEL3, "EditablePanel")
