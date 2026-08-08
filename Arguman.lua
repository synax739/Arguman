-- BLOX FRUITS AUTO CHEST (SADELEŞTİRİLMİŞ - SORUNSUZ ÇALIŞAN)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local collectedChests = {}

local cfg = {
    flySpeed = 200,
    flyHeight = 60,
    checkInterval = 0.1,
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
    
    -- NOCLIP AÇ
    setNoclip(true)
    
    -- UÇUŞ MODU
    hum.PlatformStand = true
    hum.Sit = false
    
    -- YÜKSEKTE UÇ (denizden uzak)
    local flyTarget = Vector3.new(targetPos.X, targetPos.Y + cfg.flyHeight, targetPos.Z)
    
    -- DOĞRUDAN IŞINLA (ilk adım)
    if (flyTarget - hrp.Position).Magnitude > 100 then
        hrp.CFrame = CFrame.new(flyTarget - Vector3.new(0, 20, 0))
        wait(0.05)
    end
    
    -- HIZLI UÇUŞ (son yaklaşma)
    local dir = (flyTarget - hrp.Position).Unit
    local attempts = 0
    local currentDist = (flyTarget - hrp.Position).Magnitude
    
    while currentDist > 5 and attempts < 30 do
        if not chestFarmEnabled then return false end
        local newPos = hrp.Position + dir * cfg.flySpeed * 0.08
        hrp.CFrame = CFrame.new(newPos)
        currentDist = (flyTarget - hrp.Position).Magnitude
        attempts = attempts + 1
        wait(0.01)
    end
    
    -- NOCLIP KAPAT ve SANDIĞA İN
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
    wait(0.1)
    
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
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
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
    
    -- Denizdeyse yukarı çık
    if hrp.Position.Y < 0 then
        hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 30, 0))
        wait(0.05)
    end
    
    local chest = getBestChest()
    if not chest then
        wait(0.5)
        return
    end
    
    -- Çok uzaktaki sandıkları atla (3. Deniz'de bazen çok uzak oluyor)
    if chest.distance > 2000 then
        collectedChests[chest.id] = true
        wait(0.2)
        return
    end
    
    local success = flyTo(chest.position)
    if not success then
        collectedChests[chest.id] = true
        wait(0.2)
        return
    end
    
    local grabbed = interactWithChest(chest)
    if not grabbed then
        collectedChests[chest.id] = true
    end
    
    wait(0.1)
end

createPanel()

task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST (SADE) YUKLENDI!")
