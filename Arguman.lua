-- TAM KİLİT (KAMERA + KARAKTER GÖVDESİ) - INPUT ENGELLEMELİ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local lockTarget = nil
local lockCircle = nil
local controlsDisabled = false

-- PlayerModule'ü al (input kontrolü için)
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local PlayerModule = nil
local Controls = nil

pcall(function()
    PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    Controls = PlayerModule:GetControls()
end)

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

local function getPlayerTeam(plr)
    local attr = plr:GetAttribute("Team")
    if attr then return tostring(attr) end
    return nil
end

local function isSameTeam(plr)
    local myTeam = getPlayerTeam(LocalPlayer)
    local plrTeam = getPlayerTeam(plr)
    if myTeam and plrTeam then
        return myTeam == plrTeam
    end
    return false
end

local function findClosestEnemy()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not isAlive(plr) then continue end
        if isSameTeam(plr) then continue end
        
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

-- ===== TAM KİLİT (TÜM PARÇALAR) =====
local function applyLock()
    if not aimbotEnabled or not lockTarget then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local targetChar = lockTarget.Character
    if not targetChar then return end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    
    if not myHrp or not targetHrp or not hum then return end
    
    local targetPos = targetHrp.Position + Vector3.new(0, 1, 0)
    local myPos = myHrp.Position
    local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
    
    -- AutoRotate kapat
    hum.AutoRotate = false
    
    -- 1. HumanoidRootPart'ı döndür
    pcall(function()
        myHrp.CFrame = CFrame.lookAt(myPos, flatTarget)
    end)
    
    -- 2. UpperTorso / Torso döndür
    local upper = myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso")
    if upper then
        pcall(function()
            local upPos = upper.Position
            local upFlatTarget = Vector3.new(targetPos.X, upPos.Y, targetPos.Z)
            upper.CFrame = CFrame.lookAt(upPos, upFlatTarget)
        end)
    end
    
    -- 3. Head döndür
    local head = myChar:FindFirstChild("Head")
    if head then
        pcall(function()
            local headPos = head.Position
            local headFlatTarget = Vector3.new(targetPos.X, headPos.Y, targetPos.Z)
            head.CFrame = CFrame.lookAt(headPos, headFlatTarget)
        end)
    end
    
    -- 4. Kamera
    if head then
        Camera.CameraType = Enum.CameraType.Scriptable
        pcall(function()
            Camera.CFrame = CFrame.lookAt(head.Position, targetPos)
        end)
    end
end

-- INPUT ENGELLEME (karakter gövdesinin dönmesini engeller)
local function disableControls()
    if controlsDisabled then return end
    pcall(function()
        if Controls then
            Controls:Disable()
            controlsDisabled = true
        end
    end)
end

local function enableControls()
    if not controlsDisabled then return end
    pcall(function()
        if Controls then
            Controls:Enable()
            controlsDisabled = false
        end
    end)
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

local function enableFirstPerson()
    pcall(function()
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
        Camera.FieldOfView = 70
    end)
end

local function disableLock()
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
            hum.AutoRotate = true
        end
    end)
    enableControls()
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
    hLine.BorderSizePixel = 0

    local vLine = Instance.new("Frame", btn)
    vLine.Size = UDim2.new(0, 2, 0, 28)
    vLine.Position = UDim2.new(0.5, -1, 0.5, -14)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vLine.BorderSizePixel = 0

    local statusDot = Instance.new("Frame", btn)
    statusDot.Size = UDim2.new(0, 18, 0, 18)
    statusDot.Position = UDim2.new(0.5, -9, 0.5, -9)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
            lockTarget = findClosestEnemy()
            enableFirstPerson()
            disableControls() -- INPUT ENGELLE
        else
            lockTarget = nil
            if lockCircle then lockCircle.Visible = false end
            disableLock()
        end
        updateButton()
    end)

    updateButton()
    return btn
end

-- ===== ÇOK KATMANLI HOOK =====
-- 1. PreAnimation (animasyondan önce)
RunService.PreAnimation:Connect(function()
    pcall(applyLock)
end)

-- 2. PreSimulation (fizikten önce)
RunService.PreSimulation:Connect(function()
    pcall(applyLock)
end)

-- 3. En yüksek öncelikli RenderStep (render öncesi son söz)
RunService:BindToRenderStep("ForceAimLock", Enum.RenderPriority.Camera.Value + 10, function()
    pcall(applyLock)
    pcall(updateLockCircle)
end)

-- 4. Heartbeat (yedek)
RunService.Heartbeat:Connect(function()
    pcall(applyLock)
end)

createLockCircle()
createToggleButton()
enableFirstPerson()

LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if aimbotEnabled then
        enableFirstPerson()
        disableControls()
    end
end)

print("✅ TAM KILIT (INPUT ENGELLEMELI) YUKLENDI!")
print("🎯 Karakter govdesi de hedefe kilitli. Ekrana surukleme calismaz.")
