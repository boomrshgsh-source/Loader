local Players = game:GetService("Players")

local function AddESP(player)
    if player == Players.LocalPlayer then
        return
    end

    local function Setup(character)
        if character:FindFirstChild("ESP_Highlight") then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end

    if player.Character then
        Setup(player.Character)
    end

    player.CharacterAdded:Connect(Setup)
end

for _, player in ipairs(Players:GetPlayers()) do
    AddESP(player)
end

Players.PlayerAdded:Connect(AddESP)
