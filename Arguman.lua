-- SADECE GUN ESP - ÇALIŞIR VERSİYON

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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

RunService.RenderStepped:Connect(function()
    updateGunESP()
end)

print("🔫 GUN ESP AKTIF! GunDrop'lari gosteriyor.")
