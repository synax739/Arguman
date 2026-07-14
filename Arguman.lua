-- // Otomatik Boş Sunucu Bulucu (Teleport)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local function checkAndTeleport()
    -- Eğer sunucuda 1'den fazla oyuncu varsa (sen + başkaları)
    if #Players:GetPlayers() > 1 then
        -- Bir sonraki karede teleport et (çakışmayı önlemek için)
        wait(0.1)
        -- Aynı oyunun başka bir sunucusuna git
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

-- Oyuna girer girmez kontrol et
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    checkAndTeleport()
end)

-- Sunucudaki oyuncu sayısı değiştiğinde kontrol et (biri girdiğinde kaçmak için)
Players.PlayerAdded:Connect(function()
    wait(0.3)
    checkAndTeleport()
end)

-- Her 5 saniyede bir kontrol (güvenlik)
while wait(5) do
    checkAndTeleport()
end
