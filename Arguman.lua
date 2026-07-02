-- MM2 GUN ESP TEST SCRIPTI (SADECE GUN ESP)
-- Bu script sadece yerdeki silahları gösterir

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
    -- Eski objeleri temizle
    for _, obj in pairs(gunESPObjects) do
        pcall(function() obj.box:Remove() end)
        pcall(function() obj.text:Remove() end)
    end
    gunESPObjects = {}

    -- Yerdeki silahları tara
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name == "Gun" then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                local pos = handle.Position
                if pos ~= pos then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen and isInFront(pos) then
                    local box = newDrawing("Square")
                    local text = newDrawing("Text")
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
                        text.Text = "🔫 GUN"
                        text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                        text.Visible = true
                    end
                    gunESPObjects[obj] = {box = box, text = text}
                end
            end
        end
    end
end

-- Her kare güncelle
RunService.RenderStepped:Connect(function()
    updateGunESP()
end)

print("GUN ESP TEST AKTIF! Yerdeki silahlari gostermeli.")
