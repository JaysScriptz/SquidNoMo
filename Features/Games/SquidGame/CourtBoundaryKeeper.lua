local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table" and Environment.__SquidNoMoBuildManifest or {}
local Runtime = Environment.__SquidNoMoGameRuntime
if type(Runtime) ~= "table"
    or tostring(Runtime.Revision) ~= tostring(Manifest.GameRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo game runtime is unavailable; deploy and execute the complete current build")
end


return Runtime:CreateFeature({
    Game = "Squid Game",
    Id = "mapped.games.squid_game.courtboundarykeeper",
    Name = "Court Boundary Keeper",
    Description = "Detects the active Squid Game court and moves inward only after the character crosses the configured boundary.",
    Handler = "Boundary",
    TargetTokens = {"squid court", "court", "play area", "field", "arena"},
    ExcludeTokens = {"sky", "lobby", "spectator"},
    TargetClasses = {"Model", "BasePart"},
    Radius = 58,
    MovementPriority = 72,
    Interval = 0.26,
    IdleInterval = 0.8,
    WaitingMessage = "Waiting for the Squid Game court",
})
