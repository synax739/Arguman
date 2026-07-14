-- // Delta Mobil – MM2: BASİT ESP (Rol Renkli) + Mesafe

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
local maxDist = 500

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),    -- Kırmızı
    Sheriff  = Color3.fromRGB(0, 120, 255),  -- Mavi
    Innocent = Color3.fromRGB(0, 255, 0),    -- Yeşil
    Unknown  = Color3.fromRGB(255, 255, 0)   -- Sarı
}

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

-- Rol tespiti (her kare hesaplanır)
local function getPlayerRole(plr)
    local char = plr.Character
    local backpack = plr:FindFirstChild("Backpack")
    
    -- Player.Role StringValue
    local roleObj = plr:FindFirstChild("Role")
    if roleObj and roleObj:IsA("StringValue") then
        local r = roleObj.Value
        if r == "Murderer" or r == "Killer" then return "Murderer"
        elseif r == "Sheriff" or r == "Hero" then return "Sheriff"
        elseif r == "Innocent" or r == "Civilian" then return "Innocent"
        end
    end

    -- Backpack'teki eşyalar
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name
                if name == "Knife" or name == "Murderer" or name == "Killer" then return "Murderer" end
                if name == "Gun" or name == "Sheriff" or name == "Revolver" or name == "Pistol" then return "Sheriff" end
            end
        end
    end

    -- Karakter içindeki eşyalar (eldeki)
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

local function createESP(plr)
    local d = {}
    d.box = newDrawing("Square")
    if d.box then
        d.box.Thickness = 2
        d.box.Filled = false
        d.box.Visible = false
    end
    d.dist = newDrawing("Text")
    if d.dist then
        d.dist.Size = 13
        d.dist.Center = true
        d.dist.Outline = true
        d.dist.Visible = false
    end
    d.role = newDrawing("Text")
    if d.role then
        d.role.Size = 12
        d.role.Center = true
        d.role.Outline = true
        d.role.Visible = false
    end
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

RunService.RenderStepped:Connect(function()
    local my = LocalPlayer.Character
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

        -- Rol al
        local role = getPlayerRole(plr)
        local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown

        -- Kutu
        if d.box then
            d.box.Visible = true
            d.box.Position = Vector2.new(x, y)
            d.box.Size = Vector2.new(w, h)
            d.box.Color = color
        end
        -- Mesafe
        if d.dist then
            d.dist.Visible = true
            d.dist.Text = math.floor(dist) .. "m"
            d.dist.Color = color
            d.dist.Position = Vector2.new(cx, y + h + 2)
        end
        -- Rol yazısı
        if d.role then
            d.role.Visible = true
            d.role.Text = role
            d.role.Color = color
            d.role.Position = Vector2.new(cx, y - 15)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
print("✅ MM2 Basit ESP (Katil Kırmızı, Şerif Mavi, Masum Yeşil) aktif!")
