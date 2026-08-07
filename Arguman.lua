-- BLOX FRUITS AUTO CHEST (TÜM DENİZLER - UÇARAK VE NOCLIP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local chestFarmEnabled = false
local currentTarget = nil
local chestESP = {}

-- Ayarlar
local cfg = {
    flySpeed = 80,
    noclip = true,
    prioritizeValue = true, -- Önce Elmas, sonra Altın, sonra Gümüş
    checkInterval = 0.1,
}

-- Sandık değerleri (3. Deniz baz alındı, 1-2. Deniz için otomatik uyarlanacak)
local CHEST_VALUES = {
    Diamond = 10000,
    Golden = 5000,
    Silver = 1500,
}

-- ==============================================
-- YARDIMCI FONKSİYONLAR
-- ==============================================
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHumanoidRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==============================================
-- SANDIK BULMA
-- ==============================================
local function findChests()
    local chests = {}
    local myPos = getHumanoidRootPart()
    if not myPos then return chests end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
            local isChest = false
            local value = 0
            local name = obj.Name:lower()
            
            -- Sandık türünü belirle
            if name:find("diamond") then
                value = CHEST_VALUES.Diamond
                isChest = true
            elseif name:find("golden") or name:find("gold") then
                value = CHEST_VALUES.Golden
                isChest = true
            elseif name:find("silver") then
                value = CHEST_VALUES.Silver
                isChest = true
            elseif name:find("chest") or name:find("crate") then
                -- Bilinmeyen sandık (varsayılan)
                value = CHEST_VALUES.Silver
                isChest = true
            end
            
            if isChest then
                local pos = obj.Position
                if pos ~= pos then continue end -- nan kontrolü
                local dist = (myPos.Position - pos).Magnitude
                table.insert(chests, {
                    object = obj,
                    position = pos,
                    value = value,
                    distance = dist,
                    name = obj.Name,
                })
            end
        end
    end
    
    return chests
end

local function getBestChest()
    local chests = findChests()
    if #chests == 0 then return nil end
    
    if cfg.prioritizeValue then
        -- En değerli sandığı bul (değer yüksekten düşüğe)
        table.sort(chests, function(a, b) return a.value > b.value end)
        return chests[1]
    else
        -- En yakın sandığı bul
        table.sort(chests, function(a, b) return a.distance < b.distance end)
        return chests[1]
    end
end

-- ==============================================
-- UÇUŞ VE NOCLIP
-- ==============================================
local function flyTo(targetPos)
    local char = getCharacter()
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not char or not hrp or not hum then return false end
    
    -- Noclip aç
    if cfg.noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Uçmayı etkinleştir
    hum.PlatformStand = true
    hum.Sit = false
    
    local distance = (targetPos - hrp.Position).Magnitude
    local startPos = hrp.Position
    
    -- Hedefe doğru uç
    local dir = (targetPos - startPos).Unit
    local speed = cfg.flySpeed
    
    -- Yaklaşma döngüsü
    local attempts = 0
    while distance > 5 and attempts < 100 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        distance = (targetPos - currentPos).Magnitude
        
        -- Yeni pozisyon
        local newPos = currentPos + dir * speed * 0.1
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.05)
    end
    
    -- Hedefe yaklaştıysa tam üzerine ışınlan
    if distance < 10 then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
        wait(0.2)
        return true
    end
    
    return false
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    -- Sandığın üzerine ışınlan
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 2, 0))
    wait(0.2)
    
    -- ClickDetector varsa tıkla
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        wait(0.3)
        return true
    end
    
    -- ProximityPrompt varsa etkileşime geç
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        wait(0.3)
        return true
    end
    
    -- Tool olarak alınabilir mi?
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        wait(0.2)
        return true
    end
    
    return false
end

-- ==============================================
-- ESP (Sandıkları Göster)
-- ==============================================
local function createChestESP()
    for _, obj in pairs(chestESP) do
        pcall(function() obj.text:Remove() end)
        pcall(function() obj.box:Remove() end)
    end
    chestESP = {}
    
    if not chestFarmEnabled then return end
    
    local myPos = getHumanoidRootPart()
    if not myPos then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
            local pos = obj.Position
            if pos ~= pos then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen then
                local text = Drawing.new("Text")
                if text then
                    text.Size = 14
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 200, 0)
                    text.Text = "📦 " .. obj.Name
                    text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                    text.Visible = true
                    chestESP[obj] = {text = text}
                end
            end
        end
    end
end

-- ==============================================
-- PANEL (BASİT MOBİL UYUMLU)
-- ==============================================
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
    -- Buton (kırmızı/toggle)
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 100, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "BAŞLAT"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    btn.Activated:Connect(function()
        chestFarmEnabled = not chestFarmEnabled
        if chestFarmEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            btn.Text = "DURDUR"
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BAŞLAT"
            -- Noclip'i kapat
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
        end
    end)
    
    return gui
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
local function mainLoop()
    if not chestFarmEnabled then return end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return end
    
    -- En değerli sandığı bul
    local chest = getBestChest()
    if not chest then
        print("⚠️ Sandık bulunamadı! Bekleniyor...")
        wait(2)
        return
    end
    
    print("🎯 Hedef: " .. chest.name .. " (Değer: " .. chest.value .. ")")
    
    -- Sandığa uç
    local success = flyTo(chest.position)
    if not success then
        print("❌ Sandığa ulaşılamadı!")
        wait(1)
        return
    end
    
    -- Sandıkla etkileşime geç
    local grabbed = interactWithChest(chest)
    if grabbed then
        print("✅ " .. chest.name .. " toplandı!")
    else
        print("⚠️ " .. chest.name .. " toplanamadı!")
    end
    
    wait(0.5)
end

-- ==============================================
-- BAŞLAT
-- ==============================================
createPanel()

-- ESP güncelleme (RenderStepped)
RunService.RenderStepped:Connect(function()
    pcall(function()
        if chestFarmEnabled then
            createChestESP()
        else
            for _, obj in pairs(chestESP) do
                pcall(function() obj.text:Remove() end)
            end
            chestESP = {}
        end
    end)
end)

-- Ana döngü (task.spawn ile ayrı thread)
task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("✅ BLOX FRUITS AUTO CHEST YÜKLENDİ!")
print("📦 Tüm denizlerde çalışır. En değerli sandığa uçarak gider.")
print("🔴 Kırmızı 'BAŞLAT' butonuna tıkla başlat.")
