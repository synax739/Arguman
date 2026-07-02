-- GUN ESP + BASİT PANEL (Sadece Gun ESP toggle)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cfg = { gun_esp = true }
local gunESPObjects = {}

local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

local function isInFront(pos)
    local camPos = Camera.CFrame.Position
    return Camera.CFrame.LookVector:Dot((pos - camPos).Unit) > 0
end

local function updateGunESP()
    if not cfg.gun_esp then
        for _, obj in pairs(gunESPObjects) do
            pcall(function() obj.box:Remove() end)
            pcall(function() obj.text:Remove() end)
            pcall(function() obj.dist:Remove() end)
        end
        gunESPObjects = {}
        return
    end

    for _, obj in pairs(gunESPObjects) do
        pcall(function() obj.box:Remove() end)
        pcall(function() obj.text:Remove() end)
        pcall(function() obj.dist:Remove() end)
    end
    gunESPObjects = {}

    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    local myPosition = myPos.Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local isHeld = false
            local parent = obj.Parent
            if parent then
                if parent:IsA("Tool") then
                    local toolParent = parent.Parent
                    if toolParent and toolParent:IsA("Model") and toolParent:FindFirstChild("Humanoid") then
                        isHeld = true
                    end
                end
                if parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true
                end
            end
            
            if not isHeld then
                local pos = obj.Position
                if pos ~= pos then continue end
                local dist = (myPosition - pos).Magnitude
                local distText = math.floor(dist) .. "m"
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen and isInFront(pos) then
                    local box = newDrawing("Square")
                    local text = newDrawing("Text")
                    local distLabel = newDrawing("Text")
                    
                    if box then
                        box.Thickness = 2
                        box.Filled = false
                        box.Color = Color3.fromRGB(255, 200, 0)
                        box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                        box.Size = Vector2.new(40, 40)
                        box.Visible = true
                    end
                    
                    if text then
                        text.Size = 14
                        text.Center = true
                        text.Outline = true
                        text.Color = Color3.fromRGB(255, 200, 0)
                        text.Text = "🔫 SILAH"
                        text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                        text.Visible = true
                    end
                    
                    if distLabel then
                        distLabel.Size = 12
                        distLabel.Center = true
                        distLabel.Outline = true
                        distLabel.Color = Color3.fromRGB(100, 255, 100)
                        distLabel.Text = distText
                        distLabel.Position = Vector2.new(screenPos.X, screenPos.Y + 25)
                        distLabel.Visible = true
                    end
                    
                    gunESPObjects[obj] = {box = box, text = text, dist = distLabel}
                end
            end
        end
    end
end

-- Panel (sadece buton)
local function createPanel()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "GunESP_Panel"
    
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 120, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn.Text = "GUN ESP: AÇIK"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.Activated:Connect(function()
        cfg.gun_esp = not cfg.gun_esp
        btn.Text = cfg.gun_esp and "GUN ESP: AÇIK" or "GUN ESP: KAPALI"
        btn.BackgroundColor3 = cfg.gun_esp and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end)
end

RunService.RenderStepped:Connect(function()
    pcall(function() updateGunESP() end)
end)

createPanel()
print("🔫 GUN ESP AKTIF! Sol üstteki butonla kapatıp açabilirsin.")
