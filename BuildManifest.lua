-- SquidNoMo deployment manifest.
-- BuildNumber is advanced automatically by repository workflows whenever feature code changes.

local Manifest = {
    Release = "1.1",
    Channel = "beta",
    BuildNumber = 7,
    Revision = "adaptive-game-detection-r7",
    FeatureRuntimeRevision = "adaptive-game-runtime-r7",
    PlayerRuntimeRevision = "player-runtime-r4",
    FarmingRuntimeRevision = "farming-runtime-r2",
    CatalogFeatureCount = 68,
    PlayerFeatureCount = 26,
    UIFeatureCount = 23,
    ExpectedRegistryTotal = 117,
    StartupBundle = "SourceBundle.lua",
    StartupTimeoutSeconds = 30,
    RequiredSharedFiles = {
        "Features/Shared/Runtime.lua",
        "Features/Shared/PlayerRuntime.lua",
        "Features/Shared/RoleService.lua",
        "Features/Farming/FarmingRuntime.lua",
        "Features/Player/AutoPickUpBaby.lua",
    },
}

Manifest.Version = string.format(
    "%s %s %d",
    tostring(Manifest.Release),
    tostring(Manifest.Channel),
    tonumber(Manifest.BuildNumber) or 0
)
Manifest.DisplayVersion = Manifest.Version
Manifest.BuildToken = string.gsub(
    Manifest.Version .. "-" .. tostring(Manifest.Revision),
    "[^%w_%-]",
    "_"
)

return Manifest
