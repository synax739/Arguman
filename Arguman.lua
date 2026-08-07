-- DELTA EXECUTOR - AUTO CHEST TOPLAMA V2
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled
local active = false
local gui = nil
local mobileBtn = nil

print("📦 AUTO CHEST TOPLAMA V2 BAŞLATILDI...")

-- ===== KARAKTER KONTROL =====
local function getChar()
    local char = player.Character
    if not char then
        player.CharacterAdded:Wait()
        char = player.Character
    end
    return char
end

-- ===== IŞINLANMA =====
local function teleport(pos)
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- ===== TÜM SANDIKLARI BUL (KAYBOLANLARI ATLA) =====
local function findAllChests()
    local chests = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:match("Chest") then
            -- Sandık hala duruyor mu kontrol et
            if v.Parent and v.Parent:FindFirstChild(v.Name) then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

-- ===== EN YAKIN SANDIĞI BUL (CANLI OLAN) =====
local function findNearestChest()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local pos = char.HumanoidRootPart.Position
    local nearest = nil
    local dist = math.huge
    
    local chests = findAllChests()
    
    for _, chest in pairs(chests) do
        -- Sandık hala var mı ve alınabilir mi?
        if chest and chest.Parent and chest.Parent:FindFirstChild(chest.Name) then
            local d = (chest.Position - pos).Magnitude
            if d < dist and d < 1000 then -- 1000 stud uzaklığa kadar
                dist = d
                nearest = chest
            end
        end
    end
    
    return nearest, dist
end

-- ===== SANDIK TOPLAMA =====
local function collectChests()
    while active do
        local chest, dist = findNearestChest()
        
        if chest then
            print("📦 Sandık bulundu! Mesafe: " .. math.floor(dist) .. " | İsim: " .. chest.Name)
            
            -- Sandığa ışınlan
            teleport(chest.Position + Vector3.new(0, 3, 0))
            wait(0.3)
            
            -- Sandığa dokun
            local char = getChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(chest.Position + Vector3.new(0, 2, 0))
            end
            
            wait(1.5)
            
            -- Sandık hala duruyor mu kontrol et (hala varsa tekrar dene)
            local stillExists = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v == chest and v.Parent and v.Parent:FindFirstChild(v.Name) then
                    stillExists = true
                    break
                end
            end
            
            if stillExists then
                print("⚠️ Sandık hala duruyor, tekrar deneniyor...")
                wait(1)
            else
                print("✅ Sandık toplandı!")
            end
        else
            print("❌ Sandık bulunamadı, bekleniyor...")
            wait(3)
        end
        
        wait(0.5)
    end
end

-- ===== PANEL =====
local function createPanel()
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = isMobile and UDim2.new(0.8, 0, 0.3, 0) or UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, isMobile and -150 or -150, 0.5, isMobile and -100 or -75)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    frame.Parent = gui
    frame.Active = true
    frame.Draggable = true
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "📦 AUTO CHEST"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 20 or 18
    title.Parent = frame
    
    -- Kapat
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 3)
    close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        active = false
        gui:Destroy()
        gui = nil
        if isMobile then createMobileButton() end
    end)
    
    -- AÇ/KAPA Butonu
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.6, 0, 0, isMobile and 45 or 40)
    toggleBtn.Position = UDim2.new(0.2, 0, 0, 50)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "▶️ BAŞLAT"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = isMobile and 18 or 16
    toggleBtn.Parent = frame
    
    -- Durum
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 25)
    status.Position = UDim2.new(0.05, 0, 0, isMobile and 105 or 95)
    status.Text = "⏸️ DURAKLATILDI"
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = isMobile and 14 or 12
    status.Parent = frame
    
    -- Buton işlevi
    toggleBtn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            toggleBtn.Text = "⏹️ DURDUR"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            status.Text = "▶️ ÇALIŞIYOR..."
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
            print("✅ Auto Chest başlatıldı!")
            spawn(collectChests)
        else
            toggleBtn.Text = "▶️ BAŞLAT"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            status.Text = "⏸️ DURAKLATILDI"
            status.TextColor3 = Color3.fromRGB(200, 200, 255)
            print("⏸️ Auto Chest durduruldu!")
        end
    end)
end

-- ===== MOBİL BUTON =====
local function createMobileButton()
    if mobileBtn then mobileBtn:Destroy() end
    
    mobileBtn = Instance.new("TextButton")
    mobileBtn.Parent = player.PlayerGui
    mobileBtn.Size = UDim2.new(0, 60, 0, 60)
    mobileBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileBtn.Text = "📦"
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.TextSize = 30
    mobileBtn.BorderSizePixel = 2
    mobileBtn.BorderColor3 = Color3.fromRGB(0, 255, 200)
    mobileBtn.BackgroundTransparency = 0.1
    mobileBtn.Name = "ChestButton"
    
    mobileBtn.MouseButton1Click:Connect(function()
        mobileBtn:Destroy()
        mobileBtn = nil
        createPanel()
    end)
end

-- ===== F8 İLE AÇ/KAPA =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then
        if gui then
            active = false
            gui:Destroy()
            gui = nil
            if isMobile then createMobileButton() end
        else
            if mobileBtn then
                mobileBtn:Destroy()
                mobileBtn = nil
            end
            createPanel()
        end
    end
end)

-- ===== BAŞLAT =====
if isMobile then
    createMobileButton()
    print("📦 Mobil buton aktif! Tıkla aç.")
else
    createPanel()
    print("📦 Panel açıldı! F8 ile kapat.")
end

print("✅ AUTO CHEST TOPLAMA V2 HAZIR!")
