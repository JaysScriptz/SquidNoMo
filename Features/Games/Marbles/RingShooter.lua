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
    Id = "mapped.games.marbles.ringshooter",
    Name = "Ring Shooter",
    Description = "Assists with lining up and firing marbles toward ring targets.",
    Kind = "AimActivate",
    TargetTokens = {"ring", "hoop", "hole", "target"},
    ToolTokens = {"marble", "ball"},
    Range = 160,
    Interval = 0.20,
    ActionPriority = 75,
    WaitingMessage = "Waiting for a ring target and marble tool",
})
