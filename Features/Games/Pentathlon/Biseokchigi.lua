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
    Id = "mapped.games.pentathlon.biseokchigi",
    Name = "Biseokchigi Assist",
    Description = "Automates the timing and interaction used for the Biseokchigi event.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "power", "cursor", "needle"},
    ZoneTokens = {"target", "sweet spot", "green", "hit zone"},
    ActionTokens = {"throw", "hit", "biseok", "play"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.25,
    ActionPriority = 85,
    WaitingMessage = "Waiting for the Biseokchigi timing interface",
})
