-- // MM2 GELİŞMİŞ GUN ESP - Yere Düşen Silahları da Gösterir
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local gunESPObjects = {}

local function newDrawing(type)
    local success, drawing = pcall(function() return Drawing.new(type) end)
    return success and drawing or nil
end

local function isOnScreenAndInFront(position)
    local _, onScreen = Camera:WorldToViewportPoint(position)
    local camPos = Camera.CFrame.Position
    local toTarget = (position - camPos).Unit
    return onScreen and Camera.CFrame.LookVector:Dot(toTarget) > 0.1
end

local function findGunRoot(tool)
    -- En iyi root part bulma
    if tool:FindFirstChild("Handle") then return tool.Handle end
    if tool:FindFirstChild("PrimaryPart") then return tool.PrimaryPart end
    if tool:FindFirstChild("Gun") then return tool.Gun end
    
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("BasePart") and child.Transparency < 1 then
            return child
        end
    end
    return tool:FindFirstChildWhichIsA("BasePart")
end

local function updateGunESP()
    -- Eski ESP'leri temizle
    for obj, data in pairs(gunESPObjects) do
        if data.box then data.box:Remove() end
        if data.text then data.text:Remove() end
    end
    gunESPObjects = {}

    -- Workspace'teki tüm Tool'ları tara
    for _, tool in ipairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") then
            local nameLower = tool.Name:lower()
            
            -- MM2 silahlarını tespit et
            if nameLower:find("gun") or nameLower == "pistol" or nameLower == "revolver" or 
               nameLower:find("sheriff") or nameLower:find("murderer") or nameLower:find("knife") then
                
                -- Oyuncunun elinde mi diye kontrol et
                local isHeld = false
                local currentParent = tool.Parent
                while currentParent do
                    if currentParent:FindFirstChildOfClass("Humanoid") then
                        isHeld = true
                        break
                    end
                    currentParent = currentParent.Parent
                end

                if not isHeld then
                    local rootPart = findGunRoot(tool)
                    if rootPart then
                        local pos = rootPart.Position
                        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)

                        if onScreen and isOnScreenAndInFront(pos) then
                            -- Box
                            local box = newDrawing("Square")
                            if box then
                                box.Thickness = 2.5
                                box.Filled = false
                                box.Color = Color3.fromRGB(255, 215, 0)
                                box.Transparency = 1
                                box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 25)
                                box.Size = Vector2.new(50, 50)
                                box.Visible = true
                            end

                            -- Text
                            local text = newDrawing("Text")
                            if text then
                                text.Size = 15
                                text.Center = true
                                text.Outline = true
                                text.Color = Color3.fromRGB(255, 215, 0)
                                text.Text = "🔫 " .. tool.Name
                                text.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                                text.Visible = true
                            end

                            gunESPObjects[tool] = {box = box, text = text}
                        end
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateGunESP)

print("✅ MM2 Gelişmiş Gun ESP Aktif! Yere düşen silahlar da gözükecek.")
