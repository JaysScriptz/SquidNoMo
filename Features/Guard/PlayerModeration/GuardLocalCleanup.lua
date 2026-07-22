local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo verified feature runtime is unavailable; execute the complete current build")
end

return Runtime:CreateFeature({
    Id = "mapped.guards.game_moderation.guardlocalcleanup",
    Name = "Guard Local Cleanup",
    Description = "Locally clears nearby eliminated bodies and cleanup targets during guard duty.",
    Kind = "Interact",
    TargetTokens = {"body", "dead", "eliminated", "cleanup", "coffin", "remove body", "dispose body", "collect body", "grab body"},
    ExcludeTokens = {"alive"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 55,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.55,
    WaitingMessage = "Waiting for a nearby cleanup target",
})
