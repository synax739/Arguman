--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hazırladığımız GUI elemanlarına güvenli erişim
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")
local MainFrame = ScreenGui:WaitForChild("MainFrame") :: Frame
local ToggleBtn = ScreenGui:WaitForChild("ToggleBtn") :: TextButton

local EspBtn = MainFrame:WaitForChild("EspBtn") :: TextButton
local AimBtn = MainFrame:WaitForChild("AimBtn") :: TextButton
local SpeedBtn = MainFrame:WaitForChild("SpeedBtn") :: TextButton
local NoclipBtn = MainFrame:WaitForChild("NoclipBtn") :: TextButton

-- Durum Değişkenleri
local menuOpen = false
local espActive = false
local aimlockActive = false
local speedActive = false
local noclipActive = false

local NEON_GREEN = Color3.fromRGB(0, 255, 102)
local GRAY = Color3.fromRGB(150, 150, 150)

-- Hedef Boyut (Ekran boyutuna göre kendini ayarlar)
local TARGET_SIZE = ULim2 and UDim2.new(0, 280, 0, 280) or UDim2.new(0, 280, 0, 280)

------------------------------------------------------------------------
-- AÇILIŞ / KAPANIŞ ANİMASYONU
------------------------------------------------------------------------
local function toggleMenu()
	menuOpen = not menuOpen
	if menuOpen then
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		MainFrame.Visible = true
		MainFrame:TweenSize(TARGET_SIZE, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	else
		MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
			MainFrame.Visible = false
		end)
	end
end

-- Mobilde en garanti tetikleyici MouseButton1Click veya Activated'dır
ToggleBtn.MouseButton1Click:Connect(toggleMenu)

------------------------------------------------------------------------
-- BUTON FONKSİYONLARI VE AKTİVASYONLAR
------------------------------------------------------------------------
EspBtn.MouseButton1Click:Connect(function()
	espActive = not espActive
	EspBtn.Text = "Thermal Vision " .. (espActive and "[AÇIK]" or "[KAPALI]")
	EspBtn.TextColor3 = espActive and NEON_GREEN or GRAY
end)

AimBtn.MouseButton1Click:Connect(function()
	aimlockActive = not aimlockActive
	AimBtn.Text = "Auto-Targeting " .. (aimlockActive and "[AÇIK]" or "[KAPALI]")
	AimBtn.TextColor3 = aimlockActive and NEON_GREEN or GRAY
end)

SpeedBtn.MouseButton1Click:Connect(function()
	speedActive = not speedActive
	SpeedBtn.Text = "Velocity Boost " .. (speedActive and "[AÇIK]" or "[KAPALI]")
	SpeedBtn.TextColor3 = speedActive and NEON_GREEN or GRAY
end)

NoclipBtn.MouseButton1Click:Connect(function()
	noclipActive = not noclipActive
	NoclipBtn.Text = "Phase Shift " .. (noclipActive and "[AÇIK]" or "[KAPALI]")
	NoclipBtn.TextColor3 = noclipActive and NEON_GREEN or GRAY
end)

------------------------------------------------------------------------
-- CORE MEKANİK DÖNGÜLERİ
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- ESP (Thermal Vision)
	if espActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
				local h = Instance.new("Highlight")
				h.Name = "ESPHighlight"
				h.FillColor = NEON_GREEN
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = p.Character
			end
		end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("ESPHighlight") then 
				p.Character.ESPHighlight:Destroy() 
			end
		end
	end
	
	-- Aimlock (Auto-Targeting)
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
	
	-- Speed (Velocity Boost)
	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			if speedActive and hum.WalkSpeed ~= 100 then
				hum.WalkSpeed = 100
			elseif not speedActive and hum.WalkSpeed == 100 then
				hum.WalkSpeed = 16
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	-- Noclip (Phase Shift)
	if noclipActive and LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)
