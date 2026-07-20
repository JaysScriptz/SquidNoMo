local ForceThirdPerson = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local Connection = nil
local Defaults = nil
local Elapsed = 0

local function apply()
    if not LocalPlayer then return end
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    LocalPlayer.CameraMinZoomDistance = math.max(6, LocalPlayer.CameraMinZoomDistance)
    LocalPlayer.CameraMaxZoomDistance = math.max(12, LocalPlayer.CameraMaxZoomDistance)
end

function ForceThirdPerson:Enable()
    if Enabled or not LocalPlayer then return end
    Enabled = true
    Defaults = {
        CameraMode = LocalPlayer.CameraMode,
        MinZoom = LocalPlayer.CameraMinZoomDistance,
        MaxZoom = LocalPlayer.CameraMaxZoomDistance,
    }
    apply()
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed >= 0.5 then
            Elapsed = 0
            apply()
        end
    end)
end

function ForceThirdPerson:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    if LocalPlayer and Defaults then
        pcall(function() LocalPlayer.CameraMode = Defaults.CameraMode end)
        pcall(function() LocalPlayer.CameraMinZoomDistance = Defaults.MinZoom end)
        pcall(function() LocalPlayer.CameraMaxZoomDistance = Defaults.MaxZoom end)
    end
    Defaults = nil
end

function ForceThirdPerson:IsEnabled()
    return Enabled
end

function ForceThirdPerson:GetState()
    return Enabled and "on" or "off"
end

return ForceThirdPerson
