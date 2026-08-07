-- DELTA EXECUTOR - AUTO CHEST (BUTONSUZ)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("📦 AUTO CHEST BAŞLATILDI...")

local active = true

-- ===== KARAKTER =====
local function getChar()
    local char = player.Character
    if not char then
        player.CharacterAdded:Wait()
        char = player.Character
    end
    return char
end

-- ===== IŞINLANMA =====
local function tp(pos)
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- ===== SANDIK BUL =====
local function findChest()
    local char = getChar()
    if not char then return nil end
    
    local pos = char.HumanoidRootPart.Position
    local nearest = nil
    local dist = 9999
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name, "Chest") then
            if v.Parent and v.Parent:FindFirstChild(v.Name) then
                local d = (v.Position - pos).Magnitude
                if d < dist and d < 2000 then
                    dist = d
                    nearest = v
                end
            end
        end
    end
    
    return nearest, dist
end

-- ===== ANA DÖNGÜ =====
spawn(function()
    while active do
        local chest, dist = findChest()
        
        if chest then
            print("📦 Sandık bulundu: " .. chest.Name .. " | Mesafe: " .. math.floor(dist))
            
            -- Sandığa git
            tp(chest.Position + Vector3.new(0, 3, 0))
            wait(0.5)
            
            -- Sandığa dokun
            local char = getChar()
            if char then
                char.HumanoidRootPart.CFrame = CFrame.new(chest.Position)
            end
            
            wait(2)
            
            -- Sandık hala var mı?
            local exists = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v == chest then
                    exists = true
                    break
                end
            end
            
            if not exists then
                print("✅ Sandık toplandı!")
            end
        else
            -- Sandık yoksa bekle
            wait(2)
        end
        
        wait(0.5)
    end
end)

print("✅ AUTO CHEST ÇALIŞIYOR!")
print("📌 Sandıkları otomatik topluyor...")
