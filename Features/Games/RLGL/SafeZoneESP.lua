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
    ExpectedGame = "Red Light, Green Light",
    Id = "mapped.games.red_light_green_light.safezoneesp",
    Name = "Safe Zone ESP",
    Description = "Marks safe areas and the finish zone to make the route easier to read.",
    Kind = "Highlight",
    TargetTokens = {"safe zone", "finish", "end zone", "goal"},
    ExcludeTokens = {"start", "spawn"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(60, 255, 126),
    WaitingMessage = "Waiting for the finish or safe zone",
})
