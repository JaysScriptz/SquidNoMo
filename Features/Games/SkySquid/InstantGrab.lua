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
    Id = "mapped.games.sky_squid.instantgrab",
    Name = "Instant Grab",
    Description = "Quickly collects nearby weapons, poles, and usable tools.",
    Kind = "Interact",
    TargetTokens = {"weapon", "pole", "knife", "tool", "bat"},
    ExcludeTokens = {"owned", "inventory"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 45,
    Walk = true,
    InteractDistance = 11,
    ActionCooldown = 0.45,
    WaitingMessage = "Waiting for a nearby usable item",
})
