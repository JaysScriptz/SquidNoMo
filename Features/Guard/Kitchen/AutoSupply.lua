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
local expectedRevision = tostring(Manifest.FeatureRuntimeRevision or "visual-gameplay-runtime-r2")

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
    Id = "mapped.guards.kitchen_staff.autosupply",
    Name = "Auto Supply",
    Description = "Collects nearby kitchen supplies when inventory space is available.",
    Kind = "Interact",
    TargetTokens = {"supply", "ingredient", "raw", "food", "crate", "collect", "pick up", "take supply"},
    ExcludeTokens = {"cooked", "empty"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 50,
    Walk = true,
    InteractDistance = 11,
    ActionCooldown = 0.6,
    MovementPriority = 50,
    ActionPriority = 50,
    WaitingMessage = "Waiting for kitchen supplies",
})
