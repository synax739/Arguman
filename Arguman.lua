-- // +1 Speed Keyboard Escape | Candy & Chocolate | Ultimate GUI
-- // Gelişmiş Mobil Uyumlu Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- AYARLAR
-- ==============================================
local cfg = {
    auto_walk = false,
    auto_win = false,
    speed_hack = false,
    speed_value = 30,
    super_jump = false,
    infinite_jump = false,
    noclip = false,
    no_gravity = false,
    esp = false,
    fullbright = false,
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
    -- En yakın koşu bandını bulmaya çalış
    local function findClosestTreadmill()
        local hrp = getHumanoidRootPart()
        if not hrp then return nil end
        local myPos = hrp.Position
        local closest, closestDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("treadmill") then
                local dist = (myPos - obj.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
        return closest
    end

    local target = findClosestTreadmill()
    if target then
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        end
    end
end

-- ==============================================
-- OTOMATİK KAZANMA (Auto Win)
-- ==============================================
local function startAutoWin()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("win") then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                wait(0.5)
                -- Kazanma butonuna tıkla (simüle et)
                local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                end
                break
            end
        end
    end
end

-- ==============================================
-- HIZ AŞIMI (Speed Hack)
-- ==============================================
local function applySpeed(value)
    local hum = getHumanoid()
    if hum and cfg.speed_hack then
        hum.WalkSpeed = value
    end
end

-- ==============================================
-- SÜPER ZIPLAMA (Super Jump)
-- ==============================================
local function applySuperJump()
    local hum = getHumanoid()
    if hum and cfg.super_jump then
        hum.JumpPower = 150
    end
end

-- ==============================================
-- SINIRSIZ ZIPLAMA (Infinite Jump)
-- ==============================================
local function applyInfiniteJump()
    local hrp = getHumanoidRootPart()
    if hrp and cfg.infinite_jump then
        local vel = hrp.Velocity
        hrp.Velocity = Vector3.new(vel.X, 50, vel.Z)
    end
end

-- ==============================================
-- DUVARLARDAN GEÇME (Noclip)
-- ==============================================
local function applyNoclip()
    local char = getCharacter()
    if char and cfg.noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ==============================================
-- YER ÇEKİMSİZLİK (No Gravity)
-- ==============================================
local function applyNoGravity()
    local hrp = getHumanoidRootPart()
    if hrp and cfg.no_gravity then
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end

-- ==============================================
-- OYUNCU ESP
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
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.new(1, 1, 0)
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
        lighting.Brightness = 10
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        lighting.Brightness = 2
        lighting.Ambient = Color3.new(0, 0, 0)
        lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    end
end

-- ==============================================
-- GUI (Kontrol Paneli)
-- ==============================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedKeyboardGUI"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚡ HACK PANEL"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 17
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

    title.InputEnded:Connect(function()
        dragging = false
    end)

    title.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Butonları
    local function addToggle(yPos, name, default, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text = name .. ": " .. (default and "AÇIK" or "KAPALI")
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local toggled = default
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = name .. ": " .. (toggled and "AÇIK" or "KAPALI")
            btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
            callback(toggled)
        end)
    end

    -- Hız Aşımı Kaydırıcısı
    local speedSlider = Instance.new("Slider", mainFrame)
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(1, -10, 0, 25)
    speedSlider.Position = UDim2.new(0, 5, 0, 250)
    speedSlider.Min = 20
    speedSlider.Max = 1000
    speedSlider.Value = cfg.speed_value
    speedSlider.Visible = false -- Sadece speed hack açıkken görünür

    -- Kaydırıcı için başlık
    local speedLabel = Instance.new("TextLabel", mainFrame)
    speedLabel.Size = UDim2.new(1, -10, 0, 20)
    speedLabel.Position = UDim2.new(0, 5, 0, 235)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Hız: " .. cfg.speed_value
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextSize = 12
    speedLabel.Visible = false

    speedSlider.Changed:Connect(function()
        local val = math.floor(speedSlider.Value)
        speedLabel.Text = "Hız: " .. val
        cfg.speed_value = val
        if cfg.speed_hack then
            applySpeed(val)
        end
    end)

    -- Özellikleri ekle
    addToggle(40, "Otomatik Yürü", cfg.auto_walk, function(v)
        cfg.auto_walk = v
        if v then startAutoWalk() end
    end)

    addToggle(75, "Otomatik Kazan", cfg.auto_win, function(v)
        cfg.auto_win = v
        if v then startAutoWin() end
    end)

    addToggle(110, "Hız Aşımı", cfg.speed_hack, function(v)
        cfg.speed_hack = v
        speedSlider.Visible = v
        speedLabel.Visible = v
        if v then
            applySpeed(cfg.speed_value)
        else
            applySpeed(16)
        end
    end)

    addToggle(145, "Süper Zıplama", cfg.super_jump, function(v)
        cfg.super_jump = v
        applySuperJump()
    end)

    addToggle(180, "Sınırsız Zıplama", cfg.infinite_jump, function(v)
        cfg.infinite_jump = v
    end)

    addToggle(215, "Duvarlardan Geç", cfg.noclip, function(v)
        cfg.noclip = v
    end)

    -- Diğer özellikler için yeni butonlar (ESP, No Gravity, Fullbright) aynı mantıkla eklenebilir.
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
local function mainLoop()
    if cfg.auto_walk then
        startAutoWalk()
    end
    if cfg.auto_win then
        startAutoWin()
    end
    if cfg.speed_hack then
        applySpeed(cfg.speed_value)
    end
    if cfg.super_jump then
        applySuperJump()
    end
    if cfg.infinite_jump then
        applyInfiniteJump()
    end
    if cfg.noclip then
        applyNoclip()
    end
    if cfg.no_gravity then
        applyNoGravity()
    end
    if cfg.esp then
        applyESP()
    end
    if cfg.fullbright then
        applyFullbright()
    end
end

-- ==============================================
-- BAŞLAT
-- ==============================================
createGUI()

RunService.RenderStepped:Connect(function()
    pcall(mainLoop)
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if cfg.speed_hack then
        applySpeed(cfg.speed_value)
    end
    if cfg.super_jump then
        applySuperJump()
    end
end)

print("✅ +1 Speed Keyboard Escape | Ultimate GUI başarıyla yüklendi!")
