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
    ExpectedGame = "Jump Rope",
    Id = "mapped.games.jump_rope.autocomplete",
    Name = "Auto Complete",
    Description = "Coordinates movement and jumps to progress across the rope course.",
    Kind = "CourseAssist",
    TargetTokens = {"finish", "end", "goal", "exit", "other side", "checkpoint"},
    ObstacleTokens = {"rope", "swing", "bar", "spinner", "sweep"},
    JumpDistance = 17,
    MovementPriority = 70,
    WaitingMessage = "Waiting for the Jump Rope course",
})
