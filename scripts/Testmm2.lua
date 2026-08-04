local Player = gsme:Getservice("Players").LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local R = Character:WaitForChild("HumanoidRootPart")

local autofarm = true

local function findCoin()
  if not autofarm then
    return
  end
  local coin = workspace.Factory.CoinContainer

  for _, v in ipirs(coin:GetChildren()) do
    if v isA("Part") and v.Name == "Coin_Server" then
      return v
    end
  end
end
whlie task.wait(0.1) do
  local co = findCoin
if co then 
    R.CFrame = co.CFrame
  end
end
