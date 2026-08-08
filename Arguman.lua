-- BLOX FRUITS AUTO CHEST (SON - SORUNSUZ ÇALIŞAN)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local collectedChests = {}
local currentTarget = nil
local stuckCounter = 0

local cfg = {
    flySpeed = 200,
    flyHeight = 60,
    checkInterval = 0.15,
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
end

local function isChestValid(chestObj)
    if not chestObj or not chestObj.Parent then return false end
    if collectedChests[tostring(chestObj)] then return false end
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
                local pos = obj.Position
                if pos == pos then
                    local dist = (myPos.Position - pos).Magnitude
                    table.insert(chests, {
                        object = obj,
                        id = tostring(obj),
                        position = pos,
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
    
    setNoclip(true)
    hum.PlatformStand = true
    hum.Sit = false
    
    local flyTarget = Vector3.new(targetPos.X, targetPos.Y + cfg.flyHeight, targetPos.Z)
    local distance = (flyTarget - hrp.Position).Magnitude
    
    -- Uzun mesafe: ışınlan
    if distance > 150 then
        local steps = math.min(math.floor(distance / 120), 4)
        for i = 1, steps do
            if not chestFarmEnabled then return false end
            local stepPos = hrp.Position + (flyTarget - hrp.Position).Unit * 120
            hrp.CFrame = CFrame.new(stepPos)
            wait(0.02)
        end
    end
    
    -- Yaklaşma uçuşu
    local dir = (flyTarget - hrp.Position).Unit
    local attempts = 0
    local currentDist = (flyTarget - hrp.Position).Magnitude
    
    while currentDist > 5 and attempts < 40 do
        if not chestFarmEnabled then return false end
        local newPos = hrp.Position + dir * cfg.flySpeed * 0.1
        hrp.CFrame = CFrame.new(newPos)
        currentDist = (flyTarget - hrp.Position).Magnitude
        attempts = attempts + 1
        wait(0.015)
    end
    
    setNoclip(false)
    local landPos = Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z)
    hrp.CFrame = CFrame.new(landPos)
    wait(0.05)
    
    hum.PlatformStand = false
    return true
end

local function interactWithChest(chest)
    if not chest or not chest.object then return false end
    
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 1.5, 0))
    wait(0.15)
    
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        collectedChests[chest.id] = true
        return true
    end
    
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        collectedChests[chest.id] = true
        return true
    end
    
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        collectedChests[chest.id] = true
        return true
    end
    
    return false
end

local function resetPosition()
    local hrp = getHumanoidRootPart()
    if not hrp then return end
    local pos = hrp.Position
    if pos.Y < 10 or pos.Y > 200 then
        hrp.CFrame = CFrame.new(pos.X, 50, pos.Z)
        wait(0.1)
    end
end

local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 150, 0, 100)
    mainFrame.Position = UDim2.new(0, 10, 0.8, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 130, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "BAŞLAT"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local resetBtn = Instance.new("TextButton", mainFrame)
    resetBtn.Size = UDim2.new(0, 60, 0, 30)
    resetBtn.Position = UDim2.new(0, 10, 0, 55)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    resetBtn.Text = "↺ SIFIRLA"
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.TextSize = 12
    resetBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
    resetBtn.Activated:Connect(function()
        collectedChests = {}
        print("🔄 Hatırlanan sandıklar temizlendi!")
    end)
    
    local statusText = Instance.new("TextLabel", mainFrame)
    statusText.Size = UDim2.new(0, 60, 0, 30)
    statusText.Position = UDim2.new(0, 80, 0, 55)
    statusText.BackgroundTransparency = 1
    statusText.Text = "⏹"
    statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
    statusText.TextSize = 20
    statusText.Font = Enum.Font.SourceSansBold
    
    btn.Activated:Connect(function()
        chestFarmEnabled = not chestFarmEnabled
        if chestFarmEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            btn.Text = "DURDUR"
            collectedChests = {}
            statusText.Text = "▶"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BAŞLAT"
            setNoclip(false)
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
            statusText.Text = "⏹"
            statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
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
    
    -- Konum düzeltme
    resetPosition()
    
    local chest = getBestChest()
    if not chest then
        wait(1)
        return
    end
    
    -- Çok uzaktaki sandıkları atla
    if chest.distance > 3000 then
        collectedChests[chest.id] = true
        wait(0.2)
        return
    end
    
    currentTarget = chest
    local success = flyTo(chest.position)
    if not success then
        collectedChests[chest.id] = true
        wait(0.2)
        return
    end
    
    local grabbed = interactWithChest(chest)
    if not grabbed then
        collectedChests[chest.id] = true
    else
        print("✅ " .. chest.name .. " toplandı! Kalan: " .. #findChests())
    end
    
    wait(0.1)
end

createPanel()

task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST (SON) YUKLENDI!")
