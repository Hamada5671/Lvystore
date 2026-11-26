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
