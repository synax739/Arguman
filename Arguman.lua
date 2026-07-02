-- MM2 DEBUG PANEL - Yerdeki Silahları Bul
-- Test butonuna bas, yerdeki silahları listeler

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugPanel"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.95
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 SILAH TARAYICI"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Test butonu
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 120, 0, 40)
testBtn.Position = UDim2.new(0.5, -60, 0, 50)
testBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
testBtn.Text = "🔍 TEST"
testBtn.TextColor3 = Color3.new(1, 1, 1)
testBtn.TextSize = 18
testBtn.Font = Enum.Font.SourceSansBold
testBtn.Parent = mainFrame
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 8)

-- Sonuç listesi (ScrollingFrame)
local resultFrame = Instance.new("ScrollingFrame")
resultFrame.Size = UDim2.new(1, -20, 0, 280)
resultFrame.Position = UDim2.new(0, 10, 0, 105)
resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
resultFrame.BackgroundTransparency = 0.8
resultFrame.BorderSizePixel = 0
resultFrame.Parent = mainFrame
Instance.new("UICorner", resultFrame).CornerRadius = UDim.new(0, 8)

local resultLayout = Instance.new("UIListLayout")
resultLayout.Padding = UDim.new(0, 4)
resultLayout.Parent = resultFrame

-- Silinmiş yazıları temizleme
local function clearResults()
    for _, child in ipairs(resultFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- Yerdeki silahları tara
local function scanGuns()
    clearResults()
    
    local found = 0
    local tools = {}
    
    -- workspace'teki tüm Tool'ları tara
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local parent = obj.Parent
            local isHeld = false
            
            -- Oyuncunun elinde mi?
            if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                isHeld = true
            end
            
            -- Sadece yerdekileri al
            if not isHeld then
                table.insert(tools, {
                    name = obj.Name,
                    parentName = parent and parent.Name or "YOK",
                    hasHandle = obj:FindFirstChild("Handle") ~= nil
                })
                found = found + 1
            end
        end
    end
    
    -- Sonuçları göster
    if found == 0 then
        local noGun = Instance.new("TextLabel")
        noGun.Size = UDim2.new(1, 0, 0, 30)
        noGun.BackgroundTransparency = 1
        noGun.Text = "❌ Yerde silah bulunamadı!"
        noGun.TextColor3 = Color3.fromRGB(255, 200, 100)
        noGun.TextSize = 16
        noGun.Font = Enum.Font.SourceSans
        noGun.Parent = resultFrame
    else
        -- Başlık
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.Text = "🔫 " .. found .. " adet yerde silah bulundu:"
        header.TextColor3 = Color3.fromRGB(100, 255, 100)
        header.TextSize = 16
        header.Font = Enum.Font.SourceSansBold
        header.Parent = resultFrame
        
        for i, tool in ipairs(tools) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 24)
            label.BackgroundTransparency = 1
            label.Text = i .. ". " .. tool.name .. " | Ebeveyn: " .. tool.parentName
            if tool.hasHandle then
                label.Text = label.Text .. " ✅ Handle var"
            else
                label.Text = label.Text .. " ⚠️ Handle yok"
            end
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = resultFrame
        end
    end
    
    -- Sonuç sayısını başlığa yaz
    title.Text = "🔍 SILAH TARAYICI (" .. found .. " adet)"
end

-- Butona tıklayınca tara
testBtn.MouseButton1Click:Connect(function()
    scanGuns()
end)

-- Otomatik ilk tarama
wait(0.5)
scanGuns()

print("🔍 Debug panel aktif! 'TEST' butonuna basarak yerdeki silahları tarayabilirsin.")
