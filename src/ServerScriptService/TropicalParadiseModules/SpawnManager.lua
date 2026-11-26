--!strict
-- SpawnManager.lua
-- Membangun Main Spawn Plaza dengan desain Resort Tropis:
-- SpawnLocation rata & aman, Gerbang Kayu & Batu Alam, Sign "TROPICAL PARADISE",
-- Kolam Dekoratif Air Jernih + Air Mancur, Gazebo Santai, Bangku, Welcome Board,
-- dan Jalan Setapak Cobblestone Melengkung yang menghubungkan seluruh area.

local OptimizationManager = require(script.Parent.OptimizationManager)

local SpawnManager = {}

local function createBench(cf: CFrame, parent: Instance)
	local bench = Instance.new("Model")
	bench.Name = "ResortBench"

	OptimizationManager.Part({
		Name = "SeatPlank",
		Size = Vector3.new(6, 0.5, 2),
		CFrame = cf * CFrame.new(0, 1.8, 0),
		Color = Color3.fromRGB(138, 92, 58),
		Material = Enum.Material.WoodPlanks,
		Parent = bench
	})
	OptimizationManager.Part({
		Name = "Backrest",
		Size = Vector3.new(6, 1.8, 0.4),
		CFrame = cf * CFrame.new(0, 2.8, -0.85) * CFrame.Angles(math.rad(-10), 0, 0),
		Color = Color3.fromRGB(122, 80, 48),
		Material = Enum.Material.WoodPlanks,
		Parent = bench
	})
	for _, side in ipairs({-2.4, 2.4}) do
		OptimizationManager.Part({
			Name = "Leg",
			Size = Vector3.new(0.6, 1.8, 1.8),
			CFrame = cf * CFrame.new(side, 0.9, 0),
			Color = Color3.fromRGB(75, 75, 78),
			Material = Enum.Material.Slate,
			Parent = bench
		})
	end

	for _, sOff in ipairs({-1.5, 1.5}) do
		local seat = Instance.new("Seat")
		seat.Name = "BenchSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(2.2, 0.5, 1.8)
		seat.Transparency = 1
		seat.CFrame = cf * CFrame.new(sOff, 2.05, 0)
		seat.Parent = bench
	end

	bench.Parent = parent
end

function SpawnManager.BuildSpawnPlaza(root: Folder)
	local folder = root:FindFirstChild("SpawnPlaza") :: Folder
	local pathFolder = root:FindFirstChild("PathwaysAndLights") :: Folder
	local baseY = 15.2

	-- 1. LANTAI PLAZA BUNDAR BERMOTIF BATU RESORT
	OptimizationManager.Part({
		Name = "PlazaOuterRing",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 68, 68),
		CFrame = CFrame.new(0, baseY, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(185, 174, 158),
		Material = Enum.Material.Cobblestone,
		Parent = folder
	})
	OptimizationManager.Part({
		Name = "PlazaInnerCompass",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.7, 46, 46),
		CFrame = CFrame.new(0, baseY + 0.05, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(214, 198, 172),
		Material = Enum.Material.Sandstone,
		Parent = folder
	})

	-- 2. BEBERAPA SPAWNLOCATION YANG RATA, AMAN & TIDAK MENGHALANGI JALAN
	local spawnOffsets = {
		Vector3.new(0, baseY + 0.4, 8),
		Vector3.new(-10, baseY + 0.4, 8),
		Vector3.new(10, baseY + 0.4, 8),
		Vector3.new(0, baseY + 0.4, 15),
	}
	for idx, pos in ipairs(spawnOffsets) do
		local sp = Instance.new("SpawnLocation")
		sp.Name = "ResortSpawn_" .. idx
		sp.Anchored = true
		sp.Size = Vector3.new(6, 0.4, 6)
		sp.Position = pos
		sp.Transparency = 1
		sp.CanCollide = true
		sp.Neutral = true
		sp.Parent = folder
	end

	-- 3. GERBANG MASUK KAYU & BATU ALAM + SIGN BESAR "TROPICAL PARADISE"
	local gateZ = 28
	for _, side in ipairs({-13, 13}) do
		-- Fondasi Batu Alam
		OptimizationManager.Part({
			Name = "GateStoneBase",
			Size = Vector3.new(4.2, 5, 4.2),
			Position = Vector3.new(side, baseY + 2.5, gateZ),
			Color = Color3.fromRGB(118, 114, 108),
			Material = Enum.Material.Cobblestone,
			Parent = folder
		})
		-- Pilar Kayu Resort
		OptimizationManager.Part({
			Name = "GateWoodPillar",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(15, 2.2, 2.2),
			CFrame = CFrame.new(side, baseY + 11.5, gateZ) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(115, 74, 44),
			Material = Enum.Material.Wood,
			Parent = folder
		})
	end

	-- Balok Atas Gerbang Berundak
	OptimizationManager.Part({
		Name = "GateMainBeam",
		Size = Vector3.new(34, 2.2, 3.2),
		Position = Vector3.new(0, baseY + 19, gateZ),
		Color = Color3.fromRGB(98, 62, 36),
		Material = Enum.Material.Wood,
		Parent = folder
	})
	OptimizationManager.Part({
		Name = "GateTopRoof",
		Size = Vector3.new(38, 1.2, 4.8),
		Position = Vector3.new(0, baseY + 22.8, gateZ),
		Color = Color3.fromRGB(132, 88, 48),
		Material = Enum.Material.WoodPlanks,
		Parent = folder
	})

	-- Papan Sign Besar "TROPICAL PARADISE" (2 Sisi Depan & Belakang)
	local signBoard = OptimizationManager.Part({
		Name = "MainResortSignBoard",
		Size = Vector3.new(26, 4.6, 1.4),
		Position = Vector3.new(0, baseY + 20.8, gateZ),
		Color = Color3.fromRGB(62, 38, 22),
		Material = Enum.Material.Wood,
		Parent = folder
	})

	for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
		local sg = Instance.new("SurfaceGui")
		sg.Face = face
		sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		sg.PixelsPerStud = 45
		sg.Parent = signBoard

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.BackgroundTransparency = 1
		lbl.Text = "🌴 TROPICAL PARADISE 🌴"
		lbl.Font = Enum.Font.GothamBlack
		lbl.TextColor3 = Color3.fromRGB(255, 232, 165)
		lbl.TextStrokeColor3 = Color3.fromRGB(42, 24, 10)
		lbl.TextStrokeTransparency = 0.15
		lbl.TextScaled = true
		lbl.Parent = sg
	end

	-- 4. KOLAM DEKORATIF AIR JERNIH & AIR MANCUR DI UTARA PLAZA (0, baseY, -28)
	local fPos = Vector3.new(0, baseY, -28)
	OptimizationManager.Part({
		Name = "FountainBasinRim",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2.2, 22, 22),
		CFrame = CFrame.new(fPos + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(165, 158, 148),
		Material = Enum.Material.Cobblestone,
		Parent = folder
	})
	OptimizationManager.Part({
		Name = "FountainClearWater",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.8, 19.5, 19.5),
		CFrame = CFrame.new(fPos + Vector3.new(0, 1.15, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(38, 195, 215),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		CanCollide = false,
		Parent = folder
	})
	-- Tugu Air Mancur Bertingkat
	OptimizationManager.Part({
		Name = "FountainSpire",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(6.5, 3.2, 3.2),
		CFrame = CFrame.new(fPos + Vector3.new(0, 3.25, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(188, 182, 174),
		Material = Enum.Material.Marble,
		Parent = folder
	})
	local jetTop = OptimizationManager.Ellipsoid({
		Name = "FountainWaterCrown",
		Size = Vector3.new(2.5, 2.5, 2.5),
		Position = fPos + Vector3.new(0, 6.8, 0),
		Color = Color3.fromRGB(175, 240, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.4,
		CanCollide = false,
		Parent = folder
	})

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "FountainSpray"
	emitter.Texture = "rbxassetid://241685484"
	emitter.Color = ColorSequence.new(Color3.fromRGB(205, 245, 255))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.5, 1.8),
		NumberSequenceKeypoint.new(1, 2.8)
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.Lifetime = NumberRange.new(1.2, 1.8)
	emitter.Rate = 55
	emitter.Speed = NumberRange.new(12, 16)
	emitter.SpreadAngle = Vector2.new(30, 30)
	emitter.Acceleration = Vector3.new(0, -24, 0)
	emitter.Parent = jetTop

	-- 5. GAZEBO KECIL UNTUK BERSANTAI DI SISI TIMUR SPAWN (28, baseY, -4)
	local gazCenter = Vector3.new(28, baseY, -4)
	OptimizationManager.Part({
		Name = "SpawnGazeboDeck",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1, 16, 16),
		CFrame = CFrame.new(gazCenter + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(132, 88, 54),
		Material = Enum.Material.WoodPlanks,
		Parent = folder
	})
	for p = 1, 6 do
		local a = (p / 6) * math.pi * 2
		OptimizationManager.Part({
			Name = "GazeboPillar",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(9.5, 0.85, 0.85),
			CFrame = CFrame.new(gazCenter + Vector3.new(math.cos(a) * 6.5, 5.2, math.sin(a) * 6.5)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(108, 68, 42),
			Material = Enum.Material.Wood,
			Parent = folder
		})
	end
	OptimizationManager.Ellipsoid({
		Name = "GazeboDomeRoof",
		Size = Vector3.new(19, 5.5, 19),
		Position = gazCenter + Vector3.new(0, 11.2, 0),
		Color = Color3.fromRGB(148, 98, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = folder
	})
	createBench(CFrame.new(gazCenter + Vector3.new(0, 0.5, -3.5)), folder)
	createBench(CFrame.new(gazCenter + Vector3.new(0, 0.5, 3.5)) * CFrame.Angles(0, math.rad(180), 0), folder)

	-- 6. WELCOME BOARD ESTETIK & BANGKU TAMAN PLAZA
	local wbBase = Vector3.new(-18, baseY, 12)
	local wbPanel = OptimizationManager.Part({
		Name = "WelcomeDirectoryBoard",
		Size = Vector3.new(8.5, 5.2, 0.6),
		CFrame = CFrame.new(wbBase + Vector3.new(0, 4.2, 0)) * CFrame.Angles(0, math.rad(28), 0),
		Color = Color3.fromRGB(68, 45, 28),
		Material = Enum.Material.Wood,
		Parent = folder
	})
	local wGui = Instance.new("SurfaceGui")
	wGui.Face = Enum.NormalId.Front
	wGui.Parent = wbPanel

	local wTxt = Instance.new("TextLabel")
	wTxt.Size = UDim2.fromScale(0.92, 0.88)
	wTxt.Position = UDim2.fromScale(0.04, 0.06)
	wTxt.BackgroundTransparency = 1
	wTxt.Font = Enum.Font.GothamBold
	wTxt.TextColor3 = Color3.fromRGB(255, 245, 215)
	wTxt.TextScaled = true
	wTxt.Text = "WELCOME TO TROPICAL PARADISE

[South] Beach, Pier & Sunset Bridge
[West] Botanical Garden, Playground & Cafe
[North] Mountain Hike & Secret Waterfall

(Tekan E di sini untuk Fast-Travel)"
	wTxt.Parent = wGui

	createBench(CFrame.new(-21, baseY, -4) * CFrame.Angles(0, math.rad(75), 0), folder)
	createBench(CFrame.new(21, baseY, 14) * CFrame.Angles(0, math.rad(-55), 0), folder)

	-- Pohon Palem & Lampu Warm White Mengelilingi Spawn Plaza
	for i = 1, 8 do
		local ang = (i / 8) * math.pi * 2
		local r = 34
		local px = math.cos(ang) * r
		local pz = math.sin(ang) * r
		OptimizationManager.CreatePalmTree(Vector3.new(px, baseY - 0.5, pz), 21, 14, ang, true, folder)
		OptimizationManager.CreateLanternPost(Vector3.new(math.cos(ang + 0.35) * 29, baseY, math.sin(ang + 0.35) * 29), 7.5, folder)
	end

	-- 7. JALAN SETAPAK COBBLESTONE MELENGKUNG PENGHUBUNG SEMUA 5 AREA UTAMA
	local function buildCurvedCobblePath(p0: Vector3, p1: Vector3, p2: Vector3, steps: number, width: number)
		for s = 0, steps do
			local t = s / steps
			local u = 1 - t
			local pos = (u * u * p0) + (2 * u * t * p1) + (t * t * p2)

			OptimizationManager.Part({
				Name = "CobblePathStep",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.45, width, width),
				CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(162, 154, 142),
				Material = Enum.Material.Cobblestone,
				Parent = pathFolder
			})

			if s % 4 == 0 and s > 0 and s < steps then
				OptimizationManager.CreateLanternPost(pos + Vector3.new(width * 0.58, 0, 0), 6.2, pathFolder)
			end
		end
	end

	-- Jalur 1: Spawn Plaza -> Beach & Coastal Hangout
	buildCurvedCobblePath(Vector3.new(0, 15.1, 28), Vector3.new(12, 13.5, 105), Vector3.new(0, 9.2, 175), 26, 9)
	-- Jalur 2: Spawn Plaza -> Tropical Garden & Playground
	buildCurvedCobblePath(Vector3.new(-28, 15.1, 0), Vector3.new(-90, 15.3, 18), Vector3.new(-155, 15.2, 25), 24, 8.5)
	-- Jalur 3: Spawn Plaza -> Central Resort & Sunset Beach Cafe
	buildCurvedCobblePath(Vector3.new(-20, 15.1, 20), Vector3.new(-75, 15.0, 95), Vector3.new(-135, 14.8, 145), 24, 8.5)
	-- Jalur 4: Spawn Plaza -> Mountain & Waterfall Paradise
	buildCurvedCobblePath(Vector3.new(0, 15.1, -38), Vector3.new(-18, 15.2, -105), Vector3.new(0, 15.0, -162), 24, 8.5)
	-- Jalur 5: Spawn Plaza -> Sunset Wooden Bridge
	buildCurvedCobblePath(Vector3.new(25, 15.1, 18), Vector3.new(62, 14.5, 95), Vector3.new(82, 13.8, 158), 22, 8)

	print("[SpawnManager] Main Spawn Plaza & jaringan jalan cobblestone selesai dibangun.")
end

return SpawnManager
