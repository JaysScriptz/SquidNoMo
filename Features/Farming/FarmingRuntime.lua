-- SquidNoMo farming controller runtime
-- Coordinates existing feature modules without relying on Roblox Instance require paths.

local Players = game:GetService("Players")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local FarmingRuntime = {
    Revision = "1.1b1-farming-r1",
    Repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/",
}

local FeatureRuntime = Environment.__SquidNoMoFeatureRuntime
if type(FeatureRuntime) ~= "table" or FeatureRuntime.Revision ~= "1.1b1-ultralight-r4" then
    local source = game:HttpGet(
        FarmingRuntime.Repository
            .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4"
    )
    FeatureRuntime = loadstring(source)()
end
if type(FeatureRuntime) ~= "table" or FeatureRuntime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo farming runtime requires feature runtime 1.1b1-ultralight-r4")
end

local ModuleCache = Environment.__SquidNoMoFarmingModuleCache
if type(ModuleCache) ~= "table" then
    ModuleCache = {}
    Environment.__SquidNoMoFarmingModuleCache = ModuleCache
end

local function getLoader()
    local session = Environment.__SquidNoMoSession
    if type(session) == "table" and type(session.Loader) == "table" then
        return session.Loader
    end
    return nil
end

local function loadFeature(path)
    if type(ModuleCache[path]) == "table" then
        return ModuleCache[path]
    end

    local loader = getLoader()
    local feature

    -- Reuse the same feature object used by the normal Games/Guards/Detective
    -- pages. This prevents a farming controller and a page toggle from creating
    -- two independent copies of the same worker.
    local manager = loader and loader.FeatureManager
    if manager and type(manager.Registry) == "table" then
        for id, entry in pairs(manager.Registry) do
            if entry.Path == path then
                if type(entry.Feature) == "table" then
                    feature = entry.Feature
                elseif type(manager.LoadCatalogFeature) == "function" then
                    local loaded, loadError = manager:LoadCatalogFeature(id)
                    if type(loaded) == "table" then
                        feature = loaded
                    elseif loadError then
                        error(tostring(loadError))
                    end
                end
                break
            end
        end
    end

    if not feature and loader and type(loader.LoadRemote) == "function" then
        feature = loader:LoadRemote(path)
    elseif not feature then
        local separator = string.find(path, "?", 1, true) and "&" or "?"
        local source = game:HttpGet(
            FarmingRuntime.Repository
                .. path
                .. separator
                .. "squidnomo_farming=1_1b1_farming_r1"
        )
        local chunk, compileError = loadstring(source)
        if not chunk then
            error("compile failed for " .. tostring(path) .. ": " .. tostring(compileError))
        end
        feature = chunk()
    end

    if type(feature) ~= "table" then
        error("feature module did not return a table: " .. tostring(path))
    end
    if type(feature.Toggle) ~= "function"
        and not (type(feature.Enable) == "function" and type(feature.Disable) == "function")
    then
        error("feature module has no Toggle or Enable/Disable API: " .. tostring(path))
    end

    ModuleCache[path] = feature
    return feature
end

local function featureEnabled(feature)
    if type(feature) ~= "table" then return false end
    if type(feature.IsEnabled) == "function" then
        local ok, value = pcall(feature.IsEnabled, feature)
        if ok then return value == true end
    end
    if type(feature.GetState) == "function" then
        local ok, value = pcall(feature.GetState, feature)
        if ok then
            value = string.lower(tostring(value or ""))
            return value == "on" or value == "enabled" or value == "full"
        end
    end
    return feature.Enabled == true or feature.Active == true
end

local function setFeatureEnabled(feature, state)
    state = state == true
    if type(feature) ~= "table" then
        return false, "feature is unavailable"
    end
    if featureEnabled(feature) == state then
        return true
    end

    local method = state and feature.Enable or feature.Disable
    if type(method) == "function" then
        local ok, result, detail = pcall(method, feature)
        if not ok then return false, tostring(result) end
        if result == false then return false, tostring(detail or "feature rejected the requested state") end
        return true
    end

    if type(feature.Toggle) == "function" then
        local ok, result, detail = pcall(feature.Toggle, feature, state)
        if not ok then return false, tostring(result) end
        if result == false then return false, tostring(detail or "feature rejected the requested state") end
        return true
    end

    return false, "feature has no supported toggle API"
end

local function getFeatureStatus(feature)
    if type(feature) ~= "table" then return "Off", "Not loaded" end
    if type(feature.GetStatus) == "function" then
        local ok, state, detail = pcall(feature.GetStatus, feature)
        if ok then
            return tostring(state or "Off"), tostring(detail or "")
        end
    end
    return featureEnabled(feature) and "Active" or "Off", featureEnabled(feature) and "Enabled" or "Disabled"
end

local function getCharacter()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return player, character, humanoid, root
end

local function normalizePathList(paths)
    local result = {}
    local seen = {}
    for _, path in ipairs(paths or {}) do
        if type(path) == "string" and path ~= "" and not seen[path] then
            seen[path] = true
            table.insert(result, path)
        end
    end
    return result
end

local ControllerMethods = {}
ControllerMethods.__index = ControllerMethods

function ControllerMethods:_SetStatus(state, detail)
    state = tostring(state or "Off")
    detail = tostring(detail or "")
    if self.Status == state and self.StatusDetail == detail then return end
    self.Status = state
    self.StatusDetail = detail
    for _, callback in pairs(self.StatusListeners) do
        task.spawn(function()
            pcall(callback, state, detail)
        end)
    end
end

function ControllerMethods:GetStatus()
    return self.Status, self.StatusDetail
end

function ControllerMethods:SubscribeStatus(callback)
    if type(callback) ~= "function" then return nil end
    self.NextListenerId = self.NextListenerId + 1
    local id = self.NextListenerId
    self.StatusListeners[id] = callback
    local connection = {}
    function connection:Disconnect()
        self.Connected = false
        if self._owner then self._owner.StatusListeners[self._id] = nil end
    end
    connection.Connected = true
    connection._owner = self
    connection._id = id
    return connection
end

function ControllerMethods:_Load(path)
    if type(self.Children[path]) == "table" then
        return self.Children[path]
    end
    local ok, result = pcall(loadFeature, path)
    if not ok then
        return nil, tostring(result)
    end
    self.Children[path] = result
    return result
end

function ControllerMethods:_DisableAll()
    local firstError
    for _, feature in pairs(self.Children) do
        local ok, err = setFeatureEnabled(feature, false)
        if not ok and not firstError then firstError = err end
    end
    self.ActivePaths = {}
    return firstError == nil, firstError
end

function ControllerMethods:_SwitchTo(paths)
    paths = normalizePathList(paths)
    local desired = {}
    for _, path in ipairs(paths) do desired[path] = true end

    -- Stop the old phase before starting the next one so movement and action
    -- leases cannot fight during a farming transition.
    for path, feature in pairs(self.Children) do
        if self.ActivePaths[path] and not desired[path] then
            local ok, err = setFeatureEnabled(feature, false)
            if not ok then return false, "failed to stop " .. tostring(path) .. ": " .. tostring(err) end
            self.ActivePaths[path] = nil
        end
    end

    for _, path in ipairs(paths) do
        local feature, loadError = self:_Load(path)
        if not feature then return false, loadError end
        local ok, err = setFeatureEnabled(feature, true)
        if not ok then return false, "failed to start " .. tostring(path) .. ": " .. tostring(err) end
        self.ActivePaths[path] = true
    end
    return true
end

function ControllerMethods:_Summarize(paths, fallbackDetail)
    local activeCount = 0
    local waitingCount = 0
    local firstWaiting
    for _, path in ipairs(paths or {}) do
        local feature = self.Children[path]
        local state, detail = getFeatureStatus(feature)
        local normalized = string.lower(state)
        if normalized == "error" then
            return "Error", detail ~= "" and detail or ("Child failed: " .. tostring(path))
        elseif normalized == "active" or normalized == "complete" then
            activeCount = activeCount + 1
        elseif normalized == "waiting" or normalized == "starting" then
            waitingCount = waitingCount + 1
            firstWaiting = firstWaiting or detail
        end
    end

    if activeCount > 0 then
        return "Active", fallbackDetail
    elseif waitingCount > 0 then
        return "Waiting", firstWaiting or fallbackDetail
    end
    return "Waiting", fallbackDetail
end

function ControllerMethods:_RunStep()
    local ok, paths, detail = xpcall(function()
        return self.Config.Select(self, FarmingRuntime, FeatureRuntime)
    end, debug.traceback)
    if not ok then
        self.LastError = tostring(paths)
        self:_DisableAll()
        self:_SetStatus("Error", self.LastError)
        return false
    end

    paths = normalizePathList(paths)
    detail = tostring(detail or self.Config.WaitingMessage or "Waiting for a supported farming task")
    if #paths == 0 then
        self:_DisableAll()
        self:_SetStatus("Waiting", detail)
        return false
    end

    local switched, switchError = self:_SwitchTo(paths)
    if not switched then
        self.LastError = tostring(switchError)
        self:_SetStatus("Error", self.LastError)
        return false
    end

    local state, statusDetail = self:_Summarize(paths, detail)
    self:_SetStatus(state, statusDetail)
    return state == "Active"
end

function ControllerMethods:Toggle(state)
    state = state == true
    if self.Enabled == state then return true end

    self.Enabled = state
    self.LastError = nil
    local scheduler = FeatureRuntime.Scheduler
    if scheduler and type(scheduler.Remove) == "function" then
        scheduler:Remove(self)
    end

    if not state then
        local ok, err = self:_DisableAll()
        self:_SetStatus("Off", "Disabled")
        if not ok then return false, err end
        return true
    end

    self:_SetStatus("Starting", "Preparing " .. self.Name)
    if not scheduler or type(scheduler.Add) ~= "function" then
        self.Enabled = false
        self:_SetStatus("Error", "Shared scheduler is unavailable")
        return false, "shared scheduler is unavailable"
    end

    scheduler:Add(
        self,
        self.Config.Interval or 0.8,
        self.Config.IdleInterval or 1.5,
        function(owner)
            return owner:_RunStep()
        end
    )
    self:_RunStep()
    return true
end

function ControllerMethods:Enable()
    return self:Toggle(true)
end

function ControllerMethods:Disable()
    return self:Toggle(false)
end

function ControllerMethods:IsEnabled()
    return self.Enabled == true
end

function ControllerMethods:GetState()
    return self.Enabled and "on" or "off"
end

function FarmingRuntime:CreateController(config)
    assert(type(config) == "table", "farming controller config must be a table")
    assert(type(config.Select) == "function", "farming controller Select callback is required")
    return setmetatable({
        Id = tostring(config.Id or config.Name or "farming.controller"),
        Name = tostring(config.Name or "Farming Controller"),
        Description = tostring(config.Description or ""),
        Config = config,
        Enabled = false,
        Status = "Off",
        StatusDetail = "Disabled",
        LastError = nil,
        Children = {},
        ActivePaths = {},
        StatusListeners = {},
        NextListenerId = 0,
    }, ControllerMethods)
end

function FarmingRuntime:GetCharacter()
    return getCharacter()
end

function FarmingRuntime:FindTool(tokens)
    if type(FeatureRuntime.FindTool) == "function" then
        return FeatureRuntime:FindTool(tokens or {})
    end
    return nil
end

function FarmingRuntime:FindNearest(config, origin)
    if type(FeatureRuntime.FindNearest) ~= "function" then return nil, math.huge end
    return FeatureRuntime:FindNearest(config or {}, origin)
end

Environment.__SquidNoMoFarmingRuntime = FarmingRuntime
return FarmingRuntime
