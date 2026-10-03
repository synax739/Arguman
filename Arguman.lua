-- Delta Executor | Roblox Tek Kişilik Savaş Oyunu
-- Aim + Karakter Dönüşü | En Yakın Hedef | Kafaya Kilit

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
local AYARLAR = {
    KILIT_HIZI = 0.35,        -- Kamera dönüş hızı (0.1 = anında, 1.0 = yavaş)
    KARAKTER_DONUS_HIZI = 0.25, -- Karakter dönüş hızı
    KAFAYA_KILIT = true,
    TUS = Enum.KeyCode.E,
    MAKS_MESAFE = 1000
}

local aktif = true
local hedef = nil

-- En yakın geçerli hedefi bul
local function EnYakinHedefiBul()
    local enYakin = nil
    local enKisaMesafe = AYARLAR.MAKS_MESAFE
    
    if not LocalPlayer.Character then return nil end
    local benimKok = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not benimKok then return nil end

    for _, oyuncu in pairs(Players:GetPlayers()) do
        if oyuncu ~= LocalPlayer and oyuncu.Character then
            local kok = oyuncu.Character:FindFirstChild("HumanoidRootPart")
            local insan = oyuncu.Character:FindFirstChildOfClass("Humanoid")
            
            if kok and insan and insan.Health > 0 then
                local mesafe = (kok.Position - benimKok.Position).Magnitude
                if mesafe < enKisaMesafe then
                    enKisaMesafe = mesafe
                    enYakin = oyuncu
                end
            end
        end
    end
    return enYakin
end

-- Hedefin kafa pozisyonunu al
local function KafaPozisyonu(oyuncu)
    if not oyuncu or not oyuncu.Character then return nil end
    if AYARLAR.KAFAYA_KILIT then
        local kafa = oyuncu.Character:FindFirstChild("Head")
        if kafa then return kafa.Position end
    end
    local kok = oyuncu.Character:FindFirstChild("HumanoidRootPart")
    return kok and kok.Position or nil
end

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    if not aktif then return end
    if not LocalPlayer.Character then return end
    
    local benimKok = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not benimKok then return end

    -- Hedefi güncelle
    hedef = EnYakinHedefiBul()
    if not hedef then return end

    local hedefPoz = KafaPozisyonu(hedef)
    if not hedefPoz then return end

    -- 1) KAMERA KİLİT
    local kameraCFrame = CFrame.new(Camera.CFrame.Position, hedefPoz)
    Camera.CFrame = Camera.CFrame:Lerp(kameraCFrame, AYARLAR.KILIT_HIZI)

    -- 2) KARAKTER DÖNÜŞÜ (Aim ile birlikte karakter de hedefe döner)
    local hedefYatay = Vector3.new(hedefPoz.X, benimKok.Position.Y, hedefPoz.Z)
    local karakterCFrame = CFrame.lookAt(benimKok.Position, hedefYatay)
    benimKok.CFrame = benimKok.CFrame:Lerp(karakterCFrame, AYARLAR.KARAKTER_DONUS_HIZI)
end)

-- AÇMA/KAPAMA
UserInputService.InputBegan:Connect(function(giris, islenmis)
    if islenmis then return end
    if giris.KeyCode == AYARLAR.TUS then
        aktif = not aktif
        print("[AimBot] " .. (aktif and "AKTIF" or "KAPALI"))
    end
end)

print("[AimBot] Yüklendi | " .. AYARLAR.TUS.Name .. " ile aç/kapat")