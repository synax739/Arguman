-- DELTA EXECUTOR - CHEST DEBUG PANELİ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

print("🔍 CHEST DEBUG PANELİ BAŞLATILIYOR...")

-- ===== PANEL =====
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "ChestDebug"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 500)
frame.Position = UDim2.new(0.5, -225, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🔍 CHEST DEBUG PANELİ"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Kapat
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Bilgi alanı
local infoFrame = Instance.new("ScrollingFrame")
infoFrame.Size = UDim2.new(0.95, 0, 0, 400)
infoFrame.Position = UDim2.new(0.025, 0, 0, 50)
infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
infoFrame.BackgroundTransparency = 0.3
infoFrame.BorderSizePixel = 1
infoFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
infoFrame.Parent = frame
infoFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.95, 0, 0, 10000)
infoText.Position = UDim2.new(0.025, 0, 0, 0)
infoText.Text = "Bekleniyor..."
infoText.TextColor3 = Color3.fromRGB(200, 200, 255)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Code
infoText.TextSize = 12
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoFrame
infoText.TextWrapped = true

-- ===== CHEST BUL =====
local function findChests()
    local chests = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name, "Chest") then
            table.insert(chests, v)
        end
    end
    return chests
end

-- ===== DEBUG GÖSTER =====
local function showDebug()
    local chests = findChests()
    local info = {}
    
    info[#info + 1] = "🔍 CHEST DEBUG BİLGİLERİ"
    info[#info + 1] = "========================================"
    info[#info + 1] = "📊 TOPLAM SANDIK: " .. #chests
    info[#info + 1] = ""
    
    if #chests == 0 then
        info[#info + 1] = "❌ HİÇ SANDIK BULUNAMADI!"
        info[#info + 1] = ""
        info[#info + 1] = "📌 OLASI SEBEPLER:"
        info[#info + 1] = "1. Sandıklar spawn olmamış"
        info[#info + 1] = "2. Başka bir bölgedesin"
        info[#info + 1] = "3. Sandıklar toplanmış ve yenilenmemiş"
        info[#info + 1] = "4. Oyun modunda sandık yok"
    else
        for i, chest in pairs(chests) do
            info[#info + 1] = "📦 SANDIK #" .. i
            info[#info + 1] = "   ├─ İsim: " .. chest.Name
            info[#info + 1] = "   ├─ Konum: " .. string.format("%.1f, %.1f, %.1f", chest.Position.X, chest.Position.Y, chest.Position.Z)
            info[#info + 1] = "   ├─ Renk: " .. tostring(chest.Color)
            info[#info + 1] = "   ├─ Malzeme: " .. tostring(chest.Material)
            info[#info + 1] = "   ├─ Şeffaflık: " .. chest.Transparency
            info[#info + 1] = "   ├─ Boyut: " .. string.format("%.1f, %.1f, %.1f", chest.Size.X, chest.Size.Y, chest.Size.Z)
            info[#info + 1] = "   ├─ Parent: " .. (chest.Parent and chest.Parent.Name or "YOK")
            info[#info + 1] = "   └─ Aktif: " .. (chest.Enabled and "✅ Evet" or "❌ Hayır")
            info[#info + 1] = ""
        end
    end
    
    info[#info + 1] = "========================================"
    info[#info + 1] = "💡 BİLGİ:"
    info[#info + 1] = "- Sandıklar her 3-5 dakikada yenilenir"
    info[#info + 1] = "- Bazı sandıklar özel koşullarda açılır"
    info[#info + 1] = "- Sea 3 sandıkları daha değerlidir"
    
    local result = table.concat(info, "\n")
    infoText.Text = result
    infoFrame.CanvasSize = UDim2.new(0, 0, 0, #info * 18 + 50)
end

-- ===== OTOMATİK GÜNCELLE =====
showDebug()

-- Her 5 saniyede güncelle
spawn(function()
    while true do
        wait(5)
        showDebug()
    end
end)

-- Yeni chest eklendiğinde güncelle
Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("BasePart") and string.find(v.Name, "Chest") then
        wait(0.5)
        showDebug()
    end
end)

print("✅ CHEST DEBUG PANELİ AKTİF!")
print("📌 Sandık bilgileri otomatik güncelleniyor...")
