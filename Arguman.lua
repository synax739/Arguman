-- BLOX FRUITS AUTO CHEST (HIZLI + SANDIKLARI TAMAMEN UNUT)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local chestESP = {}
local collectedChests = {} -- Toplanan sandıkların ID'si

local cfg = {
    flySpeed = 200,
    flyHeight = 45,
    prioritizeValue = false,
    checkInterval = 0.1,
    rotationSpeed = 2,
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
                if not isChestValid(obj) then
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
    
    -- En yakın sandığı bul (hızlı toplama için)
    table.sort(chests, function(a, b) return a.distance < b.distance end)
    return chests[1]
end

local function flyTo(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    enableWalkOnWater()
    setNoclip(true)
    
    hum.PlatformStand = true
    hum.Sit = false
    
    local targetWithHeight = Vector3.new(targetPos.X, targetPos.Y + cfg.flyHeight, targetPos.Z)
    local distance = (targetWithHeight - hrp.Position).Magnitude
    
    -- DOĞRUDAN IŞINLAN (hızlı)
    if distance > 50 then
        local steps = math.min(math.floor(distance / 80), 3)
        for i = 1, steps do
            if not chestFarmEnabled then return false end
            local stepPos = hrp.Position + (targetWithHeight - hrp.Position).Unit * 80
            hrp.CFrame = CFrame.new(stepPos)
            wait(0.01)
        end
    end
    
    -- Hızlı uçuş
    local dir = (targetWithHeight - hrp.Position).Unit
    local attempts = 0
    local currentDist = (targetWithHeight - hrp.Position).Magnitude
    while currentDist > 5 and attempts < 30 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        currentDist = (targetWithHeight - currentPos).Magnitude
        local newPos = currentPos + dir * cfg.flySpeed * 0.1
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.01)
    end
    
    -- Sandığa yaklaş (noclip kapat)
    setNoclip(false)
    local targetPosGround = Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z)
    hrp.CFrame = CFrame.new(targetPosGround)
    wait(0.05)
    return true
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 1.5, 0))
    wait(0.1)
    
    local success = false
    
    -- ClickDetector
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        success = true
    end
    
    -- ProximityPrompt
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        success = true
    end
    
    -- Tool
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        success = true
    end
    
    if success then
        local id = chest.id or tostring(chest.object)
        collectedChests[id] = true
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
        if count > 30 then break end
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                if not isChestValid(obj) then
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
    
    -- Reset butonu
    local resetBtn = Instance.new("TextButton", gui)
    resetBtn.Size = UDim2.new(0, 50, 0, 50)
    resetBtn.Position = UDim2.new(0.12, 0, 0.85, 0)
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
            enableWalkOnWater()
            collectedChests = {}
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BAŞLAT"
            setNoclip(false)
            local hum = getHumanoid()
            if hum then 
                hum.PlatformStand = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
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
    
    -- Eğer denizdeyse yukarı çık
    if hrp.Position.Y < 0 then
        hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 20, 0))
        wait(0.1)
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
        -- Toplanamadıysa da unut (takılmasın)
        local id = chest.id or tostring(chest.object)
        collectedChests[id] = true
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

print("BLOX FRUITS AUTO CHEST (HIZLI + SANDIKLARI UNUT) YUKLENDI!")
print("📦 Toplanan sandıklar tamamen unutulur.")
print("🔄 '↺' butonu ile hatırlanan sandıkları temizle.")
