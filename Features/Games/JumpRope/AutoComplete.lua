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
    Id = "mapped.games.jump_rope.autocomplete",
    Name = "Auto Complete",
    Description = "Coordinates movement and jumps to progress across the rope course.",
    Kind = "CourseAssist",
    TargetTokens = {"finish", "end", "goal", "exit"},
    ObstacleTokens = {"rope", "swing", "bar"},
    JumpDistance = 17,
    MovementPriority = 70,
    WaitingMessage = "Waiting for the Jump Rope course",
})
