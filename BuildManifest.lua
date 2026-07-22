-- SquidNoMo deployment manifest.
-- BuildNumber is advanced automatically by repository workflows whenever feature code changes.

local Manifest = {
    Release = "1.1",
    Channel = "beta",
    BuildNumber = 3,
    Revision = "deep-compatibility-baby-r3",
    FeatureRuntimeRevision = "compatibility-runtime-r3",
    PlayerRuntimeRevision = "player-runtime-r2",
    FarmingRuntimeRevision = "farming-runtime-r1",
    CatalogFeatureCount = 69,
    PlayerFeatureCount = 26,
    UIFeatureCount = 23,
    ExpectedRegistryTotal = 118,
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
