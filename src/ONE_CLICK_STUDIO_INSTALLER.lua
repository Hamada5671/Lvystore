-- ============================================================================
-- ONE_CLICK_STUDIO_INSTALLER.lua
-- Paste seluruh script ini ke Command Bar Roblox Studio lalu tekan ENTER!
-- Script ini akan membuat semua ModuleScript di ServerScriptService sekaligus
-- langsung membangun map Tropical Paradise di Workspace Studio Anda.
-- ============================================================================

local ServerScriptService = game:GetService("ServerScriptService")

local oldFolder = ServerScriptService:FindFirstChild("TropicalParadiseModules")
if oldFolder then oldFolder:Destroy() end
local oldRunner = ServerScriptService:FindFirstChild("WorldGenerator")
if oldRunner then oldRunner:Destroy() end

local modFolder = Instance.new("Folder")
modFolder.Name = "TropicalParadiseModules"
modFolder.Parent = ServerScriptService

local function createModule(name, sourceCode)
    local m = Instance.new("ModuleScript")
    m.Name = name
    m.Source = sourceCode
    m.Parent = modFolder
    return m
end

createModule("OptimizationManager", [==[
--!strict
-- OptimizationManager.lua
-- Mengelola pembuatan objek 3D organik (Mesh, Sphere, Cylinder, Wedge),
-- keamanan InsertService Toolbox, Anchoring, Collision, dan performa multiplayer.

local InsertService = game:GetService("InsertService")
local PhysicsService = game:GetService("PhysicsService")

local OptimizationManager = {}
OptimizationManager.PartCount = 0

export type PartProps = {
	Name: string?,
	Size: Vector3?,
	CFrame: CFrame?,
	Position: Vector3?,
	Color: Color3?,
	Material: Enum.Material?,
	Transparency: number?,
	Reflectance: number?,
	CanCollide: boolean?,
	CastShadow: boolean?,
	Shape: Enum.PartType?,
	Parent: Instance?
}

function OptimizationManager.ConfigureWorkspace()
	workspace.StreamingEnabled = true
	workspace.StreamingMinRadius = 128
	workspace.StreamingTargetRadius = 512
	workspace.FallenPartsDestroyHeight = -250
end

function OptimizationManager.GetWorldRoot(): Folder
	local existing = workspace:FindFirstChild("TropicalParadiseWorld")
	if existing then
		existing:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "TropicalParadiseWorld"
	root.Parent = workspace

	local subFolders = {
		"SpawnPlaza",
		"TropicalGarden",
		"Playground",
		"BeachAndCoast",
		"WoodenBridge",
		"MountainAndWaterfall",
		"SunsetCafeResort",
		"ObservationTowers",
		"PhotoBooths",
		"AudioEmitters",
		"PathwaysAndLights"
	}

	for _, name in ipairs(subFolders) do
		local f = Instance.new("Folder")
		f.Name = name
		f.Parent = root
	end

	return root
end

function OptimizationManager.Part(props: PartProps): Part
	local p = Instance.new("Part")
	p.Name = props.Name or "EnvPart"
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = props.Size or Vector3.new(4, 1, 4)
	if props.Shape then
		p.Shape = props.Shape
	end
	if props.CFrame then
		p.CFrame = props.CFrame
	elseif props.Position then
		p.Position = props.Position
	end
	p.Color = props.Color or Color3.fromRGB(163, 162, 165)
	p.Material = props.Material or Enum.Material.SmoothPlastic
	p.Transparency = props.Transparency or 0
	p.Reflectance = props.Reflectance or 0
	p.CanCollide = if props.CanCollide ~= nil then props.CanCollide else true

	-- Optimasi Shadow: matikan shadow untuk objek dekorasi sangat kecil
	local volume = p.Size.X * p.Size.Y * p.Size.Z
	if props.CastShadow ~= nil then
		p.CastShadow = props.CastShadow
	else
		p.CastShadow = (volume >= 4)
	end

	if props.Parent then
		p.Parent = props.Parent
	end
	OptimizationManager.PartCount += 1
	return p
end

function OptimizationManager.Wedge(props: PartProps): WedgePart
	local w = Instance.new("WedgePart")
	w.Name = props.Name or "EnvWedge"
	w.Anchored = true
	w.TopSurface = Enum.SurfaceType.Smooth
	w.BottomSurface = Enum.SurfaceType.Smooth
	w.Size = props.Size or Vector3.new(4, 4, 4)
	if props.CFrame then
		w.CFrame = props.CFrame
	elseif props.Position then
		w.Position = props.Position
	end
	w.Color = props.Color or Color3.fromRGB(163, 162, 165)
	w.Material = props.Material or Enum.Material.SmoothPlastic
	w.Transparency = props.Transparency or 0
	w.CanCollide = if props.CanCollide ~= nil then props.CanCollide else true
	w.CastShadow = if props.CastShadow ~= nil then props.CastShadow else true
	if props.Parent then
		w.Parent = props.Parent
	end
	OptimizationManager.PartCount += 1
	return w
end

-- Membuat bentuk elipsoid/organik dengan SpecialMesh (bukan kotak kaku)
function OptimizationManager.Ellipsoid(props: PartProps): Part
	local p = OptimizationManager.Part(props)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- Membuat bentuk silinder presisi (untuk batang pohon melengkung, tiang bambu/kayu)
function OptimizationManager.Cylinder(props: PartProps): Part
	local p = OptimizationManager.Part(props)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Cylinder
	mesh.Parent = p
	return p
end

-- Generator Pohon Palem/Kelapa Realistis Beruas Melengkung
function OptimizationManager.CreatePalmTree(origin: Vector3, height: number, leanAngle: number, yawAngle: number, hasCoconuts: boolean, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "RealisticPalmTree"
	local segments = 8
	local segLen = height / segments
	local currentCF = CFrame.new(origin) * CFrame.Angles(0, yawAngle, 0)

	for i = 1, segments do
		local t = i / segments
		local radius = 1.35 * (1 - t * 0.55)
		local bend = math.rad(leanAngle / segments)
		local nextCF = currentCF * CFrame.Angles(bend, 0, 0) * CFrame.new(0, segLen, 0)
		local midCF = currentCF:Lerp(nextCF, 0.5)

		OptimizationManager.Part({
			Name = "TrunkSeg_" .. i,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(segLen + 0.35, radius * 2, radius * 2),
			CFrame = midCF * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(122, 92, 65),
			Material = Enum.Material.Wood,
			Parent = model
		})
		currentCF = nextCF
	end

	-- Buah Kelapa
	if hasCoconuts then
		for c = 1, 4 do
			local cAng = (c / 4) * math.pi * 2
			OptimizationManager.Ellipsoid({
				Name = "Coconut",
				Size = Vector3.new(1.1, 1.3, 1.1),
				CFrame = currentCF * CFrame.new(math.cos(cAng) * 0.85, -0.4, math.sin(cAng) * 0.85),
				Color = Color3.fromRGB(95, 65, 38),
				Material = Enum.Material.Wood,
				CanCollide = false,
				CastShadow = false,
				Parent = model
			})
		end
	end

	-- Pelepah Daun Palem Melengkung (9 Pelepah)
	local frondCount = 9
	for f = 1, frondCount do
		local fYaw = (f / frondCount) * math.pi * 2
		for sub = 1, 3 do
			local pitch = math.rad(18 - (sub * 18))
			local dist = sub * 3.1
			local frondCF = currentCF * CFrame.Angles(0, fYaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -dist)
			OptimizationManager.Ellipsoid({
				Name = "PalmFrond",
				Size = Vector3.new(2.6 - sub * 0.45, 0.35, 3.6),
				CFrame = frondCF,
				Color = Color3.fromRGB(52 + sub * 8, 128 + sub * 10, 48),
				Material = Enum.Material.LeafyGrass,
				CanCollide = false,
				CastShadow = true,
				Parent = model
			})
		end
	end

	model.Parent = parent
	return model
end

-- Generator Pohon Rindang Tropis Multi-Tajuk
function OptimizationManager.CreateCanopyTree(origin: Vector3, scale: number, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "TropicalCanopyTree"
	local trunkH = 14 * scale

	-- Batang utama
	OptimizationManager.Part({
		Name = "MainTrunk",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(trunkH, 2.8 * scale, 2.8 * scale),
		CFrame = CFrame.new(origin + Vector3.new(0, trunkH * 0.45, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(98, 71, 48),
		Material = Enum.Material.Wood,
		Parent = model
	})

	-- Cabang & Tajuk Organik
	local topPos = origin + Vector3.new(0, trunkH * 0.88, 0)
	OptimizationManager.Ellipsoid({
		Name = "MainCrown",
		Size = Vector3.new(18 * scale, 10 * scale, 18 * scale),
		Position = topPos + Vector3.new(0, 3 * scale, 0),
		Color = Color3.fromRGB(46, 118, 52),
		Material = Enum.Material.LeafyGrass,
		CanCollide = false,
		Parent = model
	})

	for b = 1, 5 do
		local ang = (b / 5) * math.pi * 2
		local branchOffset = Vector3.new(math.cos(ang) * 5.5 * scale, (b % 2) * 1.8 * scale, math.sin(ang) * 5.5 * scale)
		OptimizationManager.Ellipsoid({
			Name = "SubCrown_" .. b,
			Size = Vector3.new(12 * scale, 7.5 * scale, 12 * scale),
			Position = topPos + branchOffset,
			Color = Color3.fromRGB(58 + (b * 4), 132 + (b * 3), 55),
			Material = Enum.Material.LeafyGrass,
			CanCollide = false,
			Parent = model
		})
	end

	model.Parent = parent
	return model
end

-- Generator Batu Alam Organik (Bukan Kotak)
function OptimizationManager.CreateNaturalRock(pos: Vector3, size: Vector3, color: Color3?, material: Enum.Material?, parent: Instance): Part
	local rot = CFrame.Angles(math.rad(math.random(-25, 25)), math.rad(math.random(0, 360)), math.rad(math.random(-25, 25)))
	return OptimizationManager.Ellipsoid({
		Name = "NaturalRock",
		Size = size,
		CFrame = CFrame.new(pos) * rot,
		Color = color or Color3.fromRGB(115, 112, 108),
		Material = material or Enum.Material.Slate,
		Parent = parent
	})
end

-- Lampu Taman / Lentera Warm White Reusable
function OptimizationManager.CreateLanternPost(pos: Vector3, height: number, parent: Instance): Model
	local m = Instance.new("Model")
	m.Name = "GardenLantern"

	OptimizationManager.Part({
		Name = "Post",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, 0.55, 0.55),
		CFrame = CFrame.new(pos + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(65, 45, 32),
		Material = Enum.Material.Wood,
		Parent = m
	})

	local bulb = OptimizationManager.Ellipsoid({
		Name = "WarmBulb",
		Size = Vector3.new(1.1, 1.3, 1.1),
		Position = pos + Vector3.new(0, height + 0.4, 0),
		Color = Color3.fromRGB(255, 214, 145),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
		Parent = m
	})

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 204, 130)
	light.Brightness = 1.6
	light.Range = 26
	light.Shadows = false
	light.Parent = bulb

	m.Parent = parent
	return m
end

-- Fungsi Aman Load Free Model dari Toolbox & Sanitasi Script Mencurigakan
function OptimizationManager.SafeLoadToolboxAsset(assetId: number, position: Vector3, parent: Instance): Model?
	local ok, result = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)
	if ok and result then
		-- Sanitasi penuh: hapus semua Script/LocalScript/ModuleScript dari model pihak ketiga
		for _, desc in ipairs(result:GetDescendants()) do
			if desc:IsA("LuaSourceContainer") then
				desc:Destroy()
			elseif desc:IsA("BasePart") then
				desc.Anchored = true
			end
		end
		result:PivotTo(CFrame.new(position))
		result.Parent = parent
		return result
	end
	return nil
end

function OptimizationManager.FinalizeWorld(root: Folder)
	local totalAnchored = 0
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") then
			if not obj:FindFirstAncestorOfClass("Tool") then
				obj.Anchored = true
				totalAnchored += 1
			end
		end
	end
	print(string.format("[OptimizationManager] Selesai optimasi %d BaseParts (100%% Anchored & StreamingEnabled Aktif).", totalAnchored))
end

return OptimizationManager

]==])

createModule("LightingManager", [==[
--!strict
-- LightingManager.lua
-- Mengatur pencahayaan Golden Hour (ClockTime = 17.5), Future Lighting,
-- Atmosphere, BloomEffect, SunRaysEffect, ColorCorrectionEffect, dan Skybox.

local Lighting = game:GetService("Lighting")

local LightingManager = {}

function LightingManager.SetupGoldenHour()
	-- Bersihkan efek lama agar tidak bertumpuk
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") then
			child:Destroy()
		end
	end

	-- Parameter Utama Golden Hour
	Lighting.ClockTime = 17.5
	Lighting.GeographicLatitude = 14.5
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.25
	Lighting.Brightness = 2.4
	Lighting.ExposureCompensation = 0.08

	-- Warna Warm Orange & Soft Gold yang seimbang (tidak terlalu jenuh/gelap)
	Lighting.Ambient = Color3.fromRGB(88, 76, 72)
	Lighting.OutdoorAmbient = Color3.fromRGB(145, 118, 98)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 198, 135)
	Lighting.ColorShift_Bottom = Color3.fromRGB(70, 82, 95)
	Lighting.EnvironmentDiffuseScale = 0.85
	Lighting.EnvironmentSpecularScale = 0.9

	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)

	-- Atmosphere Realistis
	local atmo = Instance.new("Atmosphere")
	atmo.Density = 0.28
	atmo.Offset = 0.15
	atmo.Color = Color3.fromRGB(255, 195, 145)
	atmo.Decay = Color3.fromRGB(215, 130, 85)
	atmo.Glare = 0.35
	atmo.Haze = 1.65
	atmo.Parent = Lighting

	-- Skybox Sore Berawan Lembut
	local sky = Instance.new("Sky")
	sky.Name = "TropicalGoldenHourSky"
	sky.SunAngularSize = 16
	sky.MoonAngularSize = 11
	sky.CelestialBodiesShown = true
	sky.StarCount = 1200
	sky.Parent = Lighting

	-- BloomEffect Halus
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "GoldenBloom"
	bloom.Intensity = 0.45
	bloom.Size = 28
	bloom.Threshold = 1.15
	bloom.Parent = Lighting

	-- SunRaysEffect
	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Name = "GoldenSunRays"
	sunRays.Intensity = 0.14
	sunRays.Spread = 0.65
	sunRays.Parent = Lighting

	-- ColorCorrectionEffect (Seimbang & Natural)
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "TropicalColorGrading"
	cc.Brightness = 0.02
	cc.Contrast = 0.09
	cc.Saturation = 0.12
	cc.TintColor = Color3.fromRGB(255, 244, 232)
	cc.Parent = Lighting

	print("[LightingManager] Golden Hour (ClockTime 17.5) berhasil diterapkan.")
end

return LightingManager

]==])

createModule("AudioManager", [==[
--!strict
-- AudioManager.lua
-- Mengatur suara lingkungan 3D Spatial & Ambience (Ombak, Burung Tropis,
-- Angin Pepohonan, Air Terjun, Kolam Air Mancur, dan Musik Santai Cafe).

local SoundService = game:GetService("SoundService")
local OptimizationManager = require(script.Parent.OptimizationManager)

local AudioManager = {}

-- Daftar Verified Public Audio Asset IDs Roblox
AudioManager.VerifiedAudio = {
	TropicalBirdsAndWind = "rbxassetid://9114222745",
	OceanWaves           = "rbxassetid://9112756455",
	WaterfallRoar        = "rbxassetid://9114392907",
	FountainBabble       = "rbxassetid://9113626426",
	CafeAcousticChill    = "rbxassetid://1848354536",
	GardenBreeze         = "rbxassetid://9114224721",
}

local function createSpatialEmitter(name: string, pos: Vector3, soundId: string, volume: number, minDist: number, maxDist: number, parent: Instance)
	local node = OptimizationManager.Part({
		Name = "AudioEmitter_" .. name,
		Size = Vector3.new(1, 1, 1),
		Position = pos,
		Transparency = 1,
		CanCollide = false,
		CastShadow = false,
		Parent = parent
	})

	local snd = Instance.new("Sound")
	snd.Name = name
	snd.SoundId = soundId
	snd.Volume = volume
	snd.Looped = true
	snd.RollOffMode = Enum.RollOffMode.InverseTapered
	snd.RollOffMinDistance = minDist
	snd.RollOffMaxDistance = maxDist
	snd.Parent = node

	task.defer(function()
		pcall(function()
			snd:Play()
		end)
	end)
end

function AudioManager.SetupAmbience(root: Folder)
	local audioFolder = root:FindFirstChild("AudioEmitters") or root

	-- Bersihkan ambient global lama
	local oldGlobal = SoundService:FindFirstChild("GlobalTropicalAmbience")
	if oldGlobal then
		oldGlobal:Destroy()
	end

	-- 1. Ambience Global Halus (Angin Tropis & Burung)
	local globalAmb = Instance.new("Sound")
	globalAmb.Name = "GlobalTropicalAmbience"
	globalAmb.SoundId = AudioManager.VerifiedAudio.TropicalBirdsAndWind
	globalAmb.Volume = 0.22
	globalAmb.Looped = true
	globalAmb.Parent = SoundService
	pcall(function()
		globalAmb:Play()
	end)

	-- 2. Suara Ombak Pantai (Sepanjang Garis Pantai)
	createSpatialEmitter("OceanWaves_West", Vector3.new(-140, 4, 245), AudioManager.VerifiedAudio.OceanWaves, 0.55, 25, 240, audioFolder)
	createSpatialEmitter("OceanWaves_Center", Vector3.new(0, 4, 235), AudioManager.VerifiedAudio.OceanWaves, 0.6, 25, 240, audioFolder)
	createSpatialEmitter("OceanWaves_East", Vector3.new(140, 4, 245), AudioManager.VerifiedAudio.OceanWaves, 0.55, 25, 240, audioFolder)

	-- 3. Suara Air Terjun & Sungai
	createSpatialEmitter("WaterfallTop", Vector3.new(0, 82, -255), AudioManager.VerifiedAudio.WaterfallRoar, 0.75, 20, 200, audioFolder)
	createSpatialEmitter("WaterfallLagoon", Vector3.new(0, 16, -195), AudioManager.VerifiedAudio.WaterfallRoar, 0.9, 25, 220, audioFolder)
	createSpatialEmitter("RiverStream", Vector3.new(55, 12, -45), AudioManager.VerifiedAudio.FountainBabble, 0.45, 15, 130, audioFolder)

	-- 4. Suara Kolam Air Mancur Spawn & Kolam Koi Taman
	createSpatialEmitter("SpawnFountainSound", Vector3.new(0, 18, -32), AudioManager.VerifiedAudio.FountainBabble, 0.45, 10, 80, audioFolder)
	createSpatialEmitter("GardenKoiPondSound", Vector3.new(-145, 17, -15), AudioManager.VerifiedAudio.FountainBabble, 0.45, 10, 85, audioFolder)

	-- 5. Suara Lingkungan Taman
	createSpatialEmitter("GardenBirds", Vector3.new(-170, 22, 45), AudioManager.VerifiedAudio.GardenBreeze, 0.45, 20, 180, audioFolder)

	-- 6. Musik Santai di Sunset Beach Cafe
	createSpatialEmitter("SunsetCafeMusic", Vector3.new(-135, 20, 155), AudioManager.VerifiedAudio.CafeAcousticChill, 0.4, 15, 115, audioFolder)

	print("[AudioManager] 3D Spatial Audio & Ambience aktif.")
end

return AudioManager

]==])

createModule("TerrainGenerator", [==[
--!strict
-- TerrainGenerator.lua
-- Menghasilkan Voxel Terrain 3D Skala Besar:
-- Pulau Tropis, Bukit Taman Bervariasi, Pantai Pasir Putih Melengkung Natural,
-- Lautan Turquoise Jernih, Pegunungan Belakang, Kolam Air Terjun (Lagoon),
-- Gua Tersembunyi (Hidden Cave), dan Aliran Sungai yang Terhubung ke Laut.

local TerrainGenerator = {}

function TerrainGenerator.GenerateWorldTerrain()
	local terrain = workspace.Terrain
	terrain:Clear()

	-- Konfigurasi Air Laut & Kolam Turquoise Jernih
	terrain.WaterColor = Color3.fromRGB(22, 168, 178)
	terrain.WaterTransparency = 0.78
	terrain.WaterReflectance = 0.85
	terrain.WaterWaveSize = 0.22
	terrain.WaterWaveSpeed = 14

	-- Warna Material Terrain Natural
	pcall(function()
		terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(76, 138, 62))
		terrain:SetMaterialColor(Enum.Material.LeafyGrass, Color3.fromRGB(62, 122, 52))
		terrain:SetMaterialColor(Enum.Material.Sand, Color3.fromRGB(242, 226, 188))
		terrain:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(108, 104, 100))
		terrain:SetMaterialColor(Enum.Material.Cobblestone, Color3.fromRGB(145, 138, 128))
		terrain:SetMaterialColor(Enum.Material.Mud, Color3.fromRGB(115, 88, 65))
	end)

	-- 1. LAUTAN LUAS (OCEAN) & DASAR LAUT
	terrain:FillBlock(CFrame.new(0, -34, 60), Vector3.new(1300, 12, 1300), Enum.Material.Sand)
	terrain:FillBlock(CFrame.new(0, -11, 290), Vector3.new(1250, 32, 620), Enum.Material.Water)

	-- 2. DARATAN UTAMA PULAU & GARIS PANTAI MELENGKUNG (Bukan Garis Lurus!)
	-- Menggunakan gelombang sinus ganda + Perlin noise agar garis pantai alami
	for x = -380, 380, 12 do
		local coastCurveZ = 175 + math.sin(x / 68) * 32 + math.cos(x / 35) * 14
		local islandDepth = coastCurveZ + 290
		local centerZ = coastCurveZ - (islandDepth / 2)

		-- Inti Daratan Rumput
		terrain:FillBlock(
			CFrame.new(x, -1, centerZ),
			Vector3.new(16, 32, islandDepth),
			Enum.Material.Grass
		)

		-- Transisi Pasir Pantai & Beach Dunes
		for d = 1, 6 do
			local sandZ = coastCurveZ + (d * 10)
			local sandY = 14 - (d * 2.8)
			terrain:FillBall(
				Vector3.new(x, sandY, sandZ),
				18,
				Enum.Material.Sand
			)
		end

		-- Area Pasir Pantai Kering Luas
		terrain:FillCylinder(
			CFrame.new(x, 8, coastCurveZ - 12),
			14,
			22,
			Enum.Material.Sand
		)
	end

	-- 3. TELUK KECIL (COASTAL LAGOON INLET) DI BAWAH JEMBATAN KAYU TIMUR
	for i = 0, 1, 0.08 do
		local inletX = 95 + i * 70
		local inletZ = 155 + math.sin(i * math.pi) * 28
		terrain:FillBall(Vector3.new(inletX, 8, inletZ), 26, Enum.Material.Air)
		terrain:FillCylinder(CFrame.new(inletX, -4, inletZ), 16, 26, Enum.Material.Water)
	end

	-- 4. SPAWN PLAZA RATA & AMAN DI TENGAH (0, 15, 0)
	terrain:FillCylinder(CFrame.new(0, 7, 0), 16, 72, Enum.Material.Grass)
	terrain:FillCylinder(CFrame.new(0, 14.5, 0), 1.5, 52, Enum.Material.Cobblestone)

	-- 5. TAMAN TROPIS (TROPICAL GARDEN) DENGAN VARIASI ELEVASI BUKIT & LEAFYGRASS
	for gx = -320, -65, 18 do
		for gz = -110, 110, 18 do
			local n = math.noise(gx / 95, gz / 95, 42)
			local hillH = math.max(0, n * 16)
			local mat = if n > 0.08 then Enum.Material.LeafyGrass else Enum.Material.Grass
			terrain:FillBall(Vector3.new(gx, 11 + hillH, gz), 22, mat)
		end
	end
	-- Ratakan sedikit area Playground (-205, 15, 65) & Kolam Koi (-145, 15, -15)
	terrain:FillCylinder(CFrame.new(-205, 14, 65), 18, 42, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(-205, 7, 65), 16, 44, Enum.Material.LeafyGrass)
	terrain:FillCylinder(CFrame.new(-145, 14, -15), 16, 36, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(-145, 7, -15), 16, 38, Enum.Material.Grass)

	-- 6. PEGUNUNGAN TROPIS BESAR DI BELAKANG MAP (Z = -210 s/d -410)
	for mx = -360, 360, 20 do
		local distFromCenter = math.abs(mx)
		local peakProfile = math.clamp(1 - (distFromCenter / 390), 0.25, 1)
		local noiseVal = math.noise(mx / 75, -290 / 75, 19) * 28
		local mountainHeight = (118 * peakProfile) + noiseVal

		-- Lereng Tebing Batu (Rock)
		terrain:FillBall(
			Vector3.new(mx, mountainHeight * 0.45, -295 + math.sin(mx / 55) * 18),
			68,
			Enum.Material.Rock
		)
		-- Puncak & Bukit Hijau (Grass & LeafyGrass)
		terrain:FillBall(
			Vector3.new(mx, mountainHeight * 0.82, -310 + math.cos(mx / 60) * 15),
			46,
			Enum.Material.Grass
		)
	end

	-- 7. TEBING AIR TERJUN UTAMA & KOLAM ALAMI (NATURAL LAGOON) DI BAWAHNYA
	-- Pastikan tebing vertikal jelas di (0, 15..105, -255)
	terrain:FillBlock(CFrame.new(0, 62, -268), Vector3.new(78, 98, 52), Enum.Material.Rock)
	terrain:FillCylinder(CFrame.new(0, 108, -280), 12, 34, Enum.Material.Grass)

	-- Gali Kolam Air Terjun (Lagoon) di (0, 14, -195) dan isi dengan Air Jernih
	terrain:FillCylinder(CFrame.new(0, 18, -195), 24, 48, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(0, 4, -195), 14, 52, Enum.Material.Sand)
	terrain:FillCylinder(CFrame.new(0, 8, -195), 11, 46, Enum.Material.Water)

	-- 8. SECRET WATERFALL HIDDEN CAVE (Gua Tersembunyi di Balik Air Terjun)
	terrain:FillBall(Vector3.new(0, 21, -262), 21, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(0, 12, -262), 4, 22, Enum.Material.Rock)

	-- 9. SUNGAI ALAMI YANG MENGALIR DARI LAGOON AIR TERJUN MENUJU LAUT TIMUR
	local riverSteps = 36
	for s = 0, riverSteps do
		local t = s / riverSteps
		local rx = math.sin(t * math.pi * 0.85) * 105
		local rz = -165 + (t * 345)
		local ry = 13.5 - (t * 3.5)

		-- Gali lembah sungai & isi air
		terrain:FillBall(Vector3.new(rx, ry + 7, rz), 14, Enum.Material.Air)
		terrain:FillCylinder(CFrame.new(rx, ry - 4, rz), 6, 15, Enum.Material.Sand)
		terrain:FillCylinder(CFrame.new(rx, ry - 1, rz), 5, 13, Enum.Material.Water)
	end

	print("[TerrainGenerator] Voxel Terrain Pulau, Pantai, Gunung, Lagoon, Hidden Cave & Sungai selesai dibangun.")
end

return TerrainGenerator

]==])

createModule("SpawnManager", [==[
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

]==])

createModule("MountainBuilder", [==[
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

]==])

createModule("WaterfallBuilder", [==[
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

]==])

createModule("GardenBuilder", [==[
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

]==])

createModule("PlaygroundBuilder", [==[
--!strict
-- PlaygroundBuilder.lua
-- Membangun Playground Kayu Tropis yang realistis & interaktif:
-- Permukaan tanah aman, Ayunan Taman (Swing), Perosotan (Slide),
-- Jungkat-jungkit (Seesaw), Rumah Bermain Kayu, dan Bangku Pengunjung.

local OptimizationManager = require(script.Parent.OptimizationManager)

local PlaygroundBuilder = {}

function PlaygroundBuilder.BuildPlayground(root: Folder)
	local folder = root:FindFirstChild("Playground") :: Folder
	local center = Vector3.new(-205, 15.2, 65)

	-- 1. PERMUKAAN TANAH BERMAIN YANG AMAN & RATA (SOFT MULCH/SAND PAD)
	OptimizationManager.Part({
		Name = "SafePlaygroundPad",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 54, 54),
		CFrame = CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(212, 178, 132),
		Material = Enum.Material.Sand,
		Parent = folder
	})

	-- 2. AYUNAN TAMAN KAYU (SWING SET) DENGAN 2 KURSI SEAT FUNGSIONAL
	local swingOrigin = center + Vector3.new(-12, 0, -8)
	local swingModel = Instance.new("Model")
	swingModel.Name = "WoodenSwingSet"

	for _, side in ipairs({-7, 7}) do
		OptimizationManager.Part({
			Name = "SwingLegFront",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(12, 0.8, 0.8),
			CFrame = CFrame.new(swingOrigin + Vector3.new(side, 5.5, 2.2)) * CFrame.Angles(math.rad(20), 0, math.rad(90)),
			Color = Color3.fromRGB(122, 78, 44),
			Material = Enum.Material.Wood,
			Parent = swingModel
		})
		OptimizationManager.Part({
			Name = "SwingLegBack",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(12, 0.8, 0.8),
			CFrame = CFrame.new(swingOrigin + Vector3.new(side, 5.5, -2.2)) * CFrame.Angles(math.rad(-20), 0, math.rad(90)),
			Color = Color3.fromRGB(122, 78, 44),
			Material = Enum.Material.Wood,
			Parent = swingModel
		})
	end
	OptimizationManager.Part({
		Name = "SwingTopBeam",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(16, 1.0, 1.0),
		CFrame = CFrame.new(swingOrigin + Vector3.new(0, 11, 0)),
		Color = Color3.fromRGB(102, 64, 34),
		Material = Enum.Material.Wood,
		Parent = swingModel
	})

	for _, sX in ipairs({-3.2, 3.2}) do
		for _, rX in ipairs({-1.1, 1.1}) do
			OptimizationManager.Part({
				Name = "SwingRope",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(8.2, 0.18, 0.18),
				CFrame = CFrame.new(swingOrigin + Vector3.new(sX + rX, 6.8, 0)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(215, 195, 155),
				Material = Enum.Material.Fabric,
				CanCollide = false,
				Parent = swingModel
			})
		end
		local swingSeat = Instance.new("Seat")
		swingSeat.Name = "PlaygroundSwingSeat"
		swingSeat.Anchored = true
		swingSeat.Size = Vector3.new(2.8, 0.4, 1.6)
		swingSeat.Position = swingOrigin + Vector3.new(sX, 2.6, 0)
		swingSeat.Color = Color3.fromRGB(158, 98, 52)
		swingSeat.Material = Enum.Material.WoodPlanks
		swingSeat.Parent = swingModel
	end
	swingModel.Parent = folder

	-- 3. PLAYHOUSE KAYU & PEROSOTAN (SLIDE) YANG BISA DINAIIKI & DIGUNAKAN
	local slideOrigin = center + Vector3.new(10, 0, -6)
	local playhouse = Instance.new("Model")
	playhouse.Name = "WoodenPlayhouseAndSlide"

	-- Dek Menara Bermain
	OptimizationManager.Part({
		Name = "PlayhousePlatform",
		Size = Vector3.new(8, 0.6, 8),
		Position = slideOrigin + Vector3.new(0, 7.5, 0),
		Color = Color3.fromRGB(138, 92, 54),
		Material = Enum.Material.WoodPlanks,
		Parent = playhouse
	})
	for _, px in ipairs({-3.5, 3.5}) do
		for _, pz in ipairs({-3.5, 3.5}) do
			OptimizationManager.Part({
				Name = "PlayhousePost",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(14, 0.85, 0.85),
				CFrame = CFrame.new(slideOrigin + Vector3.new(px, 7, pz)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(108, 68, 38),
				Material = Enum.Material.Wood,
				Parent = playhouse
			})
		end
	end
	-- Atap Playhouse
	OptimizationManager.Wedge({
		Name = "PlayhouseRoofA",
		Size = Vector3.new(9, 3.5, 4.8),
		CFrame = CFrame.new(slideOrigin + Vector3.new(0, 15.5, -2.4)),
		Color = Color3.fromRGB(168, 78, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = playhouse
	})
	OptimizationManager.Wedge({
		Name = "PlayhouseRoofB",
		Size = Vector3.new(9, 3.5, 4.8),
		CFrame = CFrame.new(slideOrigin + Vector3.new(0, 15.5, 2.4)) * CFrame.Angles(0, math.rad(180), 0),
		Color = Color3.fromRGB(168, 78, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = playhouse
	})

	-- Tangga Panjat (TrussPart)
	local climbTruss = Instance.new("TrussPart")
	climbTruss.Name = "PlayhouseLadder"
	climbTruss.Anchored = true
	climbTruss.Size = Vector3.new(2, 8, 2)
	climbTruss.CFrame = CFrame.new(slideOrigin + Vector3.new(0, 4, -4.6))
	climbTruss.Color = Color3.fromRGB(138, 92, 54)
	climbTruss.Material = Enum.Material.Wood
	climbTruss.Parent = playhouse

	-- Jalur Perosotan Miring Halus + Seat Meluncur
	local slideChute = OptimizationManager.Part({
		Name = "SlideChute",
		Size = Vector3.new(3.4, 0.4, 13.5),
		CFrame = CFrame.new(slideOrigin + Vector3.new(0, 4.1, 8.8)) * CFrame.Angles(math.rad(-32), 0, 0),
		Color = Color3.fromRGB(245, 185, 55),
		Material = Enum.Material.SmoothPlastic,
		Parent = playhouse
	})
	-- Berikan dorongan kecepatan halus saat pemain menginjak perosotan
	slideChute.AssemblyLinearVelocity = Vector3.new(0, -8, 22)

	local slideSeat = Instance.new("Seat")
	slideSeat.Name = "SlideStartSeat"
	slideSeat.Anchored = true
	slideSeat.Size = Vector3.new(2.8, 0.4, 2)
	slideSeat.Transparency = 1
	slideSeat.CFrame = CFrame.new(slideOrigin + Vector3.new(0, 7.8, 3.6))
	slideSeat.Parent = playhouse

	playhouse.Parent = folder

	-- 4. JUNGKAT-JUNGKIT (SEESAW) DENGAN 2 KURSI SEAT
	local seesawOrigin = center + Vector3.new(-2, 0, 12)
	local seesawModel = Instance.new("Model")
	seesawModel.Name = "PlaygroundSeesaw"

	OptimizationManager.Wedge({
		Name = "SeesawFulcrum",
		Size = Vector3.new(2.6, 2.2, 2.2),
		Position = seesawOrigin + Vector3.new(0, 1.1, 0),
		Color = Color3.fromRGB(95, 95, 98),
		Material = Enum.Material.Slate,
		Parent = seesawModel
	})
	local plank = OptimizationManager.Part({
		Name = "SeesawPlank",
		Size = Vector3.new(12, 0.5, 2.2),
		CFrame = CFrame.new(seesawOrigin + Vector3.new(0, 2.35, 0)) * CFrame.Angles(0, 0, math.rad(8)),
		Color = Color3.fromRGB(72, 168, 125),
		Material = Enum.Material.WoodPlanks,
		Parent = seesawModel
	})
	for _, endX in ipairs({-4.8, 4.8}) do
		local sSeat = Instance.new("Seat")
		sSeat.Name = "SeesawSeat"
		sSeat.Anchored = true
		sSeat.Size = Vector3.new(2, 0.4, 2)
		sSeat.Transparency = 1
		sSeat.CFrame = plank.CFrame * CFrame.new(endX, 0.45, 0) * CFrame.Angles(0, if endX > 0 then math.rad(-90) else math.rad(90), 0)
		sSeat.Parent = seesawModel
	end
	seesawModel.Parent = folder

	-- 5. BANGKU UNTUK PENGUNJUNG DI TEPI PLAYGROUND
	for _, bAng in ipairs({0, math.pi * 0.5, math.pi}) do
		local bPos = center + Vector3.new(math.cos(bAng) * 24, 0, math.sin(bAng) * 24)
		local seat = Instance.new("Seat")
		seat.Name = "ParentVisitorBench"
		seat.Anchored = true
		seat.Size = Vector3.new(6, 1.6, 2)
		seat.CFrame = CFrame.lookAt(bPos + Vector3.new(0, 0.8, 0), center + Vector3.new(0, 0.8, 0))
		seat.Color = Color3.fromRGB(132, 86, 48)
		seat.Material = Enum.Material.WoodPlanks
		seat.Parent = folder
	end

	print("[PlaygroundBuilder] Playground (Ayunan, Perosotan, Jungkat-jungkit & Playhouse) selesai dibangun.")
end

return PlaygroundBuilder

]==])

createModule("BeachBuilder", [==[
--!strict
-- BeachBuilder.lua
-- Membangun Beach & Coastal Hangout:
-- Dermaga Kayu (Wooden Pier), Payung Pantai Oktagonal, Sun Loungers, Bean Bags,
-- Beach Bar Tiki, Area Bonfire dengan kursi melingkar & efek api, Pohon Kelapa,
-- Batu Karang, dan Lampu Lentera Pantai.

local OptimizationManager = require(script.Parent.OptimizationManager)

local BeachBuilder = {}

local function createBeachUmbrellaAndLoungers(pos: Vector3, umbrellaColor: Color3, parent: Instance)
	local m = Instance.new("Model")
	m.Name = "BeachLoungeSet"

	-- Tiang Payung
	OptimizationManager.Part({
		Name = "UmbrellaPole",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(8.5, 0.45, 0.45),
		CFrame = CFrame.new(pos + Vector3.new(0, 4.2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(235, 228, 215),
		Material = Enum.Material.Wood,
		Parent = m
	})
	-- Kanopi Payung Melengkung
	OptimizationManager.Ellipsoid({
		Name = "UmbrellaCanopy",
		Size = Vector3.new(9.5, 2.2, 9.5),
		Position = pos + Vector3.new(0, 8.2, 0),
		Color = umbrellaColor,
		Material = Enum.Material.Fabric,
		Parent = m
	})
	-- Meja Kecil Pantai
	OptimizationManager.Part({
		Name = "BeachSideTable",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.6, 2.4, 2.4),
		CFrame = CFrame.new(pos + Vector3.new(0, 0.8, 1.2)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(142, 95, 55),
		Material = Enum.Material.WoodPlanks,
		Parent = m
	})

	-- 2 Sun Loungers Menghadap Laut
	for _, xOff in ipairs({-3.2, 3.2}) do
		local lBase = pos + Vector3.new(xOff, 0.6, 1.5)
		OptimizationManager.Part({
			Name = "LoungerBed",
			Size = Vector3.new(2.4, 0.45, 5.2),
			Position = lBase,
			Color = Color3.fromRGB(245, 242, 235),
			Material = Enum.Material.Fabric,
			Parent = m
		})
		OptimizationManager.Part({
			Name = "LoungerBackrest",
			Size = Vector3.new(2.4, 0.45, 2.2),
			CFrame = CFrame.new(lBase + Vector3.new(0, 0.65, -2.8)) * CFrame.Angles(math.rad(-32), 0, 0),
			Color = umbrellaColor,
			Material = Enum.Material.Fabric,
			Parent = m
		})
		local seat = Instance.new("Seat")
		seat.Name = "SunLoungerSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(2.2, 0.4, 2.2)
		seat.Transparency = 1
		seat.CFrame = CFrame.new(lBase + Vector3.new(0, 0.3, 0.5)) * CFrame.Angles(0, math.rad(180), 0)
		seat.Parent = m
	end

	m.Parent = parent
end

local function createBeanBag(pos: Vector3, color: Color3, lookAtPos: Vector3, parent: Instance)
	local bag = OptimizationManager.Ellipsoid({
		Name = "BeachBeanBag",
		Size = Vector3.new(3.8, 2.2, 3.8),
		CFrame = CFrame.lookAt(pos + Vector3.new(0, 0.9, 0), Vector3.new(lookAtPos.X, pos.Y + 0.9, lookAtPos.Z)),
		Color = color,
		Material = Enum.Material.Fabric,
		Parent = parent
	})

	local seat = Instance.new("Seat")
	seat.Name = "BeanBagSeat"
	seat.Anchored = true
	seat.Size = Vector3.new(2.2, 0.4, 2.2)
	seat.Transparency = 1
	seat.CFrame = bag.CFrame * CFrame.new(0, 0.4, 0)
	seat.Parent = bag
end

function BeachBuilder.BuildBeachAndCoast(root: Folder)
	local folder = root:FindFirstChild("BeachAndCoast") :: Folder

	-- 1. DERMAGA KAYU PANJANG (WOODEN PIER) MENJOROK KE LAUT JERNIH (0, 6.5, 195..315)
	local pierModel = Instance.new("Model")
	pierModel.Name = "CoastalWoodenPier"
	for z = 190, 310, 4 do
		OptimizationManager.Part({
			Name = "PierPlank",
			Size = Vector3.new(12, 0.6, 3.6),
			Position = Vector3.new(0, 6.5, z),
			Color = Color3.fromRGB(134, 88, 52),
			Material = Enum.Material.WoodPlanks,
			Parent = pierModel
		})
		if z % 16 == 0 then
			for _, side in ipairs({-5.4, 5.4}) do
				OptimizationManager.Part({
					Name = "PierPiling",
					Shape = Enum.PartType.Cylinder,
					Size = Vector3.new(22, 1.1, 1.1),
					CFrame = CFrame.new(side, -1.5, z) * CFrame.Angles(0, 0, math.rad(90)),
					Color = Color3.fromRGB(92, 58, 34),
					Material = Enum.Material.Wood,
					Parent = pierModel
				})
				OptimizationManager.CreateLanternPost(Vector3.new(side, 6.8, z), 4.5, pierModel)
			end
		end
	end
	pierModel.Parent = folder

	-- 2. PAYUNG PANTAI & SUN LOUNGERS SEPANJANG PESISIR PASIR PUTIH
	local loungeSpots = {
		{pos = Vector3.new(-65, 6.2, 195), col = Color3.fromRGB(255, 115, 85)},
		{pos = Vector3.new(-42, 6.4, 198), col = Color3.fromRGB(45, 195, 215)},
		{pos = Vector3.new(-22, 6.5, 196), col = Color3.fromRGB(255, 198, 65)},
		{pos = Vector3.new(22, 6.5, 196),  col = Color3.fromRGB(255, 115, 85)},
		{pos = Vector3.new(44, 6.4, 198),  col = Color3.fromRGB(45, 195, 215)},
	}
	for _, s in ipairs(loungeSpots) do
		createBeachUmbrellaAndLoungers(s.pos, s.col, folder)
	end

	-- 3. AREA BONFIRE (API UNGGUN PANTAI) + KURSI LOG & BEAN BAG MELINGKAR (-48, 6.8, 175)
	local bonfirePos = Vector3.new(-48, 6.8, 175)
	local firePit = OptimizationManager.Part({
		Name = "BonfireCore",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.2, 4.5, 4.5),
		CFrame = CFrame.new(bonfirePos) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 125, 35),
		Material = Enum.Material.Neon,
		Parent = folder
	})
	local fireEffect = Instance.new("Fire")
	fireEffect.Size = 9
	fireEffect.Heat = 12
	fireEffect.Color = Color3.fromRGB(255, 145, 40)
	fireEffect.SecondaryColor = Color3.fromRGB(255, 65, 20)
	fireEffect.Parent = firePit

	local fireLight = Instance.new("PointLight")
	fireLight.Color = Color3.fromRGB(255, 155, 65)
	fireLight.Brightness = 2.4
	fireLight.Range = 38
	fireLight.Parent = firePit

	-- Batu Cincin Api Unggun & Kursi Melingkar (Bean Bags + Kayu Bakar)
	for r = 1, 10 do
		local a = (r / 10) * math.pi * 2
		OptimizationManager.CreateNaturalRock(
			bonfirePos + Vector3.new(math.cos(a) * 3.2, 0.2, math.sin(a) * 3.2),
			Vector3.new(1.5, 1.2, 1.5),
			Color3.fromRGB(95, 92, 88),
			Enum.Material.Slate,
			folder
		)
	end

	local beanColors = {
		Color3.fromRGB(255, 125, 75),
		Color3.fromRGB(55, 198, 185),
		Color3.fromRGB(255, 205, 75),
		Color3.fromRGB(235, 95, 135)
	}
	for b = 1, 8 do
		local a = (b / 8) * math.pi * 2
		local seatPos = bonfirePos + Vector3.new(math.cos(a) * 9.5, 0, math.sin(a) * 9.5)
		createBeanBag(seatPos, beanColors[(b % #beanColors) + 1], bonfirePos, folder)
	end

	-- 4. TIKI BEACH BAR DI SISI TIMUR PANTAI (32, 7.5, 172)
	local barPos = Vector3.new(32, 7.5, 172)
	local barModel = Instance.new("Model")
	barModel.Name = "TropicalTikiBeachBar"

	OptimizationManager.Part({
		Name = "BarFloorDeck",
		Size = Vector3.new(16, 0.6, 10),
		Position = barPos,
		Color = Color3.fromRGB(134, 88, 52),
		Material = Enum.Material.WoodPlanks,
		Parent = barModel
	})
	OptimizationManager.Part({
		Name = "BarCounter",
		Size = Vector3.new(12, 3.6, 2.2),
		Position = barPos + Vector3.new(0, 2.1, 2.6),
		Color = Color3.fromRGB(112, 72, 42),
		Material = Enum.Material.WoodPlanks,
		Parent = barModel
	})
	OptimizationManager.Ellipsoid({
		Name = "ThatchRoof",
		Size = Vector3.new(19, 4.5, 13),
		Position = barPos + Vector3.new(0, 10.2, 0),
		Color = Color3.fromRGB(178, 138, 76),
		Material = Enum.Material.Grass,
		Parent = barModel
	})
	for _, sX in ipairs({-4, -1.3, 1.3, 4}) do
		local stool = OptimizationManager.Part({
			Name = "BarStool",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.2, 1.6, 1.6),
			CFrame = CFrame.new(barPos + Vector3.new(sX, 1.4, 4.8)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(145, 95, 52),
			Material = Enum.Material.Wood,
			Parent = barModel
		})
		local seat = Instance.new("Seat")
		seat.Name = "BeachBarSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(1.6, 0.4, 1.6)
		seat.Transparency = 1
		seat.CFrame = CFrame.new(stool.Position + Vector3.new(0, 1.2, 0))
		seat.Parent = barModel
	end
	barModel.Parent = folder

	-- 5. POHON KELAPA MELENGKUNG & BATU KARANG PESISIR
	local palmLocations = {
		Vector3.new(-95, 7, 185), Vector3.new(-72, 7, 178), Vector3.new(-28, 7.5, 175),
		Vector3.new(18, 7.5, 175), Vector3.new(58, 7, 182), Vector3.new(95, 6.8, 192),
	}
	for idx, pPos in ipairs(palmLocations) do
		OptimizationManager.CreatePalmTree(pPos, 22, 18, idx * 1.1, true, folder)
	end

	-- Formasi Batu Karang Pantai (Rocky Shoreline)
	local reefPositions = {
		Vector3.new(-125, 5, 215), Vector3.new(-115, 4, 228),
		Vector3.new(135, 5, 225),  Vector3.new(148, 4, 238),
	}
	for _, rPos in ipairs(reefPositions) do
		OptimizationManager.CreateNaturalRock(rPos, Vector3.new(16, 8, 14), Color3.fromRGB(98, 96, 92), Enum.Material.Rock, folder)
	end

	print("[BeachBuilder] Pantai Pasir Putih, Dermaga, Beach Bar, Sun Loungers & Bonfire selesai dibangun.")
end

return BeachBuilder

]==])

createModule("WoodenBridgeBuilder", [==[
--!strict
-- WoodenBridgeBuilder.lua
-- Membangun Landmark Utama: Jembatan Kayu Melengkung Estetik di depan area pantai.
-- Dilengkapi Railing kayu detail, Tiang penyangga ke dasar air, Lampu lentera di kedua sisi,
-- Dekorasi tanaman di pinggir jembatan, dan Spot berhenti untuk mengambil screenshot.

local OptimizationManager = require(script.Parent.OptimizationManager)

local WoodenBridgeBuilder = {}

function WoodenBridgeBuilder.BuildLandmarkBridge(root: Folder)
	local folder = root:FindFirstChild("WoodenBridge") :: Folder
	local bridgeModel = Instance.new("Model")
	bridgeModel.Name = "SunsetLandmarkWoodenBridge"

	local startPos = Vector3.new(75, 11.5, 165)
	local endPos   = Vector3.new(185, 11.5, 255)
	local totalSegments = 32
	local bridgeWidth = 11

	for i = 0, totalSegments do
		local t = i / totalSegments
		local basePos = startPos:Lerp(endPos, t)
		-- Lengkungan Parabolik Halus (Mudah dilalui karakter Roblox)
		local archHeight = math.sin(t * math.pi) * 9.5
		local currentPos = basePos + Vector3.new(0, archHeight, 0)

		local nextT = math.min(1, (i + 1) / totalSegments)
		local nextBase = startPos:Lerp(endPos, nextT)
		local nextPos = nextBase + Vector3.new(0, math.sin(nextT * math.pi) * 9.5, 0)

		local lookCF = if i < totalSegments then CFrame.lookAt(currentPos, nextPos) else CFrame.lookAt( currentPos, currentPos + (endPos - startPos).Unit )

		-- Lebarkan bagian tengah jembatan sebagai Spot Berhenti & Screenshot
		local isCenterLookout = (i >= 14 and i <= 18)
		local currentWidth = if isCenterLookout then bridgeWidth + 5 else bridgeWidth

		-- Papan Lantai Jembatan Kayu Natural
		OptimizationManager.Part({
			Name = "BridgeDeckPlank_" .. i,
			Size = Vector3.new(currentWidth, 0.65, 4.8),
			CFrame = lookCF,
			Color = Color3.fromRGB(136, 88, 50),
			Material = Enum.Material.WoodPlanks,
			Parent = bridgeModel
		})

		-- Railing Kayu Detail di Kedua Sisi
		for _, side in ipairs({-1, 1}) do
			local railOffset = (currentWidth * 0.5) - 0.45
			-- Post Railing
			OptimizationManager.Part({
				Name = "RailPost",
				Size = Vector3.new(0.55, 3.6, 0.55),
				CFrame = lookCF * CFrame.new(side * railOffset, 1.8, 0),
				Color = Color3.fromRGB(102, 64, 36),
				Material = Enum.Material.Wood,
				Parent = bridgeModel
			})
			-- Handrail Atas & Tengah
			OptimizationManager.Part({
				Name = "TopHandrail",
				Size = Vector3.new(0.45, 0.4, 5.0),
				CFrame = lookCF * CFrame.new(side * railOffset, 3.4, 0),
				Color = Color3.fromRGB(122, 76, 42),
				Material = Enum.Material.Wood,
				Parent = bridgeModel
			})
			OptimizationManager.Part({
				Name = "MidHandrail",
				Size = Vector3.new(0.3, 0.3, 5.0),
				CFrame = lookCF * CFrame.new(side * railOffset, 1.9, 0),
				Color = Color3.fromRGB(122, 76, 42),
				Material = Enum.Material.Wood,
				Parent = bridgeModel
			})
		end

		-- Tiang Penyangga Besar & Lampu Lentera + Dekorasi Tanaman setiap 4 segmen
		if i % 4 == 0 then
			for _, side in ipairs({-1, 1}) do
				local railOffset = (currentWidth * 0.5) - 0.45
				local pillarWorldPos = (lookCF * CFrame.new(side * (railOffset - 0.4), 0, 0)).Position

				-- Tiang Penyangga Menancap ke Dasar Laut
				OptimizationManager.Part({
					Name = "BridgeSupportPiling",
					Shape = Enum.PartType.Cylinder,
					Size = Vector3.new(34, 1.35, 1.35),
					CFrame = CFrame.new(pillarWorldPos.X, pillarWorldPos.Y - 17, pillarWorldPos.Z) * CFrame.Angles(0, 0, math.rad(90)),
					Color = Color3.fromRGB(88, 54, 30),
					Material = Enum.Material.Wood,
					Parent = bridgeModel
				})

				-- Lampu Lentera di Kedua Sisi Jembatan
				local lanternBulb = OptimizationManager.Ellipsoid({
					Name = "BridgeLanternBulb",
					Size = Vector3.new(1.0, 1.25, 1.0),
					Position = pillarWorldPos + Vector3.new(0, 4.3, 0),
					Color = Color3.fromRGB(255, 214, 140),
					Material = Enum.Material.Neon,
					CanCollide = false,
					CastShadow = false,
					Parent = bridgeModel
				})
				local pl = Instance.new("PointLight")
				pl.Color = Color3.fromRGB(255, 200, 125)
				pl.Brightness = 1.4
				pl.Range = 22
				pl.Parent = lanternBulb

				-- Dekorasi Tanaman Hias di Pinggir Jembatan
				OptimizationManager.Ellipsoid({
					Name = "BridgePlanterGreenery",
					Size = Vector3.new(1.8, 1.4, 2.4),
					CFrame = lookCF * CFrame.new(side * (railOffset + 0.45), 0.7, 0),
					Color = Color3.fromRGB(58, 138, 56),
					Material = Enum.Material.LeafyGrass,
					CanCollide = false,
					CastShadow = false,
					Parent = bridgeModel
				})
			end
		end
	end

	bridgeModel.Parent = folder
	print("[WoodenBridgeBuilder] Landmark Sunset Wooden Bridge selesai dibangun.")
end

return WoodenBridgeBuilder

]==])

createModule("PhotoBoothBuilder", [==[
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

]==])

createModule("CafeBuilder", [==[
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

]==])

createModule("TowerBuilder", [==[
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

]==])

createModule("InteractiveSystem", [==[
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

]==])

local runner = Instance.new("Script")
runner.Name = "WorldGenerator"
runner.Source = [==[
--!strict
-- WorldGenerator.server.lua
-- Master Orchestrator Script untuk membangun seluruh dunia:
-- ULTRA REALISTIC TROPICAL HANGOUT WORLD — ROBLOX

local ServerScriptService = game:GetService("ServerScriptService")
local modulesFolder = ServerScriptService:WaitForChild("TropicalParadiseModules")

local OptimizationManager = require(modulesFolder:WaitForChild("OptimizationManager"))
local LightingManager     = require(modulesFolder:WaitForChild("LightingManager"))
local TerrainGenerator    = require(modulesFolder:WaitForChild("TerrainGenerator"))
local SpawnManager        = require(modulesFolder:WaitForChild("SpawnManager"))
local MountainBuilder     = require(modulesFolder:WaitForChild("MountainBuilder"))
local WaterfallBuilder    = require(modulesFolder:WaitForChild("WaterfallBuilder"))
local GardenBuilder       = require(modulesFolder:WaitForChild("GardenBuilder"))
local PlaygroundBuilder   = require(modulesFolder:WaitForChild("PlaygroundBuilder"))
local BeachBuilder        = require(modulesFolder:WaitForChild("BeachBuilder"))
local WoodenBridgeBuilder = require(modulesFolder:WaitForChild("WoodenBridgeBuilder"))
local PhotoBoothBuilder   = require(modulesFolder:WaitForChild("PhotoBoothBuilder"))
local CafeBuilder         = require(modulesFolder:WaitForChild("CafeBuilder"))
local TowerBuilder        = require(modulesFolder:WaitForChild("TowerBuilder"))
local AudioManager        = require(modulesFolder:WaitForChild("AudioManager"))
local InteractiveSystem   = require(modulesFolder:WaitForChild("InteractiveSystem"))

local startTime = os.clock()
print("==================================================================")
print("🌴 MEMULAI PEMBANGUNAN: TROPICAL PARADISE HANGOUT WORLD...")
print("==================================================================")

-- 1. Konfigurasi Performa & Root Folder
OptimizationManager.ConfigureWorkspace()
local worldRoot = OptimizationManager.GetWorldRoot()

-- 2. Pencahayaan Golden Hour
LightingManager.SetupGoldenHour()

-- 3. Voxel Terrain (Pulau, Pantai Melengkung, Laut, Gunung, Lagoon, Gua & Sungai)
TerrainGenerator.GenerateWorldTerrain()

-- 4. Pembangunan 5 Area Utama & Landmark
SpawnManager.BuildSpawnPlaza(worldRoot)
MountainBuilder.BuildMountains(worldRoot)
WaterfallBuilder.BuildWaterfallAndRiver(worldRoot)
GardenBuilder.BuildTropicalGarden(worldRoot)
PlaygroundBuilder.BuildPlayground(worldRoot)
BeachBuilder.BuildBeachAndCoast(worldRoot)
WoodenBridgeBuilder.BuildLandmarkBridge(worldRoot)
CafeBuilder.BuildSunsetBeachCafe(worldRoot)
TowerBuilder.BuildAllTowers(worldRoot)
PhotoBoothBuilder.BuildAllPhotoBooths(worldRoot)

-- 5. Audio Spatial & Sistem Interaktif Multiplayer
AudioManager.SetupAmbience(worldRoot)
InteractiveSystem.Initialize(worldRoot)

-- 6. Finalisasi Anchoring & Optimasi
OptimizationManager.FinalizeWorld(worldRoot)

local elapsed = os.clock() - startTime
print("==================================================================")
print(string.format("✅ TROPICAL PARADISE WORLD SELESAI DIBANGUN DALAM %.2f DETIK!", elapsed))
print("==================================================================")

]==]
runner.Parent = ServerScriptService

print("✅ Semua 15 ModuleScript & WorldGenerator berhasil dipasang di ServerScriptService!")
print("⏳ Menjalankan pembangunan dunia Tropical Paradise di Studio...")

-- Jalankan langsung di Studio agar map langsung terlihat tanpa perlu klik Play terlebih dahulu
local OptimizationManager = require(modFolder.OptimizationManager)
local LightingManager     = require(modFolder.LightingManager)
local TerrainGenerator    = require(modFolder.TerrainGenerator)
local SpawnManager        = require(modFolder.SpawnManager)
local MountainBuilder     = require(modFolder.MountainBuilder)
local WaterfallBuilder    = require(modFolder.WaterfallBuilder)
local GardenBuilder       = require(modFolder.GardenBuilder)
local PlaygroundBuilder   = require(modFolder.PlaygroundBuilder)
local BeachBuilder        = require(modFolder.BeachBuilder)
local WoodenBridgeBuilder = require(modFolder.WoodenBridgeBuilder)
local PhotoBoothBuilder   = require(modFolder.PhotoBoothBuilder)
local CafeBuilder         = require(modFolder.CafeBuilder)
local TowerBuilder        = require(modFolder.TowerBuilder)
local AudioManager        = require(modFolder.AudioManager)
local InteractiveSystem   = require(modFolder.InteractiveSystem)

-- Hapus Baseplate bawaan jika ada
local bp = workspace:FindFirstChild("Baseplate")
if bp then bp:Destroy() end

OptimizationManager.ConfigureWorkspace()
local worldRoot = OptimizationManager.GetWorldRoot()
LightingManager.SetupGoldenHour()
TerrainGenerator.GenerateWorldTerrain()
SpawnManager.BuildSpawnPlaza(worldRoot)
MountainBuilder.BuildMountains(worldRoot)
WaterfallBuilder.BuildWaterfallAndRiver(worldRoot)
GardenBuilder.BuildTropicalGarden(worldRoot)
PlaygroundBuilder.BuildPlayground(worldRoot)
BeachBuilder.BuildBeachAndCoast(worldRoot)
WoodenBridgeBuilder.BuildLandmarkBridge(worldRoot)
CafeBuilder.BuildSunsetBeachCafe(worldRoot)
TowerBuilder.BuildAllTowers(worldRoot)
PhotoBoothBuilder.BuildAllPhotoBooths(worldRoot)
AudioManager.SetupAmbience(worldRoot)
InteractiveSystem.Initialize(worldRoot)
OptimizationManager.FinalizeWorld(worldRoot)
print("🌴 TROPICAL PARADISE WORLD SIAP DIJELAJAHI!")
