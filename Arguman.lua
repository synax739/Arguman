-- MM2 GUN ESP - GELİŞMİŞ (Ölünce düşen silahları da gösterir)

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

local function findGunPart(tool)
    -- Önce Handle dene
    local part = tool:FindFirstChild("Handle")
    if part then return part end
    
    -- Handle yoksa, PrimaryPart veya başka bir parça bul
    part = tool:FindFirstChild("PrimaryPart")
    if part then return part end
    
    -- Hiçbiri yoksa, tool'un altındaki ilk BasePart'i al
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function updateGunESP()
    -- Eski objeleri temizle
    for _, obj in pairs(gunESPObjects) do
        pcall(function() obj.box:Remove() end)
        pcall(function() obj.text:Remove() end)
    end
    gunESPObjects = {}

    -- workspace'teki tüm Tool'ları tara
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local toolName = obj.Name:lower()
            -- "gun" içeren veya "Gun" olan tüm silahları al
            if toolName == "gun" or toolName:find("gun") or toolName:find("sheriff") or toolName:find("pistol") or toolName:find("revolver") then
                
                -- Silahın bir oyuncunun elinde olup olmadığını kontrol et
                local isHeld = false
                local parent = obj.Parent
                if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                    isHeld = true  -- Bir oyuncunun elinde
                end
                
                -- Eğer oyuncunun elinde değilse (yere düşmüş veya yerde duruyorsa)
                if not isHeld then
                    local part = findGunPart(obj)
                    if part then
                        local pos = part.Position
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
                                text.Text = "🔫 " .. obj.Name
                                text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                                text.Visible = true
                            end
                            gunESPObjects[obj] = {box = box, text = text}
                        end
                    end
                end
            end
        end
    end
    
    -- Silahın oyuncuya ait olup olmadığını kontrol et
    -- Bazı oyunlar silahı karakterin içine atar, onları da filtrele
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name == "Gun" then
            local parent = obj.Parent
            if parent and parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
                -- Oyuncunun elinde, ESP'den çıkar
                if gunESPObjects[obj] then
                    if gunESPObjects[obj].box then gunESPObjects[obj].box:Remove() end
                    if gunESPObjects[obj].text then gunESPObjects[obj].text:Remove() end
                    gunESPObjects[obj] = nil
                end
            end
        end
    end
end

-- Her kare güncelle
RunService.RenderStepped:Connect(function()
    updateGunESP()
end)

print("GUN ESP GELISMIS AKTIF! Yerdeki tum silahlari gostermeli.")
