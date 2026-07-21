--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Core/FeatureRegistry.lua
--// Read-only dashboard state for the existing feature objects.
--//========================================================--

local FeatureRegistry = {}
FeatureRegistry.__index = FeatureRegistry

FeatureRegistry.Definitions = {
    {
        Id = "WalkSpeed",
        Name = "Walk Speed",
        Category = "Players",
        Path = {"Player", "WalkSpeed"},
        Kind = "slider",
        Default = 16,
        Maximum = 100,
    },
    {
        Id = "JumpPower",
        Name = "Jump Power",
        Category = "Players",
        Path = {"Player", "JumpPower"},
        Kind = "slider",
        Default = 50,
        Maximum = 200,
    },
    {
        Id = "InfiniteJump",
        Name = "Infinite Jump",
        Category = "Players",
        Path = {"Player", "InfiniteJump"},
        Kind = "toggle",
    },
    {
        Id = "Noclip",
        Name = "Noclip",
        Category = "Players",
        Path = {"Player", "Noclip"},
        Kind = "toggle",
    },
    {
        Id = "PlayerESP",
        Name = "Player ESP",
        Category = "Players",
        Path = {"Player", "PlayerESP"},
        Kind = "toggle",
    },
    {
        Id = "GuardESP",
        Name = "Guard ESP",
        Category = "Players",
        Path = {"Player", "GuardESP"},
        Kind = "toggle",
    },
    {
        Id = "DetectiveESP",
        Name = "Detective ESP",
        Category = "Players",
        Path = {"Player", "DetectiveESP"},
        Kind = "toggle",
    },
    {
        Id = "FrontmanESP",
        Name = "Frontman ESP",
        Category = "Players",
        Path = {"Player", "FrontmanESP"},
        Kind = "toggle",
    },
    {
        Id = "AntiAFK",
        Name = "Anti AFK",
        Category = "Players",
        Path = {"Player", "AntiAFK"},
        Kind = "toggle",
    },
    {
        Id = "AntiLag",
        Name = "Anti Lag",
        Category = "Players",
        Path = {"Player", "AntiLag"},
        Kind = "toggle",
    },
}

local function resolvePath(root, path)
    local current = root

    for _, segment in ipairs(path) do
        if type(current) ~= "table" then
            return nil
        end

        current = current[segment]
    end

    return current
end

function FeatureRegistry.new(loader)
    local self = setmetatable({}, FeatureRegistry)
    self.Loader = loader or {}
    self.ReadErrors = {}
    return self
end

function FeatureRegistry:SetLoader(loader)
    self.Loader = loader or {}
end

function FeatureRegistry:GetDefinitions()
    return self.Definitions
end

function FeatureRegistry:GetFeatureObject(definition)
    local features = self.Loader and self.Loader.Features
    return resolvePath(features, definition.Path)
end

function FeatureRegistry:GetState(definition)
    local object = self:GetFeatureObject(definition)

    if type(object) ~= "table" then
        return "off", false
    end

    if definition.Kind == "slider" then
        if type(object.Get) ~= "function" then
            return "off", true
        end

        local ok, value = pcall(function()
            return tonumber(object:Get())
        end)

        if not ok or value == nil then
            self.ReadErrors[definition.Id] = true
            return "off", true
        end

        if value <= definition.Default then
            return "off", true
        end

        if value >= definition.Maximum then
            return "full", true
        end

        return "partial", true
    end

    if type(object.IsEnabled) ~= "function" then
        return "off", true
    end

    local ok, enabled = pcall(function()
        return object:IsEnabled()
    end)

    if not ok then
        self.ReadErrors[definition.Id] = true
        return "off", true
    end

    return enabled and "full" or "off", true
end

function FeatureRegistry:GetSummary()
    local manager = self.Loader and self.Loader.FeatureManager
    if manager and type(manager.GetSnapshot) == "function" then
        local ok, snapshot = pcall(manager.GetSnapshot, manager)
        if ok and type(snapshot) == "table" then
            local total = tonumber(snapshot.Total) or 0
            local full = tonumber(snapshot.FullyOn) or 0
            local partial = tonumber(snapshot.Partial) or 0
            local off = tonumber(snapshot.Off) or math.max(0, total - full - partial)
            local loaded = type(manager.GetLoadedCount) == "function"
                and manager:GetLoadedCount()
                or 0
            return {
                full = full,
                partial = partial,
                off = off,
                total = total,
                loaded = loaded,
                states = {},
                fullPercent = total > 0 and math.floor((full / total) * 100 + 0.5) or 0,
                partialPercent = total > 0 and math.floor((partial / total) * 100 + 0.5) or 0,
                offPercent = total > 0 and math.floor((off / total) * 100 + 0.5) or 0,
            }
        end
    end

    local summary = {
        full = 0,
        partial = 0,
        off = 0,
        total = #self.Definitions,
        loaded = 0,
        states = {},
    }

    for _, definition in ipairs(self.Definitions) do
        local state, loaded = self:GetState(definition)
        summary.states[definition.Id] = state

        if loaded then
            summary.loaded = summary.loaded + 1
        end

        summary[state] = summary[state] + 1
    end

    if summary.total > 0 then
        summary.fullPercent = math.floor((summary.full / summary.total) * 100 + 0.5)
        summary.partialPercent = math.floor((summary.partial / summary.total) * 100 + 0.5)
        summary.offPercent = math.max(0, 100 - summary.fullPercent - summary.partialPercent)
    else
        summary.fullPercent = 0
        summary.partialPercent = 0
        summary.offPercent = 0
    end

    return summary
end

function FeatureRegistry:GetLoadedCount()
    return self:GetSummary().loaded
end

function FeatureRegistry:GetTotalCount()
    return #self.Definitions
end

function FeatureRegistry:GetReadErrorCount()
    local count = 0

    for _ in pairs(self.ReadErrors) do
        count = count + 1
    end

    return count
end

return FeatureRegistry
