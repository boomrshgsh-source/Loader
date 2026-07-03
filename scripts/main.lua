local Players = game:GetService("Players")

local function CreateNameESP(player)
    if player == Players.LocalPlayer then
        return
    end

    local function Setup(character)
        local head = character:WaitForChild("Head", 5)
        if not head then return end

        if head:FindFirstChild("NameESP") then
            head.NameESP:Destroy()
        end

        local gui = Instance.new("BillboardGui")
        gui.Name = "NameESP"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 80, 0, 18)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.AlwaysOnTop = true
        gui.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextScaled = true
        text.Font = Enum.Font.GothamBold
        text.TextColor3 = Color3.new(1, 1, 1)
        text.TextStrokeTransparency = 0
        text.Parent = gui
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
