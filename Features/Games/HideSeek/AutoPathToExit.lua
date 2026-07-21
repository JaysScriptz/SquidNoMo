local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_feature_recode_r2")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "mapped.games.hide_seek.autopathtoexit",
    Name = "Auto Path to Exit",
    Description = "Uses pathfinding to walk toward the nearest detected exit.",
    Kind = "WalkTo",
    TargetTokens = {"exit", "escape", "gate", "finish door"},
    ExcludeTokens = {"emergency light"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 7,
    Interact = true,
    InteractDistance = 12,
    WaitingMessage = "Waiting for a detected exit",
})
