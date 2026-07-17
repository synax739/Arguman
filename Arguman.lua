-- JJS AIMBOT + LOCK İŞARETİ (MOBİL UYUMLU)
-- Sadece aimbot, aç/kapa butonu ve mavi lock işareti

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local aimbotEnabled = false
local lockTarget = nil
local lockCircle = nil  -- Mavi daire çizimi
local circleVisible = false

-- ===== YARDIMCI FONKSİYONLAR =====
local function getCharacter(plr)
    return plr and plr.Character or nil
end

local function getHumanoidRootPart(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function isAlive(plr)
    local char = getCharacter(plr)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 or false
end

-- ===== EN YAKIN OYUNCUYU BUL =====
local function getClosestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not isAlive(plr) then continue end
        local hrp = getHumanoidRootPart(plr)
        if not hrp then continue end
        local dist = (myHrp.Position - hrp.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = plr
        end
    end
    return closest
end

-- ===== KAMERAYI HEDEFE KİTLE =====
local function lockCamera(targetPlayer)
    if not targetPlayer then return end
    local char = getCharacter(targetPlayer)
    if not char then return end
    local hrp = getHumanoidRootPart(targetPlayer)
    if not hrp then return end

    local targetPos = hrp.Position + Vector3.new(0, 2, 0) -- Gövde + baş hizası
    local camPos = Camera.CFrame.Position
    if camPos == camPos and targetPos == targetPos then
        Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    end
end

-- ===== LOCK İŞARETİ (MAVİ DAİRE) =====
local function createLockCircle()
    if lockCircle then
        pcall(function() lockCircle:Remove() end)
        lockCircle = nil
    end
    lockCircle = Drawing.new("Circle")
    if lockCircle then
        lockCircle.Thickness = 3
        lockCircle.NumSides = 32
        lockCircle.Filled = false
        lockCircle.Color = Color3.fromRGB(0, 180, 255) -- Mavi
        lockCircle.Transparency = 0.8
        lockCircle.Radius = 30
        lockCircle.Visible = false
        lockCircle.Position = Vector2.new(0, 0)
    end
    return lockCircle
end

-- ===== LOCK İŞARETİNİ GÜNCELLE =====
local function updateLockCircle()
    if not aimbotEnabled then
        if lockCircle then lockCircle.Visible = false end
        return
    end

    local target = lockTarget
    if not target then
        if lockCircle then lockCircle.Visible = false end
        return
    end

    local char = getCharacter(target)
    if not char then
        if lockCircle then lockCircle.Visible = false end
        return
    end

    local hrp = getHumanoidRootPart(target)
    if not hrp then
        if lockCircle then lockCircle.Visible = false end
        return
    end

    local pos = hrp.Position + Vector3.new(0, 2, 0) -- Baş hizası
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    if onScreen and lockCircle then
        lockCircle.Visible = true
        lockCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
        -- Hedefin boyutuna göre daireyi ölçeklendir (isteğe bağlı)
        -- Burada sabit radius kullanıyoruz
    else
        if lockCircle then lockCircle.Visible = false end
    end
end

-- ===== AIMBOT AÇ/KAPA BUTONU =====
local function createToggleButton()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AimbotToggle"
    gui.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", gui)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.5, -30, 0.85, 0) -- Orta-alt
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    -- İkon (🎯)
    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🎯"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextSize = 28
    icon.Font = Enum.Font.SourceSansBold
    icon.TextScaled = true

    -- Buton rengi duruma göre
    local function updateButton()
        if aimbotEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) -- Açık yeşil
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Siyah
        end
    end

    btn.Activated:Connect(function()
        aimbotEnabled = not aimbotEnabled
        updateButton()
        if not aimbotEnabled then
            lockTarget = nil
            if lockCircle then lockCircle.Visible = false end
        end
    end)

    updateButton()
    return btn
end

-- ===== ANA DÖNGÜ =====
local function mainLoop()
    if aimbotEnabled then
        -- En yakın oyuncuyu bul
        local target = getClosestPlayer()
        if target then
            lockTarget = target
            lockCamera(target)
        else
            lockTarget = nil
        end
    else
        lockTarget = nil
    end
    -- Lock işaretini güncelle
    updateLockCircle()
end

-- ===== BAŞLAT =====
-- Lock circle oluştur
createLockCircle()

-- Butonu oluştur
createToggleButton()

-- Ana döngüyü başlat
RunService.RenderStepped:Connect(function()
    pcall(mainLoop)
end)

print("✅ JJS AIMBOT + LOCK İŞARETİ YÜKLENDİ!")
print("🎯 Siyah butona tıkla aç/kapat. Hedefte mavi daire belirir.")
