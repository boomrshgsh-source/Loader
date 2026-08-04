local Player = game:GetService("Players").LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local autofarm = true

local function findCoin()
	if not autofarm then
		return nil
	end

	local coinFolder = workspace.Factory.CoinContainer

	for _, v in ipairs(coinFolder:GetChildren()) do
		if v:IsA("Part") and v.Name == "Coin_Server" then
			return v
		end
	end

	return nil
end

while task.wait(0.1) do
	local co = findCoin()

	if co then
		HRP.CFrame = co.CFrame
	end
end
