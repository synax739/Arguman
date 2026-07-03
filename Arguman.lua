-- MM2 - ESP + GUN ESP + PANEL (ÇALIŞIR - Hata Düzeltmeli)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cfg = {
    esp_on = true,
    esp_box = true,
    esp_dist = true,
    esp_maxDist = 500,
    gun_esp = true,
    team_check = false
}

local gunESPObjects = {}
local ESPData = {}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 120, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Unknown  = Color3.fromRGB(255, 255, 0)
}

-- ==============================================
-- GÜVENLİ POZİSYON KONTROLÜ
-- ==============================================
local function isValidVector(v)
    return v and type(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z and v.Magnitude < 1e6
end

local function getSafePosition(part)
    if not part then return nil end
    local pos = part.Position
    if isValidVector(pos) then
        return pos
    end
    return nil
end

local function getPlayerRole(plr)
    local char = plr.Character
    if not char then return "Unknown" end
    local backpack = plr:FindFirstChild("Backpack") or plr
    if backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Murderer") or backpack:FindFirstChild("Killer") then
        return "Murderer"
    end
    if char:FindFirstChild("Knife") or char:FindFirstChild("MurdererWeapon") then
        return "Murderer"
    end
    if backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Sheriff") or backpack:FindFirstChild("Revolver") or backpack:FindFirstChild("Pistol") then
        return "Sheriff"
    end
    if char:FindFirstChild("Gun") or char:FindFirstChild("SheriffWeapon") then
        return "Sheriff"
    end
    local roleObj = plr:FindFirstChild("Role") or plr:FindFirstChild("PlayerRole")
    if roleObj and roleObj:IsA("StringValue") then
        local roleName = roleObj.Value
        if roleName == "Murderer" or roleName == "Killer" then return "Murderer" end
        if roleName == "Sheriff" or roleName == "Hero" then return "Sheriff" end
        if roleName == "Innocent" or roleName == "Civilian" then return "Innocent" end
    end
    return "Innocent"
end

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

local function isInFront(pos)
    if not isValidVector(pos) then return false end
    local camPos = Camera.CFrame.Position
    if not isValidVector(camPos) then return false end
    return Camera.CFrame.LookVector:Dot((pos - camPos).Unit) > 0
end

-- ===== OYUNCU ESP =====
local function createESP(plr)
    local d = {}
    d.box = newDrawing("Square")
    if d.box then d.box.Thickness = 2 d.box.Filled = false end
    d.dist = newDrawing("Text")
    if d.dist then d.dist.Size = 13 d.dist.Center = true d.dist.Outline = true d.dist.Color = Color3.new(1,1,1) end
    d.role = newDrawing("Text")
    if d.role then d.role.Size = 12 d.role.Center = true d.role.Outline = true end
    ESPData[plr] = d
end

local function removeESP(plr)
    local d = ESPData[plr]
    if not d then return end
    for _, v in pairs(d) do pcall(function() v:Remove() end) end
    ESPData[plr] = nil
end

local function getBox(character)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil end
    
    local headPos = head and getSafePosition(head)
    local hrpPos = getSafePosition(hrp)
    if not hrpPos then return nil end
    
    local top = headPos and (headPos + Vector3.new(0, 1.5, 0)) or (hrpPos + Vector3.new(0, 2.5, 0))
    local bottom = hrpPos - Vector3.new(0, 3, 0)
    
    if not isValidVector(top) or not isValidVector(bottom) then return nil end
    
    local ts, on1 = Camera:WorldToViewportPoint(top)
    local bs, on2 = Camera:WorldToViewportPoint(bottom)
    if not on1 and not on2 then return nil end
    local h = math.abs(ts.Y - bs.Y)
    local w = h * 0.5
    local cx = (ts.X + bs.X) / 2
    return {
        pos = Vector2.new(cx - w/2, math.min(ts.Y, bs.Y)),
        size = Vector2.new(w, h),
        top = Vector2.new(cx, math.min(ts.Y, bs.Y)),
        bottom = Vector2.new(cx, math.min(ts.Y, bs.Y) + h)
    }
end

local function updateESP()
    if not cfg.esp_on then
        for plr, d in pairs(ESPData) do
            for _, v in pairs(d) do v.Visible = false end
        end
        return
    end

    local my = LocalPlayer.Character
    local myPos = my and my:FindFirstChild("HumanoidRootPart") and getSafePosition(my.HumanoidRootPart)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local role = getPlayerRole(plr)
        if cfg.team_check and role == getPlayerRole(LocalPlayer) then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
        local char = plr.Character
        if not char then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
        
        local hrpPos = getSafePosition(hrp)
        if not hrpPos then
            if ESPData[plr] then removeESP(plr) end
            continue
        end

        if not isInFront(hrpPos) then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        local dist = 0
        if myPos then
            dist = (myPos - hrpPos).Magnitude
        end
        if dist > cfg.esp_maxDist then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        if not ESPData[plr] then createESP(plr) end
        local d = ESPData[plr]
        if not d then continue end
        local box = getBox(char)
        if not box then for _, v in pairs(d) do v.Visible = false end continue end

        local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown
        if cfg.esp_box and d.box then
            d.box.Visible = true d.box.Position = box.pos d.box.Size = box.size d.box.Color = color
        end
        if cfg.esp_dist and d.dist then
            d.dist.Visible = true d.dist.Text = math.floor(dist) .. "m" d.dist.Position = box.bottom + Vector2.new(0, 2)
        end
        if d.role then
            d.role.Visible = true d.role.Text = role d.role.Color = color d.role.Position = box.top - Vector2.new(0, 15)
        end
    end
end

-- ===== GUN ESP =====
local function updateGunESP()
    if not cfg.gun_esp then
        for _, obj in pairs(gunESPObjects) do
            pcall(function() obj.box:Remove() end)
            pcall(function() obj.text:Remove() end)
            pcall(function() obj.dist:Remove() end)
        end
        gunESPObjects = {}
        return
    end

    for _, obj in pairs(gunESPObjects) do
        pcall(function() obj.box:Remove() end)
        pcall(function() obj.text:Remove() end)
        pcall(function() obj.dist:Remove() end)
    end
    gunESPObjects = {}

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    local myPosition = getSafePosition(myPos)
    if not myPosition then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local pos = getSafePosition(obj)
            if not pos then continue end
            local dist = (myPosition - pos).Magnitude
            local distText = math.floor(dist) .. "m"
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen and isInFront(pos) then
                local box = newDrawing("Square")
                local text = newDrawing("Text")
                local distLabel = newDrawing("Text")
                
                if box then
                    box.Thickness = 2
                    box.Filled = false
                    box.Color = Color3.fromRGB(255, 200, 0)
                    box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                    box.Size = Vector2.new(40, 40)
                    box.Visible = true
                end
                
                if text then
                    text.Size = 14
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 200, 0)
                    text.Text = "🔫 SILAH"
                    text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                    text.Visible = true
                end
                
                if distLabel then
                    distLabel.Size = 12
                    distLabel.Center = true
                    distLabel.Outline = true
                    distLabel.Color = Color3.fromRGB(100, 255, 100)
                    distLabel.Text = distText
                    distLabel.Position = Vector2.new(screenPos.X, screenPos.Y + 25)
                    distLabel.Visible = true
                end
                
                gunESPObjects[obj] = {box = box, text = text, dist = distLabel}
            end
        end
    end
end

-- ===== PANEL =====
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MM2Hack"
    gui.ResetOnSpawn = false

    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(1, -60, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    openBtn.Text = "⚙"
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.TextSize = 24
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 280, 0, 250)
    panel.Position = UDim2.new(1, -295, 0, 70)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    -- Sürükleme
    local dragging = false
    local dragStart = nil
    local startPos = nil

    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    panel.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Başlık
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚡ MM2 HACK"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 17
    title.Font = Enum.Font.SourceSansBold
    title.BorderSizePixel = 0
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    -- İçerik
    local content = Instance.new("Frame", panel)
    content.Size = UDim2.new(1, -20, 1, -45)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1

    local function addToggle(name, default, callback, yPos)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        btn.BackgroundTransparency = 0.15
        btn.Text = name .. ": " .. (default and "AÇIK" or "KAPALI")
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 13
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local toggled = default
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = name .. ": " .. (toggled and "AÇIK" or "KAPALI")
            btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
            btn.BackgroundTransparency = 0.15
            callback(toggled)
        end)
    end

    addToggle("ESP", cfg.esp_on, function(v) cfg.esp_on = v end, 5)
    addToggle("Kutu", cfg.esp_box, function(v) cfg.esp_box = v end, 43)
    addToggle("Mesafe", cfg.esp_dist, function(v) cfg.esp_dist = v end, 81)
    addToggle("Gun ESP", cfg.gun_esp, function(v) cfg.gun_esp = v end, 119)
    addToggle("Takım Kontrolü", cfg.team_check, function(v) cfg.team_check = v end, 157)

    openBtn.Activated:Connect(function() panel.Visible = not panel.Visible end)
end

-- ===== BAŞLAT =====
Players.PlayerRemoving:Connect(function(p) 
    if ESPData[p] then 
        for _, v in pairs(ESPData[p]) do pcall(function() v:Remove() end) end
        ESPData[p] = nil 
    end 
end)

createPanel()

RunService.RenderStepped:Connect(function()
    pcall(function()
        updateESP()
        updateGunESP()
    end)
end)

print("🔪 MM2 Yüklendi! ESP + Gun ESP aktif. Invalid position hatası önlendi.")
