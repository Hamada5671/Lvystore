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
