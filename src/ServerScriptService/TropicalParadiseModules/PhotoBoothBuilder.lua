--!strict
-- PhotoBoothBuilder.lua
-- Membangun 5 Area Foto (Photo Booths) Estetik yang bisa dimasuki pemain:
-- 1. PHOTOBOOTH 1 — BEACH VINTAGE ("SUNSET MEMORIES")
-- 2. PHOTOBOOTH 2 — GARDEN (Arch Bunga, Tanaman Merambat, Lampu Gantung)
-- 3. PHOTOBOOTH 3 — WATERFALL (Platform Kayu, Background Air Terjun, Batu Alam)
-- 4. PHOTOBOOTH 4 — MOUNTAIN VIEW (Platform Observasi, Railing Kayu, View Gunung)
-- 5. PHOTOBOOTH 5 — SUNSET BRIDGE (Spot di Tengah Jembatan, Lentera, Sunset View)

local OptimizationManager = require(script.Parent.OptimizationManager)

local PhotoBoothBuilder = {}

local function addPhotoPromptAndSeat(standPart: BasePart, boothTitle: string)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PhotoBoothPrompt"
	prompt.ActionText = "Ambil Foto Pose"
	prompt.ObjectText = boothTitle
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = standPart
end

function PhotoBoothBuilder.BuildAllPhotoBooths(root: Folder)
	local folder = root:FindFirstChild("PhotoBooths") :: Folder

	-- =========================================================================
	-- PHOTOBOOTH 1 — BEACH VINTAGE ("SUNSET MEMORIES") DI (48, 7.2, 198)
	-- =========================================================================
	local pb1 = Instance.new("Model")
	pb1.Name = "PhotoBooth1_BeachVintage"
	local p1Origin = Vector3.new(48, 7.2, 198)

	local deck1 = OptimizationManager.Part({
		Name = "VintageDeck",
		Size = Vector3.new(11, 0.5, 8),
		Position = p1Origin,
		Color = Color3.fromRGB(168, 128, 88),
		Material = Enum.Material.WoodPlanks,
		Parent = pb1
	})
	-- Frame Kayu Vintage
	for _, side in ipairs({-4.6, 4.6}) do
		OptimizationManager.Part({
			Name = "VintageFramePost",
			Size = Vector3.new(0.8, 9.5, 0.8),
			Position = p1Origin + Vector3.new(side, 4.8, 2.5),
			Color = Color3.fromRGB(225, 208, 182),
			Material = Enum.Material.Wood,
			Parent = pb1
		})
	end
	local header1 = OptimizationManager.Part({
		Name = "SunsetMemoriesHeader",
		Size = Vector3.new(10.8, 1.8, 1.0),
		Position = p1Origin + Vector3.new(0, 9.6, 2.5),
		Color = Color3.fromRGB(128, 82, 48),
		Material = Enum.Material.Wood,
		Parent = pb1
	})
	local sg1 = Instance.new("SurfaceGui")
	sg1.Face = Enum.NormalId.Front
	sg1.Parent = header1
	local txt1 = Instance.new("TextLabel")
	txt1.Size = UDim2.fromScale(1, 1)
	txt1.BackgroundTransparency = 1
	txt1.Text = "🌅 SUNSET MEMORIES 🌅"
	txt1.Font = Enum.Font.GothamBlack
	txt1.TextColor3 = Color3.fromRGB(255, 224, 155)
	txt1.TextScaled = true
	txt1.Parent = sg1

	-- Kursi Kecil & Lampu Warm White
	local seat1 = Instance.new("Seat")
	seat1.Name = "VintagePhotoStool"
	seat1.Anchored = true
	seat1.Size = Vector3.new(3.2, 1.5, 1.8)
	seat1.Position = p1Origin + Vector3.new(0, 1.0, 1.2)
	seat1.Color = Color3.fromRGB(238, 225, 200)
	seat1.Material = Enum.Material.WoodPlanks
	seat1.Parent = pb1

	OptimizationManager.CreateLanternPost(p1Origin + Vector3.new(-4.8, 0.25, -2.2), 5.2, pb1)
	OptimizationManager.CreateLanternPost(p1Origin + Vector3.new(4.8, 0.25, -2.2), 5.2, pb1)
	addPhotoPromptAndSeat(deck1, "PHOTOBOOTH 1: SUNSET MEMORIES")
	pb1.Parent = folder

	-- =========================================================================
	-- PHOTOBOOTH 2 — GARDEN FLORAL ARCH DI (-128, 15.3, 5)
	-- =========================================================================
	local pb2 = Instance.new("Model")
	pb2.Name = "PhotoBooth2_GardenFloralArch"
	local p2Origin = Vector3.new(-128, 15.3, 5)

	local deck2 = OptimizationManager.Part({
		Name = "GardenPhotoStonePad",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 11, 11),
		CFrame = CFrame.new(p2Origin) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(188, 180, 168),
		Material = Enum.Material.Cobblestone,
		Parent = pb2
	})
	-- Arch Bunga & Tanaman Merambat Melengkung
	for aStep = 0, 12 do
		local ang = (aStep / 12) * math.pi
		local ax = math.cos(ang) * 4.8
		local ay = math.sin(ang) * 8.5 + 1.0
		OptimizationManager.Ellipsoid({
			Name = "FloralVineSegment_" .. aStep,
			Size = Vector3.new(2.2, 2.2, 2.2),
			Position = p2Origin + Vector3.new(ax, ay, 0),
			Color = Color3.fromRGB(52, 138, 58),
			Material = Enum.Material.LeafyGrass,
			CanCollide = false,
			Parent = pb2
		})
		OptimizationManager.Ellipsoid({
			Name = "ArchBlossom_" .. aStep,
			Size = Vector3.new(1.1, 1.1, 1.1),
			Position = p2Origin + Vector3.new(ax, ay, 0.85),
			Color = if aStep % 2 == 0 then Color3.fromRGB(255, 118, 158) else Color3.fromRGB(255, 225, 115),
			Material = Enum.Material.Neon,
			CanCollide = false,
			CastShadow = false,
			Parent = pb2
		})
	end
	local seat2 = Instance.new("Seat")
	seat2.Name = "GardenArchBench"
	seat2.Anchored = true
	seat2.Size = Vector3.new(4.2, 1.4, 1.8)
	seat2.Position = p2Origin + Vector3.new(0, 0.95, 0)
	seat2.Color = Color3.fromRGB(138, 92, 54)
	seat2.Material = Enum.Material.WoodPlanks
	seat2.Parent = pb2
	addPhotoPromptAndSeat(deck2, "PHOTOBOOTH 2: GARDEN FLORAL ARCH")
	pb2.Parent = folder

	-- =========================================================================
	-- PHOTOBOOTH 3 — WATERFALL PLATFORM DI (32, 15.5, -182)
	-- =========================================================================
	local pb3 = Instance.new("Model")
	pb3.Name = "PhotoBooth3_WaterfallDeck"
	local p3Origin = Vector3.new(32, 15.5, -182)

	local deck3 = OptimizationManager.Part({
		Name = "WaterfallPhotoDeck",
		Size = Vector3.new(10, 0.6, 10),
		CFrame = CFrame.new(p3Origin) * CFrame.Angles(0, math.rad(30), 0),
		Color = Color3.fromRGB(132, 86, 48),
		Material = Enum.Material.WoodPlanks,
		Parent = pb3
	})
	OptimizationManager.CreateNaturalRock(p3Origin + Vector3.new(-4.8, 1.2, -3.5), Vector3.new(4.5, 3.2, 4.2), nil, Enum.Material.Slate, pb3)
	OptimizationManager.CreateNaturalRock(p3Origin + Vector3.new(4.8, 1.2, -3.5), Vector3.new(4.5, 3.2, 4.2), nil, Enum.Material.Slate, pb3)
	OptimizationManager.CreateLanternPost(p3Origin + Vector3.new(-4.2, 0.3, 3.8), 5.5, pb3)
	OptimizationManager.CreateLanternPost(p3Origin + Vector3.new(4.2, 0.3, 3.8), 5.5, pb3)
	addPhotoPromptAndSeat(deck3, "PHOTOBOOTH 3: SECRET WATERFALL VIEW")
	pb3.Parent = folder

	-- =========================================================================
	-- PHOTOBOOTH 4 — MOUNTAIN VIEW PLATFORM DI (65, 92.5, -260)
	-- =========================================================================
	local pb4 = Instance.new("Model")
	pb4.Name = "PhotoBooth4_MountainObservationPlatform"
	local p4Origin = Vector3.new(65, 92.5, -260)

	local deck4 = OptimizationManager.Part({
		Name = "MountainViewPlatform",
		Size = Vector3.new(14, 0.8, 12),
		Position = p4Origin,
		Color = Color3.fromRGB(136, 90, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = pb4
	})
	-- Railing Kayu Pengaman
	OptimizationManager.Part({
		Name = "ViewpointFrontRail",
		Size = Vector3.new(14, 3.2, 0.5),
		Position = p4Origin + Vector3.new(0, 1.8, 5.75),
		Color = Color3.fromRGB(108, 68, 38),
		Material = Enum.Material.Wood,
		Transparency = 0.25,
		Parent = pb4
	})
	OptimizationManager.CreateLanternPost(p4Origin + Vector3.new(-6.2, 0.4, 5.2), 5.2, pb4)
	OptimizationManager.CreateLanternPost(p4Origin + Vector3.new(6.2, 0.4, 5.2), 5.2, pb4)
	addPhotoPromptAndSeat(deck4, "PHOTOBOOTH 4: SUMMIT MOUNTAIN VIEW")
	pb4.Parent = folder

	-- =========================================================================
	-- PHOTOBOOTH 5 — SUNSET BRIDGE APEX DI (130, 21.4, 210)
	-- =========================================================================
	local pb5 = Instance.new("Model")
	pb5.Name = "PhotoBooth5_SunsetBridgeSpot"
	local p5Origin = Vector3.new(130, 21.4, 210)

	local stand5 = OptimizationManager.Part({
		Name = "BridgePhotoCarpet",
		Size = Vector3.new(6, 0.2, 6),
		CFrame = CFrame.new(p5Origin) * CFrame.Angles(0, math.rad(-40), 0),
		Color = Color3.fromRGB(195, 65, 58),
		Material = Enum.Material.Fabric,
		Parent = pb5
	})
	addPhotoPromptAndSeat(stand5, "PHOTOBOOTH 5: GOLDEN SUNSET BRIDGE")
	pb5.Parent = folder

	print("[PhotoBoothBuilder] 5 Area Photo Booth Estetik selesai dibangun.")
end

return PhotoBoothBuilder
