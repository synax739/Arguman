-- // MM2 BİLGİ TOPLAMA SCRIPTİ (Debug)
-- // Bu script, oyundaki silah mekaniklerini keşfetmek için

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("========== MM2 BİLGİ TOPLAMA BAŞLADI ==========")

-- 1. Oyuncunun elindeki tüm araçları listele
local function listTools(character)
    if not character then return end
    print("---- KARAKTERDEKİ ARAÇLAR ----")
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            print("Araç Adı:", tool.Name, "| Sınıf:", tool.ClassName)
            -- Handle var mı?
            local handle = tool:FindFirstChild("Handle")
            if handle then
                print("  Handle var, pozisyon:", handle.Position)
            end
            -- Tool içindeki diğer özellikler
            for _, child in ipairs(tool:GetChildren()) do
                if child:IsA("Script") or child:IsA("LocalScript") then
                    print("  Script bulundu:", child.Name)
                end
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    print("  RemoteEvent/Function bulundu:", child.Name)
                end
                if child:IsA("AnimationTrack") or child:IsA("Animator") then
                    print("  Animasyon bulundu:", child.Name)
                end
            end
        end
    end
end

-- 2. Karaktere araç eklendiğinde yakala
local function onCharacterAdded(character)
    print("Yeni karakter oluşturuldu!")
    listTools(character)
    
    -- Yeni araç eklendiğinde
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            print("Yeni araç eklendi:", child.Name)
            listTools(character)
            
            -- Araç kuşanıldığında (Equipped)
            child.Equipped:Connect(function()
                print("=== ARAÇ KUŞANILDI:", child.Name, "===")
                print("Aracın ebeveyni:", child.Parent and child.Parent.Name or "yok")
                print("Aracın modeli:", child:GetFullName())
                -- Handle varsa pozisyon
                local handle = child:FindFirstChild("Handle")
                if handle then
                    print("Handle pozisyonu:", handle.Position)
                end
                -- Tool içinde RemoteEvent var mı?
                for _, c in ipairs(child:GetDescendants()) do
                    if c:IsA("RemoteEvent") then
                        print("RemoteEvent bulundu:", c.Name, "| Yol:", c:GetFullName())
                    end
                    if c:IsA("RemoteFunction") then
                        print("RemoteFunction bulundu:", c.Name, "| Yol:", c:GetFullName())
                    end
                end
            end)
            
            -- Araç ateşleme (Activated) - bazı oyunlar bunu kullanır
            child.Activated:Connect(function()
                print(">>> ARAÇ TETİKLENDİ (Activated):", child.Name)
            end)
        end
    end)
end

-- 3. Yerdeki tüm Tool'ları tara (silahları bul)
local function scanWorldTools()
    print("---- YERDEKİ ARAÇLAR (TOOL) ----")
    local found = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            found = found + 1
            print("Yerdeki araç:", obj.Name, "| Sınıf:", obj.ClassName, "| Yol:", obj:GetFullName())
            -- Handle var mı?
            local handle = obj:FindFirstChild("Handle")
            if handle then
                print("  Handle var, pozisyon:", handle.Position)
            end
        end
    end
    print("Toplam", found, "adet Tool nesnesi bulundu.")
end

-- 4. Oyuncu değiştiğinde
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    onCharacterAdded(char)
end)

-- 5. Mevcut karakteri kontrol et
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- 6. Workspace'teki tüm araçları tara (bir kere)
wait(1)
scanWorldTools()

-- 7. Sürekli güncelleme (her saniye yeni araçları kontrol et)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        -- Eldeki araçları listele
        local hasGun = false
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "gun") or string.find(string.lower(tool.Name), "pistol") or string.find(string.lower(tool.Name), "revolver") or string.find(string.lower(tool.Name), "rifle") or string.find(string.lower(tool.Name), "sheriff") or string.find(string.lower(tool.Name), "knife") or string.find(string.lower(tool.Name), "murderer")) then
                if not hasGun then
                    print("[SİLAH TESPİTİ] Elde silah var:", tool.Name)
                    hasGun = true
                end
            end
        end
    end
end)

print("========== BİLGİ TOPLAMA AKTİF ==========")
print("Elinde bir silah al, ateş et, konsoldaki mesajları bana gönder.")
print("Ayrıca 'yerdeki araçlar' kısmına da bak, orada silah isimleri yazıyor.")
