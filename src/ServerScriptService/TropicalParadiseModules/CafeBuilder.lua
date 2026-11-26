--!strict
-- CafeBuilder.lua
-- Membangun "SUNSET BEACH CAFE" 2 Lantai dengan Arsitektur Tropical Resort:
-- Kayu & Batu Alam, Jendela Kaca, Balkon, Rooftop Terrace menghadap Laut & Sunset,
-- Tangga yang bisa dilewati pemain, Meja & Kursi, Counter Makanan, Lampu Gantung,
-- Signboard "SUNSET BEACH CAFE", Gerobak Es Krim, dan Coffee Corner.

local OptimizationManager = require(script.Parent.OptimizationManager)

local CafeBuilder = {}

local function createCafeTableSet(pos: Vector3, parent: Instance)
	local m = Instance.new("Model")
	m.Name = "CafeTableAndChairs"

	OptimizationManager.Part({
		Name = "TablePedestal",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2.6, 0.6, 0.6),
		CFrame = CFrame.new(pos + Vector3.new(0, 1.3, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(72, 52, 36),
		Material = Enum.Material.Wood,
		Parent = m
	})
	OptimizationManager.Part({
		Name = "RoundTableTop",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.35, 3.8, 3.8),
		CFrame = CFrame.new(pos + Vector3.new(0, 2.7, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(158, 108, 65),
		Material = Enum.Material.WoodPlanks,
		Parent = m
	})

	for c = 1, 3 do
		local a = (c / 3) * math.pi * 2
		local cPos = pos + Vector3.new(math.cos(a) * 2.8, 0.85, math.sin(a) * 2.8)
		local seat = Instance.new("Seat")
		seat.Name = "CafeChairSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(1.8, 1.5, 1.8)
		seat.CFrame = CFrame.lookAt(cPos, Vector3.new(pos.X, cPos.Y, pos.Z))
		seat.Color = Color3.fromRGB(135, 88, 52)
		seat.Material = Enum.Material.WoodPlanks
		seat.Parent = m
	end

	m.Parent = parent
end

function CafeBuilder.BuildSunsetBeachCafe(root: Folder)
	local folder = root:FindFirstChild("SunsetCafeResort") :: Folder
	local origin = Vector3.new(-135, 14.8, 155)

	local cafe = Instance.new("Model")
	cafe.Name = "SunsetBeachCafeTwoStory"

	-- 1. FONDASI BATU ALAM & LANTAI DASAR KAYU RESORT (38 x 28 Studs)
	OptimizationManager.Part({
		Name = "StoneFoundation",
		Size = Vector3.new(40, 2.2, 30),
		Position = origin + Vector3.new(0, 0.5, 0),
		Color = Color3.fromRGB(122, 118, 112),
		Material = Enum.Material.Cobblestone,
		Parent = cafe
	})
	OptimizationManager.Part({
		Name = "FirstFloorHardwood",
		Size = Vector3.new(38, 0.6, 28),
		Position = origin + Vector3.new(0, 1.8, 0),
		Color = Color3.fromRGB(142, 94, 56),
		Material = Enum.Material.WoodPlanks,
		Parent = cafe
	})

	-- 2. PILAR STRUKTUR KAYU & DINDING KACA TROPIS LANTAI 1
	local f1Height = 13
	for _, px in ipairs({-17.5, 0, 17.5}) do
		for _, pz in ipairs({-12.5, 12.5}) do
			OptimizationManager.Part({
				Name = "ResortTimberPillar",
				Size = Vector3.new(1.6, f1Height, 1.6),
				Position = origin + Vector3.new(px, 1.8 + f1Height * 0.5, pz),
				Color = Color3.fromRGB(98, 62, 36),
				Material = Enum.Material.Wood,
				Parent = cafe
			})
		end
	end

	-- Dinding Belakang Batu Alam & Jendela Kaca Samping
	OptimizationManager.Part({
		Name = "BackStoneWall",
		Size = Vector3.new(36, f1Height, 1.4),
		Position = origin + Vector3.new(0, 1.8 + f1Height * 0.5, -12.5),
		Color = Color3.fromRGB(138, 132, 124),
		Material = Enum.Material.Cobblestone,
		Parent = cafe
	})
	OptimizationManager.Part({
		Name = "WestGlassWindow",
		Size = Vector3.new(0.6, f1Height - 2, 24),
		Position = origin + Vector3.new(-17.5, 1.8 + f1Height * 0.5, 0),
		Color = Color3.fromRGB(185, 232, 245),
		Material = Enum.Material.Glass,
		Transparency = 0.55,
		Parent = cafe
	})

	-- 3. COUNTER MAKANAN & COFFEE CORNER LANTAI 1 + INTERACTIVE PROMPT
	local counterBar = OptimizationManager.Part({
		Name = "MainFoodAndCoffeeCounter",
		Size = Vector3.new(18, 3.8, 3.2),
		Position = origin + Vector3.new(-4, 3.9, -6.5),
		Color = Color3.fromRGB(112, 72, 42),
		Material = Enum.Material.WoodPlanks,
		Parent = cafe
	})
	local orderPrompt = Instance.new("ProximityPrompt")
	orderPrompt.Name = "CafeOrderPrompt"
	orderPrompt.ActionText = "Ambil Tropical Drink & Coffee"
	orderPrompt.ObjectText = "SUNSET BEACH CAFE COUNTER"
	orderPrompt.HoldDuration = 0.25
	orderPrompt.MaxActivationDistance = 12
	orderPrompt.Parent = counterBar

	-- Lampu Gantung Warm White di Lantai 1
	for _, lx in ipairs({-10, 0, 10}) do
		local lamp = OptimizationManager.Ellipsoid({
			Name = "PendantLamp",
			Size = Vector3.new(1.6, 1.2, 1.6),
			Position = origin + Vector3.new(lx, 12.8, 0),
			Color = Color3.fromRGB(255, 216, 145),
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = cafe
		})
		local pl = Instance.new("PointLight")
		pl.Color = Color3.fromRGB(255, 202, 130)
		pl.Brightness = 1.6
		pl.Range = 28
		pl.Parent = lamp
	end

	-- 4. LANTAI 2 ROOFTOP TERRACE & BALKON MENGHADAP LAUT + SUNSET
	local f2Y = 1.8 + f1Height
	-- Sisakan bukaan tangga di sisi Timur (X = 11..17) agar pemain tidak terbentur kepala!
	OptimizationManager.Part({
		Name = "SecondFloorRooftopSlabMain",
		Size = Vector3.new(29, 0.8, 30),
		Position = origin + Vector3.new(-4.5, f2Y, 1),
		Color = Color3.fromRGB(146, 98, 58),
		Material = Enum.Material.WoodPlanks,
		Parent = cafe
	})
	OptimizationManager.Part({
		Name = "SecondFloorFrontBalcony",
		Size = Vector3.new(9, 0.8, 12),
		Position = origin + Vector3.new(14.5, f2Y, 10),
		Color = Color3.fromRGB(146, 98, 58),
		Material = Enum.Material.WoodPlanks,
		Parent = cafe
	})

	-- Tangga Fungsional Lantai 1 -> Lantai 2 Rooftop (Mudah Dinaiki Karakter)
	local stairSteps = 16
	for s = 1, stairSteps do
		local t = s / stairSteps
		OptimizationManager.Part({
			Name = "CafeStairStep_" .. s,
			Size = Vector3.new(5.2, 0.6, 1.4),
			Position = origin + Vector3.new(14.2, 1.8 + (t * f1Height), -10.5 + (s * 0.95)),
			Color = Color3.fromRGB(124, 80, 46),
			Material = Enum.Material.WoodPlanks,
			Parent = cafe
		})
	end

	-- Railing Kaca & Kayu Balkon Rooftop Lantai 2
	OptimizationManager.Part({
		Name = "RooftopFrontGlassRailing",
		Size = Vector3.new(38, 3.4, 0.4),
		Position = origin + Vector3.new(0, f2Y + 1.9, 15.6),
		Color = Color3.fromRGB(195, 238, 250),
		Material = Enum.Material.Glass,
		Transparency = 0.5,
		Parent = cafe
	})
	OptimizationManager.Part({
		Name = "RooftopBackRailing",
		Size = Vector3.new(38, 3.4, 0.4),
		Position = origin + Vector3.new(0, f2Y + 1.9, -13.6),
		Color = Color3.fromRGB(112, 72, 42),
		Material = Enum.Material.Wood,
		Parent = cafe
	})

	-- Kanopi Pergola Kayu di Atas Rooftop + Signboard "SUNSET BEACH CAFE"
	OptimizationManager.Part({
		Name = "RooftopPergolaCanopy",
		Size = Vector3.new(28, 0.8, 16),
		Position = origin + Vector3.new(-4, f2Y + 10.5, -2),
		Color = Color3.fromRGB(118, 76, 44),
		Material = Enum.Material.WoodPlanks,
		Parent = cafe
	})

	local signPart = OptimizationManager.Part({
		Name = "SunsetBeachCafeSignboard",
		Size = Vector3.new(24, 3.4, 0.9),
		Position = origin + Vector3.new(0, f2Y + 2.2, 16.0),
		Color = Color3.fromRGB(58, 36, 20),
		Material = Enum.Material.Wood,
		Parent = cafe
	})
	local sGui = Instance.new("SurfaceGui")
	sGui.Face = Enum.NormalId.Front
	sGui.Parent = signPart
	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.fromScale(1, 1)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = "🍹 SUNSET BEACH CAFE 🌅"
	sLbl.Font = Enum.Font.GothamBlack
	sLbl.TextColor3 = Color3.fromRGB(255, 218, 138)
	sLbl.TextScaled = true
	sLbl.Parent = sGui

	-- Meja & Kursi Lantai 1, Outdoor Patio, dan Lantai 2 Rooftop
	createCafeTableSet(origin + Vector3.new(-9, 2.1, 4), cafe)
	createCafeTableSet(origin + Vector3.new(2, 2.1, 4), cafe)
		createCafeTableSet(origin + Vector3.new(-10, 0.2, 20), cafe)
	createCafeTableSet(origin + Vector3.new(2, 0.2, 20), cafe)
	createCafeTableSet(origin + Vector3.new(-10, f2Y + 0.4, 4), cafe)
	createCafeTableSet(origin + Vector3.new(0, f2Y + 0.4, 4), cafe)

	-- 5. GEROBAK ES KRIM (ICE CREAM CART) INTERAKTIF DI DEPAN CAFE
	local cartPos = origin + Vector3.new(24, 0.5, 16)
	local cart = Instance.new("Model")
	cart.Name = "TropicalIceCreamCart"

	local cartBody = OptimizationManager.Part({
		Name = "CartBody",
		Size = Vector3.new(5.5, 3.4, 3.2),
		Position = cartPos + Vector3.new(0, 2.2, 0),
		Color = Color3.fromRGB(255, 238, 210),
		Material = Enum.Material.SmoothPlastic,
		Parent = cart
	})
	OptimizationManager.Part({
		Name = "CartAwning",
		Size = Vector3.new(6.4, 0.6, 4.2),
		Position = cartPos + Vector3.new(0, 6.2, 0),
		Color = Color3.fromRGB(255, 115, 135),
		Material = Enum.Material.Fabric,
		Parent = cart
	})
	for _, wx in ipairs({-2.0, 2.0}) do
		OptimizationManager.Part({
			Name = "CartWheel",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.4, 2.2, 2.2),
			CFrame = CFrame.new(cartPos + Vector3.new(wx, 1.1, 1.7)) * CFrame.Angles(math.rad(90), 0, 0),
			Color = Color3.fromRGB(98, 64, 38),
			Material = Enum.Material.Wood,
			Parent = cart
		})
	end
	local icePrompt = Instance.new("ProximityPrompt")
	icePrompt.Name = "IceCreamPrompt"
	icePrompt.ActionText = "Ambil Tropical Gelato Cone"
	icePrompt.ObjectText = "ISLAND ICE CREAM CART"
	icePrompt.HoldDuration = 0.2
	icePrompt.MaxActivationDistance = 10
	icePrompt.Parent = cartBody

	cart.Parent = cafe
	cafe.Parent = folder

	print("[CafeBuilder] Sunset Beach Cafe 2 Lantai, Rooftop Terrace & Ice Cream Cart selesai dibangun.")
end

return CafeBuilder
