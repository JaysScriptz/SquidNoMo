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
    ExpectedGame = "Dalgona",
    Id = "mapped.games.dalgona.autocut",
    Name = "Auto Cut",
    Description = "Automates the cookie carving interaction to help complete the selected shape.",
    Kind = "GuiAction",
    ActionTokens = {"cut", "carve", "trace", "complete", "finish", "tap"},
    ActionCooldown = 0.12,
    ActionPriority = 55,
    Interval = 0.12,
    WaitingMessage = "Waiting for the Dalgona cutting controls",
})
