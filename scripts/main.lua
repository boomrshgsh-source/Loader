local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function Setup(plr)
	if plr == LocalPlayer then return end

	local function CharacterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end

		if hrp:FindFirstChild("DistanceESP") then
			hrp.DistanceESP:Destroy()
		end

		local gui = Instance.new("BillboardGui")
		gui.Name = "DistanceESP"
		gui.Adornee = hrp
		gui.AlwaysOnTop = true
		gui.Size = UDim2.new(0, 28, 0, 8)
		gui.StudsOffset = Vector3.new(0, -3.5, 0)
		gui.Parent = hrp

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.Code
		label.TextScaled = false
		label.TextSize = 6
		label.Parent = gui

		RunService.RenderStepped:Connect(function()
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") and hrp.Parent then
				local dist = math.floor((myChar.HumanoidRootPart.Position - hrp.Position).Magnitude)
				label.Text = "[" .. dist .. "]"
			end
		end)
	end

	if plr.Character then
		CharacterAdded(plr.Character)
	end

	plr.CharacterAdded:Connect(CharacterAdded)
end

for _, plr in ipairs(Players:GetPlayers()) do
	Setup(plr)
end

Players.PlayerAdded:Connect(Setup)
