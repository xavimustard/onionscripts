local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local delayBetweenStages = 2
local autofarmEnabled = false
local totalRuns = 0
local totalGold = 0

local stages = {
	Vector3.new(-69.88, 60, 1371.00),    -- STAGE 1
	Vector3.new(-45.50, 60, 2133.89),    -- STAGE 2
	Vector3.new(-43.02, 60, 2907.28),    -- STAGE 3
	Vector3.new(-57.43, 60, 3679.27),    -- STAGE 4
	Vector3.new(-39.82, 60, 4451.44),    -- STAGE 5a
	Vector3.new(-19.72, 60, 5222.60),    -- STAGE 5b
	Vector3.new(-3.54, 60, 5985.04),     -- STAGE 6
	Vector3.new(1.23, 60, 6758.04),      -- STAGE 7
	Vector3.new(-23.42, 60, 7531.34),    -- STAGE 8
}

local treasure = Vector3.new(-60.73, -348.92, 9495.40)

-- GUI
local Window = Rayfield:CreateWindow({
	Name = "OnionScripts - Build A Boat AutoFarm",
	LoadingTitle = "OnionScripts",
	LoadingSubtitle = "Fixed idiot bugs",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "OnionScripts",
		FileName = "BABAutoFarm"
	},
	KeySystem = false,
})

local farmTab = Window:CreateTab("AutoFarm", 4483362458)
local configTab = Window:CreateTab("Config", 4483362458)

farmTab:CreateParagraph({
	Title = "INFO",
	Content = "Teleports through stages and farms gold.\nResets when chest kills you."
})

local runsText = farmTab:CreateParagraph({Title = "Rundy ukończone", Content = "0"})
local goldText = farmTab:CreateParagraph({Title = "Szacowany Gold", Content = "0"})

farmTab:CreateToggle({
	Name = "Turn ON/OFF Autofarm",
	CurrentValue = false,
	Flag = "AutoFarmToggle",
	Callback = function(Value)
		autofarmEnabled = Value
	end,
})

configTab:CreateSlider({
	Name = "Delay through checkpoints",
	Range = {1, 10},
	Increment = 1,
	Suffix = "s",
	CurrentValue = 2,
	Flag = "StageDelay",
	Callback = function(Value)
		delayBetweenStages = Value
	end,
})

configTab:CreateParagraph({
	Title = "WARNING",
	Content = "Low delay = less gold.\nDepends on ping & wifi."
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Died detection
local died = false
local function SetupDeathDetection()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")

	died = false
	hum.Died:Connect(function()
		died = true
	end)
end

-- Gold counter updater
local function UpdateStats()
	runsText:Set({Title = "Rundy ukończone", Content = tostring(totalRuns)})
	goldText:Set({Title = "Szacowany Gold", Content = tostring(totalGold)})
end

-- Autofarm main loop
task.spawn(function()
	while true do
		if autofarmEnabled then
			local char = player.Character or player.CharacterAdded:Wait()
			local root = char:WaitForChild("HumanoidRootPart")

			SetupDeathDetection()

			for _, pos in ipairs(stages) do
				if not autofarmEnabled then break end
				root.Anchored = false
				root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(0.25)
				root.Anchored = true
				task.wait(delayBetweenStages)
			end

			if not autofarmEnabled then
				task.wait(1)
				continue
			end

			-- Skrzynka teleport
			root.Anchored = false
			root.CFrame = CFrame.new(treasure + Vector3.new(0, 5, 0))
			task.wait(0.5)
			root.Anchored = true

			-- Oczekiwanie na śmierć
			local timer = 0
			while timer < 15 and not died do
				if not autofarmEnabled then break end
				task.wait(1)
				timer += 1
			end

			if died then
				totalRuns += 1
				local earnedGold = 50 + math.random(10, 35)
				totalGold += earnedGold

				UpdateStats()

				game.StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "[OnionScripts] Runda #" .. totalRuns .. " zakończona (+ " .. earnedGold .. " golda)",
					Color = Color3.fromRGB(255, 255, 0),
					Font = Enum.Font.SourceSansBold,
					FontSize = Enum.FontSize.Size24,
				})
			end

			task.wait(6) -- czas na respawn
		else
			task.wait(1)
		end
	end
end)
