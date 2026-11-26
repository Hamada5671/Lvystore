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
