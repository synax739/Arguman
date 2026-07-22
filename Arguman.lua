-- DELTA EXECUTOR - MAKSİMUM FPS BOOST (TÜM EFEKTLER KAPALI)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

print("⚡ MAKSİMUM FPS BOOST BAŞLATILIYOR...")

-- ===== 1. IŞIKLANDIRMA (TAMAMEN KAPALI) =====
Lighting.Brightness = 0
Lighting.GlobalShadows = false
Lighting.FogEnd = 10
Lighting.FogStart = 0
Lighting.ClockTime = 12
Lighting.Ambient = Color3.fromRGB(50, 50, 50)
Lighting.ColorShift_Top = Color3.new(0,0,0)
Lighting.ColorShift_Bottom = Color3.new(0,0,0)
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
Lighting.ShadowSoftness = 0
Lighting.Technology = Enum.Technology.Compatibility

-- ===== 2. TÜM EFEKTLERİ KAPAT =====
local function killAllEffects()
    for _, v in pairs(Workspace:GetDescendants()) do
        -- Partiküller
        if v:IsA("ParticleEmitter") then
            v.Enabled = false
            v.Rate = 0
            v:Destroy()
        end
        -- Trail
        if v:IsA("Trail") then
            v.Enabled = false
            v:Destroy()
        end
        -- Ateş
        if v:IsA("Fire") then
            v.Enabled = false
            v:Destroy()
        end
        -- Duman
        if v:IsA("Smoke") then
            v.Enabled = false
            v:Destroy()
        end
        -- Parıltı
        if v:IsA("Sparkles") then
            v.Enabled = false
            v:Destroy()
        end
        -- Işıklar
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
            v:Destroy()
        end
        -- Bulutlar
        if v:IsA("Cloud") then
            v.Enabled = false
            v:Destroy()
        end
        -- Kırılma efektleri
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
            v:Destroy()
        end
        -- Çim ve arazi
        if v:IsA("Terrain") then
            v.WaterWaveSize = 0
            v.WaterWaveSpeed = 0
            v.WaterReflectance = 0
            v.WaterTransparency = 1
            v.Material = Enum.Material.Plastic
        end
        -- TÜM PARÇALARI SADELEŞTİR
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.Transparency = 0
            -- Şekilleri basitleştir
            if v.Shape then
                v.Shape = Enum.PartShape.Ball
            end
            -- Kırılma yok
            if v:FindFirstChild("BreakForce") then
                v.BreakForce = math.huge
            end
            if v:FindFirstChild("CanCollide") then
                v.CanCollide = true
            end
        end
        -- Modelleri sadeleştir
        if v:IsA("Model") then
            -- Gereksiz modelleri temizle
            for _, child in pairs(v:GetChildren()) do
                if child:IsA("BasePart") and child.Size.Magnitude < 0.5 then
                    child:Destroy()
                end
            end
        end
        -- Yapraklar
        if v:IsA("Leaf") then
            v:Destroy()
        end
        -- UI efektleri (bazı oyunlar)
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            v.Enabled = false
        end
    end
end

-- ===== 3. SÜREKLİ TEMİZLİK =====
killAllEffects()

-- Yeni eklenen her şeyi temizle
Workspace.DescendantAdded:Connect(function(v)
    task.wait(0.05)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or 
       v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
        v:Destroy()
    end
    if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
        v.Enabled = false
        v:Destroy()
    end
    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
        v:Destroy()
    end
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.Transparency = 0
    end
    if v:IsA("Cloud") then
        v:Destroy()
    end
end)

-- ===== 4. MESAFE AYARI =====
Workspace.CameraMinZoomDistance = 0.5
Workspace.CameraMaxZoomDistance = 150

-- ===== 5. KARAKTER HIZI =====
local function speedBoost()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 25
            hum.JumpPower = 65
            -- Animasyon hızı
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(1.5)
                end
            end
        end
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.3)
    speedBoost()
end)

RunService.RenderStepped:Connect(function()
    speedBoost()
end)

-- ===== 6. GEREKSİZ ŞEYLERİ TEMİZLE =====
-- Çöpleri temizle
RunService.Stepped:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.Magnitude < 0.3 then
            v:Destroy()
        end
    end
end)

-- ===== 7. SESLERİ KAPAT =====
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("Sound") then
        v.Volume = 0
        v.Playing = false
    end
end

print("✅ MAKSİMUM FPS BOOST AKTİF!")
print("📌 Tüm efektler, ışıklar, partiküller KAPALI")
print("📌 Şekiller basitleştirildi, FPS maksimum!")
