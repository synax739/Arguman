-- // +1 Speed Keyboard Escape | Candy & Chocolate | ULTIMATE MOBILE SCRIPT
-- // Tüm Özellikler + GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==============================================
-- AYARLAR
-- ==============================================
local cfg = {
    auto_walk = false,
    auto_win = false,
    auto_collect = false,
    speed_hack = false,
    speed_value = 110,
    super_jump = false,
    infinite_jump = false,
    noclip = false,
    no_gravity = false,
    esp = false,
    fullbright = false,
    anti_fall = false,
    teleport_to_win = false,
    claim_rewards = false,
    admin_xp = false,
}

-- ==============================================
-- YARDIMCI FONKSİYONLAR
-- ==============================================
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function getHumanoidRootPart()
    local char = getCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- ==============================================
-- OTOMATİK YÜRÜME (Auto Walk)
-- ==============================================
local function startAutoWalk()
    local hum = getHumanoid()
    if hum and cfg.auto_walk then
        hum.MoveDirection = Vector3.new(1, 0, 0)
        -- Klavye W tuşuna basılı tut
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
    end
end

-- ==============================================
-- OTOMATİK KAZANMA (Auto Win)
-- ==============================================
local function startAutoWin()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("finish")) then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                wait(0.3)
                -- Kazanma butonuna tıkla
                local click = obj:FindFirstChildOfClass("ClickDetector")
                if click then
                    fireclickdetector(click)
                end
            end
            break
        end
    end
end

-- ==============================================
-- OTOMATİK TOPLAMA (Auto Collect)
-- ==============================================
local function startAutoCollect()
    local hrp = getHumanoidRootPart()
    if not hrp or not cfg.auto_collect then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("candy") or obj.Name:lower():find("chocolate") or obj.Name:lower():find("collect")) then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < 100 then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                wait(0.1)
            end
        end
    end
end

-- ==============================================
-- HIZ AŞIMI (Speed Hack)
-- ==============================================
local function applySpeed()
    local hum = getHumanoid()
    if hum and cfg.speed_hack then
        pcall(function()
            hum.WalkSpeed = cfg.speed_value
            -- Oyunun hız değerini tutan RemoteEvent varsa ona müdahale
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("speed") then
                    v:FireServer(cfg.speed_value)
                end
            end
        end)
    end
end

-- ==============================================
-- SÜPER ZIPLAMA (Super Jump)
-- ==============================================
local function applySuperJump()
    local hum = getHumanoid()
    if hum and cfg.super_jump then
        pcall(function()
            hum.JumpPower = 250
        end)
    end
end

-- ==============================================
-- SINIRSIZ ZIPLAMA (Infinite Jump)
-- ==============================================
local function applyInfiniteJump()
    local hrp = getHumanoidRootPart()
    if hrp and cfg.infinite_jump then
        pcall(function()
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(vel.X, 60, vel.Z)
        end)
    end
end

-- ==============================================
-- DUVARLARDAN GEÇME (Noclip)
-- ==============================================
local function applyNoclip()
    local char = getCharacter()
    if char and cfg.noclip then
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end

-- ==============================================
-- YER ÇEKİMSİZLİK (No Gravity)
-- ==============================================
local function applyNoGravity()
    local hrp = getHumanoidRootPart()
    if hrp and cfg.no_gravity then
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            workspace.Gravity = 0
        end)
    else
        workspace.Gravity = 196.2
    end
end

-- ==============================================
-- DÜŞME ENGELLEME (Anti Fall)
-- ==============================================
local function applyAntiFall()
    local hrp = getHumanoidRootPart()
    if hrp and cfg.anti_fall then
        pcall(function()
            if hrp.Position.Y < -50 then
                hrp.CFrame = CFrame.new(0, 50, 0)
            end
        end)
    end
end

-- ==============================================
-- OYUNCU ESP (Highlight)
-- ==============================================
local function applyESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local highlight = char:FindFirstChild("ESP_Highlight")
                if not highlight and cfg.esp then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.Parent = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineTransparency = 0.2
                elseif highlight and not cfg.esp then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- ==============================================
-- HER YER AYDINLIK (Fullbright)
-- ==============================================
local function applyFullbright()
    local lighting = game:GetService("Lighting")
    if cfg.fullbright then
        pcall(function()
            lighting.Brightness = 10
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            lighting.GlobalShadows = false
            lighting.FogEnd = 10000
        end)
    else
        pcall(function()
            lighting.Brightness = 2
            lighting.Ambient = Color3.fromRGB(0, 0, 0)
            lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            lighting.GlobalShadows = true
            lighting.FogEnd = 1000
        end)
    end
end

-- ==============================================
-- BİTİŞE IŞINLAN (Teleport to Win)
-- ==============================================
local function teleportToWin()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("finish")) then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 10, 0))
                wait(0.3)
                local click = obj:FindFirstChildOfClass("ClickDetector")
                if click then
                    fireclickdetector(click)
                end
            end
            break
        end
    end
end

-- ==============================================
-- ÖDÜLLERİ TOPLA (Claim Rewards)
-- ==============================================
local function claimRewards()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("reward") or obj.Name:lower():find("claim")) then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                wait(0.2)
                local click = obj:FindFirstChildOfClass("ClickDetector")
                if click then
                    fireclickdetector(click)
                end
            end
        end
    end
end

-- ==============================================
-- ADMIN XP HIZLANDIRMA
-- ==============================================
local function applyAdminXP()
    if cfg.admin_xp then
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("admin") or v.Name:lower():find("xp")) then
                    v:FireServer(99999)
                end
            end
        end)
    end
end

-- ==============================================
-- HIZ ARTIRMA BUTONLARI (GUI'deki butonları simüle et)
-- ==============================================
local function clickSpeedButton(amount)
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("TextButton") and v:FindFirstChild("TextLabel") then
                local text = v.TextLabel.Text or v.Text
                if text and text:find("+" .. amount) then
                    v:Activate()
                    wait(0.1)
                end
            end
            if v:IsA("ClickDetector") and v.Parent and v.Parent:IsA("BasePart") then
                local name = v.Parent.Name
                if name and name:find(tostring(amount)) then
                    fireclickdetector(v)
                    wait(0.1)
                end
            end
        end
    end)
end

-- ==============================================
-- GELİŞMİŞ GUI
-- ==============================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedKeyboardGUI"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Ana Panel
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 230, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -115, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚡ HACK PANEL | +1 Speed"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.BorderSizePixel = 0
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    -- Sürükleme
    local dragging = false
    local dragStart = nil
    local startPos = nil

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    title.InputEnded:Connect(function() dragging = false end)

    title.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Kaydırma çubuğu (ScrollingFrame)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.Parent = mainFrame

    -- Toggle Butonları
    local function addToggle(yPos, name, default, callback)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text = name .. ": " .. (default and "AÇIK" or "KAPALI")
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local toggled = default
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = name .. ": " .. (toggled and "AÇIK" or "KAPALI")
            btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
            callback(toggled)
        end)
    end

    -- Hız kaydırıcısı
    local speedLabel = Instance.new("TextLabel", scroll)
    speedLabel.Size = UDim2.new(1, -10, 0, 20)
    speedLabel.Position = UDim2.new(0, 5, 0, 310)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Hız: " .. cfg.speed_value
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextSize = 12
    speedLabel.Visible = false

    local speedSlider = Instance.new("Slider", scroll)
    speedSlider.Size = UDim2.new(1, -10, 0, 25)
    speedSlider.Position = UDim2.new(0, 5, 0, 330)
    speedSlider.Min = 20
    speedSlider.Max = 1000
    speedSlider.Value = cfg.speed_value
    speedSlider.Visible = false

    speedSlider.Changed:Connect(function()
        local val = math.floor(speedSlider.Value)
        speedLabel.Text = "Hız: " .. val
        cfg.speed_value = val
        if cfg.speed_hack then
            applySpeed()
        end
    end)

    -- Butonları ekle
    addToggle(5, "Otomatik Yürü", cfg.auto_walk, function(v)
        cfg.auto_walk = v
        if v then startAutoWalk() end
    end)

    addToggle(37, "Otomatik Kazan", cfg.auto_win, function(v) cfg.auto_win = v end)

    addToggle(69, "Otomatik Topla", cfg.auto_collect, function(v) cfg.auto_collect = v end)

    addToggle(101, "Hız Aşımı", cfg.speed_hack, function(v)
        cfg.speed_hack = v
        speedSlider.Visible = v
        speedLabel.Visible = v
        if v then applySpeed() else pcall(function() local h = getHumanoid() if h then h.WalkSpeed = 16 end end) end
    end)

    addToggle(133, "Süper Zıplama", cfg.super_jump, function(v)
        cfg.super_jump = v
        applySuperJump()
    end)

    addToggle(165, "Sınırsız Zıplama", cfg.infinite_jump, function(v)
        cfg.infinite_jump = v
    end)

    addToggle(197, "Duvarlardan Geç", cfg.noclip, function(v)
        cfg.noclip = v
    end)

    addToggle(229, "Yer Çekimsizlik", cfg.no_gravity, function(v)
        cfg.no_gravity = v
        if not v then workspace.Gravity = 196.2 end
    end)

    addToggle(261, "Düşme Engelle", cfg.anti_fall, function(v)
        cfg.anti_fall = v
    end)

    addToggle(293, "ESP", cfg.esp, function(v)
        cfg.esp = v
    end)

    addToggle(325, "Fullbright", cfg.fullbright, function(v)
        cfg.fullbright = v
        applyFullbright()
    end)

    addToggle(357, "Admin XP Hız", cfg.admin_xp, function(v)
        cfg.admin_xp = v
    end)

    -- HIZ BUTONLARI (GUI'deki butonlara tıkla)
    local function createSpeedButton(y, text, amount)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(0.3, -5, 0, 28)
        btn.Position = UDim2.new(0.05 + (y % 3) * 0.32, 0, 0, 390 + math.floor(y / 3) * 32)
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        btn.BackgroundTransparency = 0.3
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 10
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.Activated:Connect(function()
            clickSpeedButton(amount)
        end)
    end

    createSpeedButton(0, "+65K", 65000)
    createSpeedButton(1, "+150K", 150000)
    createSpeedButton(2, "+1M", 1000000)
    createSpeedButton(3, "+10M", 10000000)
    createSpeedButton(4, "+1.5M", 1500000)

    -- Canvas boyutunu güncelle
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)

    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    closeBtn.Activated:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- Açma butonu (sağ üstte küçük)
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 35, 0, 35)
    openBtn.Position = UDim2.new(1, -45, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    openBtn.Text = "⚡"
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.TextSize = 18
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.BorderSizePixel = 0
    openBtn.Parent = screenGui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    openBtn.Activated:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    return screenGui
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
local function mainLoop()
    pcall(function()
        if cfg.auto_walk then startAutoWalk() end
        if cfg.auto_win then startAutoWin() end
        if cfg.auto_collect then startAutoCollect() end
        if cfg.speed_hack then applySpeed() end
        if cfg.super_jump then applySuperJump() end
        if cfg.infinite_jump then applyInfiniteJump() end
        if cfg.noclip then applyNoclip() end
        if cfg.no_gravity then applyNoGravity() end
        if cfg.anti_fall then applyAntiFall() end
        if cfg.esp then applyESP() end
        if cfg.fullbright then applyFullbright() end
        if cfg.admin_xp then applyAdminXP() end
        
        -- Bitişe ışınlan (her 5 saniyede bir)
        if cfg.teleport_to_win then
            teleportToWin()
        end
    end)
end

-- ==============================================
-- BAŞLAT
-- ==============================================
createGUI()

-- Oyuncu yeniden doğduğunda
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    pcall(function()
        if cfg.speed_hack then applySpeed() end
        if cfg.super_jump then applySuperJump() end
    end)
end)

-- Ana döngü
RunService.RenderStepped:Connect(function()
    mainLoop()
end)

print("✅ +1 Speed Keyboard Escape | ULTI
