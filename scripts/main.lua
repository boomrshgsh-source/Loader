local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function Setup(plr)
	if plr == LocalPlayer then return end

	local function CharacterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end

		local old = hrp:FindFirstChild("DistanceESP")
		if old then
			old:Destroy()
		end

		local gui = Instance.new("BillboardGui")
		gui.Name = "DistanceESP"
		gui.Adornee = hrp
		gui.AlwaysOnTop = true
		gui.Size = UDim2.new(0, 50, 0, 14)
		gui.StudsOffset = Vector3.new(0, -3.3, 0)
		gui.Parent = hrp

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextSize = 15
		label.TextScaled = false
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextStrokeTransparency = 0
		label.Parent = gui

		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not hrp.Parent then
				connection:Disconnect()
				return
			end

			local myChar = LocalPlayer.Character
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if myHRP then
				local distance = math.floor((myHRP.Position - hrp.Position).Magnitude)
				label.Text = "[" .. distance .. "]"
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
