-- BLOX FRUITS AUTO CHEST (OPTİMİZE - HIZLI UÇUŞ + NOCLIP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local chestESP = {}

local cfg = {
    flySpeed = 150,
    noclip = true,
    prioritizeValue = true,
    checkInterval = 0.15,
}

local CHEST_VALUES = {
    Diamond = 10000,
    Golden = 5000,
    Silver = 1500,
}

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

local function findChests()
    local chests = {}
    local myPos = getHumanoidRootPart()
    if not myPos then return chests end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                local value = 0
                if name:find("diamond") then
                    value = CHEST_VALUES.Diamond
                elseif name:find("golden") or name:find("gold") then
                    value = CHEST_VALUES.Golden
                elseif name:find("silver") then
                    value = CHEST_VALUES.Silver
                else
                    value = CHEST_VALUES.Silver
                end
                
                local pos = obj.Position
                if pos == pos then
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
    end
    return chests
end

local function getBestChest()
    local chests = findChests()
    if #chests == 0 then return nil end
    
    if cfg.prioritizeValue then
        table.sort(chests, function(a, b) return a.value > b.value end)
        return chests[1]
    else
        table.sort(chests, function(a, b) return a.distance < b.distance end)
        return chests[1]
    end
end

-- HIZLI UÇUŞ + NOCLIP (OPTİMİZE)
local function flyTo(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    -- NOCLIP (TÜM PARÇALAR)
    if cfg.noclip then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            -- Karakterin tüm uzuvlarını da noclip yap
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
    
    -- Uçuş modu
    hum.PlatformStand = true
    hum.Sit = false
    
    local distance = (targetPos - hrp.Position).Magnitude
    local dir = (targetPos - hrp.Position).Unit
    local speed = cfg.flySpeed
    
    -- Hızlı uçuş (doğrudan ışınlanma + uçuş karışımı)
    if distance > 100 then
        -- Uzak mesafede ışınlan + uç
        local steps = math.min(math.floor(distance / 50), 5)
        for i = 1, steps do
            if not chestFarmEnabled then return false end
            local stepPos = hrp.Position + dir * 50
            hrp.CFrame = CFrame.new(stepPos)
            wait(0.03)
        end
    end
    
    -- Son yaklaşma (uçarak)
    local attempts = 0
    while distance > 5 and attempts < 50 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        distance = (targetPos - currentPos).Magnitude
        local newPos = currentPos + dir * speed * 0.15
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.02)
    end
    
    -- Hedefe ulaş
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
    wait(0.1)
    return true
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 2, 0))
    wait(0.15)
    
    -- ClickDetector
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        wait(0.2)
        return true
    end
    
    -- ProximityPrompt
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        wait(0.2)
        return true
    end
    
    -- Tool
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        wait(0.1)
        return true
    end
    
    return false
end

-- ESP (Sadece aktifken çalışsın, performans için)
local function createChestESP()
    for _, obj in pairs(chestESP) do
        pcall(function() 
            if obj.text then obj.text:Remove() end
            if obj.box then obj.box:Remove() end
        end)
    end
    chestESP = {}
    
    if not chestFarmEnabled then return end
    
    local myPos = getHumanoidRootPart()
    if not myPos then return end
    
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if count > 30 then break end -- Maksimum 30 sandık göster (performans)
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                local pos = obj.Position
                if pos == pos then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                    if onScreen then
                        local text = Drawing.new("Text")
                        if text then
                            text.Size = 12
                            text.Center = true
                            text.Outline = true
                            text.Color = Color3.fromRGB(255, 200, 0)
                            text.Text = "📦"
                            text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                            text.Visible = true
                            chestESP[obj] = {text = text}
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
end

-- PANEL
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 110, 0, 50)
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
                for _, v in ipairs(char:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
        end
    end)
    
    return gui
end

-- ANA DÖNGÜ (OPTİMİZE)
local function mainLoop()
    if not chestFarmEnabled then return end
    
    local hrp = getHumanoidRootPart()
    if not hrp then
        wait(1)
        return
    end
    
    local chest = getBestChest()
    if not chest then
        wait(2)
        return
    end
    
    local success = flyTo(chest.position)
    if not success then
        wait(0.5)
        return
    end
    
    interactWithChest(chest)
    wait(0.3)
end

-- BAŞLAT
createPanel()

-- ESP güncelleme (daha az sıklıkta)
task.spawn(function()
    while wait(0.5) do
        pcall(function()
            if chestFarmEnabled then
                createChestESP()
            else
                for _, obj in pairs(chestESP) do
                    pcall(function() 
                        if obj.text then obj.text:Remove() end
                    end)
                end
                chestESP = {}
            end
        end)
    end
end)

-- Ana döngü
task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST (OPTIMIZE) YUKLENDI!")
print("HIZLI UCUS + NOCLIP AKTIF!")
