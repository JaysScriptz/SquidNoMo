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
    Id = "mapped.games.marbles.marblesesp",
    Name = "Marbles ESP",
    Description = "Highlights visible marbles, rings, holes, and round targets.",
    Handler = "Highlight",
    TargetTokens = {"marble", "ring", "target", "hole"},
    ExcludeTokens = {"shop", "icon"},
    TargetClasses = {"Tool", "Model", "BasePart"},
    Color = Color3.fromRGB(60, 220, 255),
    Interval = 0.6,
    IdleInterval = 1.0,
    WaitingMessage = "Waiting for marble targets",
})
