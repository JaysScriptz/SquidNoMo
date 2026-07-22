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
    Game = "Marbles",
    Id = "mapped.games.marbles.marbleaimer",
    Name = "Marble Aimer",
    Description = "Aims the camera toward the best visible marble target and activates the equipped marble tool at a controlled rate.",
    Handler = "AimAssist",
    TargetTokens = {"ring", "target", "hole", "goal", "circle"},
    ExcludeTokens = {"shop", "icon"},
    TargetClasses = {"Model", "BasePart"},
    ToolTokens = {"marble", "ball"},
    Range = 140,
    ActionCooldown = 0.5,
    ActionPriority = 62,
    Interval = 0.22,
    IdleInterval = 0.8,
})
