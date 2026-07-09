--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Menü Durumları
local menuOpen = false
local espActive = false
local aimlockActive = false
local speedActive = false
local noclipActive = false
local jumpActive = false

-- Ayarlar
local NEON_GREEN = Color3.fromRGB(0, 255, 102)
local DARK_BG = Color3.fromRGB(15, 15, 20)

------------------------------------------------------------------------
-- 1. MOBİL AÇMA BUTONU
------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberModMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Ana Menü
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = DARK_BG
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = NEON_GREEN
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Üst Başlık
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "[ RexGodStudios HACK ]"
Title.TextColor3 = NEON_GREEN
Title.Font = Enum.Font.Code
Title.TextSize = 18

-- MOBİL TOGGLE BUTONU (Ekranın köşesinde durur)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25) -- Sol orta kısım
ToggleBtn.BackgroundColor3 = NEON_GREEN
ToggleBtn.Text = "HACK"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Font = Enum.Font.CodeBold
ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

------------------------------------------------------------------------
-- MENÜ YÖNETİMİ
------------------------------------------------------------------------
local function toggleMenu()
	menuOpen = not menuOpen
	if menuOpen then
		MainFrame.Visible = true
		MainFrame:TweenSize(UDim2.new(0, 300, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	else
		MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, true, function()
			MainFrame.Visible = false
		end)
	end
end

ToggleBtn.MouseButton1Click:Connect(toggleMenu)

------------------------------------------------------------------------
-- BUTON OLUŞTURMA FONKSİYONU
------------------------------------------------------------------------
local buttonCount = 0
local function createMenuButton(text, callback)
	buttonCount = buttonCount + 1
	local btn = Instance.new("TextButton", MainFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, 50 + (buttonCount * 45))
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.Text = text .. " [KAPALI]"
	btn.Font = Enum.Font.Code
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.MouseButton1Click:Connect(function()
		local status = callback() -- Fonksiyonu çağır ve sonucu al
		btn.Text = text .. (status and " [AÇIK]" or " [KAPALI]")
		btn.TextColor3 = status and NEON_GREEN or Color3.fromRGB(150, 150, 150)
	end)
end

-- Butonları Ekle
createMenuButton("Thermal Vision", function() espActive = not espActive; return espActive end)
createMenuButton("Auto-Targeting", function() aimlockActive = not aimlockActive; return aimlockActive end)
createMenuButton("Velocity Boost", function() speedActive = not speedActive; return speedActive end)
createMenuButton("Phase Shift", function() noclipActive = not noclipActive; return noclipActive end)

------------------------------------------------------------------------
-- HİLE MANTIĞI (Aynı)
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- ESP Mantığı
	if espActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
				local h = Instance.new("Highlight", p.Character)
				h.Name = "ESPHighlight"
				h.FillColor = NEON_GREEN
			end
		end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight:Destroy() end
		end
	end
	
	-- Aimlock Mantığı
	if aimlockActive then
		local closest = nil
		local dist = math.huge
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
				if d < dist then closest = p.Character.HumanoidRootPart; dist = d end
			end
		end
		if closest then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 0.1) end
	end
end)

RunService.Stepped:Connect(function()
	if noclipActive and LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)
