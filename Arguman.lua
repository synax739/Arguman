-- GUN ESP + OYUNCU ESP + ŞERİF AIM (Aimbot)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cfg = { 
    gun_esp = true,
    esp_on = true,
    esp_box = true,
    esp_dist = true,
    aim_on = false,           -- YENİ
    aim_maxDist = 120,
    aim_smoothBase = 2.0
}

local gunESPObjects = {}
local ESPData = {}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 120, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Unknown  = Color3.fromRGB(255, 255, 0)
}

-- ==============================================
-- ROL TESPİTİ
-- ==============================================
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
    local roleObj = plr:FindFirstChild("Role") or plr:FindFirstChild("PlayerRole")
    if roleObj and roleObj:IsA("StringValue") then
        local roleName = roleObj.Value
        if roleName == "Murderer" or roleName == "Killer" then return "Murderer" end
        if roleName == "Sheriff" or roleName == "Hero" then return "Sheriff" end
        if roleName == "Innocent" or roleName == "Civilian" then return "Innocent" end
    end
    return "Innocent"
end

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

local function isInFront(pos)
    local camPos = Camera.CFrame.Position
    return Camera.CFrame.LookVector:Dot((pos - camPos).Unit) > 0
end

-- ==============================================
-- OYUNCU ESP
-- ==============================================
local function createESP(plr)
    local d = {}
    d.box = newDrawing("Square")
    if d.box then d.box.Thickness = 2 d.box.Filled = false end
    d.dist = newDrawing("Text")
    if d.dist then d.dist.Size = 13 d.dist.Center = true d.dist.Outline = true d.dist.Color = Color3.new(1,1,1) end
    d.role = newDrawing("Text")
    if d.role then d.role.Size = 12 d.role.Center = true d.role.Outline = true end
    ESPData[plr] = d
end

local function removeESP(plr)
    local d = ESPData[plr]
    if not d then return end
    for _, v in pairs(d) do pcall(function() v:Remove() end) end
    ESPData[plr] = nil
end

local function getBox(character)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil end
    local top = head and (head.Position + Vector3.new(0, 1.5, 0)) or (hrp.Position + Vector3.new(0, 2.5, 0))
    local bottom = hrp.Position - Vector3.new(0, 3, 0)
    local ts, on1 = Camera:WorldToViewportPoint(top)
    local bs, on2 = Camera:WorldToViewportPoint(bottom)
    if not on1 and not on2 then return nil end
    local h = math.abs(ts.Y - bs.Y)
    local w = h * 0.5
    local cx = (ts.X + bs.X) / 2
    return {
        pos = Vector2.new(cx - w/2, math.min(ts.Y, bs.Y)),
        size = Vector2.new(w, h),
        top = Vector2.new(cx, math.min(ts.Y, bs.Y)),
        bottom = Vector2.new(cx, math.min(ts.Y, bs.Y) + h)
    }
end

local function updateESP()
    if not cfg.esp_on then
        for plr, d in pairs(ESPData) do
            for _, v in pairs(d) do v.Visible = false end
        end
        return
    end

    local my = LocalPlayer.Character
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local role = getPlayerRole(plr)
        local char = plr.Character
        if not char then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            if ESPData[plr] then removeESP(plr) end
            continue
        end

        if not isInFront(hrp.Position) then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        local dist = 0
        if my and my:FindFirstChild("HumanoidRootPart") then
            dist = (my.HumanoidRootPart.Position - hrp.Position).Magnitude
        end

        if not ESPData[plr] then createESP(plr) end
        local d = ESPData[plr]
        if not d then continue end
        local box = getBox(char)
        if not box then for _, v in pairs(d) do v.Visible = false end continue end

        local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown
        if cfg.esp_box and d.box then
            d.box.Visible = true d.box.Position = box.pos d.box.Size = box.size d.box.Color = color
        end
        if cfg.esp_dist and d.dist then
            d.dist.Visible = true d.dist.Text = math.floor(dist) .. "m" d.dist.Position = box.bottom + Vector2.new(0, 2)
        end
        if d.role then
            d.role.Visible = true d.role.Text = role d.role.Color = color d.role.Position = box.top - Vector2.new(0, 15)
        end
    end
end

-- ==============================================
-- GUN ESP
-- ==============================================
local function updateGunESP()
    if not cfg.gun_esp then
        for _, obj in pairs(gunESPObjects) do
            pcall(function() obj.box:Remove() end)
            pcall(function() obj.text:Remove() end)
            pcall(function() obj.dist:Remove() end)
        end
        gunESPObjects = {}
        return
    end

    for _, obj in pairs(gunESPObjects) do
        pcall(function() obj.box:Remove() end)
        pcall(function() obj.text:Remove() end)
        pcall(function() obj.dist:Remove() end)
    end
    gunESPObjects = {}

    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    local myPosition = myPos.Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local pos = obj.Position
            if pos ~= pos then continue end
            local dist = (myPosition - pos).Magnitude
            local distText = math.floor(dist) .. "m"
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen and isInFront(pos) then
                local box = newDrawing("Square")
                local text = newDrawing("Text")
                local distLabel = newDrawing("Text")
                
                if box then
                    box.Thickness = 2
                    box.Filled = false
                    box.Color = Color3.fromRGB(255, 200, 0)
                    box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                    box.Size = Vector2.new(40, 40)
                    box.Visible = true
                end
                
                if text then
                    text.Size = 14
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 200, 0)
                    text.Text = "🔫 SILAH"
                    text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                    text.Visible = true
                end
                
                if distLabel then
                    distLabel.Size = 12
                    distLabel.Center = true
                    distLabel.Outline = true
                    distLabel.Color = Color3.fromRGB(100, 255, 100)
                    distLabel.Text = distText
                    distLabel.Position = Vector2.new(screenPos.X, screenPos.Y + 25)
                    distLabel.Visible = true
                end
                
                gunESPObjects[obj] = {box = box, text = text, dist = distLabel}
            end
        end
    end
end

-- ==============================================
-- ŞERİF AIMBOT (YENİ)
-- ==============================================
local function hasGun()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    for _, v in ipairs(myChar:GetChildren()) do 
        if v:IsA("Tool") and v.Name == "Gun" then return true end 
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then 
        for _, v in ipairs(bp:GetChildren()) do 
            if v:IsA("Tool") and v.Name == "Gun" then return true end 
        end 
    end
    return false
end

local function getClosestMurderer()
    local best, bestDist = nil, cfg.aim_maxDist
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if getPlayerRole(plr) ~= "Murderer" then continue end
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

local function aimAt(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetPart = head or hrp
    if not targetPart then return end
    local targetPos = targetPart.Position
    local camPos = Camera.CFrame.Position
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), 1 / cfg.aim_smoothBase)
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local root = myChar.HumanoidRootPart
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        pcall(function() root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, flatTarget), 1 / cfg.aim_smoothBase) end)
    end
end

local function updateAimbot()
    if not cfg.aim_on then return end
    if getPlayerRole(LocalPlayer) ~= "Sheriff" then return end
    if not hasGun() then return end
    local target = getClosestMurderer()
    if target then aimAt(target) end
end

-- ==============================================
-- PANEL (3 BUTON)
-- ==============================================
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MM2Hack"
    
    local btn1 = Instance.new("TextButton", gui)
    btn1.Size = UDim2.new(0, 120, 0, 40)
    btn1.Position = UDim2.new(0, 10, 0, 10)
    btn1.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn1.Text = "GUN ESP: AÇIK"
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.SourceSansBold
    btn1.TextSize = 14
    Instance.new("UICorner", btn1).CornerRadius = UDim.new(0, 8)
    
    local btn2 = Instance.new("TextButton", gui)
    btn2.Size = UDim2.new(0, 120, 0, 40)
    btn2.Position = UDim2.new(0, 10, 0, 55)
    btn2.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn2.Text = "ESP: AÇIK"
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.SourceSansBold
    btn2.TextSize = 14
    Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 8)
    
    local btn3 = Instance.new("TextButton", gui)
    btn3.Size = UDim2.new(0, 120, 0, 40)
    btn3.Position = UDim2.new(0, 10, 0, 100)
    btn3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn3.Text = "ŞERİF AIM: KAPALI"
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.SourceSansBold
    btn3.TextSize = 14
    Instance.new("UICorner", btn3).CornerRadius = UDim.new(0, 8)
    
    btn1.Activated:Connect(function()
        cfg.gun_esp = not cfg.gun_esp
        btn1.Text = cfg.gun_esp and "GUN ESP: AÇIK" or "GUN ESP: KAPALI"
        btn1.BackgroundColor3 = cfg.gun_esp and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end)
    
    btn2.Activated:Connect(function()
        cfg.esp_on = not cfg.esp_on
        btn2.Text = cfg.esp_on and "ESP: AÇIK" or "ESP: KAPALI"
        btn2.BackgroundColor3 = cfg.esp_on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end)
    
    btn3.Activated:Connect(function()
        cfg.aim_on = not cfg.aim_on
        btn3.Text = cfg.aim_on and "ŞERİF AIM: AÇIK" or "ŞERİF AIM: KAPALI"
        btn3.BackgroundColor3 = cfg.aim_on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end)
end

-- ==============================================
-- BAŞLAT
-- ==============================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateESP()
        updateGunESP()
        updateAimbot()
    end)
end)

createPanel()
print("🔫 Gun ESP + Oyuncu ESP + Şerif Aim aktif!")
