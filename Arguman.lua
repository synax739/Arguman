-- BLOX FRUITS AUTO CHEST (TOPLANAN SANDIKLARI HATIRLA + BEKLE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local chestESP = {}
local collectedChests = {} -- Toplanan sandıkları hatırla
local chestCooldown = {} -- Sandık yenilenme süresi

local cfg = {
    flySpeed = 120,
    flyHeight = 35,
    prioritizeValue = false,
    checkInterval = 0.15,
    rotationSpeed = 1.5,
    respawnWait = 10, -- Sandık yenilenene kadar bekleme süresi
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

local function enableWalkOnWater()
    pcall(function()
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        end
    end)
end

local function isChestAvailable(chestObj)
    if not chestObj or not chestObj.Parent then return false end
    -- Sandık hala varsa ve toplanmamışsa
    if collectedChests[chestObj] then
        local lastCollect = collectedChests[chestObj]
        if tick() - lastCollect < cfg.respawnWait then
            return false -- Hala bekleme süresinde
        else
            collectedChests[chestObj] = nil -- Süre doldu, tekrar toplanabilir
        end
    end
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
                -- Sandık mevcut ve toplanabilir mi?
                if not isChestAvailable(obj) then
                    continue
                end
                
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
    else
        table.sort(chests, function(a, b) return a.distance < b.distance end)
    end
    return chests[1]
end

local function flyTo(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    enableWalkOnWater()
    
    local distance = (targetPos - hrp.Position).Magnitude
    
    if distance < 15 then
        setNoclip(false)
        isNearChest = true
        local targetPosGround = Vector3.new(targetPos.X, targetPos.Y + 2.5, targetPos.Z)
        hrp.CFrame = CFrame.new(targetPosGround)
        wait(0.1)
        return true
    end
    
    isNearChest = false
    setNoclip(true)
    
    hum.PlatformStand = true
    hum.Sit = false
    
    local targetWithHeight = Vector3.new(targetPos.X, targetPos.Y + cfg.flyHeight, targetPos.Z)
    local dir = (targetWithHeight - hrp.Position).Unit
    local speed = cfg.flySpeed
    
    if distance > 100 then
        local steps = math.min(math.floor(distance / 60), 4)
        for i = 1, steps do
            if not chestFarmEnabled then return false end
            local stepPos = hrp.Position + dir * 60
            hrp.CFrame = CFrame.new(stepPos)
            wait(0.02)
        end
    end
    
    local attempts = 0
    local currentDist = (targetWithHeight - hrp.Position).Magnitude
    while currentDist > 10 and attempts < 40 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        currentDist = (targetWithHeight - currentPos).Magnitude
        local newPos = currentPos + dir * speed * 0.12
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.02)
    end
    
    setNoclip(false)
    isNearChest = true
    
    local targetPosGround = Vector3.new(targetPos.X, targetPos.Y + 2.5, targetPos.Z)
    hrp.CFrame = CFrame.new(targetPosGround)
    wait(0.1)
    return true
end

local function autoRotate()
    local hrp = getHumanoidRootPart()
    if not hrp then return end
    
    local hum = getHumanoid()
    if hum then
        hum.AutoRotate = true
    end
    
    local currentCF = hrp.CFrame
    local newCF = currentCF * CFrame.Angles(0, math.rad(cfg.rotationSpeed), 0)
    hrp.CFrame = newCF
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    local chestPos = chest.position
    hrp.CFrame = CFrame.new(chestPos + Vector3.new(0, 1.5, 0))
    wait(0.15)
    
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        wait(0.2)
        -- Sandığı toplanmış olarak işaretle
        collectedChests[chest.object] = tick()
        return true
    end
    
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        wait(0.2)
        collectedChests[chest.object] = tick()
        return true
    end
    
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        wait(0.1)
        collectedChests[chest.object] = tick()
        return true
    end
    
    return false
end

local function createChestESP()
    for _, obj in pairs(chestESP) do
        pcall(function() 
            if obj.text then obj.text:Remove() end
        end)
    end
    chestESP = {}
    
    if not chestFarmEnabled then return end
    
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if count > 25 then break end
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                -- Sadece toplanabilir sandıkları göster
                if not isChestAvailable(obj) then
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
            enableWalkOnWater()
            -- Eski sandık listesini temizle
            collectedChests = {}
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BAŞLAT"
            setNoclip(false)
            isNearChest = false
            local hum = getHumanoid()
            if hum then 
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                hum.AutoRotate = true
            end
        end
    end)
    
    return gui
end

local function mainLoop()
    if not chestFarmEnabled then return end
    
    local hrp = getHumanoidRootPart()
    if not hrp then
        wait(1)
        return
    end
    
    local chest = getBestChest()
    if not chest then
        autoRotate()
        wait(0.5)
        return
    end
    
    currentTarget = chest
    local success = flyTo(chest.position)
    if not success then
        wait(0.3)
        return
    end
    
    local grabbed = interactWithChest(chest)
    if grabbed then
        print("✅ " .. chest.name .. " toplandı! " .. cfg.respawnWait .. " saniye bekleniyor...")
    else
        print("⚠️ " .. chest.name .. " toplanamadı!")
    end
    
    wait(0.2)
end

createPanel()

task.spawn(function()
    while wait(0.5) do
        pcall(function()
            if chestFarmEnabled then
                createChestESP()
                enableWalkOnWater()
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

task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST (TOPLANAN SANDIKLARI HATIRLA) YUKLENDI!")
print("📦 Toplanan sandıklar " .. cfg.respawnWait .. " saniye boyunca hatirlanacak.")
