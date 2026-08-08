-- BLOX FRUITS AUTO CHEST (SON - SORUNLU ADALARI ENGELLE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local chestESP = {}
local collectedChests = {}

-- SORUNLU ADALARIN KOORDİNATLARI (GİDİLMEYECEK)
local blockedAreas = {
    -- Sualtı Şehri (Underwater City) - 1. Deniz
    {x = -2000, z = -2000, range = 500}, -- Yaklaşık konum
    -- Jean-Luc Adası (sadece 1 sandık, ulaşımı zor)
    -- Diğer sorunlu adalar eklenebilir
}

local function isPositionBlocked(pos)
    for _, area in ipairs(blockedAreas) do
        if math.abs(pos.X - area.x) < area.range and math.abs(pos.Z - area.z) < area.range then
            return true
        end
    end
    return false
end

local cfg = {
    flySpeed = 180,
    flyHeight = 55,
    prioritizeValue = false,
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

local function setNoclip(state)
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.CanCollide = not state end)
        end
    end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            pcall(function() v.CanCollide = not state end)
        end
    end
end

local function enableFly()
    local hum = getHumanoid()
    if not hum then return end
    hum.PlatformStand = true
    hum.Sit = false
    hum.AutoRotate = false
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
end

local function disableFly()
    local hum = getHumanoid()
    if not hum then return end
    hum.PlatformStand = false
    hum.AutoRotate = true
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    end)
end

local function isChestValid(chestObj)
    if not chestObj or not chestObj.Parent then return false end
    local id = tostring(chestObj)
    if collectedChests[id] then return false end
    return true
end

local function findChests()
    local chests = {}
    local myPos = getHumanoidRootPart()
    if not myPos then return chests end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                if not isChestValid(obj) then continue end
                
                -- SORUNLU ADA KONTROLÜ
                local pos = obj.Position
                if isPositionBlocked(pos) then
                    -- Bu sandığı atla (toplanmış gibi işaretle)
                    collectedChests[tostring(obj)] = true
                    continue
                end
                
                local value = 0
                if name:find("diamond") then value = CHEST_VALUES.Diamond
                elseif name:find("golden") or name:find("gold") then value = CHEST_VALUES.Golden
                elseif name:find("silver") then value = CHEST_VALUES.Silver
                else value = CHEST_VALUES.Silver end
                
                if pos == pos then
                    local dist = (myPos.Position - pos).Magnitude
                    table.insert(chests, {
                        object = obj,
                        id = tostring(obj),
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
    table.sort(chests, function(a, b) return a.distance < b.distance end)
    return chests[1]
end

local function flyTo(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    -- Suyun içindeyse yukarı çık
    if hrp.Position.Y < 5 then
        hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 30, 0))
        wait(0.05)
    end
    
    enableFly()
    setNoclip(true)
    
    local flyTarget = Vector3.new(targetPos.X, targetPos.Y + cfg.flyHeight, targetPos.Z)
    local distance = (flyTarget - hrp.Position).Magnitude
    
    -- Işınlanma (uzak mesafe)
    if distance > 80 then
        local steps = math.min(math.floor(distance / 100), 3)
        for i = 1, steps do
            if not chestFarmEnabled then return false end
            local stepPos = hrp.Position + (flyTarget - hrp.Position).Unit * 100
            stepPos = Vector3.new(stepPos.X, math.max(stepPos.Y, 25), stepPos.Z)
            hrp.CFrame = CFrame.new(stepPos)
            wait(0.02)
        end
    end
    
    -- Uçuş
    local dir = (flyTarget - hrp.Position).Unit
    local attempts = 0
    local currentDist = (flyTarget - hrp.Position).Magnitude
    
    while currentDist > 8 and attempts < 50 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        currentDist = (flyTarget - currentPos).Magnitude
        
        if currentPos.Y < 10 then
            hrp.CFrame = CFrame.new(currentPos + Vector3.new(0, 20, 0))
            wait(0.02)
        end
        
        local newPos = currentPos + dir * cfg.flySpeed * 0.08
        newPos = Vector3.new(newPos.X, math.max(newPos.Y, 20), newPos.Z)
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.01)
    end
    
    setNoclip(false)
    local landPos = Vector3.new(targetPos.X, targetPos.Y + 2.5, targetPos.Z)
    hrp.CFrame = CFrame.new(landPos)
    wait(0.05)
    
    disableFly()
    return true
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 1.5, 0))
    wait(0.1)
    
    local success = false
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        success = true
    end
    
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        success = true
    end
    
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        success = true
    end
    
    if success then
        collectedChests[chest.id] = true
        return true
    end
    return false
end

local function createChestESP()
    for _, obj in pairs(chestESP) do
        pcall(function() if obj.text then obj.text:Remove() end end)
    end
    chestESP = {}
    if not chestFarmEnabled then return end
    
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if count > 30 then break end
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                if not isChestValid(obj) then continue end
                if isPositionBlocked(obj.Position) then
                    collectedChests[tostring(obj)] = true
                    continue
                end
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

local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 120, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "BAŞLAT"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local resetBtn = Instance.new("TextButton", gui)
    resetBtn.Size = UDim2.new(0, 50, 0, 50)
    resetBtn.Position = UDim2.new(0.13, 0, 0.85, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    resetBtn.Text = "↺"
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.TextSize = 20
    resetBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(1, 0)
    resetBtn.Activated:Connect(function()
        collectedChests = {}
        print("🔄 Hatırlanan sandıklar temizlendi!")
    end)
    
    btn.Activated:Connect(function()
        chestFarmEnabled = not chestFarmEnabled
        if chestFarmEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            btn.Text = "DURDUR"
            collectedChests = {}
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BAŞLAT"
            setNoclip(false)
            disableFly()
            local hum = getHumanoid()
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            collectedChests = {}
        end
    end)
    
    return gui
end

local function mainLoop()
    if not chestFarmEnabled then return end
    
    local hrp = getHumanoidRootPart()
    if not hrp then
        wait(0.5)
        return
    end
    
    if hrp.Position.Y < 2 then
        hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 30, 0))
        wait(0.05)
    end
    
    local chest = getBestChest()
    if not chest then
        wait(0.3)
        return
    end
    
    local success = flyTo(chest.position)
    if not success then
        wait(0.2)
        return
    end
    
    local grabbed = interactWithChest(chest)
    if grabbed then
        print("✅ " .. chest.name .. " toplandı!")
    else
        collectedChests[chest.id] = true
        print("⚠️ " .. chest.name .. " atlandı!")
    end
    
    wait(0.1)
end

createPanel()

task.spawn(function()
    while wait(0.3) do
        pcall(function()
            if chestFarmEnabled then
                createChestESP()
            else
                for _, obj in pairs(chestESP) do
                    pcall(function() if obj.text then obj.text:Remove() end end)
                end
                chestESP = {}
            end
        end)
    end
end)

task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST (SORUNLU ADALAR ENGELLENDI) YUKLENDI!")
print("🚫 Sualti Sehri ve Jean-Luc Adasi sandiklari otomatik atlaniyor.")
