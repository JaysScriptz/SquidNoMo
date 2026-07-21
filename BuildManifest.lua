-- SquidNoMo deployment manifest.
-- Loader.lua validates this file to prevent a mixed old/new GitHub deployment.

return {
    Version = "1.1 beta 1",
    Revision = "feature-recode-r2",
    FeatureRuntimeRevision = "1.1b1-feature-recode-r2",
    PlayerRuntimeRevision = "1.1b1-player-recode-r1",
    CatalogFeatureCount = 65,
    PlayerFeatureCount = 25,
    UIFeatureCount = 23,
    ExpectedRegistryTotal = 113,
    RequiredSharedFiles = {
        "Features/Shared/Runtime.lua",
        "Features/Shared/PlayerRuntime.lua",
        "Features/Shared/RoleService.lua",
    },
}
