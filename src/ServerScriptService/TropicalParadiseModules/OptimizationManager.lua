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
