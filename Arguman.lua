-- DELTA EXECUTOR - SPAM BOT TEMİZLEYİCİ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

print("🧹 SPAM TEMİZLEYİCİ BAŞLATILDI...")

-- ===== 1. SAHTE OYUNCULARI TEMİZLE =====
local function temizle()
    -- Tüm oyuncuları kontrol et
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                -- Bot tespiti: İsmi "Buddha_Spammer" veya benzeri
                if p.Name:match("Spammer") or p.Name:match("Buddha") or 
                   p.Name:match("Bot") or p.Name:match("spam") or
                   p.Name:match("Clone") or p.Name:match("Fake") then
                    -- Karakteri yok et
                    if char then
                        char:Destroy()
                    end
                    -- Oyuncuyu at
                    p:Kick("Spam bot temizlendi!")
                end
            end
        end
    end
    
    -- ===== 2. SAHTE OBJELERİ TEMİZLE =====
    for _, v in pairs(Workspace:GetDescendants()) do
        -- Spam objeleri
        if v:IsA("BasePart") or v:IsA("Model") then
            if v.Name:match("Spam") or v.Name:match("spam") or 
               v.Name:match("Buddha") or v.Name:match("Clone") or
               v.Name:match("Fake") or v.Name:match("Bot") then
                v:Destroy()
            end
        end
        
        -- UI Spam
        if v:IsA("ScreenGui") or v:IsA("BillboardGui") then
            if v.Name:match("Spam") or v.Name:match("spam") or
               v.Name:match("Buddha") or v.Name:match("Hack") then
                v:Destroy()
            end
        end
    end
    
    -- ===== 3. REKLAM METİNLERİNİ TEMİZLE =====
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            if v.Text:match("Every Last Drop") or v.Text:match("Granite") or
               v.Text:match("Pilepeng") or v.Text:match("Appelizer") then
                v:Destroy()
            end
        end
    end
    
    -- ===== 4. SAHTE OYUNCU LİSTESİNİ TEMİZLE =====
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player then
            if v.Name:match("Spammer") or v.Name:match("Buddha") or
               v.Name:match("Bot") or v.Name:match("spam") or
               v.Name:match("Clone") or v.Name:match("Fake") then
                v:Kick("Spam bot temizlendi!")
            end
        end
    end
end

-- ===== 5. SÜREKLİ TEMİZLİK =====
temizle()

-- Her 2 saniyede bir temizle
spawn(function()
    while true do
        wait(2)
        temizle()
    end
end)

-- Yeni eklenenleri temizle
Workspace.DescendantAdded:Connect(function(v)
    task.wait(0.1)
    if v:IsA("BasePart") or v:IsA("Model") then
        if v.Name:match("Spam") or v.Name:match("Buddha") or
           v.Name:match("Clone") or v.Name:match("Fake") or
           v.Name:match("Bot") then
            v:Destroy()
        end
    end
    if v:IsA("ScreenGui") or v:IsA("BillboardGui") then
        if v.Name:match("Spam") or v.Name:match("spam") or
           v.Name:match("Buddha") or v.Name:match("Hack") then
            v:Destroy()
        end
    end
end)

-- Yeni oyuncu gelince temizle
Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    if p ~= player then
        if p.Name:match("Spammer") or p.Name:match("Buddha") or
           p.Name:match("Bot") or p.Name:match("spam") or
           p.Name:match("Clone") or p.Name:match("Fake") then
            p:Kick("Spam bot temizlendi!")
        end
    end
end)

-- ===== 6. FPS BOOST DA EKLE =====
Lighting.Brightness = 0.3
Lighting.GlobalShadows = false
Lighting.FogEnd = 30
Lighting.Ambient = Color3.fromRGB(100, 100, 100)

-- Tüm efektleri kapat
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

print("✅ SPAM TEMİZLENDİ!")
print("📌 Oyun artık oynanabilir durumda!")
