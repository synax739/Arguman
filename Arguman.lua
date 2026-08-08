local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local chestFarmEnabled = false
local collectedChests = {}

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

local function goToChest(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    setNoclip(true)
    hum.PlatformStand = true
    hum.Sit = false
    
    local flyTarget = Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z)
    hrp.CFrame = CFrame.new(flyTarget)
    wait(0.1)
    
    setNoclip(false)
    hum.PlatformStand = false
    return true
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
        print("Hatırlanan sandıklar temizlendi!")
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
    
    local chest = getBestChest()
    if not chest then
        wait(1)
        return
    end
    
    local success = goToChest(chest.position)
    if not success then
        collectedChests[chest.id] = true
        wait(0.3)
        return
    end
    
    collectedChests[chest.id] = true
    wait(0.2)
end

createPanel()

task.spawn(function()
    while wait(0.15) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST YUKLENDI!")
