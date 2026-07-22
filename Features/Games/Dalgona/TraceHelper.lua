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
    Id = "mapped.games.dalgona.tracehelper",
    Name = "Trace Helper",
    Description = "Adds a visual tracing guide that follows the cursor over the cookie shape.",
    Kind = "GuiHighlight",
    TargetTokens = {"trace", "path", "line", "cursor", "needle", "shape"},
    Color = Color3.fromRGB(60, 220, 255),
    Thickness = 4,
    WaitingMessage = "Waiting for a trace path or cursor",
})
