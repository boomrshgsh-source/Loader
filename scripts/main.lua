local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function CreateNameESP(player)
    if player == LocalPlayer then
        return
    end

    local function Setup(character)
        local head = character:WaitForChild("Head", 5)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if not head or not hrp then return end

        local old = head:FindFirstChild("NameESP")
        if old then
            old:Destroy()
        end

        local gui = Instance.new("BillboardGui")
        gui.Name = "NameESP"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 60, 0, 14)
        gui.AlwaysOnTop = true
        gui.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextScaled = false
        text.TextSize = 10
        text.Font = Enum.Font.GothamBold
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        text.TextStrokeTransparency = 0
        text.Parent = gui

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character.Parent then
                connection:Disconnect()
                return
            end

            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local distance = (myHRP.Position - hrp.Position).Magnitude

                -- ยิ่งไกล ชื่อยิ่งสูง
                local height = math.clamp(2 + distance / 40, 2, 8)
                gui.StudsOffset = Vector3.new(0, height, 0)
            end
        end)
    end

    if player.Character then
        Setup(player.Character)
    end

    player.CharacterAdded:Connect(Setup)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateNameESP(player)
end

Players.PlayerAdded:Connect(CreateNameESP)
