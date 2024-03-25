local addonName = "Flandre Stanby Screen"
local abs, sin, min, ceil
do
	local _obj_0 = math
	abs, sin, min, ceil = _obj_0.abs, _obj_0.sin, _obj_0.min, _obj_0.ceil
end
local ScrW, ScrH = ScrW, ScrH
local Add = hook.Add
local cl_flandre_color = CreateClientConVar("cl_flandre_color", "0.15 0.15 0.15", true, false, "Background color of standby screen.")
local cl_flandre_size = CreateClientConVar("cl_flandre_size", "25", true, false, "Size of standby screen icon.", 1, 100)
local width, height = ScrW(), ScrH()
local vmin = min(width, height) / 100
Add("OnScreenSizeChanged", addonName, function()
	width, height = ScrW(), ScrH()
	vmin = min(width, height) / 100
end)
local backgroundColor = Vector(cl_flandre_color:GetString()):ToColor()
cvars.AddChangeCallback(cl_flandre_color:GetName(), function(_, __, value)
	backgroundColor = Vector(value):ToColor()
end, addonName)
local isInFocus, isSinglePlayer = false, game.SinglePlayer()
local drawFlandre = nil
do
	local DrawRect, DrawTexturedRect, SetMaterial, SetDrawColor
	do
		local _obj_0 = surface
		DrawRect, DrawTexturedRect, SetMaterial, SetDrawColor = _obj_0.DrawRect, _obj_0.DrawTexturedRect, _obj_0.SetMaterial, _obj_0.SetDrawColor
	end
	local RealTime = RealTime
	local HasFocus = system.HasFocus
	local x, y, size, shadow1, shadow2, mult = 0, 0, 0, 0, 0, 0
	local material = Material("flan/flanderka")
	Add("Think", addonName, function()
		isInFocus = HasFocus()
		if not isInFocus then
			size = ceil(vmin * cl_flandre_size:GetInt())
			x, y = (width - size) / 2, (height - size) / 2
			mult = 0.25 + abs(sin(RealTime())) * 0.25
			shadow1 = size * 0.1 * mult
			shadow2 = size * 0.2 * mult
		end
	end)
	drawFlandre = function()
		SetDrawColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
		DrawRect(0, 0, width, height)
		SetMaterial(material)
		SetDrawColor(0, 0, 0, 60)
		DrawTexturedRect(x - shadow1, y - shadow1, size, size)
		SetDrawColor(0, 0, 0, 120)
		DrawTexturedRect(x + shadow2, y + shadow2, size, size)
		SetDrawColor(255, 255, 255)
		return DrawTexturedRect(x, y, size, size)
	end
	if not isSinglePlayer then
		Add("DrawOverlay", addonName, function()
			if isInFocus then
				return
			end
			return drawFlandre()
		end)
	end
end
local Start2D, End2D
do
	local _obj_0 = cam
	Start2D, End2D = _obj_0.Start2D, _obj_0.End2D
end
return Add("RenderScene", addonName, function()
	if isInFocus then
		return
	end
	if isSinglePlayer then
		Start2D()
		drawFlandre()
		End2D()
	end
	return true
end)
