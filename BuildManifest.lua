-- SquidNoMo deployment manifest.
-- Loader.lua validates this file to prevent a mixed old/new GitHub deployment.

return {
    Version = "1.1 beta 1",
    Revision = "farming-single-page-r5",
    FeatureRuntimeRevision = "1.1b1-ultralight-r4",
    PlayerRuntimeRevision = "1.1b1-player-ultralight-r3",
    CatalogFeatureCount = 68,
    PlayerFeatureCount = 25,
    UIFeatureCount = 23,
    ExpectedRegistryTotal = 116,
    RequiredSharedFiles = {
        "Features/Shared/Runtime.lua",
        "Features/Shared/PlayerRuntime.lua",
        "Features/Shared/RoleService.lua",
        "Features/Farming/FarmingRuntime.lua",
    },
}
