-- // MM2 Debug - Butona basınca neler oluyor?
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ayarlar
local cfg = {
    aim_on = true,
    aim_maxDist = 120
}

-- GUI Debug Ekranı
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugScreen"
screenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0, 10, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "DEBUG LOG"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold

local log = Instance.new("TextLabel", frame)
log.Size = UDim2.new(1, -10, 0, 155)
log.Position = UDim2.new(0, 5, 0, 30)
log.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
log.Text = "Bekleniyor...\n"
log.TextColor3 = Color3.new(0, 255, 0)
log.Font = Enum.Font.SourceSans
log.TextSize = 11
log.TextWrapped = true
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top

local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.new(1, -10, 0, 25)
clearBtn.Position = UDim2.new(0, 5, 0, 190)
clearBtn.Text = "Temizle"
clearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.MouseButton1Click:Connect(function() log.Text = "" end)

local function addLog(msg)
    log.Text = log.Text .. msg .. "\n"
    local lines = log.Text:split("\n")
    if #lines > 15 then
        table.remove(lines, 1)
        log.Text = table.concat(lines, "\n")
    end
end

-- Rol tespiti
local function getPlayerRole(plr)
    local char = plr.Character
    if not char then return "Unknown" end
    local backpack = plr:FindFirstChild("Backpack") or plr
    if backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Murderer") or backpack:FindFirstChild("Killer") then
        return "Murderer"
    end
    if char:FindFirstChild("Knife") or char:FindFirstChild("MurdererWeapon") then
        return "Murderer"
    end
    if backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Sheriff") or backpack:FindFirstChild("Revolver") or backpack:FindFirstChild("Pistol") then
        return "Sheriff"
    end
    if char:FindFirstChild("Gun") or char:FindFirstChild("SheriffWeapon") then
        return "Sheriff"
    end
    return "Innocent"
end

-- En yakın katili bul
local function getClosestMurderer()
    local best = nil
    local bestDist = cfg.aim_maxDist
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        addLog("⛔ Kendi karakterim bulunamadı!")
        return nil
    end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local role = getPlayerRole(plr)
        if role ~= "Murderer" then continue end
        local char = plr.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (head or hrp) then continue end
        local targetPos = head and head.Position or hrp.Position
        local dist = (myPos - targetPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = plr
        end
    end
    return best
end

-- Debug ateş etme
local function debugShoot()
    addLog("========== TEST BAŞLADI ==========")
    
    -- 1. Aimbot açık mı?
    if not cfg.aim_on then
        addLog("❌ aim_on = false")
        return
    end
    addLog("✅ aim_on = true")

    -- 2. Rol kontrolü
    local myRole = getPlayerRole(LocalPlayer)
    addLog("👤 Benim rolüm: " .. myRole)
    if myRole == "Murderer" then
        addLog("❌ Katilim, ateş edemem!")
        return
    end

    -- 3. Hedef bul
    local target = getClosestMurderer()
    if not target then
        addLog("❌ Hedef katil bulunamadı!")
        addLog("   (Menzil: " .. cfg.aim_maxDist .. " stud)")
        return
    end
    addLog("🎯 Hedef katil: " .. target.Name)

    -- 4. Kendi karakterim
    local myChar = LocalPlayer.Character
    if not myChar then
        addLog("❌ Kendi karakterim yok!")
        return
    end

    -- 5. Silahı bul
    local tool = nil
    for _, child in ipairs(myChar:GetChildren()) do
        if child:IsA("Tool") and child.Name == "Gun" then
            tool = child
            break
        end
    end
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") and child.Name == "Gun" then
                    tool = child
                    addLog("⚠️ Silah backpack'te, elde değil!")
                    break
                end
            end
        end
    end
    if not tool then
        addLog("❌ 'Gun' silahı bulunamadı!")
        addLog("   Elimdeki/bp'deki araçlar:")
        for _, v in ipairs(myChar:GetChildren()) do
            if v:IsA("Tool") then addLog("   - " .. v.Name) end
        end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") then addLog("   - (bp) " .. v.Name) end
            end
        end
        return
    end
    addLog("🔫 Silah: " .. tool.Name)

    -- 6. Remote'u bul
    local remote = tool:FindFirstChild("Shoot")
    if not remote then
        addLog("❌ 'Shoot' Remote'i bulunamadı!")
        addLog("   Silahın içindekiler:")
        for _, v in ipairs(tool:GetChildren()) do
            addLog("   - " .. v.Name .. " (" .. v.ClassName .. ")")
        end
        return
    end
    if not remote:IsA("RemoteEvent") then
        addLog("❌ 'Shoot' bir RemoteEvent değil! Tür: " .. remote.ClassName)
        return
    end
    addLog("📡 Remote: Shoot (RemoteEvent)")

    -- 7. Hedef pozisyonu
    local targetChar = target.Character
    if not targetChar then
        addLog("❌ Hedefin karakteri yok!")
        return
    end
    local head = targetChar:FindFirstChild("Head")
    local targetPos = head and head.Position or targetChar.HumanoidRootPart.Position
    addLog("🎯 Hedef pozisyon: " .. tostring(targetPos))

    -- 8. Ateş et
    local success, err = pcall(function()
        remote:FireServer(targetPos)
    end)
    if success then
        addLog("✅ FireServer çağrıldı! Mermi gitmiş olmalı.")
    else
        addLog("❌ FireServer hatası: " .. tostring(err))
    end
    addLog("========== TEST BİTTİ ==========")
end

-- Test butonu
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 90, 0, 90)
testBtn.Position = UDim2.new(0.5, -45, 0.7, 0)
testBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
testBtn.BackgroundTransparency = 0.5
testBtn.Text = "TEST"
testBtn.TextColor3 = Color3.new(1,1,1)
testBtn.Font = Enum.Font.SourceSansBold
testBtn.TextSize = 24
testBtn.Parent = screenGui
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(1, 0)

testBtn.MouseButton1Click:Connect(function()
    debugShoot()
end)

print("🔍 Debug modu aktif! Kırmızı 'TEST' butonuna basarak ateş etmeyi dene.")
