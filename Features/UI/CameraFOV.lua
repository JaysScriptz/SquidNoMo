local CameraFOV = {}
local Workspace = game:GetService("Workspace")

local Current = 70
local Preferred = 90
local Enabled = false
local Defaults = {}
local CameraConnection = nil
local WorkspaceConnection = nil

local function disconnectCamera()
    if CameraConnection then
        CameraConnection:Disconnect()
        CameraConnection = nil
    end
end

local function getCamera()
    return Workspace.CurrentCamera
end

local function remember(camera)
    if camera and Defaults[camera] == nil then
        Defaults[camera] = camera.FieldOfView
        if not Enabled then
            Current = camera.FieldOfView
        end
    end
end

local function apply()
    local camera = getCamera()
    if camera then
        remember(camera)
        camera.FieldOfView = Current
    end
end

local function bindCamera()
    disconnectCamera()
    local camera = getCamera()
    if not camera then return end
    remember(camera)
    CameraConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if Enabled and math.abs(camera.FieldOfView - Current) > 0.1 then
            camera.FieldOfView = Current
        elseif not Enabled then
            Defaults[camera] = camera.FieldOfView
            Current = camera.FieldOfView
        end
    end)
    if Enabled then apply() end
end

bindCamera()
WorkspaceConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

function CameraFOV:Set(value)
    local camera = getCamera()
    local default = camera and (Defaults[camera] or camera.FieldOfView) or 70
    Current = math.clamp(tonumber(value) or default, 40, 120)
    if math.abs(Current - default) > 0.1 then
        Preferred = Current
        Enabled = true
    else
        Enabled = false
    end
    apply()
end

function CameraFOV:Get()
    return Current
end

function CameraFOV:Enable()
    Enabled = true
    Current = Preferred
    apply()
end

function CameraFOV:Disable()
    Enabled = false
    local camera = getCamera()
    if camera then
        remember(camera)
        Current = Defaults[camera] or 70
        camera.FieldOfView = Current
    end
end

function CameraFOV:IsEnabled()
    return Enabled
end

function CameraFOV:GetState()
    return Enabled and "on" or "off"
end

return CameraFOV
