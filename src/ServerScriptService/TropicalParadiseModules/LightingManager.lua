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
