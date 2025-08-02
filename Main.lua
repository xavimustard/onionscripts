local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "OnionScripts - Build A Boat",
	LoadingTitle = "OnionScripts",
	LoadingSubtitle = "Troll mode activated",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "OnionScripts",
		FileName = "BABTroll",
	},
	KeySystem = false,
})

local trollTab = Window:CreateTab("Troll", 4483362458)

local bypassIsolation = false

trollTab:CreateToggle({
	Name = "Bypass Isolation Mode",
	CurrentValue = false,
	Callback = function(val)
		bypassIsolation = val
		-- Tu możesz dodać kod do faktycznego bypassa isolation mode, jeśli wiesz co i jak
		if val then
			print("Isolation mode bypass ON - ale sam se musisz zrobić resztę, pajacu")
		else
			print("Isolation mode bypass OFF")
		end
	end,
})

local teams = {
	"Yellow",
	"Magenta",
	"Blue",
	"Green",
	"Black",
	"Red",
	"White",
}

local teamPositions = {
	Yellow = Vector3.new(-474.52, -9.93, 639.84),
	Magenta = Vector3.new(365.70, -9.93, 647.55),
	Blue = Vector3.new(373.35, -9.73, 303.35),
	Green = Vector3.new(-483.60, -9.73, 292.25),
	Black = Vector3.new(-484.37, -9.73, -69.36),
	Red = Vector3.new(372.12, -9.73, -65.49),
	White = Vector3.new(-51.78, -9.73, -502.33),
}

local selectedTeam = "Yellow"

local dropdown = trollTab:CreateDropdown({
	Name = "Select Team",
	Options = teams,
	CurrentOption = "Yellow",
	Callback = function(val)
		selectedTeam = val
	end,
})

trollTab:CreateButton({
	Name = "Teleport to Team",
	Callback = function()
		local player = game.Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local root = char:WaitForChild("HumanoidRootPart")

		local pos = teamPositions[selectedTeam]
		if pos then
			root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
			game.StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "[OnionScripts] Teleported to " .. selectedTeam .. " Team",
				Color = Color3.fromRGB(255, 255, 0),
				Font = Enum.Font.SourceSansBold,
				FontSize = Enum.FontSize.Size24,
			})
		else
			warn("No position found for team: " .. selectedTeam)
		end
	end,
})
