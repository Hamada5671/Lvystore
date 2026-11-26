--!strict
-- MountainBuilder.lua
-- Membangun detail Pegunungan Tropis di belakang map:
-- Tebing batu organik, Jalur Hiking bertangga alami yang bisa dinaiki pemain,
-- Vegetasi lereng (Pinus & Pohon Tropis), Batu Alam bervariasi, dan Viewpoint Puncak.

local OptimizationManager = require(script.Parent.OptimizationManager)

local MountainBuilder = {}

local function createPineTree(origin: Vector3, scale: number, parent: Instance)
	local m = Instance.new("Model")
	m.Name = "TropicalHighlandPine"

	OptimizationManager.Part({
		Name = "Trunk",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(14 * scale, 1.8 * scale, 1.8 * scale),
		CFrame = CFrame.new(origin + Vector3.new(0, 7 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(92, 62, 38),
		Material = Enum.Material.Wood,
		Parent = m
	})

	for tier = 1, 4 do
		local radius = (11 - tier * 1.9) * scale
		local yOff = (6 + tier * 3.4) * scale
		OptimizationManager.Ellipsoid({
			Name = "PineTier_" .. tier,
			Size = Vector3.new(radius, 4.2 * scale, radius),
			Position = origin + Vector3.new(0, yOff, 0),
			Color = Color3.fromRGB(42, 102 + tier * 8, 52),
			Material = Enum.Material.LeafyGrass,
			CanCollide = false,
			Parent = m
		})
	end

	m.Parent = parent
end

function MountainBuilder.BuildMountains(root: Folder)
	local folder = root:FindFirstChild("MountainAndWaterfall") :: Folder

	-- 1. FORMASI TEBING BATU ORGANIK BESAR MENGAPIT GUNUNG & AIR TERJUN
	local cliffFormations = {
		{pos = Vector3.new(-42, 48, -265), size = Vector3.new(36, 75, 38)},
		{pos = Vector3.new(42, 48, -265),  size = Vector3.new(36, 75, 38)},
		{pos = Vector3.new(-85, 58, -285), size = Vector3.new(52, 88, 48)},
		{pos = Vector3.new(85, 58, -285),  size = Vector3.new(52, 88, 48)},
		{pos = Vector3.new(-145, 52, -295),size = Vector3.new(64, 78, 54)},
		{pos = Vector3.new(145, 52, -295), size = Vector3.new(64, 78, 54)},
	}

	for _, c in ipairs(cliffFormations) do
		OptimizationManager.CreateNaturalRock(c.pos, c.size, Color3.fromRGB(102, 98, 94), Enum.Material.Rock, folder)
		-- Sabuk lumut hijau di atas batu tebing
		OptimizationManager.Ellipsoid({
			Name = "CliffMoss",
			Size = Vector3.new(c.size.X * 0.85, 8, c.size.Z * 0.85),
			Position = c.pos + Vector3.new(0, c.size.Y * 0.42, 0),
			Color = Color3.fromRGB(68, 128, 58),
			Material = Enum.Material.LeafyGrass,
			Parent = folder
		})
	end

	-- 2. JALUR HIKING (HIKING TRAIL) DARI TEPI LAGOON MENUJU PUNCAK VIEWPOINT & TOWER
	-- Jalur Barat (Menuju Mountain Observation Tower di -70, 92, -280)
	local westSteps = 44
	for i = 0, westSteps do
		local t = i / westSteps
		local hx = -32 - (t * 42) + math.sin(t * math.pi * 2) * 12
		local hz = -175 - (t * 105)
		local hy = 15.2 + (t * 76.8)

		OptimizationManager.Part({
			Name = "HikingStepWest_" .. i,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.2, 8.5, 8.5),
			CFrame = CFrame.new(hx, hy, hz) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(132, 118, 102),
			Material = Enum.Material.Cobblestone,
			Parent = folder
		})

		if i % 8 == 0 then
			OptimizationManager.CreateLanternPost(Vector3.new(hx - 4.2, hy + 1, hz), 5.5, folder)
		end
	end

	-- Jalur Timur (Menuju Mountain View PhotoBooth #4 & Summit Viewpoint di 65, 92, -260)
	local eastSteps = 42
	for i = 0, eastSteps do
		local t = i / eastSteps
		local hx = 34 + (t * 32) + math.sin(t * math.pi * 2) * 10
		local hz = -175 - (t * 85)
		local hy = 15.2 + (t * 76.8)

		OptimizationManager.Part({
			Name = "HikingStepEast_" .. i,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.2, 8.5, 8.5),
			CFrame = CFrame.new(hx, hy, hz) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(132, 118, 102),
			Material = Enum.Material.Cobblestone,
			Parent = folder
		})

		if i % 8 == 0 then
			OptimizationManager.CreateLanternPost(Vector3.new(hx + 4.2, hy + 1, hz), 5.5, folder)
		end
	end

	-- 3. VEGETASI LERENG GUNUNG (POHON PINUS & POHON TROPIS)
	local treeSpots = {
		Vector3.new(-110, 78, -275), Vector3.new(-92, 84, -305), Vector3.new(-55, 88, -295),
		Vector3.new(55, 88, -295),   Vector3.new(95, 82, -285),  Vector3.new(125, 75, -275),
		Vector3.new(-165, 68, -260), Vector3.new(165, 68, -260), Vector3.new(0, 110, -295),
		Vector3.new(-28, 106, -290), Vector3.new(28, 106, -290),
	}
	for idx, pos in ipairs(treeSpots) do
		if idx % 2 == 0 then
			createPineTree(pos, 1.15, folder)
		else
			OptimizationManager.CreateCanopyTree(pos, 1.05, folder)
		end
	end

	print("[MountainBuilder] Pegunungan Tropis, Tebing Batu & Jalur Hiking selesai dibangun.")
end

return MountainBuilder
