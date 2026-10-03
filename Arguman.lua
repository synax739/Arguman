-- KAMERA DEBUG PANELİ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "CameraDebug"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 380, 0, 260)
frame.Position = UDim2.new(0.5, -190, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.15
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "🔍 KAMERA DEBUG"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(1, -10, 1, -50)
textBox.Position = UDim2.new(0, 5, 0, 40)
textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
textBox.BackgroundTransparency = 0.3
textBox.TextColor3 = Color3.fromRGB(200, 255, 200)
textBox.TextSize = 12
textBox.Font = Enum.Font.Code
textBox.Text = "Yukleniyor..."
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.BorderSizePixel = 0
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)

-- PlayerModule kontrolü
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local hasPlayerModule = PlayerScripts:FindFirstChild("PlayerModule") ~= nil

-- Güncelleme
RunService.RenderStepped:Connect(function()
    local lines = {}
    table.insert(lines, "CameraType: " .. tostring(Camera.CameraType))
    table.insert(lines, "CameraSubject: " .. (Camera.CameraSubject and Camera.CameraSubject.Name or "nil"))
    table.insert(lines, "CameraMode: " .. tostring(LocalPlayer.CameraMode))
    table.insert(lines, "FieldOfView: " .. tostring(Camera.FieldOfView))
    table.insert(lines, "PlayerModule: " .. tostring(hasPlayerModule))
    
    local look = Camera.CFrame.LookVector
    table.insert(lines, "LookVector: " .. string.format("%.2f, %.2f, %.2f", look.X, look.Y, look.Z))
    
    local rotY = math.deg(math.atan2(look.X, look.Z))
    table.insert(lines, "Kamera Y-Acisi: " .. string.format("%.1f°", rotY))
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        table.insert(lines, "Humanoid AutoRotate: " .. tostring(hum.AutoRotate))
    end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local hrpLook = hrp.CFrame.LookVector
        local hrpRotY = math.deg(math.atan2(hrpLook.X, hrpLook.Z))
        table.insert(lines, "Karakter Y-Acisi: " .. string.format("%.1f°", hrpRotY))
    end
    
    textBox.Text = table.concat(lines, "\n")
end)

-- Kapatma
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.Activated:Connect(function() frame.Visible = false end)

-- Açma butonu
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(1, -60, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
openBtn.Text = "🔍"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.TextSize = 20
openBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
openBtn.Activated:Connect(function() frame.Visible = not frame.Visible end)

print("✅ KAMERA DEBUG PANELI YUKLENDI!")
