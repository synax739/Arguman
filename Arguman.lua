-- MM2 EVRENSEL TARAYICI - Tool, Model, Part, Her Şeyi Bulur
-- Şerif ölünce yere ne düşüyorsa onu bulur

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalScanner"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 450)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.92
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔍 EVRENSEL TARAYICI"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 140, 0, 45)
testBtn.Position = UDim2.new(0.5, -70, 0, 50)
testBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
testBtn.Text = "🔍 TARA"
testBtn.TextColor3 = Color3.new(1, 1, 1)
testBtn.TextSize = 20
testBtn.Font = Enum.Font.SourceSansBold
testBtn.Parent = mainFrame
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 10)

local resultFrame = Instance.new("ScrollingFrame")
resultFrame.Size = UDim2.new(1, -20, 0, 320)
resultFrame.Position = UDim2.new(0, 10, 0, 110)
resultFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
resultFrame.BackgroundTransparency = 0.85
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

local function scanEverything()
    clearResults()
    
    local foundItems = {}
    local keywords = {"gun", "silah", "sheriff", "pistol", "revolver", "weapon", "knife", "murderer", "handle"}
    
    -- workspace'teki HER ŞEYİ tara
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local isMatch = false
        
        -- İsminde anahtar kelime var mı?
        for _, kw in ipairs(keywords) do
            if name:find(kw) then
                isMatch = true
                break
            end
        end
        
        -- Handle varsa da al (silahların genelde Handle'ı olur)
        if not isMatch and obj:IsA("BasePart") then
            local parent = obj.Parent
            if parent and parent:FindFirstChild("Handle") then
                isMatch = true
            end
        end
        
        -- Tool ise direkt al
        if obj:IsA("Tool") then
            isMatch = true
        end
        
        if isMatch then
            -- Oyuncunun elinde mi kontrol et
            local isHeld = false
            local parent = obj.Parent
            if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                isHeld = true
            end
            
            -- Sadece yerdekileri al (elindekileri alma)
            if not isHeld then
                table.insert(foundItems, {
                    name = obj.Name,
                    class = obj.ClassName,
                    parent = parent and parent.Name or "YOK",
                    position = obj:IsA("BasePart") and obj.Position or nil,
                    hasHandle = obj:FindFirstChild("Handle") ~= nil
                })
            end
        end
    end
    
    -- Sonuçları göster
    if #foundItems == 0 then
        local noItem = Instance.new("TextLabel")
        noItem.Size = UDim2.new(1, 0, 0, 35)
        noItem.BackgroundTransparency = 1
        noItem.Text = "❌ Hiçbir şey bulunamadı!"
        noItem.TextColor3 = Color3.fromRGB(255, 200, 100)
        noItem.TextSize = 18
        noItem.Font = Enum.Font.SourceSans
        noItem.Parent = resultFrame
    else
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.Text = "🔫 " .. #foundItems .. " adet nesne bulundu:"
        header.TextColor3 = Color3.fromRGB(100, 255, 100)
        header.TextSize = 15
        header.Font = Enum.Font.SourceSansBold
        header.Parent = resultFrame
        
        for i, item in ipairs(foundItems) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 22)
            label.BackgroundTransparency = 1
            local text = i .. ". " .. item.name .. " (" .. item.class .. ")"
            text = text .. " | Ebeveyn: " .. item.parent
            if item.hasHandle then
                text = text .. " ✅ Handle"
            end
            if item.position then
                text = text .. " 📍 " .. string.sub(tostring(item.position), 1, 20)
            end
            label.Text = text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 11
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = resultFrame
        end
    end
    
    title.Text = "🔍 EVRENSEL TARAYICI (" .. #foundItems .. " adet)"
end

testBtn.MouseButton1Click:Connect(function()
    scanEverything()
end)

-- Otomatik ilk tarama
wait(0.8)
scanEverything()

print("🔍 Evrensel tarayıcı aktif! 'TARA' butonuna bas, her şeyi tarar.")
