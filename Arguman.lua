-- // MM2 Silah Remote Bulucu (Konsolsuz, GUI'de gösterir)

local player = game.Players.LocalPlayer
local char = player.Character

-- Bilgi gösterme GUI'si
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteInfoGUI"
screenGui.Parent = game.CoreGui or player:WaitForChild("PlayerGui")

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0, 350, 0, 200)
infoFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoFrame.BackgroundTransparency = 0.5
infoFrame.BorderSizePixel = 0
infoFrame.Parent = screenGui

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, -10)
infoText.Position = UDim2.new(0, 5, 0, 5)
infoText.BackgroundTransparency = 1
infoText.Text = "Silah aranıyor..."
infoText.TextColor3 = Color3.new(1, 1, 1)
infoText.Font = Enum.Font.SourceSansBold
infoText.TextSize = 14
infoText.TextWrapped = true
infoText.Parent = infoFrame

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.Parent = infoFrame
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Silahı bul ve Remote'ları listele
local function findGunAndRemotes()
    local tool = nil
    local char = player.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then tool = v break end
        end
    end
    if not tool then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, v in ipairs(backpack:GetChildren()) do
                if v:IsA("Tool") then tool = v break end
            end
        end
    end

    local message = ""
    if not tool then
        message = "Elinizde silah yok! Lütfen şerif silahını alın."
    else
        message = "✅ Silah: " .. tool.Name .. "\n\n📡 REMOTE'LAR:\n"
        local remotesFound = false
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                message = message .. "🔹 " .. child.Name .. " (" .. child.ClassName .. ")\n"
                message = message .. "    Yol: " .. child:GetFullName() .. "\n"
                remotesFound = true
            end
        end
        if not remotesFound then
            message = message .. "Hiç Remote bulunamadı! (Silah farklı bir mekanizmaya sahip)"
        end
        message = message .. "\nBu bilgiyi kopyalayıp bana gönder."
    end
    infoText.Text = message
end

-- Karakter değişimlerini takip et
player.CharacterAdded:Connect(function()
    findGunAndRemotes()
end)

-- İlk çalıştırma
findGunAndRemotes()

-- 3 saniyede bir güncelle (silahlar değişebilir)
while wait(3) do
    findGunAndRemotes()
end
