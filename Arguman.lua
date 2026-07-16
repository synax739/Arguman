-- MM2 DEBUG ARACI - Yerdeki Tüm Nesneleri Tara ve Göster

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ===== YERDEKİ NESNELERİ TARA =====
local function scanGroundObjects()
    local results = {}
    local count = 0

    -- 1. GunDrop nesneleri (BasePart)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            count = count + 1
            local pos = obj.Position
            table.insert(results, string.format("[%d] GunDrop | Pos: %.1f, %.1f, %.1f | Parent: %s",
                count, pos.X, pos.Y, pos.Z, obj.Parent and obj.Parent.Name or "nil"))
        end
    end

    -- 2. Tool nesneleri (silah olabilir)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                count = count + 1
                local pos = handle.Position
                table.insert(results, string.format("[%d] Tool: %s | Pos: %.1f, %.1f, %.1f | Parent: %s",
                    count, obj.Name, pos.X, pos.Y, pos.Z, obj.Parent and obj.Parent.Name or "nil"))
            else
                count = count + 1
                table.insert(results, string.format("[%d] Tool: %s (Handle yok) | Parent: %s",
                    count, obj.Name, obj.Parent and obj.Parent.Name or "nil"))
            end
        end
    end

    -- 3. BasePart nesneleri (genel, isminde "gun" veya "pistol" geçen)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if (name:find("gun") or name:find("pistol") or name:find("revolver") or name:find("sheriff") or name:find("weapon")) and obj.Name ~= "GunDrop" then
                count = count + 1
                local pos = obj.Position
                table.insert(results, string.format("[%d] BasePart: %s | Pos: %.1f, %.1f, %.1f | Parent: %s",
                    count, obj.Name, pos.X, pos.Y, pos.Z, obj.Parent and obj.Parent.Name or "nil"))
            end
        end
    end

    if count == 0 then
        table.insert(results, "❌ Hiç silah/nesne bulunamadı!")
    else
        table.insert(results, string.format("✅ Toplam %d nesne bulundu.", count))
    end

    return results
end

-- ===== PANEL OLUŞTUR =====
local function createDebugPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "DebugGunScanner"
    gui.ResetOnSpawn = false

    -- Ana Panel (şeffaf)
    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.new(0, 400, 0, 500)
    panel.Position = UDim2.new(0.5, -200, 0.5, -250)
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    panel.BackgroundTransparency = 0.3
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    -- Başlık
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.BackgroundTransparency = 0.5
    title.Text = "🔍 YERDEKİ NESNELER TARAYICI"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.BorderSizePixel = 0
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    -- Sürükleme
    local dragging = false
    local dragStart = nil
    local startPos = nil

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)

    title.InputEnded:Connect(function() dragging = false end)

    title.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Buton Çerçevesi
    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(1, 0, 0, 40)
    btnFrame.Position = UDim2.new(0, 0, 0, 35)
    btnFrame.BackgroundTransparency = 1

    -- Yenile Butonu
    local refreshBtn = Instance.new("TextButton", btnFrame)
    refreshBtn.Size = UDim2.new(0.45, -5, 1, -5)
    refreshBtn.Position = UDim2.new(0, 0, 0, 2)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    refreshBtn.Text = "🔄 YENİLE"
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.TextSize = 14
    refreshBtn.Font = Enum.Font.SourceSansBold
    refreshBtn.BorderSizePixel = 0
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

    -- Kopyala Butonu
    local copyBtn = Instance.new("TextButton", btnFrame)
    copyBtn.Size = UDim2.new(0.45, -5, 1, -5)
    copyBtn.Position = UDim2.new(0.55, 0, 0, 2)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    copyBtn.Text = "📋 KOPYALA"
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.TextSize = 14
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.BorderSizePixel = 0
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

    -- TextBox (sonuçları gösterir, seçilebilir)
    local textBox = Instance.new("TextBox", panel)
    textBox.Size = UDim2.new(1, -10, 1, -85)
    textBox.Position = UDim2.new(0, 5, 0, 80)
    textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    textBox.BackgroundTransparency = 0.3
    textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.SourceSans
    textBox.Text = "🔄 'YENİLE' butonuna tıkla..."
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.BorderSizePixel = 0
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)

    -- Kapatma Butonu (X)
    local closeBtn = Instance.new("TextButton", panel)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.Activated:Connect(function()
        panel.Visible = false
    end)

    -- Açma Butonu (sağ üst)
    local openBtn = Instance.new("TextButton", gui)
    openBtn.Size = UDim2.new(0, 40, 0, 40)
    openBtn.Position = UDim2.new(1, -50, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    openBtn.Text = "🔍"
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.TextSize = 20
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    openBtn.Activated:Connect(function()
        panel.Visible = not panel.Visible
    end)

    -- ===== YENİLE FONKSİYONU =====
    local function doRefresh()
        local results = scanGroundObjects()
        local fullText = table.concat(results, "\n")
        textBox.Text = fullText
        print("===== YERDEKİ NESNELER =====")
        for _, line in ipairs(results) do
            print(line)
        end
        print("===== TARAMA BİTTİ =====")
    end

    refreshBtn.Activated:Connect(doRefresh)

    -- ===== KOPYALA FONKSİYONU =====
    copyBtn.Activated:Connect(function()
        local text = textBox.Text
        if text and text ~= "" then
            -- PC'de clipboard
            if setclipboard then
                setclipboard(text)
                print("✅ Metin panoya kopyalandı!")
            else
                -- Mobil'de alternatif (TextBox seçili hale getir)
                textBox:CaptureFocus()
                textBox.SelectionStart = 0
                textBox.SelectionLength = #text
                print("✅ Metin seçildi! Şimdi kopyala yapabilirsin.")
            end
        end
    end)

    -- İlk taramayı otomatik yap
    task.wait(0.5)
    doRefresh()

    return gui
end

-- ===== BAŞLAT =====
createDebugPanel()

print("✅ DEBUG ARACI YÜKLENDİ!")
print("🔍 Sağ üstteki '🔍' butonuna tıkla paneli aç/kapat.")
print("📋 'YENİLE' ile tara, 'KOPYALA' ile metni kopyala.")
