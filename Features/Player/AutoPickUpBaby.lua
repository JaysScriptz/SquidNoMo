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
local expectedRevision = tostring(Manifest.PlayerRuntimeRevision or "player-runtime-r2")

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
    Id = "player.auto_pickup_baby",
    Name = "Auto Pick Up Baby",
    Description = "Automatically collects the nearby Baby objective when a supported pickup prompt, click target, tool, or touch pickup appears.",
    Kind = "PickupTarget",
    TargetTokens = {
        "baby", "newborn", "infant", "player 222", "222 baby",
        "pick up baby", "pickup baby", "grab baby", "carry baby",
        "take baby", "baby carrier"
    },
    HeldTokens = {
        "baby", "newborn", "infant", "player 222", "baby carrier"
    },
    ExcludeTokens = {
        "baby shop", "baby skin", "baby icon", "baby reward", "baby pass"
    },
    MaxDistance = 30,
    Interval = 0.35,
    IdleInterval = 1.1,
    ActionCooldown = 0.8,
    WaitingMessage = "Waiting for a nearby Baby pickup",
})
