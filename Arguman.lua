-- JJS KAMERA KİLİT (SON - KIRMIZI BUTON, SOL ORTA)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local lockTarget = nil
local lockCircle = nil

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

local function findClosestPlayer()
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

local function lockOntoTarget(targetPlayer)
    if not targetPlayer then return end
    local targetChar = getCharacter(targetPlayer)
    if not targetChar then return end
    local targetHrp = getHumanoidRootPart(targetPlayer)
    if not targetHrp then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local targetPos = targetHrp.Position
    local myPos = myHrp.Position
    
    local dir = (targetPos - myPos).Unit
    local camDistance = 12
    local camPos = myPos - dir * camDistance + Vector3.new(0, 8, 0)
    
    if camPos == camPos and targetPos == targetPos then
        Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    end
end

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
        lockCircle.Color = Color3.fromRGB(0, 180, 255)
        lockCircle.Transparency = 0.8
        lockCircle.Radius = 30
        lockCircle.Visible = false
        lockCircle.Position = Vector2.new(0, 0)
    end
    return lockCircle
end

local function updateLockCircle()
    if not aimbotEnabled or not lockTarget then
        if lockCircle then lockCircle.Visible = false end
        return
    end
    local char = getCharacter(lockTarget)
    if not char then
        if lockCircle then lockCircle.Visible = false end
        return
    end
    local hrp = getHumanoidRootPart(lockTarget)
    if not hrp then
        if lockCircle then lockCircle.Visible = false end
        return
    end
    local pos = hrp.Position + Vector3.new(0, 2, 0)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    if onScreen and lockCircle then
        lockCircle.Visible = true
        lockCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
    else
        if lockCircle then lockCircle.Visible = false end
    end
end

-- ===== KIRMIZI BUTON (SOL ORTA) =====
local function createToggleButton()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AimbotToggle"
    gui.ResetOnSpawn = false

    -- Ana buton (daire, kırmızı)
    local btn = Instance.new("ImageButton", gui)
    btn.Size = UDim2.new(0, 75, 0, 75)
    btn.Position = UDim2.new(0, 20, 0.5, -37.5) -- Sol orta
    btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- Kırmızı
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(200, 30, 30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    -- İç daire (beyaz çerçeve)
    local innerCircle = Instance.new("Frame", btn)
    innerCircle.Size = UDim2.new(0, 55, 0, 55)
    innerCircle.Position = UDim2.new(0.5, -27.5, 0.5, -27.5)
    innerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    innerCircle.BackgroundTransparency = 0.8
    innerCircle.BorderSizePixel = 2
    innerCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", innerCircle).CornerRadius = UDim.new(1, 0)

    -- Crosshair (hedef işareti) - Yatay çizgi
    local hLine = Instance.new("Frame", btn)
    hLine.Size = UDim2.new(0, 30, 0, 2.5)
    hLine.Position = UDim2.new(0.5, -15, 0.5, -1.25)
    hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hLine.BackgroundTransparency = 0
    hLine.BorderSizePixel = 0

    -- Crosshair - Dikey çizgi
    local vLine = Instance.new("Frame", btn)
    vLine.Size = UDim2.new(0, 2.5, 0, 30)
    vLine.Position = UDim2.new(0.5, -1.25, 0.5, -15)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vLine.BackgroundTransparency = 0
    vLine.BorderSizePixel = 0

    -- Durum noktası (açık: yeşil, kapalı: kırmızı)
    local statusDot = Instance.new("Frame", btn)
    statusDot.Size = UDim2.new(0, 14, 0, 14)
    statusDot.Position = UDim2.new(0.5, -7, 0.5, -7)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusDot.BackgroundTransparency = 0
    statusDot.BorderSizePixel = 0
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    -- ON/OFF yazısı
    local statusText = Instance.new("TextLabel", btn)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 1, -18)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 200, 200)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.SourceSansBold
    statusText.TextScaled = true

    -- Buton rengini güncelle
    local function updateButton()
        if aimbotEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) -- Yeşil
            btn.BorderColor3 = Color3.fromRGB(0, 180, 80)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Yeşil nokta
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- Kırmızı
            btn.BorderColor3 = Color3.fromRGB(200, 30, 30)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Kırmızı nokta
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 200, 200)
        end
    end

    btn.Activated:Connect(function()
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            lockTarget = findClosestPlayer()
        else
            lockTarget = nil
            if lockCircle then lockCircle.Visible = false end
        end
        updateButton()
    end)

    updateButton()
    return btn
end

local function mainLoop()
    if aimbotEnabled then
        if not lockTarget or not isAlive(lockTarget) then
            lockTarget = findClosestPlayer()
            if not lockTarget then
                if lockCircle then lockCircle.Visible = false end
                return
            end
        end
        lockOntoTarget(lockTarget)
    end
    updateLockCircle()
end

createLockCircle()
createToggleButton()

RunService.RenderStepped:Connect(function()
    pcall(mainLoop)
end)

print("✅ JJS KAMERA KİLİT (KIRMIZI BUTON) YUKLENDI!")
print("🎯 Sol orta kısımda kırmızı buton belirdi.")
