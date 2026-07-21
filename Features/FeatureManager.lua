--// SquidNoMo live feature registry and loader

local FeatureManager = {}

FeatureManager.Features = {}
FeatureManager.Registry = {}
FeatureManager.Listeners = {}
FeatureManager._nextListenerId = 0

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
    -- The module can be re-used after a character rebuild, so clear stale entries
    -- before registering the current build's live and catalog features.
    self.Registry = {}

    local Features = {}

    Features.Shared = {}
    Features.Shared.Runtime = Load(Loader, "Features/Shared/Runtime.lua")
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
        local enabled = entry.PendingEnabled == true
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

function FeatureManager:SetFeatureState(id, state)
    local entry = self.Registry[id]
    if not entry then
        return false
    end

    entry.State = state
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
            local enabled = data.Enabled == true

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
                entry.PendingEnabled = enabled
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
        entry.State = "off"
        count = count + 1
    end

    self.SuppressPersistence = false
    self:Notify()
    return count
end

function FeatureManager:Notify()
    local snapshot = self:GetSnapshot()

    for id, callback in pairs(self.Listeners) do
        local ok = pcall(callback, snapshot)
        if not ok then
            self.Listeners[id] = nil
        end
    end

    if not self.SuppressPersistence
        and type(self.PersistenceCallback) == "function"
    then
        pcall(self.PersistenceCallback, snapshot)
    end
end

return FeatureManager
