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
