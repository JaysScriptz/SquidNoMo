-- SquidNoMo deployment manifest.
-- BuildNumber is advanced automatically by repository workflows whenever feature code changes.

local Manifest = {
    Release = "1.1",
    Channel = "beta",
    BuildNumber = 2,
    Revision = "visual-gameplay-logic-r2",
    FeatureRuntimeRevision = "visual-gameplay-runtime-r2",
    PlayerRuntimeRevision = "player-runtime-r1",
    FarmingRuntimeRevision = "farming-runtime-r1",
    CatalogFeatureCount = 69,
    PlayerFeatureCount = 25,
    UIFeatureCount = 23,
    ExpectedRegistryTotal = 117,
    RequiredSharedFiles = {
        "Features/Shared/Runtime.lua",
        "Features/Shared/PlayerRuntime.lua",
        "Features/Shared/RoleService.lua",
        "Features/Farming/FarmingRuntime.lua",
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
