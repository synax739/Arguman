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
    local dist = (targetPos - myPos).Magnitude
    
    -- Kamera mesafesi ve yüksekliği (daha yukarı ve geri)
    local camDistance = 14
    local heightOffset = 10
    
    if dist < 15 then
        camDistance = 9
        heightOffset = 7
    elseif dist < 30 then
        camDistance = 12
        heightOffset = 9
    end
    
    local dir = (targetPos - myPos).Unit
    
    -- Kamera pozisyonu: karakterin arkası + yukarı + hafif sağa (düz bakış için)
    -- Sağa kaymayı düzeltmek için cross product ile hafif sola çekelim
    local right = Vector3.new(0, 1, 0):Cross(dir).Unit
    local camPos = myPos - dir * camDistance + Vector3.new(0, heightOffset, 0) - right * 0.5
    
    -- Hedef noktası: hedefin tam ortası (gövde hizası)
    local lookTarget = targetPos + Vector3.new(0, 2, 0)
    
    if camPos == camPos and lookTarget == lookTarget then
        Camera.CFrame = CFrame.lookAt(camPos, lookTarget)
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

local function createToggleButton()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AimbotToggle"
    gui.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", gui)
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0, 20, 0.42, -40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local outerRing = Instance.new("Frame", btn)
    outerRing.Size = UDim2.new(1, 0, 1, 0)
    outerRing.Position = UDim2.new(0, 0, 0, 0)
    outerRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outerRing.BackgroundTransparency = 0.8
    outerRing.BorderSizePixel = 3
    outerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", outerRing).CornerRadius = UDim.new(1, 0)

    local innerRing = Instance.new("Frame", btn)
    innerRing.Size = UDim2.new(0, 55, 0, 55)
    innerRing.Position = UDim2.new(0.5, -27.5, 0.5, -27.5)
    innerRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    innerRing.BackgroundTransparency = 0.9
    innerRing.BorderSizePixel = 2
    innerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", innerRing).CornerRadius = UDim.new(1, 0)

    local hLine = Instance.new("Frame", btn)
    hLine.Size = UDim2.new(0, 28, 0, 2)
    hLine.Position = UDim2.new(0.5, -14, 0.5, -1)
    hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hLine.BackgroundTransparency = 0
    hLine.BorderSizePixel = 0

    local vLine = Instance.new("Frame", btn)
    vLine.Size = UDim2.new(0, 2, 0, 28)
    vLine.Position = UDim2.new(0.5, -1, 0.5, -14)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vLine.BackgroundTransparency = 0
    vLine.BorderSizePixel = 0

    local statusDot = Instance.new("Frame", btn)
    statusDot.Size = UDim2.new(0, 18, 0, 18)
    statusDot.Position = UDim2.new(0.5, -9, 0.5, -9)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusDot.BackgroundTransparency = 0
    statusDot.BorderSizePixel = 0
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local statusText = Instance.new("TextLabel", btn)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 1, -15)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusText.TextSize = 13
    statusText.Font = Enum.Font.SourceSansBold

    local function updateButton()
        if aimbotEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            outerRing.BorderColor3 = Color3.fromRGB(0, 255, 0)
            innerRing.BorderColor3 = Color3.fromRGB(0, 255, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            hLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            vLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            outerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
            innerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

print("JJS AIMBOT YUKLENDI! (KAMERA YUKARI VE GERI)")
