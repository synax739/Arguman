-- JJS GERÇEK ZAMANLI DEBUG PANELİ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local debugText = ""
local targetPlayer = nil
local isDebugging = false

-- En yakın oyuncuyu bul
local function findClosestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local dist = (myHrp.Position - hrp.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = plr
        end
    end
    return closest
end

-- Debug bilgilerini topla
local function collectDebugInfo()
    local info = {}
    local myChar = LocalPlayer.Character
    if not myChar then 
        info[#info+1] = "❌ Karakter yok!"
        return info
    end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    local torso = myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso")
    
    info[#info+1] = "===== KARAKTER BİLGİLERİ ====="
    info[#info+1] = "HumanoidRootPart: " .. (myHrp and "✅ VAR" or "❌ YOK")
    if myHrp then
        info[#info+1] = "  Pozisyon: " .. string.format("%.1f, %.1f, %.1f", myHrp.Position.X, myHrp.Position.Y, myHrp.Position.Z)
        info[#info+1] = "  Rotation (Y): " .. string.format("%.1f°", math.deg(myHrp.Orientation.Y))
    end
    info[#info+1] = "Humanoid: " .. (hum and "✅ VAR" or "❌ YOK")
    if hum then
        info[#info+1] = "  AutoRotate: " .. tostring(hum.AutoRotate)
        info[#info+1] = "  WalkSpeed: " .. hum.WalkSpeed
        info[#info+1] = "  JumpPower: " .. hum.JumpPower
    end
    info[#info+1] = "Torso/UpperTorso: " .. (torso and "✅ VAR" or "❌ YOK")
    if torso then
        info[#info+1] = "  Pozisyon: " .. string.format("%.1f, %.1f, %.1f", torso.Position.X, torso.Position.Y, torso.Position.Z)
    end
    
    -- Hedef bilgileri
    local target = targetPlayer
    if target then
        local targetChar = target.Character
        info[#info+1] = ""
        info[#info+1] = "===== HEDEF BİLGİLERİ ====="
        info[#info+1] = "İsim: " .. target.Name
        if targetChar then
            local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                info[#info+1] = "Pozisyon: " .. string.format("%.1f, %.1f, %.1f", targetHrp.Position.X, targetHrp.Position.Y, targetHrp.Position.Z)
                if myHrp then
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude
                    info[#info+1] = "Mesafe: " .. math.floor(dist) .. "m"
                end
            end
        else
            info[#info+1] = "❌ Karakter yok!"
        end
    else
        info[#info+1] = ""
        info[#info+1] = "===== HEDEF ====="
        info[#info+1] = "❌ Hedef seçili değil!"
    end
    
    return info
end

-- Panel oluştur
local function createDebugPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "DebugPanel"
    gui.ResetOnSpawn = false
    
    -- Panel
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 400, 0, 400)
    panel.Position = UDim2.new(0.5, -200, 0.5, -200)
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    panel.BackgroundTransparency = 0.15
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
    
    -- Başlık (sürükleme)
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.BackgroundTransparency = 0.5
    title.Text = "🔍 GERÇEK ZAMANLI DEBUG"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 15
    title.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)
    
    -- Sürükleme
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
    
    -- Buton çerçevesi
    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(1, 0, 0, 45)
    btnFrame.Position = UDim2.new(0, 0, 0, 35)
    btnFrame.BackgroundTransparency = 1
    
    -- Hedef Seç Butonu
    local selectBtn = Instance.new("TextButton", btnFrame)
    selectBtn.Size = UDim2.new(0.48, -5, 1, -5)
    selectBtn.Position = UDim2.new(0, 0, 0, 2)
    selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    selectBtn.Text = "🎯 HEDEF SEÇ"
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.TextSize = 13
    selectBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)
    
    -- Debug Başlat/Durdur Butonu
    local debugBtn = Instance.new("TextButton", btnFrame)
    debugBtn.Size = UDim2.new(0.48, -5, 1, -5)
    debugBtn.Position = UDim2.new(0.52, 0, 0, 2)
    debugBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    debugBtn.Text = "▶ BAŞLAT"
    debugBtn.TextColor3 = Color3.new(1, 1, 1)
    debugBtn.TextSize = 13
    debugBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", debugBtn).CornerRadius = UDim.new(0, 6)
    
    -- TextBox (çıktılar)
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
    
    -- Kapatma
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
    
    -- Açma Butonu
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
    
    -- Buton işlevleri
    selectBtn.Activated:Connect(function()
        targetPlayer = findClosestPlayer()
        if targetPlayer then
            textBox.Text = "✅ Hedef seçildi: " .. targetPlayer.Name
        else
            textBox.Text = "❌ Yakınlarda kimse yok!"
        end
    end)
    
    debugBtn.Activated:Connect(function()
        isDebugging = not isDebugging
        if isDebugging then
            debugBtn.Text = "⏹ DURDUR"
            debugBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            textBox.Text = "▶ Debug başlatıldı! Bilgiler akıyor..."
        else
            debugBtn.Text = "▶ BAŞLAT"
            debugBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        end
    end)
    
    -- Debug döngüsü
    RunService.RenderStepped:Connect(function()
        if isDebugging then
            local info = collectDebugInfo()
            local fullText = table.concat(info, "\n")
            textBox.Text = fullText
        end
    end)
    
    return gui
end

createDebugPanel()
print("✅ DEBUG PANELİ YÜKLENDI!")
print("🔍 Sağ üstteki '🔍' butonuna tıkla paneli aç.")
print("1. 'HEDEF SEÇ' ile en yakın oyuncuyu seç.")
print("2. 'BAŞLAT' ile gerçek zamanlı debug'u başlat.")
print("3. Karakter bilgilerini ve hedef bilgilerini anlık gör.")
