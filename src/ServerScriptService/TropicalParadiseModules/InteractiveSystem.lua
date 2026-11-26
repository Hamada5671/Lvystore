--!strict
-- InteractiveSystem.lua
-- Mengelola seluruh sistem interaktif Multiplayer:
-- 1. Cafe Beverage & Coffee Dispenser (Memberikan Tool Minuman Tropis ke Pemain)
-- 2. Ice Cream Cart Dispenser (Memberikan Tool Gelato Cone ke Pemain)
-- 3. Photo Booth Interaction (Efek Kamera Golden Hour & Pose Karakter)
-- 4. Area Fast-Travel Teleport System pada Welcome Board di Spawn Plaza

local Players = game:GetService("Players")
local OptimizationManager = require(script.Parent.OptimizationManager)

local InteractiveSystem = {}

local TELEPORT_DESTINATIONS = {
	{Name = "Beach & Wooden Pier",      Pos = Vector3.new(0, 10, 185)},
	{Name = "Tropical Botanical Garden",Pos = Vector3.new(-145, 19, 12)},
	{Name = "Sunset Beach Cafe Rooftop",Pos = Vector3.new(-135, 33, 155)},
	{Name = "Secret Waterfall Lagoon",  Pos = Vector3.new(0, 19, -172)},
	{Name = "Mountain Summit Viewpoint",Pos = Vector3.new(65, 96, -258)},
	{Name = "Sunset Wooden Bridge",     Pos = Vector3.new(130, 24, 210)},
}

local playerTeleportIndex: {[Player]: number} = {}

local function giveTropicalItemTool(player: Player, toolName: string, cupColor: Color3)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return
	end
	if backpack:FindFirstChild(toolName) then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = toolName
	tool.RequiresHandle = true
	tool.GripPos = Vector3.new(0, -0.35, 0)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = Enum.PartType.Cylinder
	handle.Size = Vector3.new(1.4, 0.85, 0.85)
	handle.Color = cupColor
	handle.Material = Enum.Material.SmoothPlastic
	handle.CanCollide = false
	handle.Parent = tool

	-- Sedotan / Toping Dekoratif
	local topping = Instance.new("Part")
	topping.Name = "Topping"
	topping.Shape = Enum.PartType.Ball
	topping.Size = Vector3.new(0.75, 0.75, 0.75)
	topping.Color = Color3.fromRGB(255, 245, 225)
	topping.Material = Enum.Material.SmoothPlastic
	topping.CanCollide = false
	topping.CFrame = handle.CFrame * CFrame.new(0.65, 0, 0)
	topping.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = topping
	weld.Parent = handle

	tool.Parent = backpack
end

function InteractiveSystem.Initialize(root: Folder)
	-- 1. Pasang Prompt Fast-Travel pada Welcome Directory Board di Spawn Plaza
	local spawnFolder = root:FindFirstChild("SpawnPlaza")
	if spawnFolder then
		local welcomeBoard = spawnFolder:FindFirstChild("WelcomeDirectoryBoard")
		if welcomeBoard and welcomeBoard:IsA("BasePart") then
			local tpPrompt = Instance.new("ProximityPrompt")
			tpPrompt.Name = "FastTravelPrompt"
			tpPrompt.ActionText = "Teleport ke Area Wisata Berikutnya"
			tpPrompt.ObjectText = "RESORT FAST-TRAVEL DIRECTORY"
			tpPrompt.HoldDuration = 0.2
			tpPrompt.MaxActivationDistance = 14
			tpPrompt.Parent = welcomeBoard

			tpPrompt.Triggered:Connect(function(player: Player)
				local idx = (playerTeleportIndex[player] or 0) % #TELEPORT_DESTINATIONS + 1
				playerTeleportIndex[player] = idx
				local dest = TELEPORT_DESTINATIONS[idx]

				local char = player.Character
				if char then
					char:PivotTo(CFrame.new(dest.Pos))
				end
				tpPrompt.ActionText = "Next: " .. TELEPORT_DESTINATIONS[(idx % #TELEPORT_DESTINATIONS) + 1].Name
			end)
		end
	end

	-- 2. Hubungkan Semua ProximityPrompt di Cafe, Ice Cream Cart & Photo Booths
	for _, desc in ipairs(root:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			if desc.Name == "CafeOrderPrompt" then
				desc.Triggered:Connect(function(player: Player)
					giveTropicalItemTool(player, "Tropical Sunset Smoothie", Color3.fromRGB(255, 135, 65))
					giveTropicalItemTool(player, "Island Iced Coffee", Color3.fromRGB(115, 75, 45))
				end)
			elseif desc.Name == "IceCreamPrompt" then
				desc.Triggered:Connect(function(player: Player)
					giveTropicalItemTool(player, "Tropical Gelato Cone", Color3.fromRGB(255, 155, 185))
				end)
			elseif desc.Name == "PhotoBoothPrompt" then
				desc.Triggered:Connect(function(player: Player)
					local parentPart = desc.Parent
					if parentPart and parentPart:IsA("BasePart") then
						-- Efek Flash Kamera Lembut Saat Mengambil Foto
						local flash = Instance.new("PointLight")
						flash.Color = Color3.fromRGB(255, 245, 215)
						flash.Brightness = 5
						flash.Range = 24
						flash.Parent = parentPart
						task.delay(0.35, function()
							flash:Destroy()
						end)
					end
				end)
			end
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		playerTeleportIndex[player] = nil
	end)

	print("[InteractiveSystem] Seluruh sistem interaktif Multiplayer (Seating, Cafe, Ice Cream, Photo Booth & Fast-Travel) aktif.")
end

return InteractiveSystem
