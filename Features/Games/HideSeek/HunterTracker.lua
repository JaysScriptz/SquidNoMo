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
    Id = "mapped.games.hide_seek.huntertracker",
    Name = "Hunter Tracker",
    Description = "Tracks hunters and keeps their location visible during the round.",
    Kind = "Highlight",
    PlayerMode = true,
    PlayerTokens = {"hunter", "seeker", "killer"},
    Color = Color3.fromRGB(255, 70, 70),
    WaitingMessage = "Waiting for a hunter or seeker role",
})
