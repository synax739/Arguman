-- YERDEKİ SİLAHLARI BULMAK İÇİN TARAMA SCRIPTİ
-- Bu script oyundaki tüm nesneleri tarar ve silah olabilecekleri listeler

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("========== TARAMA BAŞLADI ==========")
print("Oyuncu:", LocalPlayer.Name)

-- 1. Önce workspace'teki tüm Tool'ları listele
print("\n--- WORKSPACE'TEKİ TÜM TOOL'LAR ---")
local toolCount = 0
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Tool") then
        toolCount = toolCount + 1
        local parent = obj.Parent
        local parentName = parent and parent.Name or "YOK"
        local parentClass = parent and parent.ClassName or "YOK"
        print(toolCount .. ". Tool Adı: " .. obj.Name)
        print("   Ebeveyn: " .. parentName .. " (" .. parentClass .. ")")
        print("   Yol: " .. obj:GetFullName())
        
        -- Handle var mı?
        local handle = obj:FindFirstChild("Handle")
        if handle then
            print("   Handle var, pozisyon: " .. tostring(handle.Position))
        else
            print("   Handle YOK!")
            -- Handle yoksa başka parçaları göster
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") then
                    print("   - Parça bulundu: " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
        
        -- Silahın bir oyuncunun elinde olup olmadığını kontrol et
        if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
            print("   >>> BİR OYUNCUNUN ELİNDE: " .. parent.Name)
        else
            print("   >>> YERDE DURUYOR veya BAŞKA BİR YERDE")
        end
        print("")
    end
end
print("Toplam " .. toolCount .. " adet Tool bulundu.")

-- 2. Şimdi de "Gun" ismi geçen tüm nesneleri bul (Tool olmayanlar dahil)
print("\n--- İSMİNDE 'GUN' GEÇEN TÜM NESNELER ---")
local gunCount = 0
for _, obj in ipairs(workspace:GetDescendants()) do
    local name = obj.Name:lower()
    if name:find("gun") or name:find("sheriff") or name:find("pistol") or name:find("revolver") or name:find("weapon") then
        gunCount = gunCount + 1
        print(gunCount .. ". Nesne Adı: " .. obj.Name)
        print("   Sınıf: " .. obj.ClassName)
        print("   Ebeveyn: " .. (obj.Parent and obj.Parent.Name or "YOK"))
        print("   Yol: " .. obj:GetFullName())
        if obj:IsA("BasePart") then
            print("   Pozisyon: " .. tostring(obj.Position))
        end
        print("")
    end
end
print("Toplam " .. gunCount .. " adet 'gun' içeren nesne bulundu.")

-- 3. Şerif öldüğünde ne olduğunu görmek için sürekli izle
print("\n--- SÜREKLİ İZLEME BAŞLADI ---")
print("Şerif ölünce yere ne düştüğünü görmek için bekleniyor...")

local lastGunCount = 0
local function scanLoop()
    local currentGuns = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name == "Gun" or obj.Name:lower():find("gun")) then
            local parent = obj.Parent
            if not (parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid")) then
                -- Oyuncunun elinde değil
                table.insert(currentGuns, {
                    name = obj.Name,
                    parent = parent and parent.Name or "YOK",
                    position = obj:FindFirstChild("Handle") and obj.Handle.Position or nil
                })
            end
        end
    end
    
    if #currentGuns > lastGunCount then
        print("\n>>> YENİ SİLAH TESPİT EDİLDİ! <<<")
        for i, gun in ipairs(currentGuns) do
            print(i .. ". " .. gun.name .. " | Ebeveyn: " .. gun.parent .. " | Pozisyon: " .. tostring(gun.position))
        end
        lastGunCount = #currentGuns
    end
end

-- Her 2 saniyede bir tara
game:GetService("RunService").Heartbeat:Connect(function()
    scanLoop()
end)

print("\n========== TARAMA TAMAMLANDI ==========")
print("Şimdi oyunda Şerif'i öldür ve yere ne düştüğünü konsolda gözlemle.")
print("Eğer yeni bir silah tespit edilirse konsolda '>>> YENİ SİLAH TESPİT EDİLDİ!' yazacak.")
