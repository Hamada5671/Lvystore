--!strict
-- TowerBuilder.lua
-- Membangun 3 Menara Observasi & Pengawas dengan Desain Berbeda:
-- 1. Lifeguard Tower (Dekat Pantai, Tangga, Kursi Pengawas, Atap Kayu, Lampu Keselamatan)
-- 2. Mountain Observation Tower (Di Gunung, Platform Tinggi, Tangga, Railing, View Seluruh Map)
-- 3. Garden Viewing Tower (Desain Kayu Natural, Menghadap Taman, Spot Foto)
-- Semua tower memiliki collision akurat dan akses tangga yang berfungsi.

local OptimizationManager = require(script.Parent.OptimizationManager)

local TowerBuilder = {}

function TowerBuilder.BuildAllTowers(root: Folder)
	local folder = root:FindFirstChild("ObservationTowers") :: Folder

	-- =========================================================================
	-- 1. LIFEGUARD TOWER (DEKAT PANTAI DI -82, 6.8, 192)
	-- =========================================================================
	local lgOrigin = Vector3.new(-82, 6.8, 192)
	local lgTower = Instance.new("Model")
	lgTower.Name = "BeachLifeguardTower"

	local lgHeight = 12
	for _, px in ipairs({-4, 4}) do
		for _, pz in ipairs({-4, 4}) do
			OptimizationManager.Part({
				Name = "LifeguardStilt",
				Size = Vector3.new(0.9, lgHeight, 0.9),
				Position = lgOrigin + Vector3.new(px, lgHeight * 0.5, pz),
				Color = Color3.fromRGB(238, 232, 220),
				Material = Enum.Material.Wood,
				Parent = lgTower
			})
		end
	end

	-- Platform Dek Pengawas
	OptimizationManager.Part({
		Name = "LifeguardDeck",
		Size = Vector3.new(11, 0.7, 11),
		Position = lgOrigin + Vector3.new(0, lgHeight, 0),
		Color = Color3.fromRGB(215, 72, 58),
		Material = Enum.Material.WoodPlanks,
		Parent = lgTower
	})

	-- Kabin & Kursi Pengawas Pantai
	OptimizationManager.Part({
		Name = "LifeguardCabinBack",
		Size = Vector3.new(7, 6.5, 4.5),
		Position = lgOrigin + Vector3.new(0, lgHeight + 3.5, -2.2),
		Color = Color3.fromRGB(242, 238, 228),
		Material = Enum.Material.WoodPlanks,
		Parent = lgTower
	})
	local lgSeat = Instance.new("Seat")
	lgSeat.Name = "LifeguardChairSeat"
	lgSeat.Anchored = true
	lgSeat.Size = Vector3.new(2.6, 1.8, 2.4)
	lgSeat.CFrame = CFrame.new(lgOrigin + Vector3.new(0, lgHeight + 1.4, 2.2)) * CFrame.Angles(0, math.rad(180), 0)
	lgSeat.Color = Color3.fromRGB(215, 72, 58)
	lgSeat.Material = Enum.Material.Wood
	lgSeat.Parent = lgTower

	-- Atap Kayu Miring & Lampu Keselamatan
	OptimizationManager.Part({
		Name = "LifeguardRoof",
		Size = Vector3.new(12, 0.8, 12.5),
		CFrame = CFrame.new(lgOrigin + Vector3.new(0, lgHeight + 7.6, 0)) * CFrame.Angles(math.rad(10), 0, 0),
		Color = Color3.fromRGB(215, 72, 58),
		Material = Enum.Material.WoodPlanks,
		Parent = lgTower
	})
	local beacon = OptimizationManager.Ellipsoid({
		Name = "SafetyBeaconLight",
		Size = Vector3.new(1.4, 1.6, 1.4),
		Position = lgOrigin + Vector3.new(0, lgHeight + 8.8, 4.5),
		Color = Color3.fromRGB(255, 195, 65),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = lgTower
	})
	local bLight = Instance.new("PointLight")
	bLight.Color = Color3.fromRGB(255, 190, 75)
	bLight.Brightness = 2
	bLight.Range = 32
	bLight.Parent = beacon

	-- Tangga Akses Fungsional (TrussPart)
	local lgLadder = Instance.new("TrussPart")
	lgLadder.Name = "LifeguardClimbLadder"
	lgLadder.Anchored = true
	lgLadder.Size = Vector3.new(2, lgHeight + 1, 2)
	lgLadder.Position = lgOrigin + Vector3.new(0, (lgHeight + 1) * 0.5, -5.8)
	lgLadder.Color = Color3.fromRGB(238, 232, 220)
	lgLadder.Material = Enum.Material.Wood
	lgLadder.Parent = lgTower

	lgTower.Parent = folder

	-- =========================================================================
	-- 2. MOUNTAIN OBSERVATION TOWER (DI AREA GUNUNG -70, 92, -280)
	-- =========================================================================
	local mtOrigin = Vector3.new(-70, 92, -280)
	local mtTower = Instance.new("Model")
	mtTower.Name = "MountainObservationTower"

	local mtHeight = 28
	for _, px in ipairs({-7, 7}) do
		for _, pz in ipairs({-7, 7}) do
			OptimizationManager.Part({
				Name = "HeavyTimberColumn",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(mtHeight + 10, 1.5, 1.5),
				CFrame = CFrame.new(mtOrigin + Vector3.new(px, (mtHeight + 10) * 0.5, pz)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(92, 58, 34),
				Material = Enum.Material.Wood,
				Parent = mtTower
			})
		end
	end

	-- Platform Tengah & Platform Puncak Observasi
	OptimizationManager.Part({
		Name = "MidLandingPlatform",
		Size = Vector3.new(16, 0.8, 16),
		Position = mtOrigin + Vector3.new(0, mtHeight * 0.5, 0),
		Color = Color3.fromRGB(132, 86, 48),
		Material = Enum.Material.WoodPlanks,
		Parent = mtTower
	})
	local topDeck = OptimizationManager.Part({
		Name = "TopObservationDeck",
		Size = Vector3.new(18, 1.0, 18),
		Position = mtOrigin + Vector3.new(0, mtHeight, 0),
		Color = Color3.fromRGB(142, 94, 54),
		Material = Enum.Material.WoodPlanks,
		Parent = mtTower
	})

	-- Railing Keselamatan 4 Sisi di Puncak Tower
	for _, zSide in ipairs({-8.6, 8.6}) do
		OptimizationManager.Part({
			Name = "SafetyRailNS",
			Size = Vector3.new(18, 3.5, 0.5),
			Position = mtOrigin + Vector3.new(0, mtHeight + 2.0, zSide),
			Color = Color3.fromRGB(104, 66, 38),
			Material = Enum.Material.Wood,
			Parent = mtTower
		})
	end
	for _, xSide in ipairs({-8.6, 8.6}) do
		OptimizationManager.Part({
			Name = "SafetyRailEW",
			Size = Vector3.new(0.5, 3.5, 18),
			Position = mtOrigin + Vector3.new(xSide, mtHeight + 2.0, 0),
			Color = Color3.fromRGB(104, 66, 38),
			Material = Enum.Material.Wood,
			Parent = mtTower
		})
	end

	-- Atap Paviliun Puncak Gunung
	OptimizationManager.Ellipsoid({
		Name = "MountainTowerRoof",
		Size = Vector3.new(22, 6, 22),
		Position = mtOrigin + Vector3.new(0, mtHeight + 11, 0),
		Color = Color3.fromRGB(124, 78, 44),
		Material = Enum.Material.WoodPlanks,
		Parent = mtTower
	})

	-- Tangga Panjat Utama (TrussPart) dari Dasar ke Puncak
	local mtLadder = Instance.new("TrussPart")
	mtLadder.Name = "MountainTowerClimbTruss"
	mtLadder.Anchored = true
	mtLadder.Size = Vector3.new(2, mtHeight + 1, 2)
	mtLadder.Position = mtOrigin + Vector3.new(0, (mtHeight + 1) * 0.5, 9.2)
	mtLadder.Color = Color3.fromRGB(115, 74, 42)
	mtLadder.Material = Enum.Material.Wood
	mtLadder.Parent = mtTower

	OptimizationManager.CreateLanternPost(mtOrigin + Vector3.new(-7.5, mtHeight + 0.5, 7.5), 4.8, mtTower)
	OptimizationManager.CreateLanternPost(mtOrigin + Vector3.new(7.5, mtHeight + 0.5, 7.5), 4.8, mtTower)
	mtTower.Parent = folder

	-- =========================================================================
	-- 3. GARDEN VIEWING TOWER (MENGHADAP TAMAN DI -215, 15.2, -18)
	-- =========================================================================
	local gdOrigin = Vector3.new(-215, 15.2, -18)
	local gdTower = Instance.new("Model")
	gdTower.Name = "GardenViewingTower"

	local gdHeight = 18
	for _, px in ipairs({-5, 5}) do
		for _, pz in ipairs({-5, 5}) do
			OptimizationManager.Part({
				Name = "GardenTowerLog",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(gdHeight + 8, 1.1, 1.1),
				CFrame = CFrame.new(gdOrigin + Vector3.new(px, (gdHeight + 8) * 0.5, pz)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(106, 70, 42),
				Material = Enum.Material.Wood,
				Parent = gdTower
			})
		end
	end

	local gdDeck = OptimizationManager.Part({
		Name = "GardenViewingDeck",
		Size = Vector3.new(13, 0.8, 13),
		Position = gdOrigin + Vector3.new(0, gdHeight, 0),
		Color = Color3.fromRGB(138, 92, 54),
		Material = Enum.Material.WoodPlanks,
		Parent = gdTower
	})
	OptimizationManager.Ellipsoid({
		Name = "GardenCanopyRoof",
		Size = Vector3.new(16, 4.8, 16),
		Position = gdOrigin + Vector3.new(0, gdHeight + 8.8, 0),
		Color = Color3.fromRGB(68, 138, 62),
		Material = Enum.Material.LeafyGrass,
		Parent = gdTower
	})

	local gdLadder = Instance.new("TrussPart")
	gdLadder.Name = "GardenTowerLadder"
	gdLadder.Anchored = true
	gdLadder.Size = Vector3.new(2, gdHeight + 1, 2)
	gdLadder.Position = gdOrigin + Vector3.new(6.8, (gdHeight + 1) * 0.5, 0)
	gdLadder.Color = Color3.fromRGB(122, 80, 46)
	gdLadder.Material = Enum.Material.Wood
	gdLadder.Parent = gdTower

	-- Prompt Spot Foto di Atas Garden Viewing Tower
	local gdPrompt = Instance.new("ProximityPrompt")
	gdPrompt.Name = "PhotoBoothPrompt"
	gdPrompt.ActionText = "Nikmati Panorama Taman Tropis"
	gdPrompt.ObjectText = "GARDEN VIEWING TOWER"
	gdPrompt.HoldDuration = 0.25
	gdPrompt.Parent = gdDeck

	gdTower.Parent = folder

	print("[TowerBuilder] Lifeguard Tower, Mountain Observation Tower & Garden Viewing Tower selesai dibangun.")
end

return TowerBuilder
