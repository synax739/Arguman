-- MM2 FULL - Gelişmiş Panel + ESP + Gun ESP + Şerif Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local cfg = {
    esp_on = true,
    esp_box = true,
    esp_dist = true,
    esp_maxDist = 500,
    gun_esp = true,
    aim_on = false,
    aim_maxDist = 120,
    aim_smoothBase = 2.0,
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
-- ROL TESPİTİ
-- ==============================================
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

-- ==============================================
-- DRAWING FONKSİYONLARI
-- ==============================================
local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

local function isInFront(pos)
    local camPos = Camera.CFrame.Position
    return Camera.CFrame.LookVector:Dot((pos - camPos).Unit) > 0
end

-- ==============================================
-- OYUNCU ESP
-- ==============================================
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
    local top = head and (head.Position + Vector3.new(0, 1.5, 0)) or (hrp.Position + Vector3.new(0, 2.5, 0))
    local bottom = hrp.Position - Vector3.new(0, 3, 0)
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

        if not isInFront(hrp.Position) then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        local dist = 0
        if my and my:FindFirstChild("HumanoidRootPart") then
            dist = (my.HumanoidRootPart.Position - hrp.Position).Magnitude
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

-- ==============================================
-- GUN ESP
-- ==============================================
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

    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    local myPosition = myPos.Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local pos = obj.Position
            if pos ~= pos then continue end
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

-- ==============================================
-- ŞERİF AIMBOT
-- ==============================================
local function hasGun()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    for _, v in ipairs(myChar:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end end
    return false
end

local function getClosestMurderer()
    local best, bestDist = nil, cfg.aim_maxDist
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or getPlayerRole(plr) ~= "Murderer" then continue end
        local char = plr.Character
        if not char then continue end
        local head, hrp = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
        if not (head or hrp) then continue end
        local targetPos = head and head.Position or hrp.Position
        local dist = (myPos - targetPos).Magnitude
        if dist < bestDist then bestDist = dist best = plr end
    end
    return best
end

local function aimAt(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local head, hrp = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
    local targetPart = head or hrp
    if not targetPart then return end
    local targetPos = targetPart.Position
    local camPos = Camera.CFrame.Position
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), 1 / cfg.aim_smoothBase)
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local root = myChar.HumanoidRootPart
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        pcall(function() root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, flatTarget), 1 / cfg.aim_smoothBase) end)
    end
end

local function updateAimbot()
    if not cfg.aim_on or getPlayerRole(LocalPlayer) ~= "Sheriff" or not hasGun() then return end
    local target = getClosestMurderer()
    if target then aimAt(target) end
end

-- ==============================================
-- GELİŞMİŞ PANEL (Şık Tasarım)
-- ==============================================
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MM2Hack"
    gui.ResetOnSpawn = false

    -- Aç/Kapa butonu (Sağ üst)
    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 52, 0, 52)
    openBtn.Position = UDim2.new(1, -62, 0, 12)
    openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    openBtn.Text = "⚙"
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.TextSize = 26
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    -- Gölge efekti
    local shadow = Instance.new("Frame", openBtn)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.3
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(1, 0)

    -- Ana Panel
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 320, 0, 340)
    panel.Position = UDim2.new(1, -335, 0, 75)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

    -- Panel gölgesi (iç)
    local innerShadow = Instance.new("Frame", panel)
    innerShadow.Size = UDim2.new(1, 0, 1, 0)
    innerShadow.Position = UDim2.new(0, 0, 0, 0)
    innerShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    innerShadow.BackgroundTransparency = 0.5
    innerShadow.BorderSizePixel = 0
    innerShadow.ZIndex = -1
    Instance.new("UICorner", innerShadow).CornerRadius = UDim.new(0, 14)

    -- Panel sürükleme
    local drag, dragStart, startPos = false, nil, nil
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true dragStart = input.Position startPos = panel.Position
        end
    end)
    panel.InputEnded:Connect(function() drag = false end)
    panel.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- Başlık çubuğu
    local titleBar = Instance.new("Frame", panel)
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
    -- Sadece üst köşeleri yuvarlat
    local corner = Instance.new("UICorner", titleBar)
    corner.CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ MM2 HACK"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 14, 0, 0)

    -- Kapatma butonu (X)
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -38, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Activated:Connect(function() panel.Visible = false end)

    -- Kategori butonları (Sekmeler)
    local tabFrame = Instance.new("Frame", panel)
    tabFrame.Size = UDim2.new(1, 0, 0, 38)
    tabFrame.Position = UDim2.new(0, 0, 0, 38)
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
    tabFrame.BorderSizePixel = 0

    local activeTab = nil
    local function createTab(name, x, page)
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(0.5, 0, 1, 0)
        btn.Position = UDim2.new(x, 0, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        btn.TextSize = 14
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderSizePixel = 0

        btn.Activated:Connect(function()
            if activeTab then activeTab.BackgroundTransparency = 1 activeTab.TextColor3 = Color3.fromRGB(180, 180, 200) end
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            activeTab = btn

            for _, child in ipairs(panel:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Page" then
                    child.Visible = false
                end
            end
            page.Visible = true
        end)

        -- İlk sekmeyi aktif yap
        if x == 0 then
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            activeTab = btn
        end
    end

    -- Sayfa oluşturucu
    local function createPage()
        local page = Instance.new("Frame", panel)
        page.Name = "Page"
        page.Size = UDim2.new(1, -20, 0, 224)
        page.Position = UDim2.new(0, 10, 0, 78)
        page.BackgroundTransparency = 1
        page.Visible = false
        return page
    end

    -- Toggle oluşturucu (Şık)
    local function addToggle(parent, name, default, callback, yPos)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        btn.BackgroundTransparency = 0.2
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
            btn.BackgroundTransparency = 0.2
            callback(toggled)
        end)
    end

    -- ESP Sayfası
    local espPage = createPage()
    addToggle(espPage, "ESP", cfg.esp_on, function(v) cfg.esp_on = v end, 2)
    addToggle(espPage, "Kutu", cfg.esp_box, function(v) cfg.esp_box = v end, 42)
    addToggle(espPage, "Mesafe", cfg.esp_dist, function(v) cfg.esp_dist = v end, 82)
    addToggle(espPage, "Gun ESP", cfg.gun_esp, function(v) cfg.gun_esp = v end, 122)
    addToggle(espPage, "Takım Kontrolü", cfg.team_check, function(v) cfg.team_check = v end, 162)

    -- Şerif Sayfası
    local sheriffPage = createPage()
    addToggle(sheriffPage, "Şerif Aim", cfg.aim_on, function(v) cfg.aim_on = v end, 2)

    -- Sekmeleri oluştur
    createTab("🔍 ESP", 0, espPage)
    createTab("🔫 Şerif", 0.5, sheriffPage)

    -- İlk sayfayı göster
    espPage.Visible = true

    -- Açma butonu
    openBtn.Activated:Connect(function() panel.Visible = not panel.Visible end)
end

-- ==============================================
-- BAŞLAT
-- ==============================================
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
        updateAimbot()
    end)
end)

print("🔪 MM2 FULL Yüklendi! ⚙ butonuna tıkla.")
