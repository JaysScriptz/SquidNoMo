local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.guards.kitchen_staff.autostorage",
    Name = "Auto Storage",
    Description = "Moves cooked food into detected storage or delivery stations.",
    Kind = "TaskChain",
    RequireToolTokens = {"cooked", "meal", "food", "tray"},
    SourceTokens = {"cooked", "meal", "tray"},
    DestinationTokens = {"storage", "shelf", "delivery", "counter", "serve"},
    SourceLabel = "cooked food",
    DestinationLabel = "storage or delivery station",
    InteractDistance = 11,
    ActionCooldown = 0.8,
    MovementPriority = 85,
    ActionPriority = 80,
})
