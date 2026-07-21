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
    Id = "mapped.games.red_light_green_light.automove",
    Name = "Auto Move",
    Description = "Moves on green light and stops automatically when the doll changes to red.",
    Kind = "RLGLAutoMove",
    TargetTokens = {"finish", "safe zone", "end zone", "goal"},
    Interval = 0.10,
    MovementPriority = 95,
    IdleInterval = 0.65,
    WaitingMessage = "Waiting for the RLGL status and finish area",
})
