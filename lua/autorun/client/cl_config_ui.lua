--[[---------------------------------------------------------------------------
Config UI
---------------------------------------------------------------------------]]
OSIRIS_BLACKLIST = OSIRIS_BLACKLIST or {}
surface.CreateFont("Osiris_Config_UI_Main_Font", {
	font = "DebugFixed",
	size =  30,
	weight = 500
})

surface.CreateFont("Osiris_Config_UI_Link_Font", {
	font = "DebugFixed",
	size =  25,
	weight = 500
})

local Osiris_Config_UI_Derma_Frame
net.Receive("Osiris_Config_UI", function()
	if IsValid(Osiris_Config_UI_Derma_Frame) then Osiris_Config_UI_Derma_Frame:Remove() end

	net.Start("GetPropBlacklist") -- Get blacklist
	net.SendToServer()
	net.Start("OsirisGroupRestrict") -- Get group prop limits
		net.WriteString("__request__")
	net.SendToServer()
	net.Start("OsirisToolRestrict")
		net.WriteString("__request__")
	net.SendToServer()

	Osiris_Config_UI_Derma_Frame = vgui.Create("DFrame")
	local Osiris_Config_UI_Derma_Save_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Save_And_Close_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Prop_Protection_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Prop_Protection_Panel = vgui.Create("DScrollPanel", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Prop_Protection_Button_Panel = vgui.Create("DPanel", Osiris_Config_UI_Derma_Prop_Protection_Button)
	local Osiris_Config_UI_Derma_Credit_Panel = vgui.Create("DPanel", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Credits_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Frame)
	local Osiris_Config_UI_Derma_Credits_Button_Panel = vgui.Create("DPanel", Osiris_Config_UI_Derma_Credits_Button)
	local Osiris_Config_UI_Derma_Prop_Protection_Blocked_Panel = vgui.Create("OsirisBlacklist", Osiris_Config_UI_Derma_Prop_Protection_Panel)
	local Osiris_Config_UI_Derma_Group_Limit_Panel = vgui.Create("OsirisGroupLimit", Osiris_Config_UI_Derma_Prop_Protection_Panel)
	local OSIRIS_Config_UI_Derma_Tool_Restriction = vgui.Create("OsirisToolRestrict", Osiris_Config_UI_Derma_Prop_Protection_Panel)

	local OwnerType, WorldPhysgun, WorldGravgun
	Osiris_Config_UI_Derma_Prop_Protection_Panel:DockPadding(0, 4,0,0)
	Osiris_Config_UI_Derma_Prop_Protection_Blocked_Panel:Dock(TOP)
	Osiris_Config_UI_Derma_Group_Limit_Panel:Dock(TOP)
	OSIRIS_Config_UI_Derma_Tool_Restriction:Dock(TOP)

	Osiris_Config_UI_Derma_Frame.UpdateGroups = function(_,a) Osiris_Config_UI_Derma_Group_Limit_Panel:UpdateGroups(a) end
	Osiris_Config_UI_Derma_Frame.UpdateModels = function() Osiris_Config_UI_Derma_Prop_Protection_Blocked_Panel:UpdateModels(OSIRIS_BLACKLIST) end
	Osiris_Config_UI_Derma_Frame.UpdateTools  = function(_, a) OSIRIS_Config_UI_Derma_Tool_Restriction:UpdateGroups(a) end

	local vars = {}
	local function ProcessChanges()
		Osiris_Config_UI_Derma_Prop_Protection_Blocked_Panel:SaveChanges()
		for k, v in pairs(vars) do
			v:SaveChanges()
		end
		Osiris_Config_UI_Derma_Group_Limit_Panel:SaveChanges()
		OwnerType:SaveChanges()
		WorldPhysgun:SaveChanges()
		OSIRIS_Config_UI_Derma_Tool_Restriction:SaveChanges()
		WorldGravgun:SaveChanges()
	end

	Osiris_Config_UI_Derma_Frame:SetPos( 0, 0 )
	Osiris_Config_UI_Derma_Frame:SetSize( 500, 600 )
	Osiris_Config_UI_Derma_Frame:SetTitle( "" )
	Osiris_Config_UI_Derma_Frame:SetVisible( true )
	Osiris_Config_UI_Derma_Frame:SetDraggable( false )
	Osiris_Config_UI_Derma_Frame:ShowCloseButton( true )
	Osiris_Config_UI_Derma_Frame:Center()
	Osiris_Config_UI_Derma_Credit_Panel:SetVisible( false )
	Osiris_Config_UI_Derma_Frame:MakePopup()
	Osiris_Config_UI_Derma_Frame.Paint = function( self )
		surface.SetDrawColor( 25, 25, 25, 255 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end

	Osiris_Config_UI_Derma_Prop_Protection_Button:SetPos( 0, 0 )
	Osiris_Config_UI_Derma_Prop_Protection_Button:SetSize( 250, 50 )
	Osiris_Config_UI_Derma_Prop_Protection_Button:SetText( "Prop Protection" )
	Osiris_Config_UI_Derma_Prop_Protection_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
	Osiris_Config_UI_Derma_Prop_Protection_Button:SetFont( "Osiris_Config_UI_Main_Font" )
	Osiris_Config_UI_Derma_Prop_Protection_Button.Paint = function( self )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

		if self:IsHovered() then
			Osiris_Config_UI_Derma_Prop_Protection_Button:SetTextColor( Color( 0, 200, 0, 255 ) )
		else
			Osiris_Config_UI_Derma_Prop_Protection_Button:SetTextColor( Color( 255, 255, 255, 255  ) )
		end
	end
	Osiris_Config_UI_Derma_Prop_Protection_Button.DoClick = function( self )
		surface.PlaySound("UI/buttonclick.wav")
		Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetVisible( true )
		Osiris_Config_UI_Derma_Save_Button:SetVisible( true )
		Osiris_Config_UI_Derma_Save_And_Close_Button:SetVisible( true )
		Osiris_Config_UI_Derma_Prop_Protection_Panel:SetVisible( true )
		Osiris_Config_UI_Derma_Credits_Button_Panel:SetVisible( false )
		Osiris_Config_UI_Derma_Credit_Panel:SetVisible( false )
	end

	Osiris_Config_UI_Derma_Credits_Button:SetPos( 250, 0 )
	Osiris_Config_UI_Derma_Credits_Button:SetSize( 250, 50 )
	Osiris_Config_UI_Derma_Credits_Button:SetText( "Credits" )
	Osiris_Config_UI_Derma_Credits_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
	Osiris_Config_UI_Derma_Credits_Button:SetFont( "Osiris_Config_UI_Main_Font" )
	Osiris_Config_UI_Derma_Credits_Button.Paint = function( self )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

		if self:IsHovered() then
			Osiris_Config_UI_Derma_Credits_Button:SetTextColor( Color( 200, 0, 0, 255  ) )
		else
			Osiris_Config_UI_Derma_Credits_Button:SetTextColor( Color( 255, 255, 255, 255  ) )
		end
	end
	Osiris_Config_UI_Derma_Credits_Button.DoClick = function( self )
		surface.PlaySound("UI/buttonclick.wav")
		Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetVisible( false )
		Osiris_Config_UI_Derma_Credits_Button_Panel:SetVisible( true )
		Osiris_Config_UI_Derma_Credit_Panel:SetVisible( true )
		Osiris_Config_UI_Derma_Save_Button:SetVisible( false )
		Osiris_Config_UI_Derma_Save_And_Close_Button:SetVisible( false )
		Osiris_Config_UI_Derma_Prop_Protection_Panel:SetVisible( false )
	end

	Osiris_Config_UI_Derma_Credits_Button_Panel:SetPos( 0, 0 )
	Osiris_Config_UI_Derma_Credits_Button_Panel:SetSize( 250, 50 )
	Osiris_Config_UI_Derma_Credits_Button_Panel.Paint = function( self )
		surface.SetDrawColor( 200, 0, 0, 255 )
		surface.DrawRect( 0, 45, self:GetWide(), 5 )
	end

	Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetPos( 0, 0 )
	Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetSize( 250, 50 )
	Osiris_Config_UI_Derma_Prop_Protection_Button_Panel.Paint = function( self )
		surface.SetDrawColor( 0, 200, 0, 255 )
		surface.DrawRect( 0, 45, self:GetWide(), 5 )
	end

	Osiris_Config_UI_Derma_Prop_Protection_Panel:SetPos( 5, 55 )
	Osiris_Config_UI_Derma_Prop_Protection_Panel:SetSize( 490, 390 )
	Osiris_Config_UI_Derma_Prop_Protection_Panel.Paint = function( self )
		surface.SetDrawColor( 100, 100, 100, 255 )
		surface.DrawRect( 0, 0, self:GetWide(), 400 )
		Osiris_Config_UI_Derma_Credits_Button_Panel:SetVisible( false )
	end
	-- { Config Vars }
	--[[
		OSIRIS_CONFIG.BlacklistEnabled = true
		OSIRIS_CONFIG.Ghosting = true
		OSIRIS_CONFIG.Unfreeze = true
		OSIRIS_CONFIG.VehicleNocollide = true
		OSIRIS_CONFIG.PhysgunDropFreeze = true
		OSIRIS_CONFIG.AntiSpam = true
	]]
	local function AddVar(PrettyName, VarName)
		local Config = Osiris_Config_UI_Derma_Prop_Protection_Panel:Add("OsirisConfigToggle")
		Config:SetText(PrettyName):SetVar(VarName)
		vars[VarName] = Config
	end
	AddVar("Blacklist", "BlacklistEnabled")
	AddVar("Prop Ghosting",  "Ghosting")
	AddVar("Prevent Unfreeze",  "Unfreeze")
	AddVar("Disable Vehicle Collision",  "VehicleNocollide")
	AddVar("Freeze Props on Drop",  "PhysgunDropFreeze")
	AddVar("AntiSpam",  "AntiSpam")
	AddVar("Delete all props on spam", "AS_Delete_All")
	AddVar("Group Prop Limits", "GroupRestrictions")
	AddVar("Disable FPP", "DisableFPP")
	local LeaveTime = Osiris_Config_UI_Derma_Prop_Protection_Panel:Add("OsirisConfigNumber")
	LeaveTime:SetTitle("Remove unowned props after x seconds (-1 = disable)"):SetVar("RemovePlayerLeave")
	LeaveTime:Dock(TOP)
	vars["RemovePlayerLeave"] = LeaveTime


	OwnerType = Osiris_Config_UI_Derma_Prop_Protection_Panel:Add("OsirisConfigSeeOwner")
	OwnerType:AddChoice("Superadmins", "superadmin"):AddChoice("Admins", "admin"):AddChoice("Everyone", "all"):AddChoice("Nobody", "none"):SetTitle("Who can see prop owners?"):SetVar("OsirisSeeOwner")
	OwnerType:Dock(TOP)

	WorldPhysgun = Osiris_Config_UI_Derma_Prop_Protection_Panel:Add("OsirisConfigSeeOwner")
	WorldPhysgun:AddChoice("Superadmins", "superadmin"):AddChoice("Admins", "admin"):AddChoice("Everyone", "all"):AddChoice("Nobody", "none"):SetTitle("Who can physgun world props?"):SetVar("OsirisTouchWorld")
	WorldPhysgun:Dock(TOP)

	WorldGravgun = Osiris_Config_UI_Derma_Prop_Protection_Panel:Add("OsirisConfigSeeOwner")
	WorldGravgun:AddChoice("Superadmins", "superadmin"):AddChoice("Admins", "admin"):AddChoice("Everyone", "all"):AddChoice("Nobody", "none"):SetTitle("Who can gravgun world props?"):SetVar("GravgunWorldProps")
	WorldGravgun:Dock(TOP)

	Osiris_Config_UI_Derma_Frame.ConfigUpdated = function()
		for k, v in pairs(vars) do
			if OSIRIS_CONFIG[k] then
				if v.SetToggle then
					v:SetToggle(OSIRIS_CONFIG[k] == true)
				elseif v.UpdateValue then
					v:UpdateValue(OSIRIS_CONFIG[k])
				end
			end
		end
		Osiris_Config_UI_Derma_Prop_Protection_Blocked_Panel:UpdateModels(OSIRIS_CONFIG.PropBlacklistModels)
		if OSIRIS_CONFIG.OsirisSeeOwner then
	        if OSIRIS_CONFIG.OsirisSeeOwner == "superadmin" then
	            OwnerType:ChooseOptionID(1)
	        elseif OSIRIS_CONFIG.OsirisSeeOwner == "admin" then
	            OwnerType:ChooseOptionID(2)
	        elseif OSIRIS_CONFIG.OsirisSeeOwner == "all" then
	            OwnerType:ChooseOptionID(3)
	        elseif OSIRIS_CONFIG.OsirisSeeOwner == "none" then
	        	OwnerType:ChooseOptionID(4)
	        end
	    end
	    if OSIRIS_CONFIG.OsirisTouchWorld then
	        if OSIRIS_CONFIG.OsirisTouchWorld == "superadmin" then
	            WorldPhysgun:ChooseOptionID(1)
	        elseif OSIRIS_CONFIG.OsirisTouchWorld == "admin" then
	            WorldPhysgun:ChooseOptionID(2)
	        elseif OSIRIS_CONFIG.OsirisTouchWorld == "all" then
	            WorldPhysgun:ChooseOptionID(3)
	        elseif OSIRIS_CONFIG.OsirisTouchWorld == "none" then
	        	WorldPhysgun:ChooseOptionID(4)
	        end
	    end
	    if OSIRIS_CONFIG.GravgunWorldProps then
	        if OSIRIS_CONFIG.GravgunWorldProps == "superadmin" then
	            WorldGravgun:ChooseOptionID(1)
	        elseif OSIRIS_CONFIG.GravgunWorldProps == "admin" then
	            WorldGravgun:ChooseOptionID(2)
	        elseif OSIRIS_CONFIG.GravgunWorldProps == "all" then
	            WorldGravgun:ChooseOptionID(3)
	        elseif OSIRIS_CONFIG.GravgunWorldProps == "none" then
	        	WorldGravgun:ChooseOptionID(4)
	        end
	    end

	end

	Osiris_Config_UI_Derma_Credit_Panel:SetPos( 0, 50 )
	Osiris_Config_UI_Derma_Credit_Panel:SetSize( 500, 500 )
	Osiris_Config_UI_Derma_Credit_Panel.Paint = function( self )
	end

	local Osiris_Config_UI_Derma_Credit_Panel_Logo = vgui.Create("DImage", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Logo:SetImage( "materials/osiris/logo.png" )
	Osiris_Config_UI_Derma_Credit_Panel_Logo:SetPos( 0, 5 )
	Osiris_Config_UI_Derma_Credit_Panel_Logo:SetSize( 500, 141 )

	local Osiris_Config_UI_Derma_Credit_Panel_Logo_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Logo_Button:SetPos( 0, 0 )
	Osiris_Config_UI_Derma_Credit_Panel_Logo_Button:SetSize( 500, 141 )
	Osiris_Config_UI_Derma_Credit_Panel_Logo_Button:SetText( "" )
	Osiris_Config_UI_Derma_Credit_Panel_Logo_Button.Paint = function( self )
		if self:IsHovered() then
			surface.SetDrawColor( 200, 200, 0, 20 )
			surface.DrawRect( 0, 5, self:GetWide(), self:GetTall() )
		end
	end
	Osiris_Config_UI_Derma_Credit_Panel_Logo_Button.DoClick = function()
		surface.PlaySound("UI/buttonclick.wav")
		gui.OpenURL( "https://www.gmodstore.com/scripts/view/5237" )
	end

	local Osiris_Config_UI_Derma_Credit_Panel_Link_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetPos( 0, 141 )
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetSize( 500, 50 )
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetText( "https://www.gmodstore.com/scripts/view/5237" )
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetFont( "Osiris_Config_UI_Link_Font" )
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button.Paint = function( self )
		if self:IsHovered() then
			Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetTextColor( Color( 0, 250, 250, 255 ) )
		else
			Osiris_Config_UI_Derma_Credit_Panel_Link_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
		end
	end
	Osiris_Config_UI_Derma_Credit_Panel_Link_Button.DoClick = function()
		surface.PlaySound("UI/buttonclick.wav")
		gui.OpenURL( "https://www.gmodstore.com/scripts/view/5237" )
	end

	local Osiris_Config_UI_Derma_Credit_Panel_Author_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetPos( 0, 190 )
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetSize( 500, 50 )
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetText( "Made by Michael Conway" )
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetFont( "Osiris_Config_UI_Link_Font" )
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button.Paint = function( self )
		if self:IsHovered() then
			Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetTextColor( Color( 0, 250, 250, 255 ) )
		else
			Osiris_Config_UI_Derma_Credit_Panel_Author_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
		end
	end
	Osiris_Config_UI_Derma_Credit_Panel_Author_Button.DoClick = function()
		surface.PlaySound("UI/buttonclick.wav")
		gui.OpenURL( "https://steamcommunity.com/id/ELHS_Conway/" )
	end

	local Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header = vgui.Create("DLabel", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header:SetPos( 180, 251 )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header:SetSize( 300, 25 )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header:SetText( "Support Notice" )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header:SetTextColor( Color( 200, 0, 0, 255 ) )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label_Header:SetFont( "Osiris_Config_UI_Link_Font" )

	local Osiris_Config_UI_Derma_Credit_Panel_Support_Label = vgui.Create("DLabel", Osiris_Config_UI_Derma_Credit_Panel)
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label:SetPos( 30, 251 )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label:SetSize( 500, 150 )
	local supporttxt = [[
	Support is only provided through gmodstore
	support tickets, so please do not add me on
	steam for support! Thank you for understanding!
	]]
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label:SetText( supporttxt )
	Osiris_Config_UI_Derma_Credit_Panel_Support_Label:SetFont( "Osiris_Config_UI_Link_Font" )

	Osiris_Config_UI_Derma_Save_Button:SetPos( 0, 450 )
	Osiris_Config_UI_Derma_Save_Button:SetSize( 500, 50 )
	Osiris_Config_UI_Derma_Save_Button:SetText( "Save" )
	Osiris_Config_UI_Derma_Save_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
	Osiris_Config_UI_Derma_Save_Button:SetFont( "Osiris_Config_UI_Main_Font" )
	Osiris_Config_UI_Derma_Save_Button.Paint = function( self )
		if self:IsHovered() then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		end
	end
	Osiris_Config_UI_Derma_Save_Button.DoClick = function( self )
		surface.PlaySound("UI/buttonclickrelease.wav")
		ProcessChanges()
	end

	Osiris_Config_UI_Derma_Save_And_Close_Button:SetPos( 0, 500 )
	Osiris_Config_UI_Derma_Save_And_Close_Button:SetSize( 500, 50 )
	Osiris_Config_UI_Derma_Save_And_Close_Button:SetText( "Save & Close" )
	Osiris_Config_UI_Derma_Save_And_Close_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
	Osiris_Config_UI_Derma_Save_And_Close_Button:SetFont( "Osiris_Config_UI_Main_Font" )
	Osiris_Config_UI_Derma_Save_And_Close_Button.Paint = function( self )
		if self:IsHovered() then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		end
	end
	Osiris_Config_UI_Derma_Save_And_Close_Button.DoClick = function( self )
		surface.PlaySound("UI/buttonclickrelease.wav")
		self:GetParent():Close()
		Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetVisible( false )
		Osiris_Config_UI_Derma_Credits_Button_Panel:SetVisible( false )
		ProcessChanges()
	end

	local Osiris_Config_UI_Derma_Close_Button = vgui.Create("DButton", Osiris_Config_UI_Derma_Frame)
	Osiris_Config_UI_Derma_Close_Button:SetPos( 0, 550 )
	Osiris_Config_UI_Derma_Close_Button:SetSize( 500, 50 )
	Osiris_Config_UI_Derma_Close_Button:SetText( "Close" )
	Osiris_Config_UI_Derma_Close_Button:SetTextColor( Color( 255, 255, 255, 255 ) )
	Osiris_Config_UI_Derma_Close_Button:SetFont( "Osiris_Config_UI_Main_Font" )
	Osiris_Config_UI_Derma_Close_Button.Paint = function( self )
		if self:IsHovered() then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		end
	end
	Osiris_Config_UI_Derma_Close_Button.DoClick = function( self )
		surface.PlaySound("UI/buttonclickrelease.wav")
		self:GetParent():Close()
		Osiris_Config_UI_Derma_Prop_Protection_Button_Panel:SetVisible( false )
		Osiris_Config_UI_Derma_Credits_Button_Panel:SetVisible( false )
	end

end)

local receiving = false
net.Receive("GetPropBlacklist", function()
	if not receiving then
		OSIRIS_BLACKLIST = {}
		receiving = true
	end
	local blockn, blocks = net.ReadUInt(32), net.ReadUInt(32)
	--print("OSIRIS_BLACKLIST block ", blockn, "out of", blocks)
	local str = net.ReadString()

	while str ~= "" do
		--print("", str)
		OSIRIS_BLACKLIST[str] = true
		str = net.ReadString()
	end

	if blockn == blocks then
		if IsValid(Osiris_Config_UI_Derma_Frame) then Osiris_Config_UI_Derma_Frame.UpdateModels() end
		receiving = false
	end
end)

net.Receive("OsirisConfig", function()
	OSIRIS_CONFIG = net.ReadTable()
	if IsValid(Osiris_Config_UI_Derma_Frame) then Osiris_Config_UI_Derma_Frame:ConfigUpdated() end
	hook.Call("OsirisConfigChanged")
end)

net.Receive("OsirisGroupRestrict", function()
	if IsValid(Osiris_Config_UI_Derma_Frame) then Osiris_Config_UI_Derma_Frame:UpdateGroups(net.ReadTable()) end
end)

net.Receive("OsirisToolRestrict", function()
	if IsValid(Osiris_Config_UI_Derma_Frame) then Osiris_Config_UI_Derma_Frame:UpdateTools(net.ReadTable()) end
end)

net.Receive("OsirisConfigVar", function()
	local var, val = net.ReadString(), net.ReadType()
	if not OSIRIS_CONFIG then OSIRIS_CONFIG = {} end
	OSIRIS_CONFIG[var] = val
	hook.Call("OsirisConfigChanged")
end)

hook.Add("OsirisConfigChanged", "FPPSettings", function()
	if FPP and FPP.Settings then
        if OSIRIS_CONFIG.DisableFPP then
            OSIRIS_FPP_OLD = table.Copy(FPP.Settings)
            for k, v in pairs(FPP.Settings) do
                for _, a in pairs(v) do
                    FPP.Settings[k][_] = 0
                end
            end
            GetConVar("FPP_PrivateSettings_HideOwner"):SetBool(true)
        elseif OSIRIS_FPP_OLD then
            FPP.Settings = OSIRIS_FPP_OLD
            GetConVar("FPP_PrivateSettings_HideOwner"):SetBool(false)
        end
	end
end)
