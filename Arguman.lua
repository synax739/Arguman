local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local isRunning = false
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if not isMobile then
    warn("Bu script mobil cihazlar icin tasarlanmistir.")
    return
end

local function getLookDirection()
    local lookVector = Camera.CFrame.LookVector
    return lookVector
end

local function moveCharacter(direction)
    if not Character or not Humanoid or Humanoid.Health <= 0 then return end
    local moveDirection = Vector3.new(direction.X, 0, direction.Z).Unit
    Humanoid:MoveTo(Character.HumanoidRootPart.Position + moveDirection * 5)
end

local function onHeartbeat()
    if not isRunning then return end
    local lookDir = getLookDirection()
    moveCharacter(lookDir)
end

local function startScript()
    if isRunning then return end
    isRunning = true
    RunService.Heartbeat:Connect(onHeartbeat)
end

local function stopScript()
    isRunning = false
end

-- Baslatma komutu (ornek: "start" yazinca calisir)
local function onChatCommand(msg)
    if msg == "start" then
        startScript()
    elseif msg == "stop" then
        stopScript()
    end
end

-- Ornek komut alimi (oyun icinde sohbet veya uzaktan komut icin)
-- Not: Delta ortaminda bu fonksiyonu kendi executorunuzun komut sistemiyle baglayin.
-- Asagidaki satirlar sadece ornek amaçlidir.
-- Ornek kullanim: start() veya stop() cagirin.

-- Global fonksiyonlar (executor uzerinden erisim icin)
_G.RunScript = startScript
_G.StopScript = stopScript

print("Delta mobil bakis scripti yuklendi. 'start' yazarak calistirin, 'stop' ile durdurun.")
