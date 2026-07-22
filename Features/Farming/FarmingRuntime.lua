-- SquidNoMo farming controller runtime
-- Coordinates existing feature modules without relying on Roblox Instance require paths.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local BUILD_NUMBER = tonumber(Manifest.BuildNumber) or 0
local BUILD_TOKEN = tostring(Manifest.BuildToken or BUILD_NUMBER)

local FarmingRuntime = {
    Revision = tostring(Manifest.FarmingRuntimeRevision or "farming-runtime-r1"),
    BuildNumber = BUILD_NUMBER,
    Repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/",
}

local FeatureRuntime = Environment.__SquidNoMoFeatureRuntime
local expectedFeatureRevision = tostring(Manifest.FeatureRuntimeRevision or "compatibility-runtime-r4")
if type(FeatureRuntime) ~= "table"
    or FeatureRuntime.Revision ~= expectedFeatureRevision
    or tonumber(FeatureRuntime.BuildNumber) ~= BUILD_NUMBER
then
    local source = game:HttpGet(
        FarmingRuntime.Repository
            .. "Features/Shared/Runtime.lua?squidnomo_build="
            .. BUILD_TOKEN
    )
    FeatureRuntime = loadstring(source)()
end
if type(FeatureRuntime) ~= "table"
    or FeatureRuntime.Revision ~= expectedFeatureRevision
    or tonumber(FeatureRuntime.BuildNumber) ~= BUILD_NUMBER
then
    error("SquidNoMo farming runtime requires the current feature runtime build")
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
                .. "squidnomo_build=" .. BUILD_TOKEN
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


local function normalizeText(value)
    local text = string.lower(tostring(value or ""))
    text = string.gsub(text, "[_%-]", " ")
    text = string.gsub(text, "%s+", " ")
    return text
end

local function containsAnyText(text, tokens)
    text = normalizeText(text)
    for _, token in ipairs(tokens or {}) do
        if string.find(text, normalizeText(token), 1, true) then
            return true
        end
    end
    return false
end


local function containsModeValue(value, tokens)
    local text = normalizeText(value)
    local words = " " .. string.gsub(text, "[^%w]+", " ") .. " "
    local compact = string.gsub(text, "[^%w]", "")
    for _, token in ipairs(tokens or {}) do
        local normalized = normalizeText(token)
        local compactToken = string.gsub(normalized, "[^%w]", "")
        if string.find(words, " " .. normalized .. " ", 1, true)
            or compact == compactToken
            or compact == "frontman" .. compactToken
            or compact == compactToken .. "mode"
            or compact == "frontman" .. compactToken .. "mode"
        then
            return true
        end
    end
    return false
end

local function isSquidNoMoGui(instance)
    local current = instance
    while current do
        if current:IsA("ScreenGui") and string.lower(current.Name) == "squidnomo" then
            return true
        end
        current = current.Parent
    end
    return false
end

local FrontmanModeCache = nil

local function detectFrontmanMode()
    local now = os.clock()
    if FrontmanModeCache and now - FrontmanModeCache.Time < 0.75 then
        return FrontmanModeCache.Mode, FrontmanModeCache.Detail, FrontmanModeCache.Confidence
    end

    local scores = {Guard = 0, Player = 0}
    local strongest = {Guard = nil, Player = nil}
    local strongestWeight = {Guard = 0, Player = 0}

    local function record(mode, weight, source)
        if mode ~= "Guard" and mode ~= "Player" then return end
        weight = tonumber(weight) or 0
        scores[mode] = scores[mode] + weight
        if weight > strongestWeight[mode] then
            strongestWeight[mode] = weight
            strongest[mode] = tostring(source or "mode signal")
        end
    end

    local guardValues = {"guard", "staff", "soldier", "worker", "triangle", "square", "circle"}
    local playerValues = {"player", "contestant", "participant", "runner", "survivor"}
    local relevantKeys = {
        "frontman mode", "front man mode", "selected mode", "selected role",
        "current mode", "current role", "play as", "playing as", "active role",
        "mode", "role", "class", "job", "team", "side",
    }

    local function scoreExplicitValue(key, value, weight, source)
        local keyText = normalizeText(key)
        if not containsAnyText(keyText, relevantKeys) then return end
        local valueText = normalizeText(value)
        local hasGuard = containsModeValue(valueText, guardValues)
        local hasPlayer = containsModeValue(valueText, playerValues)
        if hasGuard and not hasPlayer then
            record("Guard", weight, source .. " = " .. tostring(value))
        elseif hasPlayer and not hasGuard then
            record("Player", weight, source .. " = " .. tostring(value))
        end
    end

    local function scanAttributes(instance, weight, source)
        if not instance then return end
        local ok, attributes = pcall(instance.GetAttributes, instance)
        if not ok or type(attributes) ~= "table" then return end
        for key, value in pairs(attributes) do
            scoreExplicitValue(key, value, weight, source .. " attribute " .. tostring(key))
        end
    end

    local function scoreStatusPhrase(value, weight, source)
        local text = normalizeText(value)
        local guardPhrase = containsAnyText(text, {
            "playing as guard", "currently guard", "current mode guard",
            "current role guard", "selected guard", "guard selected",
            "guard mode active", "guard duties active", "mode: guard", "role: guard",
        })
        local playerPhrase = containsAnyText(text, {
            "playing as player", "currently player", "current mode player",
            "current role player", "selected player", "player selected",
            "player mode active", "contestant mode active", "mode: player", "role: player",
        })
        if guardPhrase and not playerPhrase then
            record("Guard", weight, source)
        elseif playerPhrase and not guardPhrase then
            record("Player", weight, source)
        end
    end

    local player, character = getCharacter()
    if not player then
        FrontmanModeCache = {
            Time = now,
            Mode = nil,
            Detail = "Waiting for the local player",
            Confidence = 0,
        }
        return nil, FrontmanModeCache.Detail, 0
    end

    -- Explicit role/mode data is the strongest signal and is checked first.
    scanAttributes(player, 20, "Player")
    scanAttributes(character, 20, "Character")
    if player.Team then
        scoreExplicitValue("team", player.Team.Name, 16, "Team")
    end

    for _, child in ipairs(player:GetChildren()) do
        if child:IsA("ValueBase") then
            scoreExplicitValue(child.Name, child.Value, 18, "Player value " .. child.Name)
        elseif child:IsA("Folder") and containsAnyText(child.Name, {"role", "mode", "selection", "frontman"}) then
            scanAttributes(child, 16, "Player folder " .. child.Name)
            local scanned = 0
            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("ValueBase") then
                    scoreExplicitValue(descendant.Name, descendant.Value, 16, "Player folder value " .. descendant.Name)
                    scanned = scanned + 1
                    if scanned >= 40 then break end
                end
            end
        end
    end

    if character then
        local scanned = 0
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("ValueBase") then
                scoreExplicitValue(descendant.Name, descendant.Value, 18, "Character value " .. descendant.Name)
            end

            local appearance = normalizeText(descendant.Name)
            if containsAnyText(appearance, {
                "guard uniform", "guard mask", "triangle mask", "square mask",
                "circle mask", "soldier uniform", "staff uniform",
            }) then
                record("Guard", 9, "Guard uniform or mask detected")
            elseif containsAnyText(appearance, {
                "player uniform", "contestant uniform", "tracksuit", "track suit",
                "contestant outfit", "player outfit",
            }) then
                record("Player", 8, "Player uniform detected")
            end

            scanned = scanned + 1
            if scanned >= 140 then break end
        end
    end

    -- Some experiences store the local selection in a player-named folder.
    for _, dataRoot in ipairs({Workspace, ReplicatedStorage}) do
        for _, child in ipairs(dataRoot:GetChildren()) do
            local childName = normalizeText(child.Name)
            if childName == normalizeText(player.Name)
                or childName == tostring(player.UserId)
                or containsAnyText(childName, {"local player", "frontman selection", "frontman mode"})
            then
                scanAttributes(child, 16, dataRoot.Name .. "/" .. child.Name)
                local scanned = 0
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("ValueBase") then
                        scoreExplicitValue(
                            descendant.Name,
                            descendant.Value,
                            15,
                            dataRoot.Name .. "/" .. child.Name .. "/" .. descendant.Name
                        )
                        scanned = scanned + 1
                        if scanned >= 50 then break end
                    end
                end
            end
        end
    end

    -- Visible selection/status text is useful, but choice buttons by themselves
    -- are ignored because both Player and Guard buttons may be visible together.
    if type(FeatureRuntime.FindTargets) == "function" then
        local guiObjects = FeatureRuntime:FindTargets({
            Scope = "Gui",
            TargetClasses = {"TextLabel", "TextButton", "TextBox"},
            TargetTokens = {"frontman", "playing as", "selected", "current mode", "current role", "mode:", "role:"},
            VisibleOnly = true,
            MaxTargets = 90,
            CacheTTL = 0.45,
        })
        for _, object in ipairs(guiObjects) do
            if not isSquidNoMoGui(object) then
                local text = tostring(object.Text or object.Name)
                scoreStatusPhrase(text, 17, "Visible mode status: " .. text)
                scanAttributes(object, 15, "Mode UI " .. object.Name)

                local selected = false
                for _, attributeName in ipairs({"Selected", "IsSelected", "Active", "Chosen", "Current"}) do
                    local ok, value = pcall(object.GetAttribute, object, attributeName)
                    if ok and (value == true or normalizeText(value) == "selected" or normalizeText(value) == "active") then
                        selected = true
                        break
                    end
                end
                if selected then
                    local selectedText = normalizeText(text)
                    local hasGuard = containsModeValue(selectedText, guardValues)
                    local hasPlayer = containsModeValue(selectedText, playerValues)
                    if hasGuard and not hasPlayer then
                        record("Guard", 18, "Selected Guard mode button")
                    elseif hasPlayer and not hasGuard then
                        record("Player", 18, "Selected Player mode button")
                    end
                end
            end
        end
    end

    -- Equipped duty tools are a dependable fallback after the selection UI closes.
    if FeatureRuntime:FindTool({"taser", "stun", "baton", "guard weapon", "coffin", "corpse", "body bag"}) then
        record("Guard", 13, "Guard duty tool equipped")
    elseif FeatureRuntime:FindTool({"cooked", "meal", "tray", "raw", "ingredient", "uncooked"}) then
        record("Guard", 11, "Guard staff tool equipped")
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    for _, container in ipairs({character, backpack}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local toolName = normalizeText(item.Name)
                    local compactTool = string.gsub(toolName, "[^%w]", "")
                    if containsAnyText(toolName, {"marble", "dalgona", "lighter", "keycard"})
                        or compactTool == "key"
                    then
                        record("Player", 7, "Player minigame tool equipped")
                        break
                    end
                end
            end
        end
    end

    -- A detected minigame is only weak evidence. It cannot override an explicit
    -- Guard signal, but it helps Player mode settle after a player morph loads.
    local category = nil
    if type(FeatureRuntime.DetectGameCategory) == "function" then
        category = FeatureRuntime:DetectGameCategory()
    end
    if category then
        record("Player", 3, "Active minigame: " .. tostring(category))
    end

    local mode = nil
    local confidence = math.abs(scores.Guard - scores.Player)
    if scores.Guard >= 8 and scores.Guard >= scores.Player + 4 then
        mode = "Guard"
    elseif scores.Player >= 8 and scores.Player >= scores.Guard + 4 then
        mode = "Player"
    end

    local detail
    if mode then
        detail = string.format(
            "%s mode detected (%s)",
            mode,
            strongest[mode] or "combined role signals"
        )
    elseif scores.Guard > 0 or scores.Player > 0 then
        detail = string.format(
            "Mode is ambiguous (Guard %d / Player %d); waiting for the selected mode to settle",
            scores.Guard,
            scores.Player
        )
    else
        detail = "Waiting for Frontman Player or Guard mode selection"
    end

    FrontmanModeCache = {
        Time = now,
        Mode = mode,
        Detail = detail,
        Confidence = confidence,
    }
    return mode, detail, confidence
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
    for path, feature in pairs(self.Children) do
        if self.OwnedPaths[path] then
            local ok, err = setFeatureEnabled(feature, false)
            if not ok and not firstError then firstError = err end
        end
    end
    self.ActivePaths = {}
    self.OwnedPaths = {}
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
            if self.OwnedPaths[path] then
                local ok, err = setFeatureEnabled(feature, false)
                if not ok then return false, "failed to stop " .. tostring(path) .. ": " .. tostring(err) end
            end
            self.ActivePaths[path] = nil
            self.OwnedPaths[path] = nil
        end
    end

    for _, path in ipairs(paths) do
        local feature, loadError = self:_Load(path)
        if not feature then return false, loadError end
        local alreadyEnabled = featureEnabled(feature)
        local ok, err = setFeatureEnabled(feature, true)
        if not ok then return false, "failed to start " .. tostring(path) .. ": " .. tostring(err) end
        self.ActivePaths[path] = true
        if not alreadyEnabled then self.OwnedPaths[path] = true end
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
        OwnedPaths = {},
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

function FarmingRuntime:DetectFrontmanMode()
    return detectFrontmanMode()
end

Environment.__SquidNoMoFarmingRuntime = FarmingRuntime
return FarmingRuntime
