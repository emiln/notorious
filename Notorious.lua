local Notorious = {
    version = "1.0",
	UI = {
		facHeight = 18,
		visible = true,
		alpha = 0.8,
		dragAlpha = 0.3,
		width = 200,
		maxFacs = 5,
		x = 10,
		y = 10,
	},
	Event = {},
	State = {
		factions = {},
		caps = {26000, 10000, 20000, 35000, 60000}
	},
}

local function CreateContext()
	local c = UI.CreateContext("Notorious Context")
	c:SetVisible(Notorious.UI.visible)
	return c
end

local function CreateMainFrame()
	local m = Notorious.UI.main

	local wrap = UI.CreateFrame("Frame", "Notorious Wrapper",
		Notorious.UI.context)
	wrap:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Notorious.UI.x, Notorious.UI.y)
	wrap:SetVisible(true)
	wrap:SetHeight(Notorious.UI.facHeight + 3)
	wrap:SetWidth(Notorious.UI.width + 2)
	wrap:SetBackgroundColor(0, 0, 0, Notorious.UI.alpha)
	Notorious.UI.wrap = wrap

	m = UI.CreateFrame("Frame", "Notorious Main Frame", wrap)
	m:SetPoint("TOPLEFT", wrap, "TOPLEFT", 1, 1)
	m:SetVisible(true)
	m:SetHeight(Notorious.UI.facHeight + 1)
	m:SetWidth(Notorious.UI.width)
	m:SetBackgroundColor(0.1, 0.1, 0.1, Notorious.UI.alpha)

	function wrap.Event:LeftDown()
		local mouse = Inspect.Mouse()
		wrap:SetAlpha(Notorious.UI.dragAlpha)
		Notorious.State.mouseDown1 = true
		Notorious.State.startX1 = Notorious.UI.wrap:GetLeft()
		Notorious.State.startY1 = Notorious.UI.wrap:GetTop()
		Notorious.State.mouseStartX1 = mouse.x
		Notorious.State.mouseStartY1 = mouse.y
	end

	function wrap.Event:MouseMove()
		if Notorious.State.mouseDown1 then
			Notorious.State.mouseMove1 = true
			local mouse = Inspect.Mouse()
			local x = mouse.x - Notorious.State.mouseStartX1 + Notorious.State.startX1
			local y = mouse.y - Notorious.State.mouseStartY1 + Notorious.State.startY1
			Notorious.UI.wrap:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
		end
	end

	function wrap.Event:LeftUp()
		wrap:SetAlpha(Notorious.UI.alpha)
		Notorious.State.mouseDown1 = false
	end

	local n = Notorious.UI.title
	n = UI.CreateFrame("Text", "Notorious Main Title", m)
	n:SetPoint("TOPCENTER", m, "TOPCENTER", 0, 0)
	n:SetFontColor(0.9, 0.9, 0.9)
	n:SetText("Notorious")
	Notorious.UI.title = n

	local h = UI.CreateFrame("Frame", "Notorious Main Frame HR", m)
	h:SetPoint("TOPCENTER", n, "BOTTOMCENTER", 0, 0)
	h:SetWidth(Notorious.UI.width)
	h:SetHeight(1)
	h:SetBackgroundColor(0, 0, 0, Notorious.UI.alpha)

	local l = Notorious.UI.list
	l = UI.CreateFrame("Frame", "Notorious Faction List", m)
	l:SetPoint("TOPCENTER", h, "BOTTOMCENTER", 0, 0)
	l:SetWidth(Notorious.UI.width)
	l:SetHeight(0)
	Notorious.UI.list = l

	return m
end

Notorious.UI.context = CreateContext()
Notorious.UI.main = CreateMainFrame()

local function NotorietyHandler(handle, notoriety)
	
end

local function FactionShown(name)
	for i,v in pairs(Notorious.State.factions) do
		if (v.name == name) then
			return true
		end
	end
	return false
end

local function NotorietyRemaining(facId)
	fac = Inspect.Faction.Detail(facId)
	if (not (fac == nil)) then
		id = fac.id
		name = fac.name
		noto = fac.notoriety
		sum = 0
		for k,v in pairs(Notorious.State.caps) do
			sum = sum + v
			if (sum > noto) then
				return sum - noto
			end
		end
	end
	return nil
end

local function NotorietyFraction(facId)
	fac = Inspect.Faction.Detail(facId)
	if (not (fac == nil)) then
		noto = fac.notoriety
		sum = 0
		last = 0
		for k,v in pairs(Notorious.State.caps) do
			last = sum
			sum = sum + v
			if (sum > noto) then
				return 1-((sum - noto)/v)
			end
		end
	end
	return 1
end

local function UpdateFaction(id)
	for i,v in pairs(Notorious.State.factions) do
		if (v.id == id) then
			rem = NotorietyRemaining(id)
			fra = NotorietyFraction(id)
			if (remaining == 0) then
				v.frame:SetVisible(false)
				table.remove(Notorious.State.factions, i)
				return
			end
			v.frame:SetText(v.name..": "..rem)
			v.frame:SetFraction(fra)
		end
	end
end

local function CreateNotorietyBar(fac)
	id = fac.id
	name = fac.name
	noto = fac.notoriety
	frac = NotorietyFraction(id)
	rem = NotorietyRemaining(id)

	local list = Notorious.UI.list
	local b = UI.CreateFrame("Frame", "NotoriousBG ["..id.."]", list)
	local f = UI.CreateFrame("Text", "Notorious ["..id.."]", b)
	local p = UI.CreateFrame("Text", "Notorious Percentage ["..id.."]", b)
	local h = UI.CreateFrame("Frame", "NotoriousHR ["..id.."]", f)
	h:SetWidth(Notorious.UI.width)
	h:SetHeight(1)
	h:SetBackgroundColor(0, 0, 0, Notorious.UI.alpha)
	h:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)

	b:SetPoint("TOPLEFT", list, "TOPLEFT", 0,
		#Notorious.State.factions * Notorious.UI.facHeight)
	f:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
	p:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

	b:SetWidth(frac * Notorious.UI.width)
	b:SetBackgroundColor(1, 0, 0, 0.3)
	b:SetHeight(Notorious.UI.facHeight)

	f:SetWidth(Notorious.UI.width)
	f:SetHeight(Notorious.UI.facHeight)
	UpdateFaction(id)

	function f:SetFraction(frac)
		b:SetWidth(frac * Notorious.UI.width)
		p:SetText(math.floor(frac*100).."%")
	end

	return f
end

local function ResizeList()
	local w = Notorious.UI.wrap
	local m = Notorious.UI.main
	local l = Notorious.UI.list
	local fh = #Notorious.State.factions * Notorious.UI.facHeight
	w:SetHeight(fh + Notorious.UI.facHeight + 3)
	m:SetHeight(fh + Notorious.UI.facHeight + 1)
	l:SetHeight(fh)
end

Command.Event.Attach(
	Event.Faction.Notoriety,
	function (handle, notoriety)
		for i,v in pairs(notoriety) do
			fac = Inspect.Faction.Detail(i)
			if (not (fac == nil)) then
				id = fac.id
				name = fac.name
				noto = fac.notoriety
				rem = NotorietyRemaining(id)
				if (not FactionShown(name)) then
					if (not (rem == nil)) then
						local list = Notorious.UI.list
						--[[local f = UI.CreateFrame("Text", "Notorious ["..id.."]", list)
						f:SetPoint("TOPCENTER", list, "TOPCENTER", 0,
							#Notorious.State.factions * Notorious.UI.facHeight)
						list:SetHeight(#Notorious.State.factions * Notorious.UI.facHeight)
						Notorious.UI.main:SetHeight(Notorious.UI.title:GetHeight() +
							#Notorious.State.factions * Notorious.UI.facHeight + 3)
						f:SetWidth(Notorious.UI.width)
						f:SetHeight(Notorious.UI.facHeight)]]--
						local f = CreateNotorietyBar(fac)
						table.insert(Notorious.State.factions,
							{id=id, name=name, notoriety=noto, frame=f})
						UpdateFaction(id)
					end
				else
					UpdateFaction(id)
				end
				ResizeList()
			end
		end
	end,
	"Notoriety")
