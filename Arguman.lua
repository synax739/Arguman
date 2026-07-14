-- // MM2 Dropped Gun Debug
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gunDrawing = nil
local function newDrawing(t)
    local ok, d = pcall(function() return Drawing.new(t) end)
    return ok and d or nil
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Tool") then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local pos = handle.Position
                    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                    if onScreen then
                        if not gunDrawing then
                            gunDrawing = {
                                box = newDrawing("Square"),
                                text = newDrawing("Text")
                            }
                            if gunDrawing.box then
                                gunDrawing.box.Thickness = 2
                                gunDrawing.box.Filled = false
                                gunDrawing.box.Color = Color3.new(1, 0.5, 0)
                            end
                            if gunDrawing.text then
                                gunDrawing.text.Size = 14
                                gunDrawing.text.Center = true
                                gunDrawing.text.Outline = true
                                gunDrawing.text.Color = Color3.new(1, 0.5, 0)
                            end
                        end
                        if gunDrawing.box then
                            gunDrawing.box.Visible = true
                            gunDrawing.box.Position = Vector2.new(screenPos.X - 15, screenPos.Y - 15)
                            gunDrawing.box.Size = Vector2.new(30, 30)
                        end
                        if gunDrawing.text then
                            gunDrawing.text.Visible = true
                            gunDrawing.text.Text = "SİLAH: " .. obj.Name
                            gunDrawing.text.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
                        end
                        print("✅ Silah bulundu: " .. obj.Name .. " | Pozisyon: " .. tostring(pos))
                    else
                        if gunDrawing then
                            if gunDrawing.box then gunDrawing.box.Visible = false end
                            if gunDrawing.text then gunDrawing.text.Visible = false end
                        end
                    end
                end
            end
        end
    end)
end)

print("🔍 Dropped Gun Debug aktif. Bir şerif öldür ve ekrana bak.")
