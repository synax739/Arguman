-- JJS KAMERA DEBUG PANELİ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local debugEnabled = false
local targetPlayer = nil
local debugText = ""

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

local function collectDebugInfo()
    local info = {}
    local myChar = LocalPlayer.Character
    if not myChar then
        info[#info+1] = "❌ Karakter yok!"
        return info
    end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    local head = myChar:FindFirstChild("Head")
    
    info[#info+1] = "===== KAMERA BİLGİLERİ ====="
    info[#info+1] = "Kamera Pozisyonu: " .. string.format("%.1f, %.1f, %.1f", Camera.CFrame.Position.X, Camera.CFrame.Position.Y, Camera.CFrame.Position.Z)
    info[#info+1] = "Kamera Yönü: " .. string.format("%.1f, %.1f, %.1f", Camera.CFrame.LookVector.X, Camera.CFrame.LookVector.Y, Camera.CFrame.LookVector.Z)
    
    if myHrp then
        info[#info+1] = ""
        info[#info+1] = "===== KARAKTER BİLGİLERİ ====="
        info[#info+1] = "Karakter Pozisyonu: " .. string.format("%.1f, %.1f, %.1f", myHrp.Position.X, myHrp.Position.Y, myHrp.Position.Z)
    end
    
    if head then
        info[#info+1] = "Kafa Pozisyonu: " .. string.format("%.1f, %.1f, %.1f", head.Position.X, head.Position.Y, head.Position.Z)
    end
    
    if targetPlayer then
        local targetChar = getCharacter(targetPlayer)
        if targetChar then
            local targetHrp = getHumanoidRootPart(targetPlayer)
            if targetHrp then
                info[#info+1] = ""
                info[#info+1] = "===== HEDEF BİLGİLERİ ====="
                info[#info+1] = "Hedef İsim: " .. targetPlayer.Name
                info[#info+1] = "Hedef Pozisyonu: " .. string.format("%.1f, %.1f, %.1f", targetHrp.Position.X, targetHrp.Position.Y, targetHrp.Position.Z)
                if myHrp then
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude
                    info[#info+1] = "Mesafe: " .. math.floor(dist) .. "m"
                end
            end
        else
            info[#info+1] = ""
            info[#info+1] = "❌ Hedef karakteri yok!"
        end
    else
        info[#info+1] = ""
        info[#info+1] = "===== HEDEF ====="
        info[#info+1] = "❌ Hedef seçili değil!"
    end
    
    return info
end

local function createDebugPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "CameraDebug"
    gui.ResetOnSpawn = false
    
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 400, 0, 400)
    panel.Position = UDim2.new(0.5, -200, 0.5, -200)
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    panel.BackgroundTransparency = 0.15
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.BackgroundTransparency = 0.5
    title.Text = "🔍 KAMERA DEBUG"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 15
    title.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)
    
    local drag, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = i.Position
            startPos = panel.Position
        end
    end)
    title.InputEnded:Connect(function() drag = false end)
    title.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    
    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(1, 0, 0, 45)
    btnFrame.Position = UDim2.new(0, 0, 0, 35)
    btnFrame.BackgroundTransparency = 1
    
    local selectBtn = Instance.new("TextButton", btnFrame)
    selectBtn.Size = UDim2.new(0.48, -5, 1, -5)
    selectBtn.Position = UDim2.new(0, 0, 0, 2)
    selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    selectBtn.Text = "🎯 HEDEF SEÇ"
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.TextSize = 13
    selectBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)
    
    local debugBtn = Instance.new("TextButton", btnFrame)
    debugBtn.Size = UDim2.new(0.48, -5, 1, -5)
    debugBtn.Position = UDim2.new(0.52, 0, 0, 2)
    debugBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    debugBtn.Text = "▶ BAŞLAT"
    debugBtn.TextColor3 = Color3.new(1, 1, 1)
    debugBtn.TextSize = 13
    debugBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", debugBtn).CornerRadius = UDim.new(0, 6)
    
    local textBox = Instance.new("TextBox", panel)
    textBox.Size = UDim2.new(1, -10, 1, -95)
    textBox.Position = UDim2.new(0, 5, 0, 85)
    textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    textBox.BackgroundTransparency = 0.3
    textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    textBox.TextSize = 11
    textBox.Font = Enum.Font.SourceSans
    textBox.Text = "🔄 'HEDEF SEÇ' ile hedef seç, 'BAŞLAT' ile debug'u başlat."
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.BorderSizePixel = 0
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
    
    local closeBtn = Instance.new("TextButton", panel)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -33, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.Activated:Connect(function() panel.Visible = false end)
    
    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 40, 0, 40)
    openBtn.Position = UDim2.new(1, -50, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    openBtn.Text = "🔍"
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.TextSize = 20
    openBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    openBtn.Activated:Connect(function() panel.Visible = not panel.Visible end)
    
    selectBtn.Activated:Connect(function()
        targetPlayer = findClosestPlayer()
        if targetPlayer then
            textBox.Text = "✅ Hedef seçildi: " .. targetPlayer.Name
        else
            textBox.Text = "❌ Yakınlarda kimse yok!"
        end
    end)
    
    debugBtn.Activated:Connect(function()
        debugEnabled = not debugEnabled
        if debugEnabled then
            debugBtn.Text = "⏹ DURDUR"
            debugBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            textBox.Text = "▶ Debug başlatıldı! Bilgiler akıyor..."
        else
            debugBtn.Text = "▶ BAŞLAT"
            debugBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if debugEnabled then
            local info = collectDebugInfo()
            local fullText = table.concat(info, "\n")
            textBox.Text = fullText
        end
    end)
    
    return gui
end

-- ANA AIMBOT (BASİT VE SAĞLAM)
local aimbotEnabled = false
local lockTarget = nil
local lockCircle = nil

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

local function createAimbotButton()
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

-- ANA DÖNGÜ (SADECE KAMERA KİLİT)
local function mainLoop()
    if aimbotEnabled then
        if not lockTarget or not isAlive(lockTarget) then
            lockTarget = findClosestPlayer()
            if not lockTarget then
                if lockCircle then lockCircle.Visible = false end
                return
            end
        end
        
        local targetChar = getCharacter(lockTarget)
        local targetHrp = getHumanoidRootPart(lockTarget)
        if targetChar and targetHrp then
            local targetPos = targetHrp.Position + Vector3.new(0, 2, 0)
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.lookAt(camPos, targetPos)
        end
    end
    updateLockCircle()
end

-- BAŞLAT
createDebugPanel()
createLockCircle()
createAimbotButton()

RunService.RenderStepped:Connect(function()
    pcall(mainLoop)
end)

print("✅ JJS KAMERA KİLİT + DEBUG PANELİ YUKLENDI!")
print("🔍 Sağ üstteki '🔍' ile debug panelini aç.")
print("🎯 Sol üstteki siyah butonla aimbot'u aç/kapat.")
