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
    local feature = entry.Feature
    local options = entry.Options or {}

    local ok, state = pcall(function()
        if type(options.GetState) == "function" then
            return options.GetState(feature, entry)
        end
        if type(feature) == "table" and type(feature.GetState) == "function" then
            return feature:GetState()
        end
        if type(feature) == "table" and type(feature.IsPartiallyEnabled) == "function" and feature:IsPartiallyEnabled() then
            return "partial"
        end
        if type(feature) == "table" and type(feature.IsEnabled) == "function" then
            return feature:IsEnabled() and "on" or "off"
        end
        return entry.State or "off"
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
    if state == "on" or state == "enabled" or state == "fully" then
        return "on"
    elseif state == "partial" or state == "mixed" or state == "partially" then
        return "partial"
    end

    return "off"
end

function FeatureManager:Initialize(Loader)
    local Features = {}

    Features.Shared = {}
    Features.Shared.RoleService = Load(Loader, "Features/Shared/RoleService.lua")
    Loader.Features = Features

    Features.Player = Load(Loader, "Features/Player/Init.lua")
    Features.Player:Initialize(Loader)

    Features.UI = Load(Loader, "Features/UI/Init.lua")
    Features.UI:Initialize(Loader)

    self.Features = Features
    Loader.Features = Features
    self:Notify()

    return Features
end

function FeatureManager:Get()
    return self.Features
end

function FeatureManager:RegisterFeature(id, feature, options)
    assert(type(id) == "string" and id ~= "", "Feature id is required")
    assert(type(feature) == "table", "Feature table is required")

    options = options or {}
    local category = normalizeCategory(options.Category)
    assert(category and validCategories[category], "Category must be Safe, SemiSafe, or Experimental")

    self.Registry[id] = {
        Id = id,
        Name = tostring(options.Name or id),
        Category = category,
        Feature = feature,
        Options = options,
        State = options.InitialState or "off",
    }

    self:Notify()
    return self.Registry[id]
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
        if entry.Category == normalized then
            local feature = entry.Feature
            local methodName = enabled and "Enable" or "Disable"
            if type(feature) == "table" and type(feature[methodName]) == "function" then
                local ok = pcall(function()
                    feature[methodName](feature)
                end)
                if ok then
                    entry.State = enabled and "on" or "off"
                    changed = changed + 1
                end
            else
                entry.State = enabled and "on" or "off"
                changed = changed + 1
            end
        end
    end

    self:Notify()
    return changed
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

function FeatureManager:Notify()
    local snapshot = self:GetSnapshot()
    for id, callback in pairs(self.Listeners) do
        local ok = pcall(callback, snapshot)
        if not ok then
            self.Listeners[id] = nil
        end
    end
end

return FeatureManager
