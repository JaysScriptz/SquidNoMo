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
    Game = "Dalgona",
    Id = "mapped.games.dalgona.highlightesp",
    Name = "Shape Highlight",
    Description = "Outlines the visible cookie shape or cutting area without sending game actions.",
    Handler = "GuiHighlight",
    TargetTokens = {"cookie", "shape", "outline", "cut area", "dalgona"},
    Color = Color3.fromRGB(255, 210, 70),
    Thickness = 4,
    Interval = 0.28,
    IdleInterval = 0.8,
    WaitingMessage = "Waiting for the Dalgona shape interface",
})
