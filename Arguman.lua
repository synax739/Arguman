-- DELTA EXECUTOR - SİS BEYAZLIK TEMİZLEYİCİ + FPS BOOST
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera

print("🌫️ SİS VE BEYAZLIK TEMİZLENİYOR...")

-- ===== 1. SİS VE IŞIK AYARLARI (GÖRÜŞ AÇ) =====
Lighting.Brightness = 1
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000  -- Sis sonsuza kadar uzak
Lighting.FogStart = 0     -- Sis başlangıcı 0
Lighting.Ambient = Color3.fromRGB(255, 255, 255)  -- Beyazlığı azalt
Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.EnvironmentSpecularScale = 0.5

-- SİS RENGİNİ SİYAH YAP (beyazlığı önler)
Lighting.FogColor = Color3.fromRGB(0, 0, 0)

-- ZAMAN AYARI (gündüz yap)
Lighting.ClockTime = 12
Lighting.GeographicLatitude = 0

-- TÜM IŞIK EFEKTLERİNİ KAPAT
for _, v in pairs(Lighting:GetChildren()) do
    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or 
       v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or
       v:IsA("Atmosphere") then
        v.Enabled = false
        v:Destroy()
    end
end

-- ===== 2. ATMOSFERİ SIFIRLA =====
local function clearAtmosphere()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Atmosphere") then
            v.Enabled = false
            v:Destroy()
        end
        if v:IsA("BlurEffect") then
            v.Enabled = false
            v:Destroy()
        end
        if v:IsA("SunRaysEffect") then
            v.Enabled = false
            v:Destroy()
        end
        if v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
            v:Destroy()
        end
    end
end

clearAtmosphere()

-- ===== 3. KAMERA AYARI =====
Camera.FieldOfView = 100  -- Daha geniş görüş

-- ===== 4. BEYAZ OBJELERİ TEMİZLE =====
local function fixWhiteObjects()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            -- Beyaz renkli objeleri doğal renge çevir
            if v.Color == Color3.fromRGB(255, 255, 255) or 
               v.Color == Color3.fromRGB(200, 200, 200) then
                v.Color = Color3.fromRGB(150, 150, 150)
            end
            -- Şeffaflığı sıfırla
            if v.Transparency > 0.5 then
                v.Transparency = 0.3
            end
        end
    end
end

fixWhiteObjects()

-- ===== 5. SÜREKLİ TEMİZLİK =====
spawn(function()
    while true do
        wait(2)
        -- Sis ayarlarını koru
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        
        -- Beyaz objeleri temizle
        fixWhiteObjects()
        
        -- Yeni atmosferleri temizle
        clearAtmosphere()
    end
end)

-- Yeni eklenenleri temizle
Workspace.DescendantAdded:Connect(function(v)
    task.wait(0.1)
    if v:IsA("Atmosphere") or v:IsA("BlurEffect") or 
       v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
        v.Enabled = false
        v:Destroy()
    end
    if v:IsA("BasePart") then
        if v.Color == Color3.fromRGB(255, 255, 255) then
            v.Color = Color3.fromRGB(150, 150, 150)
        end
        if v.Transparency > 0.5 then
            v.Transparency = 0.3
        end
    end
end)

-- ===== 6. FPS BOOST =====
-- Efektleri kapat
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or
       v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("PointLight") then
        v.Enabled = false
        v:Destroy()
    end
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    end
end

-- ===== 7. KARAKTER HIZI =====
local function speed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 22
            hum.JumpPower = 60
        end
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.3)
    speed()
end)

RunService.RenderStepped:Connect(speed)

print("✅ SİS VE BEYAZLIK TEMİZLENDİ!")
print("📌 Görüş açıldı, FPS arttı!")
