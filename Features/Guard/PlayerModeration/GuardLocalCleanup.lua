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
local expectedRevision = tostring(Manifest.FeatureRuntimeRevision or "compatibility-runtime-r4")

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
    Id = "mapped.guards.game_moderation.guardlocalcleanup",
    Name = "Guard Local Cleanup",
    Description = "Locally clears nearby eliminated bodies and cleanup targets during guard duty.",
    Kind = "Interact",
    TargetTokens = {"body", "dead", "eliminated", "cleanup", "coffin", "remove body", "dispose body", "collect body", "grab body"},
    ExcludeTokens = {"alive"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 55,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.55,
    WaitingMessage = "Waiting for a nearby cleanup target",
})
