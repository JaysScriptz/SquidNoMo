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
    Id = "mapped.guards.morgue_staff.coffingrabber",
    Name = "Coffin Grabber",
    Description = "Finds and collects the nearest available coffin or body target.",
    Kind = "Interact",
    TargetTokens = {"coffin", "body", "corpse"},
    ExcludeTokens = {"disposal", "incinerator"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 55,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.7,
    MovementPriority = 55,
    ActionPriority = 55,
    WaitingMessage = "Waiting for an available coffin or body",
})
