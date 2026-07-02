-- MM2 SADE TARAYICI - Sadece Tool ve Gun içerenleri gösterir
-- Kaydırma çalışır, liste düzenli

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleScanner"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
mainFrame.BackgroundTransparency = 0.9
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 TARAYICI (0)"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Test butonu
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 100, 0, 35)
testBtn.Position = UDim2.new(0.5, -50, 0, 42)
testBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
testBtn.Text = "🔍 TARA"
testBtn.TextColor3 = Color3.new(1, 1, 1)
testBtn.TextSize = 16
testBtn.Font = Enum.Font.SourceSansBold
testBtn.Parent = mainFrame
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 8)

-- Sonuç listesi
local resultFrame = Instance.new("ScrollingFrame")
resultFrame.Size = UDim2.new(1, -16, 0, 300)
resultFrame.Position = UDim2.new(0, 8, 0, 85)
resultFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
resultFrame.BackgroundTransparency = 0.8
resultFrame.BorderSizePixel = 0
resultFrame.Parent = mainFrame
Instance.new("UICorner", resultFrame).CornerRadius = UDim.new(0, 8)

local resultLayout = Instance.new("UIListLayout")
resultLayout.Padding = UDim.new(0, 3)
resultLayout.Parent = resultFrame

local function clearResults()
    for _, child in ipairs(resultFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function scan()
    clearResults()
    
    local tools = {}
    local gunParts = {}
    
    -- 1. Tüm Tool'ları bul
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local parent = obj.Parent
            local isHeld = false
            if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                isHeld = true
            end
            if not isHeld then
                table.insert(tools, {
                    name = obj.Name,
                    parent = parent and parent.Name or "YOK",
                    hasHandle = obj:FindFirstChild("Handle") ~= nil
                })
            end
        end
    end
    
    -- 2. İsminde "gun" geçen BasePart'ları bul (Tool değilse)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("gun") or name:find("silah") or name:find("sheriff") or name:find("pistol") then
                local parent = obj.Parent
                local isHeld = false
                if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true
                end
                if not isHeld then
                    table.insert(gunParts, {
                        name = obj.Name,
                        class = obj.ClassName,
                        parent = parent and parent.Name or "YOK"
                    })
                end
            end
        end
    end
    
    -- Sonuçları göster
    local total = #tools + #gunParts
    title.Text = "🔍 TARAYICI (" .. total .. ")"
    
    if total == 0 then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.Text = "❌ Yerde silah yok"
        label.TextColor3 = Color3.fromRGB(255, 200, 100)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSans
        label.Parent = resultFrame
        return
    end
    
    -- Tools
    if #tools > 0 then
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Text = "🔫 TOOL (" .. #tools .. ")"
        header.TextColor3 = Color3.fromRGB(100, 255, 200)
        header.TextSize = 13
        header.Font = Enum.Font.SourceSansBold
        header.Parent = resultFrame
        
        for _, t in ipairs(tools) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = "  " .. t.name .. " | " .. t.parent
            if t.hasHandle then
                label.Text = label.Text .. " ✅"
            end
            label.TextColor3 = Color3.fromRGB(220, 220, 255)
            label.TextSize = 11
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = resultFrame
        end
    end
    
    -- Gun Parts
    if #gunParts > 0 then
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Text = "📦 GUN PARÇALARI (" .. #gunParts .. ")"
        header.TextColor3 = Color3.fromRGB(255, 200, 100)
        header.TextSize = 13
        header.Font = Enum.Font.SourceSansBold
        header.Parent = resultFrame
        
        for _, p in ipairs(gunParts) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = "  " .. p.name .. " (" .. p.class .. ") | " .. p.parent
            label.TextColor3 = Color3.fromRGB(255, 220, 180)
            label.TextSize = 11
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = resultFrame
        end
    end
end

testBtn.MouseButton1Click:Connect(function()
    scan()
end)

-- Otomatik tarama
wait(0.5)
scan()

print("🔍 Tarayıcı aktif! 'TARA' butonuna bas.")
