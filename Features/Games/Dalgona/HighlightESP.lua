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
    Id = "mapped.games.dalgona.highlightesp",
    Name = "Shape Highlight",
    Description = "Outlines the cookie shape so the tracing boundary is easier to see.",
    Kind = "GuiHighlight",
    TargetTokens = {"cookie", "shape", "outline", "cut area", "dalgona"},
    Color = Color3.fromRGB(255, 210, 70),
    Thickness = 3,
    WaitingMessage = "Waiting for the Dalgona shape interface",
})
