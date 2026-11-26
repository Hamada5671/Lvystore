--!strict
-- WaterfallBuilder.lua
-- Membangun "SECRET WATERFALL" yang realistis:
-- Aliran air bertingkat dengan Beam bergerak + ParticleEmitter Mist & Percikan,
-- Kolam Lagoon Jernih di bawahnya, Hidden Cave di balik air terjun dengan kristal/lentera,
-- Batu-batu duduk di tepi kolam, Tanaman tropis sungai, dan Jembatan Kayu Kecil.

local OptimizationManager = require(script.Parent.OptimizationManager)

local WaterfallBuilder = {}

function WaterfallBuilder.BuildWaterfallAndRiver(root: Folder)
	local folder = root:FindFirstChild("MountainAndWaterfall") :: Folder

	-- 1. KOLam ATAS SUMBER AIR TERJUN (UPPER SOURCE BASIN DI Y = 104)
	OptimizationManager.Part({
		Name = "UpperWaterfallSourcePool",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(3, 32, 32),
		CFrame = CFrame.new(0, 104, -262) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(32, 188, 205),
		Material = Enum.Material.Glass,
		Transparency = 0.25,
		CanCollide = false,
		Parent = folder
	})

	-- 2. ALIRAN AIR TERJUN MULTI-LAPIS REALISTIS (Bukan Sekadar Part Kotak Biru!)
	-- Menggunakan kombinasi silinder air melengkung, Beam bertekstur mengalir, dan ParticleEmitter Mist
	local waterfallModel = Instance.new("Model")
	waterfallModel.Name = "SecretWaterfallCascade"

	local topAttachPart = OptimizationManager.Part({
		Name = "CascadeCrest",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(24, 4.5, 4.5),
		CFrame = CFrame.new(0, 103, -246),
		Color = Color3.fromRGB(165, 240, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		CanCollide = false,
		Parent = waterfallModel
	})

	local bottomSplashPart = OptimizationManager.Part({
		Name = "CascadeSplashZone",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(28, 5, 5),
		CFrame = CFrame.new(0, 14.5, -234),
		Color = Color3.fromRGB(215, 250, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.45,
		CanCollide = false,
		Parent = waterfallModel
	})

	-- Buat 5 Jalur Beam Air Mengalir + Buih Putih
	for stream = -2, 2 do
		local xOff = stream * 4.5
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, 0, xOff)
		a0.Parent = topAttachPart

		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, 0, xOff * 1.15)
		a1.Parent = bottomSplashPart

		local waterBeam = Instance.new("Beam")
		waterBeam.Name = "FlowingWaterBeam_" .. stream
		waterBeam.Attachment0 = a0
		waterBeam.Attachment1 = a1
		waterBeam.Texture = "rbxassetid://241685484"
		waterBeam.TextureMode = Enum.TextureMode.Wrap
		waterBeam.TextureLength = 18
		waterBeam.TextureSpeed = 3.2 + math.abs(stream) * 0.25
		waterBeam.Width0 = 7.5
		waterBeam.Width1 = 10.5
		waterBeam.CurveSize0 = 8
		waterBeam.CurveSize1 = -4
		waterBeam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(195, 248, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 215, 235)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 252, 255))
		})
		waterBeam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.8, 0.1),
			NumberSequenceKeypoint.new(1, 0.25)
		})
		waterBeam.LightEmission = 0.35
		waterBeam.FaceCamera = false
		waterBeam.Parent = waterfallModel
	end

	-- Lapisan Air Volumetrik 3D Melengkung (Agar tetap terlihat padat dari samping)
	for seg = 1, 8 do
		local t = seg / 8
		local sy = 104 - (t * 89)
		local sz = -246 + math.sin(t * math.pi * 0.5) * 12
		OptimizationManager.Part({
			Name = "WaterVolumeSeg_" .. seg,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(23 + t * 4, 13.5, 3.2),
			CFrame = CFrame.new(0, sy, sz) * CFrame.Angles(math.rad(8), 0, 0),
			Color = Color3.fromRGB(85, 218, 238),
			Material = Enum.Material.Glass,
			Transparency = 0.42,
			CanCollide = false,
			CastShadow = false,
			Parent = waterfallModel
		})
	end

	-- Efek ParticleEmitter Mist & Percikan Air di Kolam Bawah
	local mist = Instance.new("ParticleEmitter")
	mist.Name = "WaterfallMistEmitter"
	mist.Texture = "rbxassetid://241685484"
	mist.Color = ColorSequence.new(Color3.fromRGB(225, 248, 255))
	mist.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 4),
		NumberSequenceKeypoint.new(0.5, 11),
		NumberSequenceKeypoint.new(1, 18)
	})
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(0.7, 0.65),
		NumberSequenceKeypoint.new(1, 1)
	})
	mist.Lifetime = NumberRange.new(2.2, 3.6)
	mist.Rate = 65
	mist.Speed = NumberRange.new(8, 16)
	mist.SpreadAngle = Vector2.new(75, 75)
	mist.Acceleration = Vector3.new(0, 3, 4)
	mist.Parent = bottomSplashPart

	waterfallModel.Parent = folder

	-- 3. SIGN & AREA "SECRET WATERFALL" + HIDDEN CAVE DI BALIK AIR TERJUN
	local caveCenter = Vector3.new(0, 15.5, -260)
	OptimizationManager.Part({
		Name = "HiddenCaveDryFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.2, 32, 32),
		CFrame = CFrame.new(caveCenter) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(92, 88, 84),
		Material = Enum.Material.Slate,
		Parent = folder
	})

	-- Papan Penanda "SECRET WATERFALL"
	local secretSign = OptimizationManager.Part({
		Name = "SecretWaterfallSign",
		Size = Vector3.new(9.5, 2.4, 0.5),
		CFrame = CFrame.new(-22, 19.5, -218) * CFrame.Angles(0, math.rad(25), 0),
		Color = Color3.fromRGB(68, 44, 26),
		Material = Enum.Material.Wood,
		Parent = folder
	})
	local sGui = Instance.new("SurfaceGui")
	sGui.Face = Enum.NormalId.Front
	sGui.Parent = secretSign
	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.fromScale(1, 1)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = "✨ SECRET WATERFALL & CAVE ✨"
	sLbl.Font = Enum.Font.GothamBlack
	sLbl.TextColor3 = Color3.fromRGB(165, 248, 255)
	sLbl.TextScaled = true
	sLbl.Parent = sGui

	-- Kristal Bercahaya & Batu Duduk di Dalam Hidden Cave
	for c = 1, 5 do
		local ang = (c / 5) * math.pi * 2
		local cPos = caveCenter + Vector3.new(math.cos(ang) * 11, 2.2, math.sin(ang) * 9 - 3)
		local crystal = OptimizationManager.Ellipsoid({
			Name = "CaveGlowCrystal_" .. c,
			Size = Vector3.new(1.6, 4.5, 1.6),
			CFrame = CFrame.new(cPos) * CFrame.Angles(math.rad(15), ang, math.rad(-12)),
			Color = Color3.fromRGB(85, 235, 255),
			Material = Enum.Material.Neon,
			Parent = folder
		})
		local pLight = Instance.new("PointLight")
		pLight.Color = Color3.fromRGB(95, 225, 255)
		pLight.Brightness = 1.4
		pLight.Range = 22
		pLight.Parent = crystal
	end

	-- 4. BATU-BATU BESAR DI SEKITAR KOLAM LAGOON (DENGAN SEAT UNTUK DUDUK SANTAI)
	local boulderRing = {
		Vector3.new(-24, 15.2, -198), Vector3.new(24, 15.2, -198),
		Vector3.new(-18, 15.0, -172), Vector3.new(18, 15.0, -172),
		Vector3.new(-8, 16.0, -256),  Vector3.new(8, 16.0, -256), -- Di dalam gua
	}
	for idx, bPos in ipairs(boulderRing) do
		OptimizationManager.CreateNaturalRock(bPos, Vector3.new(8.5, 3.8, 7.2), Color3.fromRGB(112, 108, 104), Enum.Material.Slate, folder)
		local rockSeat = Instance.new("Seat")
		rockSeat.Name = "LagoonSittingRock_" .. idx
		rockSeat.Anchored = true
		rockSeat.Size = Vector3.new(2.4, 0.5, 2.4)
		rockSeat.Transparency = 1
		rockSeat.CFrame = CFrame.new(bPos + Vector3.new(0, 2.0, 0))
		rockSeat.Parent = folder
	end

	-- 5. JEMBATAN KAYU KECIL DI DEKAT WATERFALL (MENYEBERANGI SUNGAI KELUAR LAGOON)
	local wbCenter = Vector3.new(12, 15.8, -155)
	for step = -5, 5 do
		local t = step / 5
		local archY = math.cos(t * math.pi * 0.5) * 2.2
		OptimizationManager.Part({
			Name = "WaterfallFootbridgePlank",
			Size = Vector3.new(2.2, 0.5, 7.5),
			CFrame = CFrame.new(wbCenter + Vector3.new(step * 2.3, archY, 0)),
			Color = Color3.fromRGB(128, 84, 48),
			Material = Enum.Material.WoodPlanks,
			Parent = folder
		})
	end
	OptimizationManager.CreateLanternPost(wbCenter + Vector3.new(-12, -0.5, 3.8), 5.5, folder)
	OptimizationManager.CreateLanternPost(wbCenter + Vector3.new(12, -0.5, 3.8), 5.5, folder)

	-- Tanaman Tropis di Sepanjang Tepian Kolam & Sungai
	OptimizationManager.CreatePalmTree(Vector3.new(-28, 14.5, -185), 20, 16, 0.6, true, folder)
	OptimizationManager.CreatePalmTree(Vector3.new(28, 14.5, -185), 22, 14, -0.8, true, folder)
	OptimizationManager.CreateCanopyTree(Vector3.new(-35, 15, -215), 1.1, folder)
	OptimizationManager.CreateCanopyTree(Vector3.new(35, 15, -215), 1.1, folder)

	print("[WaterfallBuilder] Secret Waterfall, Natural Lagoon, Hidden Cave & Sungai selesai dibangun.")
end

return WaterfallBuilder
