-- ============================================================
-- BLOX FRUITS - YERDEKİ MEYVE ESP
-- İstemci taraflı (executor / StarterPlayerScripts)
-- Buton yok. Çalıştırınca otomatik devreye girer.
-- ============================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Ayarlar
local AYAR = {
    Renk = Color3.fromRGB(0, 255, 120),      -- Meyve ismi rengi
    MesafeRengi = Color3.fromRGB(255, 255, 255), -- Mesafe yazısı rengi
    MaksimumMesafe = 10000,                   -- Bu mesafeden uzak olanları gizle
    MesafeGoster = true,
}

-- ESP etiketlerini tutacağımız klasör (CoreGui altında, oyun içinde görünmez kalsın)
local ESP_Klasor = Instance.new("Folder")
ESP_Klasor.Name = "MeyveESP_Klasor"
ESP_Klasor.Parent = game:GetService("CoreGui")

-- ============================================================
-- YARDIMCI: Bir objenin meyve olup olmadığını anlar
-- Blox Fruits'te yerdeki meyveler Model'dir, içinde "Handle"
-- ve genelde isimlerinde meyve adı geçer. Ayrıca IsBloxFruit
-- tag'i varsa kesin meyvedir.
-- ============================================================
local function meyveMi(obj)
    if not obj:IsA("Model") and not obj:IsA("Tool") then
        return false
    end

    -- Kesin sinyal: oyunun kendi tag'i
    if obj:FindFirstChild("IsBloxFruit") then
        return true
    end

    -- İsimde "_Fruit" geçiyorsa meyvedir
    if obj.Name:match("_Fruit$") or obj.Name:match("Fruit") then
        return true
    end

    -- Blox Fruits meyve modelleri genelde Handle + bir parça daha içerir
    -- ve meyve isimleri bilinen listede olur. Burada isim listesi kontrolü:
    local meyveIsimleri = {
        "Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike","Flame",
        "Falcon","Ice","Sand","Dark","Diamond","Light","Rubber","Barrier",
        "Ghost","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix",
        "Portal","Rumble","Paw","Gravity","Dough","Shadow","Venom","Control",
        "Spirit","Dragon","Leopard","Kitsune","Yeti","Gas","Blizzard","Pain","Revive"
    }
    for _, isim in ipairs(meyveIsimleri) do
        if obj.Name:find(isim) then
            return true
        end
    end

    return false
end

-- ============================================================
-- ESP OLUŞTUR
-- ============================================================
local function espOlustur(obj)
    if obj:FindFirstChild("MeyveESP") then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MeyveESP"
    billboard.Size = UDim2.new(0, 220, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = AYAR.MaksimumMesafe
    billboard.Parent = obj
    ESP_Klasor:FindFirstChild("x") -- no-op, klasör referansı için

    -- Meyve ismi
    local isimLabel = Instance.new("TextLabel")
    isimLabel.Name = "Isim"
    isimLabel.Size = UDim2.new(1, 0, 0.6, 0)
    isimLabel.BackgroundTransparency = 1
    isimLabel.Text = obj.Name:gsub("_Fruit", "")
    isimLabel.TextColor3 = AYAR.Renk
    isimLabel.TextStrokeTransparency = 0
    isimLabel.TextScaled = true
    isimLabel.Font = Enum.Font.GothamBold
    isimLabel.Parent = billboard

    -- Mesafe
    if AYAR.MesafeGoster then
        local mesafeLabel = Instance.new("TextLabel")
        mesafeLabel.Name = "Mesafe"
        mesafeLabel.Size = UDim2.new(1, 0, 0.4, 0)
        mesafeLabel.Position = UDim2.new(0, 0, 0.6, 0)
        mesafeLabel.BackgroundTransparency = 1
        mesafeLabel.TextColor3 = AYAR.MesafeRengi
        mesafeLabel.TextStrokeTransparency = 0
        mesafeLabel.TextScaled = true
        mesafeLabel.Font = Enum.Font.Gotham
        mesafeLabel.Text = "?"
        mesafeLabel.Parent = billboard
    end
end

-- ============================================================
-- ESP SİL
-- ============================================================
local function espSil(obj)
    local esp = obj:FindFirstChild("MeyveESP")
    if esp then
        esp:Destroy()
    end
end

-- ============================================================
-- ANA DÖNGÜ
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- Workspace içindeki tüm objeleri tara
    for _, obj in ipairs(Workspace:GetChildren()) do
        if meyveMi(obj) then
            espOlustur(obj)

            -- Mesafeyi güncelle
            local esp = obj:FindFirstChild("MeyveESP")
            if esp then
                local mesafeLabel = esp:FindFirstChild("Mesafe")
                if mesafeLabel then
                    local konum = obj:GetPivot().Position
                    local mesafe = (Camera.CFrame.Position - konum).Magnitude
                    mesafeLabel.Text = math.floor(mesafe) .. " stud"
                end
            end
        else
            -- Meyve değilse ve üzerinde ESP varsa temizle
            if obj:FindFirstChild("MeyveESP") then
                espSil(obj)
            end
        end
    end
end)

-- ============================================================
-- TEMİZLİK (script durdurulursa / oyundan çıkılırsa)
-- ============================================================
LocalPlayer.OnTeleport:Connect(function()
    ESP_Klasor:ClearAllChildren()
end)

game:BindToClose(function()
    ESP_Klasor:ClearAllChildren()
end)
