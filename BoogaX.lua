local lib = loadstring(game:HttpGet("https://pastebin.com/raw/qwdPKKDN"))()

local booga = lib.new("BoogaX")
local Local = booga:addPage("LocalPlayer", 5012544693)
local auto = Local:addSection("Automation")

local getGlobal = function()
	for i, v in pairs(getrenv()) do
		if tostring(i) == "_G" then
			return v.SD[game.Players.LocalPlayer.UserId]
		end
	end
end

local getMeds = function()
	for i, v in pairs(getGlobal().inventory) do
		for x, c in pairs(v) do
			if tostring(c) == "Medicine" then
				return i
			end
		end
	end
	return false
end

local heal = false
local hBelow = 20
local healStart = function()
	heal = true
	spawn(function()
		while wait() do
			if not heal then
				return
			end
			if getMeds() then
				local max = getGlobal().stats.maxHealth
				local health = getGlobal().stats.health
				if health < (max - hBelow) then
					local EatInventoryItem = game:GetService("ReplicatedStorage").Relay.Inventory.EatInventoryItem
					EatInventoryItem:FireServer(getMeds())
					wait(1)
				end
			end
		end
	end)
end

auto:addToggle("Auto-heal", nil, function(bool)
	if bool then
		return healStart()
	end
	heal = false
end)

auto:addSlider("Heal after 20 HP loss", 20, 1, 50, function(v)
	hBelow = v
	auto:updateSlider(auto.modules[2], "Heal after "..v.." HP loss", v, 1, 50)
end)

-- End of auto-heal
local plantgrab = false
local pFrequency = 1
local plantGrab = function()
	plantgrab = true
	spawn(function()
		while wait() do
			if not plantgrab then
				return
			end
			for i, v in pairs(game.Workspace.Deployables:GetChildren()) do
				if v.Name == "Plant Box" and v.Grown:GetChildren()[1] then
					local HR = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
					local PT = v.Grown:GetChildren()[1]:FindFirstChildOfClass("Part").Position
					local Mag = (HR - PT).magnitude
					if Mag < 25 then
						wait(pFrequency)
						local Pickup = game:GetService("ReplicatedStorage").Relay.Pickup
						Pickup:FireServer(v.Grown:GetChildren()[1])
					end
				end
			end
		end
	end)
end

auto:addToggle("Auto-grab plants from boxes", nil, function(bool)
	if bool then
		return plantGrab()
	end
	plantgrab = false
end)

auto:addSlider("Grab every 1 second(s)", 1, 0, 10, function(v)
	pFrequency = v
	auto:updateSlider(auto.modules[4], "Grab every "..v.." second(s)", v, 0, 10)
	if platgrab then
		plantgrab = false
		plantGrab()
	end
end)
-- End of plants grabber
local combat = Local:addSection("Combat")

local getClosest = function()
	local Players = game.Players
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not (Character or HumanoidRootPart) then
		return
	end
	local TargetDistance = math.huge
	local Target
	for i, v in ipairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local TargetHRP = v.Character.HumanoidRootPart
			local mag = (HumanoidRootPart.Position - TargetHRP.Position).magnitude
			if mag < TargetDistance then
				TargetDistance = mag
				Target = v
			end
		end
	end
	return Target
end

local crender = false
local kill = false
local startKill = function()
	kill = true
	spawn(function()
		if not crender then
			while wait() do
				if not kill then
					return
				end
				local HR = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
				local CL = getClosest()
				local PT = CL.Character.HumanoidRootPart.Position
				if (HR - PT).magnitude < 5 then
					local wChar = game.Workspace[CL.Name]
					local SwingTool = game:GetService("ReplicatedStorage").Relay.SwingTool
					SwingTool:FireServer({
						wChar.Head
					})
				end
			end
		else
			game:GetService("RunService").Stepped:connect(function()
				if not kill then
					return
				end
				local HR = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
				local CL = getClosest()
				local PT = CL.Character.HumanoidRootPart.Position
				if (HR - PT).magnitude < 5 then
					local wChar = game.Workspace[CL.Name]
					local SwingTool = game:GetService("ReplicatedStorage").Relay.SwingTool
					SwingTool:FireServer({
						wChar.Head
					})
				end
			end)
		end
	end)
end

combat:addToggle("Kill-aura", nil, function(bool)
	if bool then
		return startKill()
	end
	kill = false 
end)

combat:addToggle("RenderStepped Kill-aura", false, function(bool)
	crender = bool
	if kill then
		kill = false
		startKill()
	end
end)
-- End of kill-aura
local autoeat = false
local ethreshold = 80
local gfoods = {}
for i, v in pairs(require(game.ReplicatedStorage.Modules.EntityData.Food)) do
	if i ~= "Medicine" then
		table.insert(gfoods, i)
	end
end

local getFoods = function()
	local foods = {}
	for i, v in pairs(getGlobal().inventory) do
		for x, c in pairs(v) do
			if table.find(gfoods, tostring(c)) then
				table.insert(foods, c)
			end
		end
	end
	return foods
end

local getFoodValue = function(n)
	for i, v in pairs(require(game.ReplicatedStorage.Modules.EntityData.Food)) do
		if tostring(i) == n then
			return v.nourishment.food
		end
	end
end

local getHighestValuedFood = function(f)
	local Highest = 0
	local Food
	for i, v in pairs(getFoods()) do
		if getFoodValue(v) > Highest then
			Highest = getFoodValue(v)
			Food = v
		end
	end
	return Food
end

local findFoodInv = function(f)
	for i, v in pairs(getGlobal().inventory) do
		for x, c in pairs(v) do
			if tostring(c) == tostring(f) then
				return i
			end
		end
	end
	return false
end

local startEating = function()
	autoeat = true
	spawn(function()
		while wait(1) do
			if not autoeat then
				return
			end
			if getGlobal().stats.food < ethreshold then
				local EatInventoryItem = game:GetService("ReplicatedStorage").Relay.Inventory.EatInventoryItem
				EatInventoryItem:FireServer(findFoodInv(getHighestValuedFood()))
			end
		end
	end)
end

auto:addToggle("Auto-eat", nil, function(bool)
	if bool then
		return startEating()
	end
	autoeat = false
end)

auto:addSlider("Eat at 80 hunger", 80, 5, 90, function(v)
	ethreshold = v
	auto:updateSlider(auto.modules[6], "Eat at "..v.." hunger", v, 5, 90)
	if autoeat then
		autoeat = false
		startEating()
	end
end)
-- End of autoeat
local autopick = false
local autodis = 5
local pickupspeed = 1
local pickup = function()
	autopick = true
	spawn(function()
		while wait() do
			if not autopick then
				return
			end
			for i, v in pairs(game.Workspace.ItemDrops:GetChildren()) do
				if v:FindFirstChild("Pickup") then
					wait(tonumber("."..pickupspeed))
					local HR = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
					local PR = v.Position
					if ((HR - PR).magnitude) < autodis then
						local Pickup = game:GetService("ReplicatedStorage").Relay.Pickup
						Pickup:FireServer(v)
					end
				end
			end
		end
	end)
end

auto:addToggle("Auto-pickup", nil, function(bool)
	if bool then
		return pickup()
	end
	autopick = false
end)

auto:addSlider("Max distance", 5, 1, 25, function(v)
	autodis = v
end)

auto:addSlider("Pickup speed (.1 seconds)", 1, 0, 9, function(v)
	pickupspeed = v
	auto:updateSlider(auto.modules[9], "Pickup speed (."..v.." seconds)", v, 0, 9)
end)
-- End of AutoPickup BTW [9] on slider here
local plantc = false
local pname = ""
local findInv = function(n)
	for i, v in pairs(getGlobal().inventory) do
		for x, c in pairs(v) do
			if tostring(c) == n then
				return i
			end
		end
	end
	return false
end

local startPlanting = function()
	spawn(function()
		plantc = true
		while wait(0.1) do
			if not plantc then
				return
			end
			for i, v in pairs(game.Workspace.Deployables:GetChildren()) do
				if v.Name == "Plant Box" then
					local HP = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
					local PT = v:FindFirstChild("Part").Position
					if (HP - PT).magnitude < 5 and not v.Grown:GetChildren()[1] and findInv(pname) then
						local SID = v.Structure_ID.Value
						local InputStructure = game:GetService("ReplicatedStorage").Relay.Structures.InputStructure
						local inInv = findInv(pname)
						InputStructure:FireServer(SID, inInv, v)
						wait(0.1)
					end
				end
			end
		end
	end)
end

auto:addToggle("Auto-plant", nil, function(bool)
	if bool then
		return startPlanting()
	end
	plantc = bool
end)

auto:addTextbox("Plant name", "None", function(t, f)
	if f then
		pname = t
	end
end)
-- End of autoplant

booga:SelectPage(booga.pages[1], true)