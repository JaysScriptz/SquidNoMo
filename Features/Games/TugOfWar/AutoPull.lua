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
    ExpectedGame = "Tug of War",
    Id = "mapped.games.tug_of_war.autopull",
    Name = "Auto Pull",
    Description = "Repeats the pull input automatically throughout Tug of War.",
    Kind = "GuiAction",
    ActionTokens = {"pull", "tug", "tap", "rope"},
    ActionCooldown = 0.08,
    ActionPriority = 40,
    Interval = 0.09,
    WaitingMessage = "Waiting for the Tug of War pull control",
})
