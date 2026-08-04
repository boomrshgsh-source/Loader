local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local autofarm = true

local function findCoin()
	if not autofarm then
		return nil
	end

	local coinContainer = workspace:FindFirstChild("CoinContainer", true)
	if not coinContainer then
		return nil
	end

	for _, v in ipairs(coinContainer:GetChildren()) do
		if v:IsA("Part") and v.Name == "Coin_Server" then
			return v
		end
	end

	return nil
end

while task.wait(0.1) do
	local coin = findCoin()

	if coin then
		HRP.CFrame = coin.CFrame
	end
end
