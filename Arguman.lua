-- // Delta Mobil – MM2: Kompakt Panel + ESP + Gelişmiş Aimbot + Dropped Gun

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cfg = {
    esp_on = true,
    esp_box = true,
    esp_dist = true,
    esp_role = true,
    esp_maxDist = 500,
    aim_on = false,
    aim_maxDist = 150,
    speed_on = false,
    speed_value = 30,
    jump_on = false,
    dropped_esp = true,
    team_check = false
}

local droppedGunESP = {}
local ESPData = {}
local jumpButton = nil

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
    local backpack = plr:FindFirstChild("Backpack")
    
    local roleObj = plr:FindFirstChild("Role")
    if roleObj and roleObj:IsA("StringValue") then
        local r = roleObj.Value
        if r == "Murderer" or r == "Killer" then return "Murderer"
        elseif r == "Sheriff" or r == "Hero" then return "Sheriff"
        elseif r == "Innocent" or r == "Civilian" then return "Innocent"
        end
    end

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name
                if name == "Knife" or name == "Murderer" or name == "Killer" then return "Murderer" end
                if name == "Gun" or name == "Sheriff" or name == "Revolver" or name == "Pistol" then return "Sheriff" end
            end
        end
    end

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name
                if name == "Knife" or name == "MurdererWeapon" then return "Murderer" end
                if name == "Gun" or name == "SheriffWeapon" then return "Sheriff" end
            end
        end
        if char:FindFirstChild("Murderer") or char:FindFirstChild("Killer") then return "Murderer" end
        if char:FindFirstChild("Sheriff") or char:FindFirstChild("Hero") then return "Sheriff" end
    end

    return "Innocent"
end

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

-- ==============================================
-- ESP
-- ==============================================
local function createESP(plr)
    local d = {}
    d.box = newDrawing("Square")
    if d.box then d.box.Thickness = 2 d.box.Filled = false d.box.Visible = false end
    d.dist = newDrawing("Text")
    if d.dist then d.dist.Size = 13 d.dist.Center = true d.dist.Outline = true d.dist.Visible = false end
    d.role = newDrawing("Text")
    if d.role then d.role.Size = 12 d.role.Center = true d.role.Outline = true d.role.Visible = false end
    ESPData[plr] = d
end

local function removeESP(plr)
    local d = ESPData[plr]
    if d then
        for _, v in pairs(d) do pcall(function() v:Remove() end) end
        ESPData[plr] = nil
    end
end

-- ==============================================
-- AIMBOT (Anlık, sapmasız)
-- ==============================================
local function hasGun()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    for _, v in ipairs(myChar:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end end
    return false
end

local function getClosestMurderer()
    local best, bestDist = nil, cfg.aim_maxDist
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    if myPos ~= myPos then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if getPlayerRole(plr) ~= "Murderer" then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local pos = hrp.Position
        if pos ~= pos then continue end
        local dist = (myPos - pos).Magnitude
        if dist < bestDist then bestDist = dist best = plr end
    end
    return best
end

local function aimAt(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Hedef pozisyonu: Gövde ortası
    local targetPos = hrp.Position + Vector3.new(0, 1, 0)
    if targetPos ~= targetPos then return end
    
    local camPos = Camera.CFrame.Position
    if camPos ~= camPos then return end
    
    -- Anında kilitlenme (Lerp yok, direkt CFrame)
    pcall(function()
        Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    end)

    -- Karakteri de yatayda döndür
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local root = myChar.HumanoidRootPart
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        if flatTarget ~= flatTarget then return end
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        pcall(function()
            root.CFrame = CFrame.lookAt(root.Position, flatTarget)
        end)
    end
end

-- ==============================================
-- SPEED HACK
-- ==============================================
local function applySpeed()
    pcall(function()
        if LocalPlayer.Character and cfg.speed_on then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = cfg.speed_value end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function() if cfg.speed_on then wait(0.2) applySpeed() end end)

-- ==============================================
-- ZIPLAMA BUTONU
-- ==============================================
local function createJumpButton()
    if jumpButton then jumpButton:Destroy() end
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "JumpBtn"

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(1, -65, 0.8, -25)
    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    btn.BackgroundTransparency = 0.4
    btn.Text = "⬆"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 22
    btn.Visible = cfg.jump_on
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    btn.Activated:Connect(function()
        if not cfg.jump_on then return end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            hum.JumpPower = 16
            if hrp.Position.Y < 5000 then
                local vel = hrp.Velocity
                if vel ~= vel then vel = Vector3.zero end
                hrp.Velocity = Vector3.new(vel.X, 50, vel.Z)
            end
            if hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
        end)
    end)

    jumpButton = btn
end

-- ==============================================
-- KOMPAKT PANEL (Küçük, sürüklenebilir)
-- ==============================================
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MM2Mini"

    -- Açma butonu (küçük yuvarlak)
    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 30, 0, 30)
    openBtn.Position = UDim2.new(1, -40, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    openBtn.Text = "⚙"
    openBtn.TextColor3 = Color3.new(1,1,1)
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.TextSize = 16
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    -- Kompakt panel
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 160, 0, 110)
    panel.Position = UDim2.new(1, -170, 0, 50)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    panel.Visible = false
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

    -- Sürükleme
    local drag, dragStart, startPos = false, nil, nil
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true dragStart = input.Position startPos = panel.Position
        end
    end)
    panel.InputEnded:Connect(function() drag = false end)
    panel.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local function addToggle(yPos, name, default, callback)
        local btn = Instance.new("TextButton", panel)
        btn.Size = UDim2.new(1, -10, 0, 22)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        btn.Text = name .. ": " .. (default and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 11
        local toggled = default
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = name .. ": " .. (toggled and "ON" or "OFF")
            btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
            callback(toggled)
        end)
    end

    addToggle(3, "ESP", cfg.esp_on, function(v) cfg.esp_on = v end)
    addToggle(28, "Dropped Gun", cfg.dropped_esp, function(v) cfg.dropped_esp = v end)
    addToggle(53, "Şerif Aim", cfg.aim_on, function(v) cfg.aim_on = v end)
    addToggle(78, "Speed", cfg.speed_on, function(v)
        cfg.speed_on = v
        if v then applySpeed() else pcall(function() if LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end end end) end
    end)

    openBtn.Activated:Connect(function()
        panel.Visible = not panel.Visible
    end)
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
RunService.RenderStepped:Connect(function()
    local my = LocalPlayer.Character

    -- OYUNCU ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then removeESP(plr) continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then removeESP(plr) continue end

        if not cfg.esp_on then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        local top = (head and head.Position or hrp.Position) + Vector3.new(0, 2, 0)
        local bottom = hrp.Position - Vector3.new(0, 3, 0)
        local ts, on1 = Camera:WorldToViewportPoint(top)
        local bs, on2 = Camera:WorldToViewportPoint(bottom)
        if not on1 and not on2 then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        local dist = (my and my:FindFirstChild("HumanoidRootPart") and (my.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
        if dist > cfg.esp_maxDist then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
        end

        if not ESPData[plr] then createESP(plr) end
        local d = ESPData[plr]
        if not d then continue end

        local h = math.abs(ts.Y - bs.Y)
        local w = h * 0.5
        local cx = (ts.X + bs.X) / 2
        local x = cx - w/2
        local y = math.min(ts.Y, bs.Y)

        local role = getPlayerRole(plr)
        local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown

        if cfg.esp_box and d.box then
            d.box.Visible = true d.box.Position = Vector2.new(x, y) d.box.Size = Vector2.new(w, h) d.box.Color = color
        else
            if d.box then d.box.Visible = false end
        end
        if cfg.esp_dist and d.dist then
            d.dist.Visible = true d.dist.Text = math.floor(dist) .. "m" d.dist.Color = color d.dist.Position = Vector2.new(cx, y + h + 2)
        else
            if d.dist then d.dist.Visible = false end
        end
        if cfg.esp_role and d.role then
            d.role.Visible = true d.role.Text = role d.role.Color = color d.role.Position = Vector2.new(cx, y - 15)
        else
            if d.role then d.role.Visible = false end
        end
    end

    -- DROPPED GUN ESP (her kare workspace'i tara)
    if cfg.dropped_esp then
        pcall(function()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and obj.Name == "Gun" then
                    local handle = obj:FindFirstChild("Handle")
                    if handle then
                        local pos = handle.Position
                        if pos ~= pos then continue end
                        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                        if onScreen then
                            if not droppedGunESP[obj] then
                                droppedGunESP[obj] = {
                                    box = newDrawing("Square"),
                                    text = newDrawing("Text")
                                }
                                if droppedGunESP[obj].box then
                                    droppedGunESP[obj].box.Thickness = 2
                                    droppedGunESP[obj].box.Filled = false
                                end
                                if droppedGunESP[obj].text then
                                    droppedGunESP[obj].text.Size = 12
                                    droppedGunESP[obj].text.Center = true
                                    droppedGunESP[obj].text.Outline = true
                                    droppedGunESP[obj].text.Color = Color3.new(1, 0.5, 0)
                                end
                            end
                            local dg = droppedGunESP[obj]
                            if dg.box then
                                dg.box.Visible = true
                                dg.box.Position = Vector2.new(screenPos.X - 10, screenPos.Y - 10)
                                dg.box.Size = Vector2.new(20, 20)
                                dg.box.Color = Color3.new(1, 0.5, 0)
                            end
                            if dg.text then
                                dg.text.Visible = true
                                dg.text.Text = "GUN"
                                dg.text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                            end
                        else
                            if droppedGunESP[obj] then
                                if droppedGunESP[obj].box then droppedGunESP[obj].box.Visible = false end
                                if droppedGunESP[obj].text then droppedGunESP[obj].text.Visible = false end
                            end
                        end
                    end
                end
            end

            for gun, drawings in pairs(droppedGunESP) do
                if not gun.Parent or not gun:FindFirstChild("Handle") then
                    if drawings.box then drawings.box:Remove() end
                    if drawings.text then drawings.text:Remove() end
                    droppedGunESP[gun] = nil
                end
            end
        end)
    else
        pcall(function()
            for gun, drawings in pairs(droppedGunESP) do
                if drawings.box then drawings.box:Remove() end
                if drawings.text then drawings.text:Remove() end
            end
            droppedGunESP = {}
        end)
    end

    -- AIMBOT (anında kilitlenme)
    if cfg.aim_on and getPlayerRole(LocalPlayer) == "Sheriff" and hasGun() then
        local target = getClosestMurderer()
        if target then aimAt(target) end
    end
end)

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

createPanel()
createJumpButton()
print("✅ MM2 Mini Panel + ESP + Dropped Gun + Aimbot + Speed + Jump aktif!")
