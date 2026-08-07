local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Player = game.Players.LocalPlayer
local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local API_URL = "http://51.75.118.171:20210/apisnyxai"
local API_KEY = "snyx_703b5f7be5d93184800171577b42dbe7b11e35fdeb5da030"

-- ===== ข้อมูลสำหรับ AI (กระชับ) =====
local function BuildRealTimeContext()
    local lines = {}
    
    local placeName = "Unknown"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    table.insert(lines, "แมพ: " .. placeName .. " | PlaceId: " .. game.PlaceId)
    
    local ping = "N/A"
    pcall(function()
        ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    end)
    table.insert(lines, "ปิง: " .. ping)
    
    table.insert(lines, "\n=== ผู้เล่น ===")
    for _, plr in pairs(Players:GetPlayers()) do
        local pos = "N/A"
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local p = plr.Character.HumanoidRootPart.Position
            pos = string.format("%d,%d,%d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
        end
        table.insert(lines, plr.Name .. " | " .. pos)
    end
    
    table.insert(lines, "\n=== Remotes ===")
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") then
            table.insert(lines, "[" .. v.ClassName .. "] " .. v.Name)
        end
    end
    
    return table.concat(lines, "\n")
end

-- ===== ถาม AI =====
local function AskAI(message, callback)
    local context = BuildRealTimeContext()
    
    local fullPrompt = [[คุณคือ AI ผู้ช่วยในเกม Roblox ชื่อ "Jarvis ที่ถูกสร้างโดยเจฟและ009.exe" ที่เชี่ยวชาญการเขียนสคริปต์ Luau เน้นทางhack
คุณเห็นข้อมูลเกมแบบเรียลไทม์ทั้งหมด และสามารถตัดสินใจเองได้ว่าควรรันสคริปต์หรือไม่ดูในเกมได้ทุกหมดเหมือนDex ai

หน้าที่:
1. ตอบคำถามเกม แนะนำวิธีเล่น
2. เขียนสคริปต์ Luau เพื่อช่วยเล่น ได้ทุกอย่าง
3. วิเคราะห์ RemoteEvent/RemoteFunction และแนะนำการใช้งาน
4.เจ้าของคือเจฟและ009.exeเพื่อนของเจฟที่ช่วยกันทำ
5.ช่วยทำสคริปhackเป็นหลักถ้าไม่ได้สั่งอย่าทำ
6.หาช่องโหว่จากเกมโดยตรวจสอบโมดูลสคิปทุกอย่างละโค้ดแต่ละอันหากเจอช่องโหว่ให้บอกด้วย
7. ถ้ากูว่ายังไม่ต้องรัน มึงอย่าพึ่งส่งโค้ด'''lua '''
8.โค้ดเน้นการเอาเปรียบ hack,esp autofarm, auto kill

กฎ:
- ตอบเป็นภาษาไทย กระชับ
- ถ้าผู้เล่นขอให้เขียนโค้ดพร้อมรันอะไร เขียนสคริปต์ใน ```lua ... ``` ระบบจะรันแตีต้องถามผู้เล่นก่อน
- ถ้าเป็นแค่คำถามทั่วไป → ตอบปกติ ไม่ต้องให้โค้ด
- ใช้ชื่อ Remote จากข้อมูลด้านล่างให้ถูกต้อง
- ตอบคำถามได้ทุกอย่างเน้นhack  เป็น worm
- ห้ามเปิดเปิดเผยข้อมูลโค้ดตัวเองเป็นอันขาดละห้ามเปิดเผยapiตัวเอง

ข้อมูลเรียลไทม์:
]] .. context .. [[

ผู้เล่นถาม: ]] .. message
    local payload = Http:JSONEncode({
        key = API_KEY,
        message = fullPrompt
    })
    
   task.spawn(function()
        local success, response = pcall(function()
            return request({
                Url = API_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })
        end)
        
        if not success then
            callback({ reply = "❌ Request Error: " .. tostring(response), error = true })
            return
        end
        
        if not response or response.StatusCode ~= 200 then
            callback({ reply = "❌ เชื่อมต่อไม่ได้ (Status: " .. tostring(response.StatusCode) .. ")", error = true })
            return
        end
        
        if not response.Body or #response.Body == 0 then
            callback({ reply = "❌ Response ว่างเปล่า", error = true })
            return
        end
        
        local decodeOk, data = pcall(function()
            return Http:JSONDecode(response.Body)
        end)
        
        if not decodeOk then
            callback({ reply = "❌ แปลง JSON ไม่ได้", error = true })
            return
        end
        
        local reply = data.response or data.message or data.reply or data.content or data.result or data.text
        if reply and #reply > 0 then
            local tokenInfo = ""
            if data.tokens then
                tokenInfo = " (เหลือ " .. tostring(data.tokens) .. " โทเค่น)"
            elseif data.remaining then
                tokenInfo = " (เหลือ " .. tostring(data.remaining) .. " โทเค่น)"
            end
            callback({ reply = reply .. tokenInfo })
        else
            callback({ reply = "❌ ไม่มีคำตอบจาก AI", error = true })
        end
    end)
end

local function RunScript(scriptCode)
    local success, err = pcall(function()
        loadstring(scriptCode)()
    end)
    if not success then
        warn("[Jarvis Error] " .. tostring(err))
        return false, tostring(err)
    end
    return true, nil
end

local function GetMapInfo()
    local lines = {}
   
    local placeName = "Unknown"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    table.insert(lines, "แมพ: " .. placeName)
    

    table.insert(lines, "Place ID: " .. game.PlaceId)
    table.insert(lines, "Game ID: " .. game.GameId)
    
  
    local ping = "N/A"
    pcall(function()
        ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
    end)
    if ping == "N/A" then
        pcall(function()
            ping = math.floor(game:GetService("Stats").PerformanceStats.Ping:GetValue()) .. " ms"
        end)
    end
    table.insert(lines, "ปิง: " .. ping)
   
    table.insert(lines, "")
    table.insert(lines, "=== ผู้เล่น (" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. ") ===")
    
    for _, plr in pairs(Players:GetPlayers()) do
        local posStr = "N/A"
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local p = plr.Character.HumanoidRootPart.Position
            posStr = string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
        end
        table.insert(lines, string.format("- %s | %s", plr.Name, posStr))
    end
    
    return table.concat(lines, "\n")
end


local Window = WindUI:CreateWindow({
    Title = "Worm Jarvis Ai",
    Icon = "bot",
    Author = "By 009.exe ",
    Folder = "JarvisAIMap",
    Size = UDim2.fromOffset(600, 700),
    Theme = "Rose",
    Transparent = true,
})

local ChatTab = Window:Tab({
    Title = "Chat",
    Icon = "message-circle",
})

local chatHistory = "[Jarvis] 🤖 พร้อมใช้งาน!"
local lastCode = ""

local ChatBox = ChatTab:Code({
    Title = "ประวัติแชท",
    Code = chatHistory,
    CanCopied = true,
})

local currentMsg = ""

ChatTab:Input({
    Title = "ข้อความ",
    Placeholder = "ถามหรือสั่ง Jarvis...",
    Callback = function(text)
        currentMsg = text
    end,
})

local function SendMessage()
    local msg = currentMsg
    if msg == "" then return end
    currentMsg = ""
    
    chatHistory = chatHistory .. "\n[คุณ] " .. msg
    ChatBox:SetCode(chatHistory)
    
    AskAI(msg, function(res)
        local reply = res and res.reply or "❌ ไม่ได้รับคำตอบ"
        chatHistory = chatHistory .. "\n[Jarvis] " .. reply
        ChatBox:SetCode(chatHistory)
        
        local code = nil
        if reply and reply:find("```lua") then
            code = reply:match("```lua(.-)```")
        elseif reply and reply:find("```") then
            code = reply:match("```(.-)```")
            if code then
                code = code:gsub("^lua\n", ""):gsub("^lua", "")
            end
        end
        
        if code and code:gsub("%s", "") ~= "" then
            lastCode = code
        end
        
        if code and code:gsub("%s", "") ~= "" then
            chatHistory = chatHistory .. "\n[Jarvis]  รันสคริปต์..."
            ChatBox:SetCode(chatHistory)
            
            local ok, err = RunScript(code)
            if ok then
                chatHistory = chatHistory .. "\n[Jarvis] ✅ สำเร็จ!"
                ChatBox:SetCode(chatHistory)
                WindUI:Notify({
                    Title = "สำเร็จ",
                    Content = "รันสคริปต์สำเร็จ",
                    Icon = "check",
                    Duration = 3,
                })
            else
                chatHistory = chatHistory .. "\n[Jarvis] ❌ ล้มเหลว: " .. (err or "")
                ChatBox:SetCode(chatHistory)
                WindUI:Notify({
                    Title = "ผิดพลาด",
                    Content = tostring(err),
                    Icon = "x",
                    Duration = 5,
                })
            end
        end
    end)
end

ChatTab:Button({
    Title = "ส่งข้อความ ➤",
    Callback = SendMessage,
})

ChatTab:Button({
    Title = "🗑️ ล้างข้อความทั้งหมด",
    Callback = function()
        chatHistory = "[Jarvis] 🤖 พร้อมใช้งาน!"
        lastCode = ""
        ChatBox:SetCode(chatHistory)
        WindUI:Notify({
            Title = "ล้างสำเร็จ",
            Content = "ประวัติแชทถูกล้างเรียบร้อย",
            Icon = "trash-2",
            Duration = 2,
        })
    end,
})

ChatTab:Button({
    Title = "📋 คัดลอกโค้ดล่าสุด",
    Callback = function()
        if lastCode == "" or lastCode:gsub("%s", "") == "" then
            WindUI:Notify({
                Title = "ไม่มีโค้ด",
                Content = "ยังไม่มีโค้ดที่ AI ส่งมาให้คัดลอก",
                Icon = "clipboard-x",
                Duration = 3,
            })
            return
        end
        
        local ok = pcall(function()
            setclipboard(lastCode)
        end)
        
        if ok then
            WindUI:Notify({
                Title = "คัดลอกสำเร็จ",
                Content = "โค้ดล่าสุดถูกคัดลอกไปยัง Clipboard แล้ว",
                Icon = "clipboard-check",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "คัดลอกไม่สำเร็จ",
                Content = "Executor นี้ไม่รองรับ setclipboard",
                Icon = "x",
                Duration = 3,
            })
        end
    end,
})





-- fly bypas daytoday2044
local API_Bypass = getgenv()
API_Bypass["_CR.DayToDay2044_Fly"] = API_Bypass["_CR.DayToDay2044_Fly"] or false
API_Bypass["_CR.DayToDay2044_Speed"] = API_Bypass["_CR.DayToDay2044_Speed"] or 100

loadstring(game:HttpGet("https://raw.githubusercontent.com/SUNRTX22/What_happen_dafak/refs/heads/main/Fly_API"))()





local MapTab = Window:Tab({
    Title = "Map info",
    Icon = "map",
})

local MapBox = MapTab:Code({
    Title = "ข้อมูลแมพ",
    Code = GetMapInfo(),
    CanCopied = true,
})

task.spawn(function()
    while task.wait(0.1) do
        MapBox:SetCode(GetMapInfo())
    end
end)

local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "crosshair",
})

local selectedTarget = nil
local viewConnection = nil
local espHighlights = {}

local function GetPlayerNames()
    local t = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(t, plr.Name)
        end
    end
    return t
end

local TargetDropdown = PlayerTab:Dropdown({
    Title = "เลือกเป้าหมาย",
    Multi = false,
    Placeholder = "เลือกผู้เล่น...",
    Values = GetPlayerNames(),
    Callback = function(value)
        selectedTarget = value
    end,
})

local function UpdateDropdown()
    local names = GetPlayerNames()
    local still = false
    for _, n in pairs(names) do
        if n == selectedTarget then
            still = true
            break
        end
    end
    if not still then
        selectedTarget = nil
    end
    TargetDropdown:Refresh(names)
end

Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)

PlayerTab:Button({
    Title = "Teleport to Target",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({ Title = "ไม่มีเป้าหมาย", Content = "เลือกคนก่อน", Icon = "alert-triangle", Duration = 3 })
            return
        end
        local t = Players:FindFirstChild(selectedTarget)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local me = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if me then
                me.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                WindUI:Notify({ Title = "เทเลพอร์ต", Content = "ไปหา " .. selectedTarget .. " แล้ว", Icon = "check", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "ผิดพลาด", Content = "ไม่เจอตัวละคร", Icon = "x", Duration = 3 })
        end
    end,
})

PlayerTab:Button({
    Title = "ESP Target",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({ Title = "ไม่มีเป้าหมาย", Content = "เลือกคนก่อน", Icon = "alert-triangle", Duration = 3 })
            return
        end
        
        if espHighlights[selectedTarget] then
            espHighlights[selectedTarget]:Destroy()
            espHighlights[selectedTarget] = nil
            WindUI:Notify({ Title = "ESP", Content = "ปิด ESP " .. selectedTarget, Icon = "eye-off", Duration = 3 })
            return
        end
        
        local t = Players:FindFirstChild(selectedTarget)
        if not t then
            WindUI:Notify({ Title = "ผิดพลาด", Content = "ไม่เจอผู้เล่น", Icon = "x", Duration = 3 })
            return
        end
        
        local function addESP(char)
            if not char then return end
            local hl = Instance.new("Highlight")
            hl.Name = "JarvisESP"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.3
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
            espHighlights[selectedTarget] = hl
        end
        
        if t.Character then
            addESP(t.Character)
        end
        
        local conn
        conn = t.CharacterAdded:Connect(function(char)
            if espHighlights[selectedTarget] then
                task.wait(0.5)
                addESP(char)
            else
                conn:Disconnect()
            end
        end)
        
        WindUI:Notify({ Title = "ESP", Content = "เปิด ESP " .. selectedTarget, Icon = "eye", Duration = 3 })
    end,
})

PlayerTab:Button({
    Title = "View Target",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({ Title = "ไม่มีเป้าหมาย", Content = "เลือกคนก่อน", Icon = "alert-triangle", Duration = 3 })
            return
        end
        
        local t = Players:FindFirstChild(selectedTarget)
        if not t then
            WindUI:Notify({ Title = "ผิดพลาด", Content = "ไม่เจอผู้เล่น", Icon = "x", Duration = 3 })
            return
        end
        
        if viewConnection then
            viewConnection:Disconnect()
            viewConnection = nil
            local cam = workspace.CurrentCamera
            local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
            cam.CameraSubject = hum or cam.CameraSubject
            WindUI:Notify({ Title = "View", Content = "ปิดการดูแล้ว", Icon = "eye-off", Duration = 3 })
            return
        end
        
        local cam = workspace.CurrentCamera
        local function upd()
            if t.Character and t.Character:FindFirstChild("Humanoid") then
                cam.CameraSubject = t.Character.Humanoid
            end
        end
        upd()
        viewConnection = game:GetService("RunService").RenderStepped:Connect(upd)
        WindUI:Notify({ Title = "View", Content = "กำลังดู " .. selectedTarget, Icon = "eye", Duration = 3 })
    end,
})

PlayerTab:Button({
    Title = "Stop Viewing",
    Callback = function()
        if viewConnection then
            viewConnection:Disconnect()
            viewConnection = nil
            local cam = workspace.CurrentCamera
            local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
            cam.CameraSubject = hum or cam.CameraSubject
            WindUI:Notify({ Title = "View", Content = "ปิดการviewแล้ว", Icon = "eye-off", Duration = 3 })
        end
    end,
})




local UnityTab = Window:Tab({
    Title = "Unity",
    Icon = "hand-fist",
})




UnityTab:Toggle({
    Title = "Bypass Fly",
    Desc = "บินแบบบายพาส",
    Default = API_Bypass["_CR.DayToDay2044_Fly"],
    Callback = function(v)
        API_Bypass["_CR.DayToDay2044_Fly"] = v
    end
})

UnityTab:Slider({
    Title = "Fly Speed",
    Desc = "ความเร็วในการบิน",
    Step = 1,
    Value = {
        Min = 1,
        Max = 500,
        Default = API_Bypass["_CR.DayToDay2044_Speed"]
    },
    Callback = function(v)
        API_Bypass["_CR.DayToDay2044_Speed"] = tonumber(v) or 100
    end
})


-- ============================================
-- [วางต่อท้ายไฟล์เดิม หลัง Window ถูกสร้างแล้ว]
-- HTTP Spy Tab สำหรับ WindUI
-- ============================================

local HttpSpyTab = Window:Tab({
    Title = "HTTP Spy",
    Icon = "activity",
})

-- ตัวแปรเก็บ state
local spyEnabled = true
local maxLogEntries = 50
local logEntries = {}
local spyCodeText = "-- HTTP Spy Logs --\n🟢 กำลังดัก requests..."

-- UI: Code Box แสดง logs
local SpyCodeBox = HttpSpyTab:Code({
    Title = "HTTP Requests Log",
    Code = spyCodeText,
    CanCopied = true,
})

-- ฟังก์ชันอัปเดต UI
local function refreshSpyLogs()
    local lines = {
        "-- HTTP Spy Logs --",
        "สถานะ: " .. (spyEnabled and "🟢 กำลังดัก" or "🔴 ปิดอยู่"),
        "จำนวน: " .. #logEntries .. " entries",
        string.rep("-", 40)
    }
    
    if #logEntries == 0 then
        table.insert(lines, "\nยังไม่มี HTTP request...")
    else
        for i, entry in ipairs(logEntries) do
            table.insert(lines, string.format(
                "\n[%s] [%s] %s %s",
                entry.time, entry.source, entry.method, entry.url
            ))
            
            if entry.headers then
                local h = {}
                for k, v in pairs(entry.headers) do
                    table.insert(h, tostring(k) .. ": " .. tostring(v):sub(1, 50))
                end
                if #h > 0 then
                    table.insert(lines, "  Headers: " .. table.concat(h, " | "))
                end
            end
            
            if entry.body and entry.body ~= "" then
                table.insert(lines, "  Body: " .. entry.body)
            end
        end
    end
    
    spyCodeText = table.concat(lines, "\n")
    SpyCodeBox:SetCode(spyCodeText)
end

-- Toggle เปิด/ปิดการดักจับ
HttpSpyTab:Toggle({
    Title = "เปิด HTTP Spy",
    Desc = "ดักจับ request ทั้งหมดแบบ Real-time",
    Default = true,
    Callback = function(value)
        spyEnabled = value
        refreshSpyLogs()
    end,
})

-- ปุ่มล้าง Logs
HttpSpyTab:Button({
    Title = "🗑️ ล้าง Logs",
    Callback = function()
        logEntries = {}
        refreshSpyLogs()
        WindUI:Notify({
            Title = "HTTP Spy",
            Content = "ล้าง logs เรียบร้อย",
            Icon = "trash-2",
            Duration = 2,
        })
    end,
})

-- ปุ่มคัดลอก Logs ทั้งหมด
HttpSpyTab:Button({
    Title = "📋 คัดลอก Logs ทั้งหมด",
    Callback = function()
        if #logEntries == 0 then
            WindUI:Notify({
                Title = "ไม่มีข้อมูล",
                Content = "ยังไม่มี logs ให้คัดลอก",
                Icon = "clipboard-x",
                Duration = 2,
            })
            return
        end
        pcall(function()
            setclipboard(spyCodeText)
        end)
        WindUI:Notify({
            Title = "คัดลอกสำเร็จ",
            Content = "Logs ทั้งหมดถูกคัดลอกแล้ว",
            Icon = "clipboard-check",
            Duration = 2,
        })
    end,
})

-- ฟังก์ชันบันทึก log
local function pushHttpLog(source, method, url, headers, body)
    if not spyEnabled then return end
    
    local entry = {
        time = os.date("%H:%M:%S"),
        source = source,
        method = method or "GET",
        url = url or "unknown",
        headers = (type(headers) == "table") and headers or nil,
        body = type(body) == "string" and body:sub(1, 150) or nil,
    }
    
    table.insert(logEntries, 1, entry)
    
    while #logEntries > maxLogEntries do
        table.remove(logEntries)
    end
    
    refreshSpyLogs()
end

-- ============================================
-- Hook HTTP Functions
-- ============================================

-- game:HttpGet / game:HttpPost
local oldHttpGet = hookfunction(game.HttpGet, function(self, url, ...)
    pushHttpLog("game:HttpGet", "GET", url)
    return oldHttpGet(self, url, ...)
end)

local oldHttpPost = hookfunction(game.HttpPost, function(self, url, data, ...)
    pushHttpLog("game:HttpPost", "POST", url, nil, data)
    return oldHttpPost(self, url, data, ...)
end)

-- Executor request functions (request, syn.request, etc.)
local function hookExecutorRequest(name, func)
    if not func then return end
    getgenv()[name] = hookfunction(func, function(data)
        local method = data.Method or data.method or "GET"
        local url = data.Url or data.url
        local headers = data.Headers or data.headers
        local body = data.Body or data.body or data.Data or data.data
        pushHttpLog(name, method, url, headers, body)
        return func(data)
    end)
end

hookExecutorRequest("request", request)
hookExecutorRequest("http_request", http_request)
hookExecutorRequest("syn_request", syn and syn.request)

-- HttpService:RequestAsync
local oldRequestAsync = hookfunction(HttpService.RequestAsync, function(self, options)
    pushHttpLog("HttpService", options.Method or "GET", options.Url, options.Headers, options.Body)
    return oldRequestAsync(self, options)
end)

-- แจ้งเตือนเริ่มต้น
WindUI:Notify({
    Title = "HTTP Spy",
    Content = "เริ่มดักจับ HTTP requests แล้ว (เก็บสูงสุด " .. maxLogEntries .. " entries)",
    Icon = "activity",
    Duration = 3,
})

