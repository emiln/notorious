local Notorious = {
    version = "1.0",
	UI = {
		facHeight = 18,
		fontSize = 12,
		visible = true,
		alpha = 0.8,
		dragAlpha = 0.3,
		width = 60,
		maxFacs = 5,
		x = 10,
		y = 10,
	},
	Event = {},
	State = {
		spamThreshold = 5,
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

	local main = UI.CreateFrame("Frame", "Notorious Main Frame", wrap)
	main:SetPoint("TOPLEFT", wrap, "TOPLEFT", 1, 1)
	main:SetPoint("TOPRIGHT", wrap, "TOPRIGHT", -1, 1)
	main:SetHeight(Notorious.UI.facHeight)
	main:SetBackgroundColor(0.1, 0.1, 0.1, Notorious.UI.alpha)

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

	local name = Notorious.UI.title
	name = UI.CreateFrame("Text", "Notorious Main Title", main)
	name:SetPoint("CENTERLEFT", main, "CENTERLEFT", 0, 0)
	name:SetPoint("CENTERRIGHT", main, "CENTERRIGHT", 0, 0)
	name:SetFontColor(0.9, 0.9, 0.9)
	name:SetText("Notorious")
	Notorious.UI.title = name

	local hori = UI.CreateFrame("Frame", "Notorious Main Frame HR", main)
	hori:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, 0)
	hori:SetPoint("TOPRIGHT", name, "BOTTOMRIGHT", 0, 0)
	hori:SetHeight(1)
	hori:SetBackgroundColor(0, 0, 0, Notorious.UI.alpha)

	local list = Notorious.UI.list
	list = UI.CreateFrame("Frame", "Notorious Faction List", main)
	list:SetPoint("TOPLEFT", hori, "BOTTOMLEFT", 0, 0)
	list:SetPoint("TOPRIGHT", hori, "BOTTOMRIGHT", 0, 0)
	list:SetHeight(0)
	Notorious.UI.list = list

	return wrap
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

local function ResizeList()
	local w = Notorious.UI.wrap
	local m = Notorious.UI.main
	local l = Notorious.UI.list
	local f = Notorious.State.factions
	table.sort(f, function (a, b)
			return a.remaining < b.remaining
		end)
	local idx = 0
	local wid = 0
	for i,fac in pairs(f) do
		local fra = fac.frame
		local w = fra:GetMinWidth()
		if (w > wid) then wid = w end
		fra:SetPoint("TOPLEFT", l, "TOPLEFT", 0, idx * Notorious.UI.facHeight)
		idx = idx + 1
	end
	local fh = #Notorious.State.factions * Notorious.UI.facHeight
	w:SetHeight(fh + Notorious.UI.facHeight + 3)
	m:SetHeight(fh + Notorious.UI.facHeight + 1)
	l:SetHeight(fh)
	m:SetWidth(wid)
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
	ResizeList()
end

local function CreateNotorietyBar(fac)
	id = fac.id
	name = fac.name
	noto = fac.notoriety
	frac = NotorietyFraction(id)
	rem = NotorietyRemaining(id)

	local list = Notorious.UI.list
	local cont = UI.CreateFrame("Frame", "NotoriousFrame ["..id.."]", list)
	local back = UI.CreateFrame("Frame", "NotoriousBG ["..id.."]", cont)
	local fact = UI.CreateFrame("Text", "Notorious ["..id.."]", back)
	local perc = UI.CreateFrame("Text", "Notorious Percentage ["..id.."]", back)
	local hori = UI.CreateFrame("Frame", "NotoriousHR ["..id.."]", cont)
	local vert = UI.CreateFrame("Frame", "NotoriousVR ["..id.."]", cont)
	
	cont:SetHeight(Notorious.UI.facHeight)
	cont:SetPoint("TOPLEFT", list, "TOPLEFT", 0,
		#Notorious.State.factions * Notorious.UI.facHeight)
	cont:SetPoint("TOPRIGHT", list, "TOPRIGHT", 0,
		#Notorious.State.factions * Notorious.UI.facHeight)
	
	back:SetBackgroundColor(1, 0, 0, 0.3)
	back:SetPoint("CENTERLEFT", cont, "CENTERLEFT", 0, 0)
	back:SetHeight(Notorious.UI.facHeight)
	back:SetWidth(Notorious.UI.width * frac)
	
	fact:SetPoint("CENTERLEFT", cont, "CENTERLEFT", 0, 0)
	fact:SetFontSize(Notorious.UI.fontSize)
	
	perc:SetPoint("CENTERRIGHT", cont, "CENTERRIGHT", 0, 0)
	perc:SetFontSize(Notorious.UI.fontSize)
	
	hori:SetHeight(1)
	hori:SetBackgroundColor(0, 0, 0, Notorious.UI.alpha)
	hori:SetPoint("BOTTOMLEFT", cont, "BOTTOMLEFT", 0, 0)
	hori:SetPoint("BOTTOMRIGHT", cont, "BOTTOMRIGHT", 0, 0)
	
	vert:SetWidth(1)
	vert:SetBackgroundColor(0.9, 0.9, 0.9, Notorious.UI.alpha)
	vert:SetPoint("TOPLEFT", fact, "TOPRIGHT", 0, 0)
	vert:SetPoint("BOTTOMLEFT", fact, "BOTTOMRIGHT", 0, -2)
	
	UpdateFaction(id)

	function cont:SetFraction(frac)
		print(cont:GetWidth())
		back:SetWidth(frac * cont:GetWidth())
		perc:SetText(math.floor(frac*100).."%")
	end
	
	function cont:SetText(txt)
		fact:SetText(txt)
	end
	
	function cont:GetMinWidth()
		return fact:GetWidth() + perc:GetWidth() + 3
	end

	return cont
end

Command.Event.Attach(
	Event.Faction.Notoriety,
	function (handle, notoriety)
		count = 0
		for k,c in pairs(notoriety) do
			count = count + 1
		end
		if (count > Notorious.State.spamThreshold) then return end
		
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
						if (#Notorious.State.factions < Notorious.UI.maxFacs) then
							local f = CreateNotorietyBar(fac)
							table.insert(Notorious.State.factions,
								{id=id, name=name, notoriety=noto, remaining=rem, frame=f})
							UpdateFaction(id)
						end
					end
				else
					UpdateFaction(id)
				end
			end
		end
		ResizeList()
	end,
	"Notoriety")
