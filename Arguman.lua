-- DEBUG: Karakter Dönüş Testi (Panel ile)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local testTarget = nil
local outputText = ""

-- En yakın oyuncuyu bul
local function findTarget()
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

-- Karakteri döndürmeyi dene (tüm yöntemler)
local function testRotate(targetPlayer)
    if not targetPlayer then 
        outputText = "❌ Hedef yok!"
        return 
    end
    
    local myChar = LocalPlayer.Character
    if not myChar then 
        outputText = "❌ Karakter yok!"
        return 
    end
    
    local targetChar = targetPlayer.Character
    if not targetChar then 
        outputText = "❌ Hedefin karakteri yok!"
        return 
    end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then 
        outputText = "❌ Hedefin HumanoidRootPart'ı yok!"
        return 
    end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then 
        outputText = "❌ Kendi HumanoidRootPart'ım yok!"
        return 
    end
    
    local targetPos = targetHrp.Position
    local myPos = myHrp.Position
    
    outputText = ""
    outputText = outputText .. "========================================\n"
    outputText = outputText .. "🔍 HEDEF BULUNDU!\n"
    outputText = outputText .. "Hedef İsim: " .. targetPlayer.Name .. "\n"
    outputText = outputText .. "Hedef Pozisyon: " .. string.format("%.1f, %.1f, %.1f", targetPos.X, targetPos.Y, targetPos.Z) .. "\n"
    outputText = outputText .. "Benim Pozisyonum: " .. string.format("%.1f, %.1f, %.1f", myPos.X, myPos.Y, myPos.Z) .. "\n"
    outputText = outputText .. "Mesafe: " .. math.floor((myPos - targetPos).Magnitude) .. "m\n"
    outputText = outputText .. "========================================\n"
    
    -- YÖNTEM 1: HumanoidRootPart'ı döndür
    local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
    outputText = outputText .. "YÖNTEM 1: HumanoidRootPart -> CFrame.lookAt\n"
    myHrp.CFrame = CFrame.lookAt(myPos, flatTarget)
    outputText = outputText .. "✅ HumanoidRootPart döndürüldü!\n"
    
    wait(0.3)
    
    -- YÖNTEM 2: UpperTorso veya Torso'yu döndür
    local torso = myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso")
    if torso then
        outputText = outputText .. "YÖNTEM 2: " .. torso.Name .. " -> CFrame.lookAt\n"
        torso.CFrame = CFrame.lookAt(torso.Position, flatTarget)
        outputText = outputText .. "✅ " .. torso.Name .. " döndürüldü!\n"
    end
    
    wait(0.3)
    
    -- YÖNTEM 3: Humanoid.AutoRotate = true
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if hum then
        outputText = outputText .. "YÖNTEM 3: Humanoid.AutoRotate = true\n"
        hum.AutoRotate = true
        outputText = outputText .. "✅ AutoRotate açıldı!\n"
    end
    
    -- YÖNTEM 4: Kamerayı döndür
    outputText = outputText .. "YÖNTEM 4: Camera CFrame.lookAt\n"
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos + Vector3.new(0, 2, 0))
    outputText = outputText .. "✅ Kamera döndürüldü!\n"
    
    outputText = outputText .. "========================================\n"
    outputText = outputText .. "✅ Tüm yöntemler denendi! Karakter döndü mü?\n"
end

-- Panel oluştur
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "RotateTest"
    gui.ResetOnSpawn = false
    
    -- Ana Panel
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 400, 0, 350)
    panel.Position = UDim2.new(0.5, -200, 0.5, -175)
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    panel.BackgroundTransparency = 0.15
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
    
    -- Başlık
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.BackgroundTransparency = 0.5
    title.Text = "🔍 KARAKTER DÖNÜŞ TESTİ"
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
    btnFrame.Size = UDim2.new(1, 0, 0, 50)
    btnFrame.Position = UDim2.new(0, 0, 0, 35)
    btnFrame.BackgroundTransparency = 1
    
    -- Test Butonu
    local testBtn = Instance.new("TextButton", btnFrame)
    testBtn.Size = UDim2.new(0.6, -5, 1, -5)
    testBtn.Position = UDim2.new(0, 0, 0, 2)
    testBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    testBtn.Text = "🔍 KARAKTERİ DÖNDÜR"
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.TextSize = 14
    testBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 6)
    
    -- Temizle Butonu
    local clearBtn = Instance.new("TextButton", btnFrame)
    clearBtn.Size = UDim2.new(0.35, -5, 1, -5)
    clearBtn.Position = UDim2.new(0.63, 0, 0, 2)
    clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    clearBtn.Text = "🗑️ TEMİZLE"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.TextSize = 14
    clearBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    
    -- TextBox (çıktılar burada)
    local textBox = Instance.new("TextBox", panel)
    textBox.Size = UDim2.new(1, -10, 1, -100)
    textBox.Position = UDim2.new(0, 5, 0, 90)
    textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    textBox.BackgroundTransparency = 0.3
    textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.SourceSans
    textBox.Text = "🔄 'KARAKTERİ DÖNDÜR' butonuna tıkla..."
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.BorderSizePixel = 0
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
    
    -- Kapatma Butonu (X)
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
    
    -- Açma Butonu (sağ üst)
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
    testBtn.Activated:Connect(function()
        local target = findTarget()
        if target then
            testRotate(target)
            textBox.Text = outputText
        else
            textBox.Text = "❌ Yakınlarda kimse yok!"
        end
    end)
    
    clearBtn.Activated:Connect(function()
        textBox.Text = "🔄 Temizlendi! 'KARAKTERİ DÖNDÜR' butonuna tıkla..."
        outputText = ""
    end)
    
    return gui
end

createPanel()
print("✅ DEBUG PANELİ YÜKLENDI!")
print("🔍 Sağ üstteki '🔍' butonuna tıkla paneli aç.")
