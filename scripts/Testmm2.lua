local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local autofarm = true

local currentCoin = nil
local currentConn = nil

local function clearCurrent()
	if currentConn then
		currentConn:Disconnect()
		currentConn = nil
	end
	currentCoin = nil
end

local function watchCoin(coin)
	clearCurrent()
	currentCoin = coin
	if not coin or not coin:IsDescendantOf(workspace) then
		clearCurrent()
		return
	end

	currentConn = coin.AncestryChanged:Connect(function()
		if not coin or not coin:IsDescendantOf(workspace) then
			clearCurrent()
		end
	end)
end

local function findCoin()
	if not autofarm then
		return nil
	end

	local coinContainer = workspace:FindFirstChild("CoinContainer", true)
	if not coinContainer then
		return nil
	end

	for _, v in ipairs(coinContainer:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "Coin_Server" then
			return v
		end
	end

	return nil
end

while task.wait(0.05) do
	if not autofarm then
		clearCurrent()
		continue
	end

	if not currentCoin or not currentCoin:IsDescendantOf(workspace) then
		local coin = findCoin()
		if coin then
			watchCoin(coin)
		end
	end

	if currentCoin and currentCoin:IsA("BasePart") then
		pcall(function()
			HRP.CFrame = currentCoin.CFrame
		end)
	end
end
