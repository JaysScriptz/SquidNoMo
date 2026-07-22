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
    ExpectedGame = "Mingle",
    Id = "mapped.games.mingle.roomesp",
    Name = "Room ESP",
    Description = "Highlights available rooms and displays useful room information.",
    Kind = "Highlight",
    TargetTokens = {"room", "door", "mingle", "enter room", "join room"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(60, 220, 255),
    WaitingMessage = "Waiting for Mingle rooms",
})
