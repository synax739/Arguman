-- MM2 TEST: En yakın silaha ışınlan, al, geri dön

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function grabGunAndReturn()
    local char = LocalPlayer.Character
    if not char then return print("❌ Karakter yok") end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return print("❌ HumanoidRootPart yok") end

    -- En yakın GunDrop'u bul (BasePart ve ismi GunDrop)
    local closest, closestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local pos = obj.Position
            if pos ~= pos then continue end -- nan kontrolü
            local dist = (hrp.Position - pos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = obj
            end
        end
    end

    if not closest then
        print("❌ Yerde silah (GunDrop) bulunamadı!")
        return
    end

    print("🔫 Silah bulundu! Mesafe: " .. math.floor(closestDist) .. "m")

    -- Mevcut konumu kaydet
    local originalCF = hrp.CFrame

    -- Silahın üzerine ışınlan (biraz yukarıda)
    hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 2, 0))
    wait(0.3)  -- Silahın alınması için bekle

    -- Silahı aldık mı kontrol et (elinde veya backpack'te)
    local hasGunNow = false
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name == "Gun" then
            hasGunNow = true
            break
        end
    end
    if not hasGunNow then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") and item.Name == "Gun" then
                    hasGunNow = true
                    break
                end
            end
        end
    end

    -- Eski konuma geri dön
    hrp.CFrame = originalCF

    if hasGunNow then
        print("✅ Silah başarıyla alındı ve geri dönüldü!")
    else
        print("❌ Silah alınamadı! (Belki otomatik alınmıyor, el ile tıklamak gerekebilir)")
    end
end

-- Bir tuşa basınca çalıştır (mobilde ekrana dokununca)
local function setupTrigger()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 200, 0, 60)
    btn.Position = UDim2.new(0.5, -100, 0.5, -30)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btn.Text = "🔫 SİLAHI AL & GERİ DÖN"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 18
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    btn.Parent = gui

    btn.Activated:Connect(function()
        grabGunAndReturn()
    end)

    print("✅ Buton oluşturuldu! Tıkla/dokun ve silahı alıp geri dön.")
end

setupTrigger()
