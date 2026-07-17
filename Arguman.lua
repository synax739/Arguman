-- JJS LOCK SİSTEMİ (Örnek Kod)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local lockTarget = nil
local lockEnabled = false

-- En yakın oyuncuyu bul
local function getClosestPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local targetChar = plr.Character
        if not targetChar then continue end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHrp then continue end
        local dist = (hrp.Position - targetHrp.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = plr
        end
    end
    return closest
end

-- Kamerayı hedefe kilitle
local function lockCamera(targetPlayer)
    if not targetPlayer then return end
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local targetPos = hrp.Position + Vector3.new(0, 2, 0) -- Baş hizası
    local camPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.lookAt(camPos, targetPos)
end

-- Ana döngü
RunService.RenderStepped:Connect(function()
    if lockEnabled then
        local target = getClosestPlayer()
        if target then
            lockCamera(target)
            -- Mavi daire çizimi (Drawing kullanarak)
            -- Bu kısımda Drawing.new("Circle") ile hedef üzerine daire çizebilirsin
        end
    end
end)

-- Toggle ile aç/kapat
-- (Panel entegrasyonu ile)
