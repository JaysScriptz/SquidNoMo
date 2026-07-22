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
    Id = "mapped.games.marbles.ringshooter",
    Name = "Ring Shooter",
    Description = "Aims at the nearest visible ring or hole and activates the marble tool without inventing hidden target data.",
    Handler = "AimAssist",
    TargetTokens = {"ring", "hoop", "hole", "target"},
    ExcludeTokens = {"shop", "icon"},
    TargetClasses = {"Model", "BasePart"},
    ToolTokens = {"marble", "ball"},
    Range = 160,
    ActionCooldown = 0.45,
    ActionPriority = 76,
    Interval = 0.2,
    IdleInterval = 0.75,
})
