-- // Delta Mobil – MM2: ESP (Rol Renkli) + Dropped Gun ESP + Şerif Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
local maxDist = 500
local aimEnabled = true
local aimMaxDist = 120
local droppedGunESP = {}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 120, 255),
    Innocent = Color3.fromRGB(0, 255, 0),
    Unknown  = Color3.fromRGB(255, 255, 0)
}

-- ==============================================
-- ROL TESPİTİ
-- ==============================================
local function getPlayerRole(plr)
    local char = plr.Character
    local backpack = plr:FindFirstChild("Backpack")
    
    local roleObj = plr:FindFirstChild("Role")
    if roleObj and roleObj:IsA("StringValue") then
        local r = roleObj.Value
        if r == "Murderer" or r == "Killer" then return "Murderer"
        elseif r == "Sheriff" or r == "Hero" then return "Sheriff"
        elseif r == "Innocent" or r == "Civilian" then return "Innocent"
        end
    end

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name
                if name == "Knife" or name == "Murderer" or name == "Killer" then return "Murderer" end
                if name == "Gun" or name == "Sheriff" or name == "Revolver" or name == "Pistol" then return "Sheriff" end
            end
        end
    end

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name
                if name == "Knife" or name == "MurdererWeapon" then return "Murderer" end
                if name == "Gun" or name == "SheriffWeapon" then return "Sheriff" end
            end
        end
        if char:FindFirstChild("Murderer") or char:FindFirstChild("Killer") then return "Murderer" end
        if char:FindFirstChild("Sheriff") or char:FindFirstChild("Hero") then return "Sheriff" end
    end

    return "Innocent"
end

-- ==============================================
-- ESP
-- ==============================================
local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

local function createESP(plr)
    local d = {}
    d.box = newDrawing("Square")
    if d.box then d.box.Thickness = 2 d.box.Filled = false d.box.Visible = false end
    d.dist = newDrawing("Text")
    if d.dist then d.dist.Size = 13 d.dist.Center = true d.dist.Outline = true d.dist.Visible = false end
    d.role = newDrawing("Text")
    if d.role then d.role.Size = 12 d.role.Center = true d.role.Outline = true d.role.Visible = false end
    ESP[plr] = d
end

local function removeESP(plr)
    local d = ESP[plr]
    if d then
        if d.box then d.box:Remove() end
        if d.dist then d.dist:Remove() end
        if d.role then d.role:Remove() end
        ESP[plr] = nil
    end
end

-- ==============================================
-- ŞERİF AIMBOT
-- ==============================================
local function hasGun()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    for _, v in ipairs(myChar:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name == "Gun" then return true end end end
    return false
end

local function getClosestMurderer()
    local best = nil
    local bestDist = aimMaxDist
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    if myPos ~= myPos then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if getPlayerRole(plr) ~= "Murderer" then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local pos = hrp.Position
        if pos ~= pos then continue end
        local dist = (myPos - pos).Magnitude
        if dist < bestDist then bestDist = dist best = plr end
    end
    return best
end

local function aimAt(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local targetPos = hrp.Position + Vector3.new(0, 1, 0)
    if targetPos ~= targetPos then return end
    local camPos = Camera.CFrame.Position
    if camPos ~= camPos then return end
    pcall(function() Camera.CFrame = CFrame.lookAt(camPos, targetPos) end)

    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local root = myChar.HumanoidRootPart
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        if flatTarget ~= flatTarget then return end
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        pcall(function() root.CFrame = CFrame.lookAt(root.Position, flatTarget) end)
    end
end

-- ==============================================
-- ANA DÖNGÜ
-- ==============================================
RunService.RenderStepped:Connect(function()
    local my = LocalPlayer.Character

    -- ========== OYUNCU ESP ==========
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then removeESP(plr) continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then removeESP(plr) continue end

        local top = (head and head.Position or hrp.Position) + Vector3.new(0, 2, 0)
        local bottom = hrp.Position - Vector3.new(0, 3, 0)
        local ts, on1 = Camera:WorldToViewportPoint(top)
        local bs, on2 = Camera:WorldToViewportPoint(bottom)
        if not on1 and not on2 then
            if ESP[plr] then ESP[plr].box.Visible = false ESP[plr].dist.Visible = false ESP[plr].role.Visible = false end
            continue
        end

        local dist = (my and my:FindFirstChild("HumanoidRootPart") and (my.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
        if dist > maxDist then
            if ESP[plr] then ESP[plr].box.Visible = false ESP[plr].dist.Visible = false ESP[plr].role.Visible = false end
            continue
        end

        if not ESP[plr] then createESP(plr) end
        local d = ESP[plr]
        if not d then continue end

        local h = math.abs(ts.Y - bs.Y)
        local w = h * 0.5
        local cx = (ts.X + bs.X) / 2
        local x = cx - w/2
        local y = math.min(ts.Y, bs.Y)

        local role = getPlayerRole(plr)
        local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown

        if d.box then
            d.box.Visible = true d.box.Position = Vector2.new(x, y) d.box.Size = Vector2.new(w, h) d.box.Color = color
        end
        if d.dist then
            d.dist.Visible = true d.dist.Text = math.floor(dist) .. "m" d.dist.Color = color d.dist.Position = Vector2.new(cx, y + h + 2)
        end
        if d.role then
            d.role.Visible = true d.role.Text = role d.role.Color = color d.role.Position = Vector2.new(cx, y - 15)
        end
    end

    -- ========== DROPPED GUN ESP ==========
    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Tool") and obj.Name == "Gun" then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local pos = handle.Position
                    if pos ~= pos then continue end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                    if onScreen then
                        if not droppedGunESP[obj] then
                            droppedGunESP[obj] = {
                                box = newDrawing("Square"),
                                text = newDrawing("Text")
                            }
                            if droppedGunESP[obj].box then
                                droppedGunESP[obj].box.Thickness = 2
                                droppedGunESP[obj].box.Filled = false
                            end
                            if droppedGunESP[obj].text then
                                droppedGunESP[obj].text.Size = 14
                                droppedGunESP[obj].text.Center = true
                                droppedGunESP[obj].text.Outline = true
                                droppedGunESP[obj].text.Color = Color3.new(1, 0.5, 0)
                            end
                        end
                        local dg = droppedGunESP[obj]
                        if dg.box then
                            dg.box.Visible = true
                            dg.box.Position = Vector2.new(screenPos.X - 15, screenPos.Y - 15)
                            dg.box.Size = Vector2.new(30, 30)
                            dg.box.Color = Color3.new(1, 0.5, 0)
                        end
                        if dg.text then
                            dg.text.Visible = true
                            dg.text.Text = "SİLAH"
                            dg.text.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
                        end
                    else
                        if droppedGunESP[obj] then
                            if droppedGunESP[obj].box then droppedGunESP[obj].box.Visible = false end
                            if droppedGunESP[obj].text then droppedGunESP[obj].text.Visible = false end
                        end
                    end
                end
            end
        end

        -- Silinmiş silahları temizle
        for gun, drawings in pairs(droppedGunESP) do
            if not gun.Parent or not gun:FindFirstChild("Handle") then
                if drawings.box then drawings.box:Remove() end
                if drawings.text then drawings.text:Remove() end
                droppedGunESP[gun] = nil
            end
        end
    end)

    -- ========== ŞERİF AIM ==========
    if aimEnabled and getPlayerRole(LocalPlayer) == "Sheriff" and hasGun() then
        local target = getClosestMurderer()
        if target then aimAt(target) end
    end
end)

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
print("✅ MM2: ESP (renkli) + Dropped Gun ESP + Şerif Aim aktif!")
