-- MM2 FULL + DEBUG PANEL (ESP + Gun ESP + Aimbot + Speed + Jump)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- KONFIGÜRASYON
local cfg = {
    esp_on = true,
    esp_box = true,
    esp_dist = true,
    esp_maxDist = 500,
    gun_esp = true,
    aim_on = false,
    aim_maxDist = 120,
    aim_smoothBase = 2.0,
    speed_on = false,
    speed_value = 30,
    jump_on = false,
    team_check = false
}

local jumpButton = nil
local gunESPObjects = {}
local ESPData = {}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 120, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Unknown  = Color3.fromRGB(255, 255, 0)
}

-- ==============================================
-- DEBUG PANEL (Hataları gösterir)
-- ==============================================
local debugPanel = nil
local debugErrorLabel = nil
local debugResultFrame = nil
local debugTitle = nil

local function createDebugPanel()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugPanel"
    screenGui.Parent = game.CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    debugTitle = Instance.new("TextLabel")
    debugTitle.Size = UDim2.new(1, 0, 0, 40)
    debugTitle.Position = UDim2.new(0, 0, 0, 0)
    debugTitle.BackgroundTransparency = 1
    debugTitle.Text = "🔍 DEBUG PANEL (0)"
    debugTitle.TextColor3 = Color3.new(1, 1, 1)
    debugTitle.TextSize = 18
    debugTitle.Font = Enum.Font.SourceSansBold
    debugTitle.Parent = mainFrame

    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0, 120, 0, 40)
    testBtn.Position = UDim2.new(0.5, -60, 0, 48)
    testBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    testBtn.Text = "🔍 TEST"
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.TextSize = 18
    testBtn.Font = Enum.Font.SourceSansBold
    testBtn.Parent = mainFrame
    Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 10)

    debugResultFrame = Instance.new("ScrollingFrame")
    debugResultFrame.Size = UDim2.new(1, -20, 0, 290)
    debugResultFrame.Position = UDim2.new(0, 10, 0, 100)
    debugResultFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    debugResultFrame.BackgroundTransparency = 0.85
    debugResultFrame.BorderSizePixel = 0
    debugResultFrame.Parent = mainFrame
    Instance.new("UICorner", debugResultFrame).CornerRadius = UDim.new(0, 8)

    debugResultFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    debugResultFrame.ScrollBarThickness = 4
    debugResultFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)
    debugResultFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    debugResultFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

    local resultLayout = Instance.new("UIListLayout")
    resultLayout.Padding = UDim.new(0, 3)
    resultLayout.Parent = debugResultFrame

    debugErrorLabel = Instance.new("TextLabel")
    debugErrorLabel.Size = UDim2.new(1, 0, 0, 30)
    debugErrorLabel.Position = UDim2.new(0, 0, 1, -30)
    debugErrorLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    debugErrorLabel.BackgroundTransparency = 0.3
    debugErrorLabel.Text = ""
    debugErrorLabel.TextColor3 = Color3.new(1, 1, 1)
    debugErrorLabel.TextSize = 12
    debugErrorLabel.Font = Enum.Font.SourceSans
    debugErrorLabel.Visible = false
    debugErrorLabel.Parent = mainFrame
    Instance.new("UICorner", debugErrorLabel).CornerRadius = UDim.new(0, 4)

    testBtn.Activated:Connect(function()
        scanDebug()
    end)

    debugPanel = mainFrame
    scanDebug()
end

local function clearDebugResults()
    if not debugResultFrame then return end
    for _, child in ipairs(debugResultFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function showDebugError(msg)
    if debugErrorLabel then
        debugErrorLabel.Text = "⚠️ " .. tostring(msg)
        debugErrorLabel.Visible = true
    end
end

local function scanDebug()
    clearDebugResults()
    if debugErrorLabel then debugErrorLabel.Visible = false end

    local found = {}
    local err = nil

    local success, result = pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                local parent = obj.Parent
                local isHeld = false
                if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true
                end
                if not isHeld then
                    table.insert(found, {
                        name = obj.Name,
                        class = "Tool",
                        parent = parent and parent.Name or "YOK"
                    })
                end
            end
            if obj:IsA("BasePart") and (obj.Name:find("Gun") or obj.Name:find("Drop") or obj.Name:find("Display")) then
                local parent = obj.Parent
                local isHeld = false
                if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true
                end
                if not isHeld then
                    table.insert(found, {
                        name = obj.Name,
                        class = obj.ClassName,
                        parent = parent and parent.Name or "YOK"
                    })
                end
            end
        end
    end)

    if not success then
        showDebugError(result)
        if debugTitle then debugTitle.Text = "🔍 DEBUG PANEL (HATA!)" end
        return
    end

    if #found == 0 then
        local noItem = Instance.new("TextLabel")
        noItem.Size = UDim2.new(1, 0, 0, 35)
        noItem.BackgroundTransparency = 1
        noItem.Text = "❌ Yerde silah bulunamadı!"
        noItem.TextColor3 = Color3.fromRGB(255, 200, 100)
        noItem.TextSize = 15
        noItem.Font = Enum.Font.SourceSans
        noItem.Parent = debugResultFrame
        if debugTitle then debugTitle.Text = "🔍 DEBUG PANEL (0)" end
    else
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundTransparency = 1
        header.Text = "🔫 " .. #found .. " adet bulundu:"
        header.TextColor3 = Color3.fromRGB(100, 255, 100)
        header.TextSize = 14
        header.Font = Enum.Font.SourceSansBold
        header.Parent = debugResultFrame

        for i, item in ipairs(found) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 22)
            label.BackgroundTransparency = 1
            label.Text = i .. ". " .. item.name .. " (" .. item.class .. ")"
            label.Text = label.Text .. " | " .. item.parent
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 11
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = debugResultFrame
        end

        if debugTitle then debugTitle.Text = "🔍 DEBUG PANEL (" .. #found .. ")" end
    end
end

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

-- ==============================================
-- DRAWING FONKSİYONLARI
-- ==============================================
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
    local my = LocalPlayer.Character
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local role = getPlayerRole(plr)
        if cfg.team_check and role == getPlayerRole(LocalPlayer) then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
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

        if not cfg.esp_on then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
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
        if dist > cfg.esp_maxDist then
            if ESPData[plr] then for _, v in pairs(ESPData[plr]) do v.Visible = false end end
            continue
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
-- GUN ESP (Yerdeki GunDrop)
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
            local isHeld = false
            local parent = obj.Parent
            if parent then
                if parent:IsA("Tool") then
                    local toolParent = parent.Parent
                    if toolParent and toolParent:IsA("Model") and toolParent:FindFirstChild("Humanoid") then
                        isHeld = true
                    end
                end
                if parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true
                end
            end
            
            if not isHeld then
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
end

-- ==============================================
-- ŞERİF AIMBOT
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
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or getPlayerRole(plr) ~= "Murderer" then continue end
        local char = plr.Character
        if not char then continue end
        local head, hrp = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
        if not (head or hrp) then continue end
        local targetPos = head and head.Position or hrp.Position
        local dist = (myPos - targetPos).Magnitude
        if dist < bestDist then bestDist = dist best = plr end
    end
    return best
end

local function aimAt(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local head, hrp = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
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
    if not cfg.aim_on or getPlayerRole(LocalPlayer) ~= "Sheriff" or not hasGun() then return end
    local target = getClosestMurderer()
    if target then aimAt(target) end
end

-- ==============================================
-- SPEED HACK
-- ==============================================
local function applySpeed()
    if LocalPlayer.Character and cfg.speed_on then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = cfg.speed_value end
    end
end
LocalPlayer.CharacterAdded:Connect(function() if cfg.speed_on then wait(0.2) applySpeed() end end)

-- ==============================================
-- ZIPLAMA BUTONU
-- ==============================================
local function createJumpButton()
    if jumpButton then jumpButton:Destroy() end
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "JumpButtonGui"

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 80, 0, 80)
