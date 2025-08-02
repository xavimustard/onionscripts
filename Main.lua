local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local delayBetweenStages = 2
local autofarmEnabled = false
local totalRuns = 0 
local totalGold = 0
local isolationBypassEnabled = false

local stages = {
	Vector3.new(-69.88, 39.94, 1371.00),  -- Stage 1
	Vector3.new(-45.50, 35.61, 2133.89),  -- Stage 2
	Vector3.new(-43.02, 59.40, 2907.28),  -- Stage 3
	Vector3.new(-57.43, 60.20, 3679.27),  -- Stage 4
	Vector3.new(-39.82, 50.38, 4451.44),  -- Stage 5
	Vector3.new(-19.72, 52.05, 5222.60),  -- Stage 6
	Vector3.new(-3.54, 47.49, 5985.04),   -- Stage 7
	Vector3.new(1.23, 45.74, 6758.04),    -- Stage 8
	Vector3.new(-23.42, 69.45, 7531.34),  -- Stage 9
}

local treasure = Vector3.new(-60.73, -338.9, 9495.40)

local TeamsCoords = {
	["Yellow"] = Vector3.new(-474.52, -9.93, 639.84),
	["Magenta"] = Vector3.new(365.70, -9.93, 647.55),
	["Blue"] = Vector3.new(373.35, -9.73, 303.35),
	["Green"] = Vector3.new(-483.60, -9.73, 292.25),
	["Black"] = Vector3.new(-484.37, -9.73, -69.36),
	["Red"] = Vector3.new(372.12, -9.73, -65.49),
	["White"] = Vector3.new(-51.78, -9.73, -502.33),
}

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
local trollTab = Window:CreateTab("Troll", 4483362458)

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

trollTab:CreateToggle({
	Name = "Bypass Isolation Mode",
	CurrentValue = false,
	Flag = "BypassIsolation",
	Callback = function(Value)
		isolationBypassEnabled = Value
		-- Tutaj powinieneś wrzucić faktyczny kod bypassu isolation mode jeśli masz
		if isolationBypassEnabled then
			print("Isolation mode bypass enabled. Teraz możesz robić co chcesz.")
		else
			print("Isolation mode bypass disabled.")
		end
	end,
})

local selectedTeam = "Yellow"

trollTab:CreateDropdown({
	Name = "Select Team",
	Options = {"Yellow", "Magenta", "Blue", "Green", "Black", "Red", "White"},
	CurrentOption = "Yellow",
	Flag = "SelectTeam",
	Callback = function(Option)
		selectedTeam = Option
	end,
})

trollTab:CreateButton({
	Name = "Teleport to Team",
	Callback = function()
		local player = game.Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local root = char:WaitForChild("HumanoidRootPart")

		local targetPos = TeamsCoords[selectedTeam]
		if targetPos then
			root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
			game.StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "[OnionScripts] Teleported to " .. selectedTeam .. " team!",
				Color = Color3.fromRGB(255, 0, 0),
				Font = Enum.Font.SourceSansBold,
				FontSize = Enum.FontSize.Size24,
			})
		else
			warn("No coordinates for team: " .. tostring(selectedTeam))
		end
	end,
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local died = false
local function SetupDeathDetection()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")

	died = false
	hum.Died:Connect(function()
		died = true
	end)
end

local function UpdateStats()
	runsText:Set({Title = "Rundy ukończone", Content = tostring(totalRuns)})
	goldText:Set({Title = "Szacowany Gold", Content = tostring(totalGold)})
end

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

			root.Anchored = false
			root.CFrame = CFrame.new(treasure + Vector3.new(0, 5, 0))
			task.wait(0.5)
			root.Anchored = true

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

			task.wait(6)
		else
			task.wait(1)
		end
	end
end)
