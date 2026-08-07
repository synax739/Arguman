-- DELTA EXECUTOR - SANDIK İSİMLERİNİ BUL
local Workspace = game:GetService("Workspace")

print("🔍 SANDIK İSİMLERİ ARANIYOR...")
wait(1)

local chests = {}
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local name = v.Name
        if string.find(string.lower(name), "chest") or 
           string.find(string.lower(name), "sandik") or
           string.find(string.lower(name), "kutu") or
           string.find(string.lower(name), "diamond") or
           string.find(string.lower(name), "gold") or
           string.find(string.lower(name), "silver") or
           string.find(string.lower(name), "mirage") or
           string.find(string.lower(name), "fragment") then
            table.insert(chests, {
                Name = name,
                Class = v.ClassName,
                Position = v.Position,
                Parent = v.Parent and v.Parent.Name or "YOK"
            })
        end
    end
end

print("========================================")
print("📦 BULUNAN SANDIKLAR (" .. #chests .. " adet)")
print("========================================")

if #chests == 0 then
    print("❌ Hiç sandık bulunamadı!")
    print("")
    print("📌 OLASI SEBEPLER:")
    print("1. Sandıklar spawn olmamış")
    print("2. Farklı bir bölgedesin")
    print("3. Sandıklar toplanmış ve yenilenmemiş")
    print("4. Oyun modunda sandık yok")
    print("5. Sandıklar farklı isimde (örnek: 'Box', 'Crate')")
else
    for i, chest in pairs(chests) do
        print(i .. ". İsim: " .. chest.Name)
        print("   Sınıf: " .. chest.Class)
        print("   Konum: " .. string.format("%.1f, %.1f, %.1f", chest.Position.X, chest.Position.Y, chest.Position.Z))
        print("   Parent: " .. chest.Parent)
        print("")
    end
end

print("========================================")
print("💡 NOT: Bu isimleri kullanarak script yazabilirsin")
