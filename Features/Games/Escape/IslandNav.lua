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
    Id = "mapped.games.escape.islandnav",
    Name = "Island Extraction Route",
    Description = "Walks toward the detected extraction boat or finish point.",
    Kind = "WalkTo",
    TargetTokens = {"extraction", "escape boat", "boat", "dock", "finish", "exit"},
    ExcludeTokens = {"start boat"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 9,
    Interact = true,
    InteractDistance = 12,
    WaitingMessage = "Waiting for an extraction boat or finish point",
})
