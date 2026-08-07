local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local chestFarmEnabled = false
local currentTarget = nil
local chestESP = {}

local cfg = {
    flySpeed = 80,
    noclip = true,
    prioritizeValue = true,
    checkInterval = 0.1,
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

local function flyTo(targetPos)
    local hrp = getHumanoidRootPart()
    local hum = getHumanoid()
    if not hrp or not hum then return false end
    
    if cfg.noclip then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
    
    hum.PlatformStand = true
    hum.Sit = false
    
    local distance = (targetPos - hrp.Position).Magnitude
    local startPos = hrp.Position
    local dir = (targetPos - startPos).Unit
    local speed = cfg.flySpeed
    
    local attempts = 0
    while distance > 5 and attempts < 100 do
        if not chestFarmEnabled then return false end
        if not getCharacter() then return false end
        
        local currentPos = hrp.Position
        distance = (targetPos - currentPos).Magnitude
        local newPos = currentPos + dir * speed * 0.1
        hrp.CFrame = CFrame.new(newPos)
        
        attempts = attempts + 1
        wait(0.05)
    end
    
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
    
    hrp.CFrame = CFrame.new(chest.position + Vector3.new(0, 2, 0))
    wait(0.2)
    
    local click = chest.object:FindFirstChildOfClass("ClickDetector")
    if click then
        fireclickdetector(click)
        wait(0.3)
        return true
    end
    
    local prompt = chest.object:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt:Activate()
        wait(0.3)
        return true
    end
    
    if chest.object:IsA("Tool") then
        chest.object.Parent = LocalPlayer.Character
        wait(0.2)
        return true
    end
    
    return false
end

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
        if obj:IsA("BasePart") and obj.Name then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("crate") then
                local pos = obj.Position
                if pos == pos then
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
    end
end

local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "AutoChest"
    gui.ResetOnSpawn = false
    
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
        wait(1)
        return
    end
    
    interactWithChest(chest)
    wait(0.5)
end

createPanel()

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

task.spawn(function()
    while wait(cfg.checkInterval) do
        pcall(mainLoop)
    end
end)

print("BLOX FRUITS AUTO CHEST YUKLENDI!")
print("Kirmizi BASLAT butonuna tikla baslat.")
