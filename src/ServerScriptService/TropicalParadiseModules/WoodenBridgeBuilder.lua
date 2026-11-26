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
