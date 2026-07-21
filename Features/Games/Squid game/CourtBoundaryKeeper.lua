local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
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
