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
    Id = "mapped.games.dalgona.tracehelper",
    Name = "Trace Helper",
    Description = "Highlights the visible trace path, needle, or cursor so the cutting route is easier to follow.",
    Handler = "GuiHighlight",
    TargetTokens = {"trace", "path", "line", "cursor", "needle", "shape"},
    Color = Color3.fromRGB(60, 220, 255),
    Thickness = 4,
    Interval = 0.22,
    IdleInterval = 0.75,
    WaitingMessage = "Waiting for a visible trace path",
})
