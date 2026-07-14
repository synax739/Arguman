-- // Delta Mobil – BASİT ESP (Kutu + Mesafe)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
local maxDist = 500

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
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
    ESP[plr] = d
end

local function removeESP(plr)
    local d = ESP[plr]
    if d then
        if d.box then d.box:Remove() end
        if d.dist then d.dist:Remove() end
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
            if ESP[plr] then ESP[plr].box.Visible = false ESP[plr].dist.Visible = false end
            continue
        end

        local dist = (my and my:FindFirstChild("HumanoidRootPart") and (my.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
        if dist > maxDist then
            if ESP[plr] then ESP[plr].box.Visible = false ESP[plr].dist.Visible = false end
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

        if d.box then
            d.box.Visible = true
            d.box.Position = Vector2.new(x, y)
            d.box.Size = Vector2.new(w, h)
            d.box.Color = Color3.new(1, 0, 0)
        end
        if d.dist then
            d.dist.Visible = true
            d.dist.Text = math.floor(dist) .. "m"
            d.dist.Position = Vector2.new(cx, y + h + 2)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
print("✅ Basit ESP aktif.")
