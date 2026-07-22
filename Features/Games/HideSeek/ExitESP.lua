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
    ExpectedGame = "Hide & Seek",
    Id = "mapped.games.hide_seek.exitesp",
    Name = "Exit ESP",
    Description = "Marks detected exits and escape points in the map.",
    Kind = "Highlight",
    TargetTokens = {"exit", "escape", "gate", "finish door"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(60, 255, 126),
    WaitingMessage = "Waiting for detected exits",
})
