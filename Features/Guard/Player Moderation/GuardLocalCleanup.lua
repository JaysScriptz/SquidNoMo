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
    Id = "mapped.guards.game_moderation.guardlocalcleanup",
    Name = "Guard Local Cleanup",
    Description = "Locally clears nearby eliminated bodies and cleanup targets during guard duty.",
    Kind = "Interact",
    TargetTokens = {"body", "dead", "eliminated", "cleanup", "coffin"},
    ExcludeTokens = {"alive"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 55,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.55,
    WaitingMessage = "Waiting for a nearby cleanup target",
})
