local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_feature_recode_r2")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "mapped.guards.kitchen_staff.autosupply",
    Name = "Auto Supply",
    Description = "Collects nearby kitchen supplies when inventory space is available.",
    Kind = "Interact",
    TargetTokens = {"supply", "ingredient", "raw", "food", "crate"},
    ExcludeTokens = {"cooked", "empty"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 50,
    Walk = true,
    InteractDistance = 11,
    ActionCooldown = 0.6,
    WaitingMessage = "Waiting for kitchen supplies",
})
