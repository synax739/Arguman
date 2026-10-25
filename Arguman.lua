local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local espEnabled = true
local lockTarget = nil
local ESPData = {}

local function getCharacter(plr)
    return plr and plr.Character or nil
end

local function getHumanoidRootPart(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function isAlive(plr)
    local char = getCharacter(plr)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 or false
end

-- ===== TAKIM TESPİTİ =====
local function getPlayerTeam(plr)
    local teamAttr = plr:GetAttribute("Team")
    if teamAttr then return tostring(teamAttr) end
    return nil
end

local function isSameTeam(plr)
    local myTeam = getPlayerTeam(LocalPlayer)
    local plrTeam = getPlayerTeam(plr)
    if myTeam and plrTeam then
        return myTeam == plrTeam
    end
    return false
end

-- ===== ESP SİSTEMİ =====
local function createESP(plr)
    local d = {}
    
    -- Kutu
    d.box = Drawing.new("Square")
    d.box.Thickness = 1.5
    d.box.Filled = false
    d.box.Transparency = 1
    
    -- Can Barı Arka Planı (Siyah)
    d.hpBg = Drawing.new("Square")
    d.hpBg.Thickness = 0
    d.hpBg.Filled = true
    d.hpBg.Color = Color3.fromRGB(0, 0, 0)
    d.hpBg.Transparency = 1
    
    -- Can Barı Dolgusu (Yeşil)
    d.hpFill = Drawing.new("Square")
    d.hpFill.Thickness = 0
    d.hpFill.Filled = true
    d.hpFill.Color = Color3.fromRGB(0, 255, 0) -- Sabit Yeşil
    d.hpFill.Transparency = 1
    
    -- İsim
    d.name = Drawing.new("Text")
    d.name.Size = 12
    d.name.Center = true
    d.name.Outline = true
    d.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    -- Mesafe (Yeni)
    d.dist = Drawing.new("Text")
    d.dist.Size = 12
    d.dist.Center = true
    d.dist.Outline = true
    d.dist.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    ESPData[plr] = d
end

local function removeESP(plr)
    local d = ESPData[plr]
    if not d then return end
    for _, v in pairs(d) do
        pcall(function() v:Remove() end)
    end
    ESPData[plr] = nil
end

local function updateESP()
    if not espEnabled then
        for plr, d in pairs(ESPData) do
            for _, v in pairs(d) do v.Visible = false end
        end
        return
    end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position or Vector3.new(0,0,0)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = getCharacter(plr)
        if not char then
            if ESPData[plr] then removeESP(plr) end
            continue
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not head or not hum or hum.Health <= 0 then
            if ESPData[plr] then removeESP(plr) end
            continue
        end

        if not ESPData[plr] then createESP(plr) end
        local d = ESPData[plr]
        if not d then continue end

        -- Ekran koordinatları
        local topPos = head.Position + Vector3.new(0, 1, 0)
        local botPos = hrp.Position - Vector3.new(0, 3, 0)
        local screenPosTop, onScreenTop = Camera:WorldToViewportPoint(topPos)
        local screenPosBot, onScreenBot = Camera:WorldToViewportPoint(botPos)

        if onScreenTop or onScreenBot then
            local height = math.abs(screenPosTop.Y - screenPosBot.Y)
            local width = height * 0.55
            local x = screenPosTop.X - width / 2
            local y = screenPosTop.Y

            -- Takım ve Renk (Rakip Kırmızı, Dost Mavi)
            local isEnemy = not isSameTeam(plr)
            local color = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 150, 255)

            -- Kutu
            d.box.Visible = true
            d.box.Position = Vector2.new(x, y)
            d.box.Size = Vector2.new(width, height)
            d.box.Color = color

            -- Can Barı (Her zaman Yeşil, üstten aşağıya azalır)
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local hpHeight = height
            local hpWidth = 3
            local hpX = x - 6
            local hpY = y

            d.hpBg.Visible = true
            d.hpBg.Position = Vector2.new(hpX, hpY)
            d.hpBg.Size = Vector2.new(hpWidth, hpHeight)
            
            d.hpFill.Visible = true
            local fillHeight = hpHeight * hpPercent
            -- Can azaldıkça üstten boşalacak şekilde konumlandır
            d.hpFill.Position = Vector2.new(hpX, hpY + (hpHeight - fillHeight))
            d.hpFill.Size = Vector2.new(hpWidth, fillHeight)

            -- İsim
            d.name.Visible = true
            d.name.Text = plr.Name
            d.name.Color = color
            d.name.Position = Vector2.new(screenPosTop.X, y - 16)

            -- Mesafe
            local dist = (myPos - hrp.Position).Magnitude
            d.dist.Visible = true
            d.dist.Text = math.floor(dist) .. "m"
            d.dist.Color = color
            -- İsmin hemen altına koy (kutunun üst kısmına)
            d.dist.Position = Vector2.new(screenPosTop.X, y - 3)
            
        else
            d.box.Visible = false
            d.hpBg.Visible = false
            d.hpFill.Visible = false
            d.name.Visible = false
            d.dist.Visible = false
        end
    end
end

-- ===== AIMBOT SİSTEMİ =====
local function findClosestEnemy()
    local myHrp = getHumanoidRootPart(LocalPlayer)
    if not myHrp then return nil end

    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not isAlive(plr) then continue end
        if isSameTeam(plr) then continue end
        
        local hrp = getHumanoidRootPart(plr)
        if not hrp then continue end
        local dist = (myHrp.Position - hrp.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = plr
        end
    end
    return closest
end

local function lockOntoTarget(targetPlayer)
    if not targetPlayer then return end
    local targetHrp = getHumanoidRootPart(targetPlayer)
    if not targetHrp then return end
    local myHrp = getHumanoidRootPart(LocalPlayer)
    if not myHrp then return end
    
    local targetPos = targetHrp.Position
    local myPos = myHrp.Position
    
    local camDistance = 14
    local heightOffset = 12
    local dir = (targetPos - myPos).Unit
    local lookTarget = targetPos + Vector3.new(0, 1.5, 0)
    local camPos = myPos - dir * camDistance + Vector3.new(0, heightOffset, 0)
    
    if camPos == camPos and lookTarget == lookTarget then
        Camera.CFrame = CFrame.lookAt(camPos, lookTarget)
    end
end

-- ===== ARAYÜZ =====
local function createUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "KabilelerHack"
    gui.ResetOnSpawn = false

    -- Aimbot Butonu
    local btn = Instance.new("ImageButton", gui)
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0, 20, 0.42, -40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local outerRing = Instance.new("Frame", btn)
    outerRing.Size = UDim2.new(1, 0, 1, 0)
    outerRing.BackgroundTransparency = 1
    outerRing.BorderSizePixel = 3
    outerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", outerRing).CornerRadius = UDim.new(1, 0)

    local innerRing = Instance.new("Frame", btn)
    innerRing.Size = UDim2.new(0, 55, 0, 55)
    innerRing.Position = UDim2.new(0.5, -27.5, 0.5, -27.5)
    innerRing.BackgroundTransparency = 1
    innerRing.BorderSizePixel = 2
    innerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", innerRing).CornerRadius = UDim.new(1, 0)

    local hLine = Instance.new("Frame", btn)
    hLine.Size = UDim2.new(0, 28, 0, 2)
    hLine.Position = UDim2.new(0.5, -14, 0.5, -1)
    hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hLine.BorderSizePixel = 0

    local vLine = Instance.new("Frame", btn)
    vLine.Size = UDim2.new(0, 2, 0, 28)
    vLine.Position = UDim2.new(0.5, -1, 0.5, -14)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vLine.BorderSizePixel = 0

    local statusDot = Instance.new("Frame", btn)
    statusDot.Size = UDim2.new(0, 18, 0, 18)
    statusDot.Position = UDim2.new(0.5, -9, 0.5, -9)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusDot.BorderSizePixel = 0
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local statusText = Instance.new("TextLabel", btn)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 1, -15)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusText.TextSize = 13
    statusText.Font = Enum.Font.SourceSansBold

    local function updateAimbotButton()
        if aimbotEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            outerRing.BorderColor3 = Color3.fromRGB(0, 255, 0)
            innerRing.BorderColor3 = Color3.fromRGB(0, 255, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            hLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            vLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            outerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
            innerRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    btn.Activated:Connect(function()
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            lockTarget = findClosestEnemy()
        else
            lockTarget = nil
        end
        updateAimbotButton()
    end)
    updateAimbotButton()

    -- ESP Butonu
    local espBtn = Instance.new("TextButton", gui)
    espBtn.Size = UDim2.new(0, 100, 0, 40)
    espBtn.Position = UDim2.new(1, -110, 0, 10)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    espBtn.Text = "ESP: AÇIK"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.TextSize = 14
    espBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)
    
    espBtn.Activated:Connect(function()
        espEnabled = not espEnabled
        if espEnabled then
            espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            espBtn.Text = "ESP: AÇIK"
        else
            espBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            espBtn.Text = "ESP: KAPALI"
        end
    end)
end

-- ===== ANA DÖNGÜ =====
local function mainLoop()
    if aimbotEnabled then
        local closestEnemy = findClosestEnemy()
        if closestEnemy then
            lockTarget = closestEnemy
            lockOntoTarget(lockTarget)
        else
            lockTarget = nil
        end
    end
    updateESP()
end

Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)
createUI()

RunService.RenderStepped:Connect(function() pcall(mainLoop) end)

print("KABILELER 3v3 (CAN BARI VE MESAFE EKLENDI) YUKLENDI!")
