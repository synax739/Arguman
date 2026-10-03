-- DEBUG PANEL - TAKIM TESPİTİ KONTROL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function getTeamInfo(plr)
    local info = {}
    info.Name = plr.Name
    
    -- Player.Team
    if plr.Team then info.Team = plr.Team.Name else info.Team = "nil" end
    -- Player.TeamColor
    if plr.TeamColor then info.TeamColor = tostring(plr.TeamColor) else info.TeamColor = "nil" end
    -- Attributes
    local attrTeam = plr:GetAttribute("Team")
    info.AttrTeam = attrTeam and tostring(attrTeam) or "nil"
    local attrTeam2 = plr:GetAttribute("team")
    info.AttrTeam2 = attrTeam2 and tostring(attrTeam2) or "nil"
    -- Player içinde Team değeri
    local tv = plr:FindFirstChild("Team")
    if tv and tv:IsA("StringValue") then info.TeamValue = tv.Value
    elseif tv and tv:IsA("ObjectValue") and tv.Value then info.TeamValue = tv.Value.Name
    else info.TeamValue = "nil" end
    -- leaderstats
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        local t = ls:FindFirstChild("Team")
        if t then info.Leaderstats = tostring(t.Value) else info.Leaderstats = "nil" end
    else
        info.Leaderstats = "yok"
    end
    -- Karakter içinde Team
    local char = plr.Character
    if char then
        local ct = char:FindFirstChild("Team")
        if ct and ct.Value then info.CharTeam = tostring(ct.Value) else info.CharTeam = "nil" end
    else
        info.CharTeam = "karakter yok"
    end
    
    return info
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeamDebug"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 500, 0, 400)
frame.Position = UDim2.new(0.5, -250, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "🔍 TAKIM DEBUG - Bu bilgileri bana at"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(1, -10, 1, -50)
textBox.Position = UDim2.new(0, 5, 0, 40)
textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
textBox.BackgroundTransparency = 0.3
textBox.TextColor3 = Color3.fromRGB(200, 255, 200)
textBox.TextSize = 11
textBox.Font = Enum.Font.Code
textBox.Text = "Yukleniyor..."
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.BorderSizePixel = 0
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)

-- Güncelleme
local function updateDebug()
    local lines = {}
    table.insert(lines, "===== BEN =====")
    local myInfo = getTeamInfo(LocalPlayer)
    table.insert(lines, "Isim: " .. myInfo.Name)
    table.insert(lines, "Team: " .. myInfo.Team)
    table.insert(lines, "TeamColor: " .. myInfo.TeamColor)
    table.insert(lines, "Attr(Team): " .. myInfo.AttrTeam)
    table.insert(lines, "Attr(team): " .. myInfo.AttrTeam2)
    table.insert(lines, "Player.TeamValue: " .. myInfo.TeamValue)
    table.insert(lines, "leaderstats.Team: " .. myInfo.Leaderstats)
    table.insert(lines, "Char.Team: " .. myInfo.CharTeam)
    table.insert(lines, "")
    table.insert(lines, "===== DIGER OYUNCULAR =====")
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local info = getTeamInfo(plr)
            table.insert(lines, "--- " .. info.Name .. " ---")
            table.insert(lines, "Team: " .. info.Team .. " | TeamColor: " .. info.TeamColor)
            table.insert(lines, "Attr(Team): " .. info.AttrTeam .. " | Attr(team): " .. info.AttrTeam2)
            table.insert(lines, "Player.TeamValue: " .. info.TeamValue)
            table.insert(lines, "leaderstats.Team: " .. info.Leaderstats)
            table.insert(lines, "Char.Team: " .. info.CharTeam)
            table.insert(lines, "")
        end
    end
    
    textBox.Text = table.concat(lines, "\n")
end

-- Sürekli güncelle
RunService.RenderStepped:Connect(function()
    pcall(updateDebug)
end)

-- Kapatma butonu
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.Activated:Connect(function() frame.Visible = false end)

-- Açma butonu
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(1, -60, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
openBtn.Text = "🔍"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.TextSize = 20
openBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
openBtn.Activated:Connect(function() frame.Visible = not frame.Visible end)

print("✅ DEBUG PANEL YUKLENDI!")
