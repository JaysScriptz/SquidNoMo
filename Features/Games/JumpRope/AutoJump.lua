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
    ExpectedGame = "Jump Rope",
    Id = "mapped.games.jump_rope.autojump",
    Name = "Auto Jump",
    Description = "Triggers jumps automatically as the rope approaches.",
    Kind = "AutoJump",
    TargetTokens = {"rope", "swing", "bar", "spinner", "sweep"},
    TriggerDistance = 17,
    Interval = 0.10,
})
