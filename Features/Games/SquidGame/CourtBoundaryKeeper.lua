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
    ExpectedGame = "Squid Game",
    Id = "mapped.games.squid_game.courtboundarykeeper",
    Name = "Court Boundary Keeper",
    Description = "Helps keep the character inside the active Squid Game court.",
    Kind = "Boundary",
    TargetTokens = {"court", "squid game", "arena", "play area", "field"},
    Radius = 58,
    Interval = 0.28,
    MovementPriority = 70,
    WaitingMessage = "Waiting for the Squid Game court",
})
