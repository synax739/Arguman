-- BLOX FRUITS AUTO CHEST (SON - SADECE CALISAN)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local chestFarmEnabled = false
local toplananSandiklar = {}

local function karakter()
    return LocalPlayer.Character
end

local function hrp()
    local char = karakter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function insan()
    local char = karakter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function sandikBul()
    local sandiklar = {}
    local ben = hrp()
    if not ben then return sandiklar end
    
    for _, nesne in ipairs(workspace:GetDescendants()) do
        if nesne:IsA("BasePart") and nesne.Name then
            local isim = nesne.Name:lower()
            if isim:find("chest") or isim:find("crate") then
                if toplananSandiklar[tostring(nesne)] then
                    continue
                end
                local pos = nesne.Position
                if pos == pos then
                    local mesafe = (ben.Position - pos).Magnitude
                    table.insert(sandiklar, {
                        nesne = nesne,
                        id = tostring(nesne),
                        konum = pos,
                        mesafe = mesafe,
                        isim = nesne.Name,
                    })
                end
            end
        end
    end
    return sandiklar
end

local function enYakinSandik()
    local sandiklar = sandikBul()
    if #sandiklar == 0 then return nil end
    table.sort(sandiklar, function(a, b) return a.mesafe < b.mesafe end)
    return sandiklar[1]
end

local function noclipAc()
    local char = karakter()
    if not char then return end
    for _, parca in ipairs(char:GetDescendants()) do
        if parca:IsA("BasePart") then
            pcall(function() parca.CanCollide = false end)
        end
    end
end

local function noclipKapat()
    local char = karakter()
    if not char then return end
    for _, parca in ipairs(char:GetDescendants()) do
        if parca:IsA("BasePart") then
            pcall(function() parca.CanCollide = true end)
        end
    end
end

local function sandigaGit(hedef)
    local ben = hrp()
    local can = insan()
    if not ben or not can then return false end
    
    noclipAc()
    can.PlatformStand = true
    can.Sit = false
    
    local ucusNoktasi = Vector3.new(hedef.X, hedef.Y + 2, hedef.Z)
    ben.CFrame = CFrame.new(ucusNoktasi)
    wait(0.05)
    
    noclipKapat()
    can.PlatformStand = false
    return true
end

local function sandikAl(sandik)
    if not sandik or not sandik.nesne then return false end
    
    local ben = hrp()
    if not ben then return false end
    
    ben.CFrame = CFrame.new(sandik.konum + Vector3.new(0, 1.5, 0))
    wait(0.1)
    
    toplananSandiklar[sandik.id] = true
    return true
end

local function panelOlustur()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "ChestFarm"
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 120, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "BASLAT"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local sifirlaBtn = Instance.new("TextButton", gui)
    sifirlaBtn.Size = UDim2.new(0, 50, 0, 50)
    sifirlaBtn.Position = UDim2.new(0.13, 0, 0.85, 0)
    sifirlaBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    sifirlaBtn.Text = "↺"
    sifirlaBtn.TextColor3 = Color3.new(1, 1, 1)
    sifirlaBtn.TextSize = 20
    sifirlaBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", sifirlaBtn).CornerRadius = UDim.new(1, 0)
    sifirlaBtn.Activated:Connect(function()
        toplananSandiklar = {}
        print("Temizlendi!")
    end)
    
    btn.Activated:Connect(function()
        chestFarmEnabled = not chestFarmEnabled
        if chestFarmEnabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            btn.Text = "DURDUR"
            toplananSandiklar = {}
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "BASLAT"
            noclipKapat()
            local can = insan()
            if can then can.PlatformStand = false end
        end
    end)
end

local function anaDongu()
    if not chestFarmEnabled then return end
    
    local ben = hrp()
    if not ben then
        wait(0.5)
        return
    end
    
    local hedef = enYakinSandik()
    if not hedef then
        wait(0.5)
        return
    end
    
    local basarili = sandigaGit(hedef.konum)
    if not basarili then
        toplananSandiklar[hedef.id] = true
        wait(0.2)
        return
    end
    
    sandikAl(hedef)
    print("✅ " .. hedef.isim .. " toplandi!")
    wait(0.1)
end

panelOlustur()

task.spawn(function()
    while wait(0.15) do
        pcall(anaDongu)
    end
end)

print("BLOX FRUITS AUTO CHEST HAZIR!")
