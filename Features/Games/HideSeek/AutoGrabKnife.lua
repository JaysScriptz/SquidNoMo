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
    Id = "mapped.games.hide_seek.autograbknife",
    Name = "Auto Grab Knife",
    Description = "Finds the nearest knife and moves close enough to collect it.",
    Kind = "WalkTo",
    TargetTokens = {"knife", "blade", "weapon"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    Interact = true,
    StopDistance = 7,
    InteractDistance = 12,
    SkipIfToolTokens = {"knife", "blade", "weapon"},
    LocalRoleTokens = {"hunter", "seeker", "killer"},
    MovementPriority = 65,
    WaitingMessage = "Waiting for an available knife",
})
