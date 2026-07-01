-- // MM2 Remote Dedektörü
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tüm RemoteEvent ve RemoteFunction'ları tara
local function scanRemotes(parent, depth)
    if depth > 5 then return end
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") then
            print("🔵 RemoteEvent bulundu:", child:GetFullName())
        elseif child:IsA("RemoteFunction") then
            print("🟢 RemoteFunction bulundu:", child:GetFullName())
        end
        if #child:GetChildren() > 0 then
            scanRemotes(child, depth + 1)
        end
    end
end

print("========= MM2 REMOTE LİSTESİ =========")
scanRemotes(workspace, 0)
scanRemotes(ReplicatedStorage, 0)
scanRemotes(LocalPlayer, 0)
if LocalPlayer.Character then
    scanRemotes(LocalPlayer.Character, 0)
end
print("========= LİSTE SONU =========")

-- Şimdi Remote'ları dinle (Hook)
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFireServer = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            print("🔥 ATEŞ TESPİT EDİLDİ!")
            print("   Remote Adı:", remote.Name)
            print("   Remote Tam Yolu:", remote:GetFullName())
            print("   Argüman Sayısı:", #args)
            for i, arg in ipairs(args) do
                print("   Argüman " .. i .. ":", arg, "Tür:", typeof(arg))
            end
            print("---")
            return oldFireServer(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.OnClientInvoke
        remote.OnClientInvoke = function(...)
            local args = {...}
            print("🔥 ATEŞ (Function) TESPİT EDİLDİ!")
            print("   Remote Adı:", remote.Name)
            print("   Remote Tam Yolu:", remote:GetFullName())
            print("   Argüman Sayısı:", #args)
            for i, arg in ipairs(args) do
                print("   Argüman " .. i .. ":", arg, "Tür:", typeof(arg))
            end
            print("---")
            return oldInvoke(...)
        end
    end
end

-- Tüm remote'ları hookla
local function hookAll(parent, depth)
    if depth > 5 then return end
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            pcall(function() hookRemote(child) end)
        end
        if #child:GetChildren() > 0 then
            hookAll(child, depth + 1)
        end
    end
end

hookAll(workspace, 0)
hookAll(ReplicatedStorage, 0)
hookAll(LocalPlayer, 0)
if LocalPlayer.Character then
    hookAll(LocalPlayer.Character, 0)
end

print("✅ Tüm Remote'lar dinleniyor. Şimdi ateş et!")
