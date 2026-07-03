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
		gui.Size = UDim2.new(0, 60, 0, 18)
		gui.StudsOffset = Vector3.new(0, -3.5, 0) -- ใต้เท้า
		gui.Parent = hrp

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = gui

		RunService.RenderStepped:Connect(function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp.Parent then
				local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
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
