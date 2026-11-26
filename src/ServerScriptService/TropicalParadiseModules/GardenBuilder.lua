--!strict
-- GardenBuilder.lua
-- Membangun Tropical Garden luas & realistis:
-- Pohon besar rindang, Palem, Semak bunga, Pakis, Tanaman merambat,
-- Kolam Ikan Koi dengan Jembatan Kayu Kecil, Gazebo Kayu, String Lights,
-- Area Piknik (Meja & Kursi Kayu), dan Bangku Taman.

local OptimizationManager = require(script.Parent.OptimizationManager)

local GardenBuilder = {}

local function createFernAndFlowerCluster(pos: Vector3, flowerColor: Color3, parent: Instance)
	local m = Instance.new("Model")
	m.Name = "TropicalFloraCluster"

	-- Semak Hijau
	OptimizationManager.Ellipsoid({
		Name = "BushBase",
		Size = Vector3.new(4.8, 2.6, 4.8),
		Position = pos + Vector3.new(0, 1.1, 0),
		Color = Color3.fromRGB(54, 128, 52),
		Material = Enum.Material.LeafyGrass,
		CanCollide = false,
		Parent = m
	})

	-- Daun Pakis Melengkung
	for f = 1, 6 do
		local a = (f / 6) * math.pi * 2
		OptimizationManager.Ellipsoid({
			Name = "FernLeaf",
			Size = Vector3.new(1.2, 0.3, 3.4),
			CFrame = CFrame.new(pos + Vector3.new(math.cos(a) * 1.8, 1.4, math.sin(a) * 1.8)) * CFrame.Angles(math.rad(20), a, 0),
			Color = Color3.fromRGB(72, 154, 62),
			Material = Enum.Material.LeafyGrass,
			CanCollide = false,
			CastShadow = false,
			Parent = m
		})
	end

	-- Kelopak Bunga Tropis
	for b = 1, 5 do
		local a = (b / 5) * math.pi * 2
		OptimizationManager.Ellipsoid({
			Name = "FlowerBlossom",
			Size = Vector3.new(0.85, 0.65, 0.85),
			Position = pos + Vector3.new(math.cos(a) * 1.3, 2.35, math.sin(a) * 1.3),
			Color = flowerColor,
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
			CastShadow = false,
			Parent = m
		})
	end

	m.Parent = parent
end

local function createPicnicTable(pos: Vector3, yaw: number, parent: Instance)
	local m = Instance.new("Model")
	m.Name = "PicnicTableSet"
	local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)

	-- Meja Kayu
	OptimizationManager.Part({
		Name = "TableTop",
		Size = Vector3.new(7, 0.5, 3.4),
		CFrame = cf * CFrame.new(0, 2.6, 0),
		Color = Color3.fromRGB(138, 92, 54),
		Material = Enum.Material.WoodPlanks,
		Parent = m
	})

	-- Dua Bangku Panjang + Seat
	for _, zSide in ipairs({-2.8, 2.8}) do
		OptimizationManager.Part({
			Name = "BenchPlank",
			Size = Vector3.new(7, 0.45, 1.4),
			CFrame = cf * CFrame.new(0, 1.5, zSide),
			Color = Color3.fromRGB(124, 80, 46),
			Material = Enum.Material.WoodPlanks,
			Parent = m
		})
		for _, xOff in ipairs({-1.8, 1.8}) do
			local seat = Instance.new("Seat")
			seat.Name = "PicnicSeat"
			seat.Anchored = true
			seat.Size = Vector3.new(2, 0.4, 1.4)
			seat.Transparency = 1
			seat.CFrame = cf * CFrame.new(xOff, 1.75, zSide) * (if zSide > 0 then CFrame.Angles(0, math.rad(180), 0) else CFrame.identity)
			seat.Parent = m
		end
	end

	m.Parent = parent
end

function GardenBuilder.BuildTropicalGarden(root: Folder)
	local folder = root:FindFirstChild("TropicalGarden") :: Folder
	local baseY = 15.2

	-- 1. KOLAM IKAN KOI (KOI POND) DENGAN AIR MANCUR KECIL & JEMBATAN KAYU
	local pondCenter = Vector3.new(-145, baseY, -15)
	OptimizationManager.Part({
		Name = "KoiPondStoneRim",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.6, 28, 28),
		CFrame = CFrame.new(pondCenter + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(128, 124, 118),
		Material = Enum.Material.Cobblestone,
		Parent = folder
	})
	OptimizationManager.Part({
		Name = "KoiPondWater",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.3, 25.5, 25.5),
		CFrame = CFrame.new(pondCenter + Vector3.new(0, 0.65, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(28, 175, 185),
		Material = Enum.Material.Glass,
		Transparency = 0.3,
		CanCollide = false,
		Parent = folder
	})

	-- Ikan Koi & Daun Teratai di Kolam
	for k = 1, 7 do
		local a = (k / 7) * math.pi * 2
		local r = 5 + (k % 3) * 2.5
		OptimizationManager.Ellipsoid({
			Name = "KoiFish_" .. k,
			Size = Vector3.new(0.45, 0.35, 1.45),
			CFrame = CFrame.new(pondCenter + Vector3.new(math.cos(a) * r, 1.1, math.sin(a) * r)) * CFrame.Angles(0, a + 1.5, 0),
			Color = if k % 2 == 0 then Color3.fromRGB(255, 105, 35) else Color3.fromRGB(255, 235, 220),
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
			CastShadow = false,
			Parent = folder
		})
		OptimizationManager.Part({
			Name = "LilyPad_" .. k,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.12, 2.2, 2.2),
			CFrame = CFrame.new(pondCenter + Vector3.new(math.cos(a + 0.5) * (r + 1.5), 1.32, math.sin(a + 0.5) * (r + 1.5))) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(65, 148, 58),
			Material = Enum.Material.LeafyGrass,
			CanCollide = false,
			CastShadow = false,
			Parent = folder
		})
	end

	-- Jembatan Kayu Kecil Melengkung di Atas Kolam Koi
	for b = -6, 6 do
		local t = b / 6
		local archH = math.cos(t * math.pi * 0.5) * 2.4
		OptimizationManager.Part({
			Name = "KoiBridgePlank",
			Size = Vector3.new(2.0, 0.45, 6.2),
			CFrame = CFrame.new(pondCenter + Vector3.new(b * 2.1, 1.2 + archH, 0)),
			Color = Color3.fromRGB(142, 85, 48),
			Material = Enum.Material.WoodPlanks,
			Parent = folder
		})
	end

	-- 2. GAZEBO KAYU BESAR DI TENGAH TAMAN (-175, baseY, 22)
	local gazPos = Vector3.new(-175, baseY, 22)
	OptimizationManager.Part({
		Name = "GardenGazeboFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.2, 20, 20),
		CFrame = CFrame.new(gazPos + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(134, 88, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = folder
	})
	for p = 1, 8 do
		local a = (p / 8) * math.pi * 2
		OptimizationManager.Part({
			Name = "GardenGazeboPost",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(10, 0.9, 0.9),
			CFrame = CFrame.new(gazPos + Vector3.new(math.cos(a) * 8.2, 5.6, math.sin(a) * 8.2)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(104, 66, 38),
			Material = Enum.Material.Wood,
			Parent = folder
		})
	end
	OptimizationManager.Ellipsoid({
		Name = "GardenGazeboRoof",
		Size = Vector3.new(23, 6, 23),
		Position = gazPos + Vector3.new(0, 11.8, 0),
		Color = Color3.fromRGB(148, 96, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = folder
	})

	-- 3. AREA PIKNIK (MEJA KAYU & KURSI) + STRING LIGHTS GANTUNG
	createPicnicTable(Vector3.new(-125, baseY, 35), 0.3, folder)
	createPicnicTable(Vector3.new(-145, baseY, 48), -0.2, folder)
	createPicnicTable(Vector3.new(-165, baseY, 52), 0.5, folder)

	-- Tiang & String Lights Warm White di Area Piknik
	local poleA = Vector3.new(-118, baseY, 28)
	local poleB = Vector3.new(-172, baseY, 58)
	OptimizationManager.CreateLanternPost(poleA, 11, folder)
	OptimizationManager.CreateLanternPost(poleB, 11, folder)
	for s = 1, 9 do
		local t = s / 10
		local pos = poleA:Lerp(poleB, t) + Vector3.new(0, 10.5 - math.sin(t * math.pi) * 2.2, 0)
		local bulb = OptimizationManager.Ellipsoid({
			Name = "StringLightBulb_" .. s,
			Size = Vector3.new(0.65, 0.85, 0.65),
			Position = pos,
			Color = Color3.fromRGB(255, 218, 145),
			Material = Enum.Material.Neon,
			CanCollide = false,
			CastShadow = false,
			Parent = folder
		})
		if s % 3 == 0 then
			local pl = Instance.new("PointLight")
			pl.Color = Color3.fromRGB(255, 205, 130)
			pl.Brightness = 1.2
			pl.Range = 20
			pl.Parent = bulb
		end
	end

	-- 4. POHON BESAR RINDANG, PALEM, SEMAK BUNGA & PAKIS
	local canopySpots = {
		Vector3.new(-115, baseY, -45), Vector3.new(-185, baseY, -35),
		Vector3.new(-235, baseY, 15),  Vector3.new(-245, baseY, 75),
		Vector3.new(-135, baseY, 85),  Vector3.new(-95, baseY, 55),
	}
	for _, pos in ipairs(canopySpots) do
		OptimizationManager.CreateCanopyTree(pos, 1.15, folder)
	end

	local flowerColors = {
		Color3.fromRGB(255, 95, 135),
		Color3.fromRGB(255, 195, 55),
		Color3.fromRGB(195, 105, 255),
		Color3.fromRGB(255, 125, 65),
	}
	for f = 1, 22 do
		local ang = (f / 22) * math.pi * 2
		local rad = 28 + (f % 4) * 16
		local fPos = Vector3.new(-165 + math.cos(ang) * rad, baseY, 20 + math.sin(ang) * rad)
		createFernAndFlowerCluster(fPos, flowerColors[(f % #flowerColors) + 1], folder)
	end

	print("[GardenBuilder] Tropical Garden, Kolam Koi, Gazebo & Area Piknik selesai dibangun.")
end

return GardenBuilder
