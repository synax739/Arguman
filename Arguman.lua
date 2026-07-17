-- JJS KAMERA KİLİT (İKİNCİ FOTOĞRAFTAKİ GİBİ - YÜKSEKLİK AYARLANDI)
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
    
    -- Karakterin arkasını hesapla
    local dir = (targetPos - myPos).Unit
    local camDistance = 10
    
    -- Kamera pozisyonu: ikinci fotograftaki gibi daha yukarıdan
    local camPos = myPos - dir * camDistance + Vector3.new(0, 4, 0)
    
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

local function createToggleButton()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AimbotToggle"
    gui.ResetOnSpawn = false

    local btn = Instance.new("ImageButton", gui)
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 10, 0.25, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🎯"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextSize = 28
    icon.Font = Enum.Font.SourceSansBold
    icon.TextScaled = true

    local function updateButton()
        if aimbotEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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

print("✅ JJS KAMERA KİLİT (İKİNCİ FOTOĞRAFTAKİ GİBİ) YUKLENDI!")
print("🎯 Sol ustteki siyah butonla ac/kapat.")
