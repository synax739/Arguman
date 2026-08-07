-- DELTA EXECUTOR - AUTO CHEST TOPLAMA
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("📦 AUTO CHEST TOPLAMA BAŞLATILDI...")

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

-- ===== EN YAKIN SANDIĞI BUL =====
local function findNearestChest()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local pos = char.HumanoidRootPart.Position
    local nearest = nil
    local dist = math.huge
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:match("Chest") then
            local d = (v.Position - pos).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end
    
    return nearest, dist
end

-- ===== SANDIK TOPLAMA =====
local function collectChests()
    while true do
        local chest, dist = findNearestChest()
        
        if chest then
            print("📦 Sandık bulundu! Mesafe: " .. math.floor(dist))
            
            -- Sandığa ışınlan
            teleport(chest.Position + Vector3.new(0, 3, 0))
            wait(0.5)
            
            -- Sandığa tıkla (otomatik topla)
            local char = getChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(chest.Position)
            end
            
            wait(1)
        else
            print("❌ Sandık bulunamadı, bekleniyor...")
            wait(3)
        end
        
        wait(1)
    end
end

-- ===== BAŞLAT =====
spawn(collectChests)

print("✅ AUTO CHEST TOPLAMA AKTİF!")
print("📌 En yakın sandığa gidip topluyor...")
