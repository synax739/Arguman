-- // +1 Speed Keyboard Escape | TEMİZ MOBİL PANEL
-- // Basit, Düzenli, Çalışır

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- AYARLAR
-- ==============================================
local cfg = {
    auto_win = false,
    speed_hack = false,
    speed_value = 204,
    super_jump = false,
    noclip = false,
    esp = false,
    fullbright = false,
}

-- ==============================================
-- YARDIMCI FONKSİYONLAR
-- ==============================================
local function getChar() return LocalPlayer.Character end
local function getHum() local c = getChar() if c then return c:FindFirstChildOfClass("Humanoid") end end
local function getHRP() local c = getChar() if c then return c:FindFirstChild("HumanoidRootPart") end end

-- ==============================================
-- OTOMATİK KAZANMA
-- ==============================================
local function autoWin()
    if not cfg.auto_win then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("finish")) then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                wait(0.2)
                local click = obj:FindFirstChildOfClass("ClickDetector")
                if click then fireclickdetector(click) end
            end
            break
        end
    end
end

-- ==============================================
-- HIZ AŞIMI
-- ==============================================
local function applySpeed()
    local hum = getHum()
    if hum and cfg.speed_hack then
        pcall(function() hum.WalkSpeed = cfg.speed_value end)
    end
end

-- ==============================================
-- SÜPER ZIPLAMA
-- ==============================================
local function applyJump()
    local hum = getHum()
    if hum and cfg.super_jump then
        pcall(function() hum.JumpPower = 250 end)
    end
end

-- ==============================================
-- NOCLIP
-- ==============================================
local function applyNoclip()
    local char = getChar()
    if char and cfg.noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end

-- ==============================================
-- ESP
-- ==============================================
local function applyESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hl = char:FindFirstChild("ESP_HL")
                if not hl and cfg.esp then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESP_HL"
                    hl.Parent = char
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                elseif hl and not cfg.esp then
                    hl:Destroy()
                end
            end
        end
    end
end

-- ==============================================
-- FULLBRIGHT
-- ==============================================
local function applyFullbright()
    local l = game:GetService("Lighting")
    if cfg.fullbright then
        l.Brightness = 10
        l.Ambient = Color3.fromRGB(255, 255, 255)
        l.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        l.GlobalShadows = false
    else
        l.Brightness = 2
        l.Ambient = Color3.fromRGB(0, 0, 0)
        l.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        l.GlobalShadows = true
    end
end

-- ==============================================
-- HIZ BUTONLARINA TIKLA (GUI'deki + butonları)
-- ==============================================
local function clickSpeedBtn(amount)
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ClickDetector") and v.Parent and v.Parent:IsA("BasePart") then
                if v.Parent.Name and v.Parent.Name:find(tostring(amount)) then
                    fireclickdetector(v)
                    wait(0.1)
                end
            end
            if v:IsA("TextButton") and v.Text and v.Text:find("+" .. amount) then
                v:Activate()
                wait(0.1)
            end
        end
    end)
end

-- ==============================================
-- TEMİZ PANEL
-- ==============================================
local function createPanel()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpeedPanel"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false

    -- ANA FRAME (Küçük, temiz)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 250)
    frame.Position = UDim2.new(0, 10, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    -- BAŞLIK
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚡ SPEED PANEL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.SourceSansBold
    title.BorderSizePixel = 0
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    -- SÜRÜKLEME
    local drag, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    title.InputEnded:Connect(function() drag = false end)
    title.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- TOGGLE BUTONLARI (Küçük, sade)
    local function addToggle(y, name, def, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 26)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = def and Color3.fromRGB(0, 160, 70) or Color3.fromRGB(160, 40, 40)
        btn.BackgroundTransparency = 0.15
        btn.Text = name .. (def and " ✓" or " ✗")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 0
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local toggled = def
        btn.Activated:Connect(function()
            toggled = not toggled
            btn.Text = name .. (toggled and " ✓" or " ✗")
            btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 160, 70) or Color3.fromRGB(160, 40, 40)
            cb(toggled)
        end)
    end

    -- HIZ KAYDIRICI (Küçük)
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.9, 0, 0, 16)
    speedLabel.Position = UDim2.new(0.05, 0, 0, 155)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Hız: " .. cfg.speed_value
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 10
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.Parent = frame

    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(0.9, 0, 0, 18)
    slider.Position = UDim2.new(0.05, 0, 0, 172)
    slider.Min = 20
    slider.Max = 500
    slider.Value = cfg.speed_value
    slider.Parent = frame
    slider.Changed:Connect(function()
        local v = math.floor(slider.Value)
        speedLabel.Text = "Hız: " .. v
        cfg.speed_value = v
        if cfg.speed_hack then applySpeed() end
    end)

    -- HIZ BUTONLARI (Küçük, yan yana)
    local speedBtns = {"+65K", "+150K", "+1M", "+10M"}
    for i, text in ipairs(speedBtns) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, -2, 0, 22)
        btn.Position = UDim2.new(0.05 + (i-1) * 0.23, 0, 0, 195)
        btn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 9
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderSizePixel = 0
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local amount = tonumber(text:gsub("[^%d]", "")) or 0
        btn.Activated:Connect(function()
            clickSpeedBtn(amount)
        end)
    end

    -- KAPATMA BUTONU (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -26, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    closeBtn.Activated:Connect(function()
        frame.Visible = false
    end)

    -- AÇMA BUTONU (Sağ üstte küçük)
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 30, 0, 30)
    openBtn.Position = UDim2.new(1, -40, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    openBtn.Text = "⚡"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.TextSize = 16
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.BorderSizePixel = 0
    openBtn.Parent = gui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    openBtn.Activated:Connect(function()
        frame.Visible = not frame.Visible
    end)

    -- TOGGLE'ları ekle
    addToggle(32, "Otomatik Kazan", cfg.auto_win, function(v) cfg.auto_win = v end)
    addToggle(62, "Hız Aşımı", cfg.speed_hack, function(v)
        cfg.speed_hack = v
        if v then applySpeed() else pcall(function() local h = getHum() if h then h.WalkSpeed = 16 end end) end
    end)
    addToggle(92, "Süper Zıplama", cfg.super_jump, function(v)
        cfg.super_jump = v
        applyJump()
    end)
    addToggle(122, "Noclip", cfg.noclip, function(v) cfg.noclip = v end)
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if cfg.auto_win then autoWin() end
        if cfg.speed_hack then applySpeed() end
        if cfg.super_jump then applyJump() end
        if cfg.noclip then applyNoclip() end
        if cfg.esp then applyESP() end
        if cfg.fullbright then applyFullbright() end
    end)
end)

-- ==============================================
-- BAŞLAT
-- ==============================================
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    pcall(function()
        if cfg.speed_hack then applySpeed() end
        if cfg.super_jump then applyJump() end
    end)
end)

createPanel()

print("✅ TEMİZ PANEL YÜKLENDI! Sağ üstteki ⚡ ile aç/kapat")")
