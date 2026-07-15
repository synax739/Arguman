-- MM2 DEBUG: Yerdeki tüm GunDrop ve Tool nesnelerini listele

local function debugGuns()
    print("===== YERDEKİ NESNELER =====")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- BasePart ve ismi "GunDrop" olanlar
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            count = count + 1
            print(string.format("[%d] GunDrop | Pos: %.1f, %.1f, %.1f | Parent: %s", 
                count, obj.Position.X, obj.Position.Y, obj.Position.Z, obj.Parent and obj.Parent.Name or "nil"))
        end
        -- Tool olanlar (silah olabilir)
        if obj:IsA("Tool") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                count = count + 1
                print(string.format("[%d] Tool: %s | Handle Pos: %.1f, %.1f, %.1f", 
                    count, obj.Name, handle.Position.X, handle.Position.Y, handle.Position.Z))
            end
        end
    end
    if count == 0 then
        print("❌ Hiç silah bulunamadı! Oyunda silah yere düşmemiş olabilir.")
    else
        print("===== TOPLAM: " .. count .. " nesne bulundu =====")
    end
end

-- Hemen çalıştır
debugGuns()

-- Her 3 saniyede bir tekrarla (güncel kalması için)
game:GetService("RunService").Stepped:Connect(function()
    wait(3)
    debugGuns()
end)
