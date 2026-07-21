local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local BUILD_NUMBER = tonumber(Manifest.BuildNumber) or 0
local BUILD_TOKEN = tostring(Manifest.BuildToken or BUILD_NUMBER)
local expectedRevision = tostring(Manifest.PlayerRuntimeRevision or "player-runtime-r1")

local Runtime = Environment.__SquidNoMoPlayerRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(
        repository .. "Features/Shared/PlayerRuntime.lua?squidnomo_build=" .. BUILD_TOKEN
    )
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    error("SquidNoMo player runtime build mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "player.frontman_esp",
    Name = "Frontman ESP",
    Description = "Highlights players whose role data identifies them as the Frontman, host, or game master.",
    Kind = "PlayerHighlight",
    RoleTokens = {"frontman", "front man", "host", "gamemaster", "game master"},
    DefaultColor = Color3.fromRGB(172, 76, 255),
    FillTransparency = 0.45,
})
