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
local expectedRevision = tostring(Manifest.FeatureRuntimeRevision or "compatibility-runtime-r3")

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(
        repository .. "Features/Shared/Runtime.lua?squidnomo_build=" .. BUILD_TOKEN
    )
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    error("SquidNoMo feature runtime build mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.guards.kitchen_staff.autocooker",
    Name = "Auto Cooker",
    Description = "Finds raw supplies, equips them, and assists with nearby cooking stations.",
    Kind = "TaskChain",
    RequireToolTokens = {"raw", "ingredient", "food", "meat"},
    SourceTokens = {"raw", "ingredient", "supply", "food", "collect", "pick up"},
    DestinationTokens = {"cook", "stove", "oven", "grill", "pan", "place ingredient", "start cooking"},
    SourceLabel = "raw kitchen supply",
    DestinationLabel = "cooking station",
    InteractDistance = 11,
    ActionCooldown = 0.8,
    MovementPriority = 75,
    ActionPriority = 70,
})
