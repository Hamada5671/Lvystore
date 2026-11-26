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
