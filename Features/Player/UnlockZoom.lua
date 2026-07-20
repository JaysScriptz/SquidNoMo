local UnlockZoom = {}
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local DefaultMaxZoom = nil
local Connection = nil

local function apply()
    if LocalPlayer and Enabled then
        LocalPlayer.CameraMaxZoomDistance = 1000
    end
end

function UnlockZoom:Enable()
    if Enabled or not LocalPlayer then return end
    Enabled = true
    DefaultMaxZoom = LocalPlayer.CameraMaxZoomDistance
    apply()
    Connection = LocalPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
        if Enabled and LocalPlayer.CameraMaxZoomDistance < 1000 then
            LocalPlayer.CameraMaxZoomDistance = 1000
        end
    end)
end

function UnlockZoom:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    if LocalPlayer and DefaultMaxZoom ~= nil then
        LocalPlayer.CameraMaxZoomDistance = DefaultMaxZoom
    end
    DefaultMaxZoom = nil
end

function UnlockZoom:IsEnabled()
    return Enabled
end

function UnlockZoom:GetState()
    return Enabled and "on" or "off"
end

return UnlockZoom
