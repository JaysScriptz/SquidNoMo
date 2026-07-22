--// SquidNoMo live feature registry and loader

local FeatureManager = {}

FeatureManager.Features = {}
FeatureManager.Registry = {}
FeatureManager.Listeners = {}
FeatureManager._nextListenerId = 0
FeatureManager.AutoApplyPerGameEnabled = false
FeatureManager.LightweightModeEnabled = true
FeatureManager.DetectedGameCategory = nil
FeatureManager._gameWatcherOwner = {Enabled = true, Name = "Game mode monitor"}

local validCategories = {
    Safe = true,
    SemiSafe = true,
    Experimental = true,
}

local function Load(Loader, Path)
    if type(Loader.LoadRemote) == "function" then
        return Loader:LoadRemote(Path)
    end
    return loadstring(game:HttpGet(Loader.Config.Repository .. Path))()
end

local function normalizeCategory(category)
    local value = tostring(category or "")
    value = string.gsub(value, "[%s_%-]", "")
    value = string.lower(value)

    if value == "safe" then
        return "Safe"
    elseif value == "semisafe" then
        return "SemiSafe"
    elseif value == "experimental" then
        return "Experimental"
    end

    return nil
end

local function safeFeatureState(entry)
    local feature = entry and entry.Feature
    local options = entry and entry.Options or {}

    local ok, state = pcall(function()
        if type(options.GetState) == "function" then
            return options.GetState(feature, entry)
        end
        if type(feature) == "table" and type(feature.GetState) == "function" then
            return feature:GetState()
        end
        if type(feature) == "table"
            and type(feature.IsPartiallyEnabled) == "function"
            and feature:IsPartiallyEnabled()
        then
            return "partial"
        end
        if type(feature) == "table" and type(feature.IsEnabled) == "function" then
            return feature:IsEnabled() and "on" or "off"
        end
        if type(feature) == "table" then
            if feature.Enabled == true or feature.Active == true then
                return "on"
            end
        end
        return entry and entry.State or "off"
    end)

    if not ok then
        return "off"
    end

    if state == true then
        return "on"
    elseif state == false then
        return "off"
    end

    state = string.lower(tostring(state or "off"))
    if state == "on" or state == "enabled" or state == "fully" or state == "full" then
        return "on"
    elseif state == "partial" or state == "mixed" or state == "partially" then
        return "partial"
    end

    return "off"
end

local function setFeatureEnabled(feature, enabled)
    if type(feature) ~= "table" then
        return false
    end

    local method = enabled and feature.Enable or feature.Disable
    if type(method) == "function" then
        local ok, result = pcall(method, feature)
        return ok and result ~= false
    end

    if type(feature.Toggle) == "function" then
        local ok, result = pcall(
            feature.Toggle,
            feature,
            enabled
        )
        return ok and result ~= false
    end

    return false
end

function FeatureManager:Initialize(Loader)
    self.Loader = Loader
    -- The module can be re-used after a character rebuild, so clear stale entries
    -- before registering the current build's live and catalog features.
    self.Registry = {}
    self.DetectedGameCategory = nil
    self.DetectedGameScore = 0

    local Features = {}

    Features.Shared = {}
    Features.Shared.Runtime = Load(Loader, "Features/Shared/Runtime.lua")
    if type(Features.Shared.Runtime.SetLightweightMode) == "function" then
        Features.Shared.Runtime:SetLightweightMode(self.LightweightModeEnabled)
    end
    if type(Features.Shared.Runtime.WarmIndices) == "function" then
        Features.Shared.Runtime:WarmIndices()
    end
    Features.Shared.PlayerRuntime = Load(Loader, "Features/Shared/PlayerRuntime.lua")
    Features.Shared.RoleService = Load(Loader, "Features/Shared/RoleService.lua")
    Loader.Features = Features

    Features.Player = Load(Loader, "Features/Player/Init.lua")
    Features.Player:Initialize(Loader)

    Features.UI = Load(Loader, "Features/UI/Init.lua")
    Features.UI:Initialize(Loader)

    self.Features = Features
    Loader.Features = Features

    if Loader.FeatureCatalog then
        self:RegisterCatalog(Loader.FeatureCatalog)
    end

    self:_EnsureGameWatcher()
    self:Notify()
    return Features
end

function FeatureManager:Get()
    return self.Features
end

function FeatureManager:GetEntry(id)
    return self.Registry[id]
end

function FeatureManager:GetFeature(id)
    local entry = self.Registry[id]
    return entry and entry.Feature or nil
end


function FeatureManager:SetLightweightModeEnabled(state)
    self.LightweightModeEnabled = state ~= false
    local runtime = self.Features and self.Features.Shared and self.Features.Shared.Runtime
    if runtime and type(runtime.SetLightweightMode) == "function" then
        runtime:SetLightweightMode(self.LightweightModeEnabled)
    end
    self:Notify()
    return true
end

function FeatureManager:GetDetectedGameCategory()
    return self.DetectedGameCategory
end

function FeatureManager:SetManualGameCategory(category)
    if type(category) ~= "string" or category == "" then return false end
    -- Manual page selection is only a fallback while automatic detection is
    -- genuinely uncertain. It will not overwrite a strong confirmed game just
    -- because the user browsed another category.
    if self.DetectedGameCategory and (tonumber(self.DetectedGameScore) or 0) >= 30 then
        return false
    end
    local runtime = self.Features and self.Features.Shared and self.Features.Shared.Runtime
    if runtime and type(runtime.SetManualGameHint) == "function" then
        runtime:SetManualGameHint(category, 14)
    end
    self:_SetDetectedGame(category, 29, "manual fallback")
    if self.AutoApplyPerGameEnabled then self:_ApplyDetectedGame(true) end
    return true
end

function FeatureManager:_SetDetectedGame(category, score, source)
    if type(category) ~= "string" or category == "" then return false end
    local changed = category ~= self.DetectedGameCategory
    self.DetectedGameCategory = category
    self.DetectedGameScore = tonumber(score) or 0
    self.DetectedGameSource = tostring(source or "visual detector")
    self._lastDetectedAt = os.clock()

    local environment = _G
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then environment = result end
    end
    environment.__SquidNoMoDetectedGame = category
    environment.__SquidNoMoDetectedGameAt = os.clock()
    if changed then self:Notify(true) end
    return changed
end

local function hasTransientOwner(entry)
    return type(entry.TransientOwners) == "table" and next(entry.TransientOwners) ~= nil
end

function FeatureManager:SetTransientFeature(id, owner, enabled)
    local entry = self.Registry[id]
    if not entry or owner == nil then return false, "feature or owner is unavailable" end
    entry.TransientOwners = entry.TransientOwners or setmetatable({}, {__mode = "k"})
    if enabled then entry.TransientOwners[owner] = true else entry.TransientOwners[owner] = nil end

    local wanted = entry.DesiredEnabled == true or hasTransientOwner(entry)
    local environment = _G
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then environment = result end
    end
    local detectedGame = self.DetectedGameCategory or environment.__SquidNoMoDetectedGame
    local allowed = entry.PageName ~= "Games"
        or not self.AutoApplyPerGameEnabled
        or entry.CategoryName == detectedGame
    local shouldRun = wanted and allowed
    local feature = entry.Feature
    if shouldRun and type(feature) ~= "table" then
        feature = self:LoadCatalogFeature(id)
    end
    if type(feature) == "table" then
        local ok = setFeatureEnabled(feature, shouldRun)
        entry.State = ok and (shouldRun and "on" or "off") or safeFeatureState(entry)
        self:Notify()
        return ok
    end
    entry.State = "off"
    self:Notify()
    return not shouldRun, shouldRun and "feature could not be loaded" or nil
end

function FeatureManager:LoadCatalogFeature(id)
    local entry = self.Registry[id]
    if not entry then return nil, "feature is not registered" end
    if type(entry.Feature) == "table" then return entry.Feature end
    if not entry.Path or not self.Loader then return nil, "feature path is unavailable" end
    local ok, feature = pcall(Load, self.Loader, entry.Path)
    if not ok or type(feature) ~= "table" then
        return nil, tostring(feature or "module did not return a feature table")
    end
    self:AttachCatalogFeature(id, feature)
    return feature
end

function FeatureManager:_ApplyDetectedGame(force)
    if not self.AutoApplyPerGameEnabled then return 0 end
    local runtime = self.Features and self.Features.Shared and self.Features.Shared.Runtime
    if not runtime or type(runtime.DetectGameCategory) ~= "function" then return 0 end

    local detected, detectionScore = runtime:DetectGameCategory()
    local now = os.clock()
    if detected then
        self._lastDetectedAt = now
    elseif self.DetectedGameCategory and now - (self._lastDetectedAt or 0) < 4 then
        detected = self.DetectedGameCategory
    end

    if not detected then
        -- Detection is intentionally conservative. An uncertain/transition state must
        -- never turn off a feature the user enabled manually. Keep the last confirmed
        -- category and currently running features until a different game is positively
        -- identified.
        return 0
    end

    local categoryChanged = detected ~= self.DetectedGameCategory
    if not force and not categoryChanged then return 0 end
    self:_SetDetectedGame(detected, detectionScore, "runtime")

    self.SuppressPersistence = true
    local changed = 0
    for id, entry in pairs(self.Registry) do
        if entry.PageName == "Games" then
            local profileWanted = entry.DesiredEnabled == true or hasTransientOwner(entry)
            local shouldEnable = entry.CategoryName == detected and profileWanted
            local feature = entry.Feature
            if shouldEnable and type(feature) ~= "table" then
                feature = self:LoadCatalogFeature(id)
            end
            if type(feature) == "table" then
                local currentlyEnabled = safeFeatureState(entry) ~= "off"
                if currentlyEnabled ~= shouldEnable and setFeatureEnabled(feature, shouldEnable) then
                    changed = changed + 1
                end
                entry.State = shouldEnable and "on" or "off"
            else
                entry.State = "off"
            end
        end
    end
    self.SuppressPersistence = false
    if changed > 0 or categoryChanged then self:Notify(true) end
    return changed
end

function FeatureManager:_EnsureGameWatcher()
    self._gameWatcherGeneration = (self._gameWatcherGeneration or 0) + 1
    local generation = self._gameWatcherGeneration
    local runtime = self.Features and self.Features.Shared and self.Features.Shared.Runtime
    if not runtime or type(runtime.DetectGameCategory) ~= "function" then return false end

    task.spawn(function()
        while generation == self._gameWatcherGeneration do
            local detected, score = runtime:DetectGameCategory()
            if detected then
                local changed = self:_SetDetectedGame(detected, score, "continuous detector")
                if self.AutoApplyPerGameEnabled then
                    self:_ApplyDetectedGame(changed)
                end
            end
            task.wait(0.42)
        end
    end)
    return true
end

function FeatureManager:SetAutoApplyPerGameEnabled(state)
    self.AutoApplyPerGameEnabled = state == true
    self:_EnsureGameWatcher()
    if self.AutoApplyPerGameEnabled then
        self:_ApplyDetectedGame(true)
    end
    self:Notify()
    return true
end

function FeatureManager:ClearGameProfiles()
    self.SuppressPersistence = true
    local count = 0
    for _, entry in pairs(self.Registry) do
        if entry.PageName == "Games" then
            entry.DesiredEnabled = false
            entry.PendingEnabled = nil
            if type(entry.Feature) == "table" then setFeatureEnabled(entry.Feature, false) end
            entry.State = "off"
            count = count + 1
        end
    end
    self.SuppressPersistence = false
    self:Notify()
    return count
end

function FeatureManager:RegisterFeature(id, feature, options)
    assert(type(id) == "string" and id ~= "", "Feature id is required")
    assert(type(feature) == "table", "Feature table is required")

    options = options or {}
    local category = normalizeCategory(options.Category)
    assert(category and validCategories[category], "Category must be Safe, SemiSafe, or Experimental")

    local previous = self.Registry[id]
    self.Registry[id] = {
        Id = id,
        Name = tostring(options.Name or (previous and previous.Name) or id),
        Category = category,
        Feature = feature,
        Options = options,
        State = previous and previous.State or options.InitialState or "off",
        IsCatalog = previous and previous.IsCatalog or false,
        Path = previous and previous.Path or options.Path,
        Description = options.Description or (previous and previous.Description),
        PendingEnabled = previous and previous.PendingEnabled or nil,
        PageName = options.PageName or (previous and previous.PageName),
        CategoryName = options.CategoryName or (previous and previous.CategoryName),
        DesiredEnabled = previous and previous.DesiredEnabled or options.DesiredEnabled or false,
    }

    if self.Registry[id].PendingEnabled ~= nil then
        local enabled = self.Registry[id].PendingEnabled == true
        if setFeatureEnabled(feature, enabled) then
            self.Registry[id].State = enabled and "on" or "off"
            self.Registry[id].PendingEnabled = nil
        end
    end

    self:Notify()
    return self.Registry[id]
end

function FeatureManager:RegisterCatalogFeature(definition)
    if type(definition) ~= "table" then
        return nil
    end

    local id = tostring(definition.Id or "")
    if id == "" then
        return nil
    end

    local existing = self.Registry[id]
    if existing then
        existing.Name = tostring(definition.Name or existing.Name or id)
        existing.Path = definition.Path or existing.Path
        existing.Description = definition.Description or existing.Description
        existing.PageName = definition.PageName or existing.PageName
        existing.CategoryName = definition.CategoryName or existing.CategoryName
        existing.IsCatalog = true
        return existing
    end

    local category = normalizeCategory(definition.Category) or "Experimental"
    local entry = {
        Id = id,
        Name = tostring(definition.Name or id),
        Category = category,
        Feature = nil,
        Options = {
            Name = definition.Name,
            Category = category,
            Description = definition.Description,
            Path = definition.Path,
        },
        State = "off",
        IsCatalog = true,
        Path = definition.Path,
        Description = definition.Description,
        PageName = definition.PageName,
        CategoryName = definition.CategoryName,
        DesiredEnabled = false,
    }

    self.Registry[id] = entry
    return entry
end

function FeatureManager:RegisterCatalog(catalog)
    if type(catalog) ~= "table" or type(catalog.GetAllFeatures) ~= "function" then
        return 0
    end

    local ok, features = pcall(catalog.GetAllFeatures, catalog)
    if not ok or type(features) ~= "table" then
        return 0
    end

    local count = 0
    for _, definition in ipairs(features) do
        if self:RegisterCatalogFeature(definition) then
            count = count + 1
        end
    end

    return count
end

function FeatureManager:AttachCatalogFeature(id, feature)
    if type(id) ~= "string" or id == "" or type(feature) ~= "table" then
        return false
    end

    local entry = self.Registry[id]
    if not entry then
        entry = self:RegisterCatalogFeature({
            Id = id,
            Name = id,
            Category = "Experimental",
        })
    end

    entry.Feature = feature

    if entry.PendingEnabled ~= nil then
        entry.DesiredEnabled = entry.PendingEnabled == true
        local enabled = entry.DesiredEnabled or hasTransientOwner(entry)
        if self.AutoApplyPerGameEnabled and entry.PageName == "Games" then
            enabled = entry.CategoryName == self.DetectedGameCategory and enabled
        end
        if setFeatureEnabled(feature, enabled) then
            entry.State = enabled and "on" or "off"
            entry.PendingEnabled = nil
        end
    else
        entry.State = safeFeatureState(entry)
    end

    self:Notify()
    return true
end

function FeatureManager:UnregisterFeature(id)
    self.Registry[id] = nil
    self:Notify()
end

function FeatureManager:SetFeatureState(id, state, options)
    local entry = self.Registry[id]
    if not entry then return false end
    options = options or {}
    local enabled = tostring(state or "off"):lower() ~= "off"
    entry.State = enabled and "on" or "off"

    if entry.PageName == "Games" then
        entry.DesiredEnabled = enabled

        -- A direct tap is a manual command, even when Auto Apply per Game is on.
        -- The old behavior only armed the profile and did nothing unless automatic
        -- game detection happened to succeed, which made every toggle appear broken.
        if options.Manual == true then
            local feature = entry.Feature
            if type(feature) ~= "table" then
                feature = self:LoadCatalogFeature(id)
            end
            if type(feature) ~= "table" then
                entry.State = "off"
                self:Notify()
                return false
            end
            local applied = setFeatureEnabled(feature, enabled)
            entry.State = applied and (enabled and "on" or "off") or safeFeatureState(entry)
            if enabled then
                self.ManualGameCategory = entry.CategoryName
                self.ManualGameCategoryAt = os.clock()
            end
            self:Notify()
            return applied
        end

        if self.AutoApplyPerGameEnabled then
            local shouldRun = entry.CategoryName == self.DetectedGameCategory and enabled
            local feature = entry.Feature
            if shouldRun and type(feature) ~= "table" then
                feature = self:LoadCatalogFeature(id)
            end
            if type(feature) == "table" and safeFeatureState(entry) ~= (shouldRun and "on" or "off") then
                setFeatureEnabled(feature, shouldRun)
                entry.State = shouldRun and "on" or "off"
            elseif not shouldRun then
                entry.State = "off"
            end
        end
    end
    self:Notify()
    return true
end

function FeatureManager:SetCategoryEnabled(category, enabled)
    local normalized = normalizeCategory(category)
    if not normalized then
        return 0
    end

    local changed = 0
    for _, entry in pairs(self.Registry) do
        if entry.Category == normalized and type(entry.Feature) == "table" then
            if setFeatureEnabled(entry.Feature, enabled) then
                entry.State = enabled and "on" or "off"
                changed = changed + 1
            end
        end
    end

    self:Notify()
    return changed
end

function FeatureManager:GetLoadedCount()
    local count = 0
    for _, entry in pairs(self.Registry) do
        if type(entry.Feature) == "table" then
            count = count + 1
        end
    end
    return count
end

function FeatureManager:GetTotalCount()
    local count = 0
    for _ in pairs(self.Registry) do
        count = count + 1
    end
    return count
end

function FeatureManager:GetSnapshot()
    local snapshot = {
        FullyOn = 0,
        Partial = 0,
        Off = 0,
        Total = 0,
        Categories = {
            Safe = {Total = 0, On = 0, Partial = 0, Off = 0, State = "empty"},
            SemiSafe = {Total = 0, On = 0, Partial = 0, Off = 0, State = "empty"},
            Experimental = {Total = 0, On = 0, Partial = 0, Off = 0, State = "empty"},
        },
    }

    for _, entry in pairs(self.Registry) do
        local state = safeFeatureState(entry)
        local category = snapshot.Categories[entry.Category]
            or snapshot.Categories.Experimental

        snapshot.Total = snapshot.Total + 1
        category.Total = category.Total + 1

        if state == "on" then
            snapshot.FullyOn = snapshot.FullyOn + 1
            category.On = category.On + 1
        elseif state == "partial" then
            snapshot.Partial = snapshot.Partial + 1
            category.Partial = category.Partial + 1
        else
            snapshot.Off = snapshot.Off + 1
            category.Off = category.Off + 1
        end
    end

    for _, category in pairs(snapshot.Categories) do
        if category.Total == 0 then
            category.State = "empty"
        elseif category.On == category.Total then
            category.State = "on"
        elseif category.Off == category.Total then
            category.State = "off"
        else
            category.State = "partial"
        end
    end

    return snapshot
end

function FeatureManager:Subscribe(callback)
    assert(type(callback) == "function", "Feature listener must be a function")

    self._nextListenerId = self._nextListenerId + 1
    local id = self._nextListenerId
    self.Listeners[id] = callback

    local disconnected = false
    local connection = {}

    function connection:Disconnect()
        if disconnected then
            return
        end
        disconnected = true
        FeatureManager.Listeners[id] = nil
    end

    return connection
end

local function packColor(value)
    if typeof(value) ~= "Color3" then
        return nil
    end
    return {R = value.R, G = value.G, B = value.B}
end

local function unpackColor(value)
    if type(value) ~= "table" then
        return nil
    end

    local r = tonumber(value.R)
    local g = tonumber(value.G)
    local b = tonumber(value.B)
    if not r or not g or not b then
        return nil
    end

    return Color3.new(
        math.clamp(r, 0, 1),
        math.clamp(g, 0, 1),
        math.clamp(b, 0, 1)
    )
end

function FeatureManager:SetPersistenceCallback(callback)
    self.PersistenceCallback =
        type(callback) == "function" and callback or nil
end

function FeatureManager:ExportSettings()
    local result = {}

    for id, entry in pairs(self.Registry) do
        local feature = entry.Feature
        local data = {
            Enabled = safeFeatureState(entry) ~= "off",
            DesiredEnabled = entry.DesiredEnabled == true,
        }

        if type(feature) == "table" and type(feature.Get) == "function" then
            local ok, value = pcall(feature.Get, feature)
            if ok and (
                type(value) == "number"
                or type(value) == "string"
                or type(value) == "boolean"
            ) then
                data.Value = value
            end
        end

        if type(feature) == "table" and type(feature.GetColor) == "function" then
            local ok, color = pcall(feature.GetColor, feature)
            if ok then
                data.Color = packColor(color)
            end
        end

        result[id] = data
    end

    return result
end

function FeatureManager:ApplySettings(saved)
    if type(saved) ~= "table" then
        return 0
    end

    self.SuppressPersistence = true
    local count = 0

    for id, data in pairs(saved) do
        local entry = self.Registry[id]
        if entry and type(data) == "table" then
            local feature = entry.Feature
            local desired = data.DesiredEnabled
            if desired == nil then desired = data.Enabled end
            entry.DesiredEnabled = desired == true
            local enabled = data.Enabled == true
            if self.AutoApplyPerGameEnabled and entry.PageName == "Games" then
                enabled = entry.DesiredEnabled and entry.CategoryName == self.DetectedGameCategory
            end

            if type(feature) == "table" then
                if data.Value ~= nil and type(feature.Set) == "function" then
                    pcall(feature.Set, feature, data.Value)
                end

                local color = unpackColor(data.Color)
                if color and type(feature.SetColor) == "function" then
                    pcall(feature.SetColor, feature, color)
                end

                if setFeatureEnabled(feature, enabled) then
                    entry.State = enabled and "on" or "off"
                    count = count + 1
                end
            elseif entry.IsCatalog then
                -- Catalog features are loaded only when their page button is used.
                -- Preserve the requested state and apply it when the module attaches.
                entry.PendingEnabled = entry.PageName == "Games" and entry.DesiredEnabled or enabled
                entry.State = "off"
            end
        end
    end

    self.SuppressPersistence = false
    self:Notify()
    return count
end

function FeatureManager:ResetAll()
    self.SuppressPersistence = true
    local count = 0

    for _, entry in pairs(self.Registry) do
        local feature = entry.Feature
        local options = entry.Options or {}

        if type(feature) == "table" then
            setFeatureEnabled(feature, false)

            if options.DefaultValue ~= nil and type(feature.Set) == "function" then
                pcall(feature.Set, feature, options.DefaultValue)
            end

            if typeof(options.DefaultColor) == "Color3"
                and type(feature.SetColor) == "function"
            then
                pcall(feature.SetColor, feature, options.DefaultColor)
            end
        end

        entry.PendingEnabled = nil
        entry.DesiredEnabled = false
        entry.State = "off"
        count = count + 1
    end

    self.SuppressPersistence = false
    self:Notify()
    return count
end

function FeatureManager:Notify(skipPersistence)
    local snapshot = self:GetSnapshot()

    for id, callback in pairs(self.Listeners) do
        local ok = pcall(callback, snapshot)
        if not ok then
            self.Listeners[id] = nil
        end
    end

    if not skipPersistence
        and not self.SuppressPersistence
        and type(self.PersistenceCallback) == "function"
    then
        pcall(self.PersistenceCallback, snapshot)
    end
end

return FeatureManager
