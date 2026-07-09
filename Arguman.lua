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

-- Ayarlar
local NEON_GREEN = Color3.fromRGB(0, 255, 102)
local DARK_BG = Color3.fromRGB(15, 15, 20)

------------------------------------------------------------------------
-- 1. GUI OLUŞTURMA & KATMAN AYARLARI (ZIndex)
------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberModMenuGui"
ScreenGui.ResetOnSpawn = false
-- DisplayOrder'ı yüksek tutuyoruz ki oyunun kendi arayüzlerinin hep en üstünde çıksın
ScreenGui.DisplayOrder = 99999 
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Ana Menü Paneli
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
-- Başlangıç boyutu sıfır yerine çok küçük (0.01) yapıyoruz, Tween hatasını önlemek için
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -140) -- Ekranın tam ortası
MainFrame.BackgroundColor3 = DARK_BG
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = NEON_GREEN
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 10 -- Katman önceliği yüksek
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
Title.TextSize = 16
Title.ZIndex = 11

-- MOBİL TOGGLE BUTONU (Ekrandaki yeşil butonun yerini sabitleyip güçlendiriyoruz)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 70, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.45, 0) -- Mevcut konumuna yakın sabitleme
ToggleBtn.BackgroundColor3 = NEON_GREEN
ToggleBtn.Text = "HACK"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Font = Enum.Font.CodeBold
ToggleBtn.TextSize = 14
ToggleBtn.ZIndex = 10000 -- Butonun her zaman tıklanabilir olması için en üst katman
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------------
-- MENÜ AÇMA / KAPATMA MANTIĞI
------------------------------------------------------------------------
local function toggleMenu()
	menuOpen = not menuOpen
	
	if menuOpen then
		MainFrame.Visible = true
		-- Mobil ekranlar için güvenli ve sabit bir boyut atıyoruz
		MainFrame:TweenSize(UDim2.new(0, 280, 0, 280), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	else
		MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
			MainFrame.Visible = false
		end)
	end
end

-- Mobil ve PC uyumluluğu için en garanti event "Activated" olayıdır
ToggleBtn.Activated:Connect(toggleMenu)

------------------------------------------------------------------------
-- BUTON OLUŞTURMA SİSTEMİ
------------------------------------------------------------------------
local buttonCount = 0
local function createMenuButton(text, callback)
	buttonCount = buttonCount + 1
	local btn = Instance.new("TextButton", MainFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 38)
	btn.Position = UDim2.new(0.05, 0, 0, 45 + (buttonCount * 45))
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.Text = text .. " [KAPALI]"
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.BorderSizePixel = 0
	btn.ZIndex = 12
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.Activated:Connect(function()
		local status = callback()
		btn.Text = text .. (status and " [AÇIK]" or " [KAPALI]")
		btn.TextColor3 = status and NEON_GREEN or Color3.fromRGB(150, 150, 150)
		
		-- Glitch efekti (Anlık parlayıp sönme)
		btn.BackgroundColor3 = NEON_GREEN
		task.wait(0.05)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	end)
end

-- Menü Seçenekleri
createMenuButton("Thermal Vision", function() espActive = not espActive; return espActive end)
createMenuButton("Auto-Targeting", function() aimlockActive = not aimlockActive; return aimlockActive end)
createMenuButton("Velocity Boost", function() speedActive = not speedActive; return speedActive end)
createMenuButton("Phase Shift", function() noclipActive = not noclipActive; return noclipActive end)

------------------------------------------------------------------------
-- SİSTEM DÖNGÜLERİ (ESP, Aimlock, Noclip vb.)
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- Thermal Vision (ESP)
	if espActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
				local h = Instance.new("Highlight", p.Character)
				h.Name = "ESPHighlight"
				h.FillColor = NEON_GREEN
				h.OutlineColor = Color3.fromRGB(255, 255, 255)
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end
		end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("ESPHighlight") then 
				p.Character.ESPHighlight:Destroy() 
			end
		end
	end
	
	-- Auto-Targeting (Aimlock)
	if aimlockActive then
		local closest = nil
		local dist = math.huge
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
				if d < dist then closest = p.Character.HumanoidRootPart; dist = d end
			end
		end
		if closest then 
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 0.1) 
		end
	end
	
	-- Velocity Boost (Speed)
	if speedActive and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed ~= 100 then
			hum.WalkSpeed = 100
		end
	elseif not speedActive and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed == 100 then
			hum.WalkSpeed = 16
		end
	end
end)

RunService.Stepped:Connect(function()
	-- Phase Shift (Noclip)
	if noclipActive and LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)
