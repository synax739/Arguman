-- Delta Executor için Roblox AimBot Script
-- Tek kişilik savaş oyunu için en yakın hedefe kilitlenme

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Ayarlar
local AYARLAR = {
    FOV = 150,              -- Kilitlenme açısı (piksel)
    KILIT_HIZI = 0.15,      -- Kameranın dönüş hızı
    KAFAYA_KILIT = true,    -- Kafaya kilitle
    DUVAR_ARDI = false,     -- Duvarların arkasındaki hedefleri kilitle
    TUS = Enum.KeyCode.E,   -- Açma/kapama tuşu
    MAX_MESAFE = 500        -- Maksimum hedef mesafesi
}

local aktif = true
local hedef = nil

-- En yakın oyuncuyu bul
local function EnYakinHedefiBul()
    local enYakin = nil
    local enKisaMesafe = AYARLAR.MAX_MESAFE

    for _, oyuncu in pairs(Players:GetPlayers()) do
        if oyuncu ~= LocalPlayer and oyuncu.Character then
            local karakter = oyuncu.Character
            local kok = karakter:FindFirstChild("HumanoidRootPart")
            local insan = karakter:FindFirstChildOfClass("Humanoid")

            if kok and insan and insan.Health > 0 then
                local mesafe = (kok.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if mesafe < enKisaMesafe then
                    enKisaMesafe = mesafe
                    enYakin = oyuncu
                end
            end
        end
    end
    return enYakin
end

-- Kafa pozisyonunu al
local function HedefPozisyonu(oyuncu)
    if not oyuncu or not oyuncu.Character then return nil end
    local karakter = oyuncu.Character
    local kafa = karakter:FindFirstChild("Head")
    local kok = karakter:FindFirstChild("HumanoidRootPart")

    if AYARLAR.KAFAYA_KILIT and kafa then
        return kafa.Position
    elseif kok then
        return kok.Position
    end
    return nil
end

-- Ana döngü
RunService.RenderStepped:Connect(function()
    if not aktif then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    hedef = EnYakinHedefiBul()
    if not hedef then return end

    local hedefPoz = HedefPozisyonu(hedef)
    if not hedefPoz then return end

    -- Kamerayı hedefe yönlendir
    local yeniCFrame = CFrame.new(Camera.CFrame.Position, hedefPoz)
    Camera.CFrame = Camera.CFrame:Lerp(yeniCFrame, AYARLAR.KILIT_HIZI)
end)

-- Açma/kapama
game:GetService("UserInputService").InputBegan:Connect(function(giris, islenmis)
    if islenmis then return end
    if giris.KeyCode == AYARLAR.TUS then
        aktif = not aktif
        print("[AimBot] Durum:", aktif and "AKTIF" or "KAPALI")
    end
end)

print("[AimBot] Yüklendi. Tuş:", AYARLAR.TUS.Name)
