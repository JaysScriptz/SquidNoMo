--// SquidNoMo loader

local REPOSITORY = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local function LoadBuildManifest()
    local cached = Environment.__SquidNoMoBuildManifest
    if type(cached) == "table" and cached.Version and cached.BuildNumber then
        return cached
    end

    local nonce = tostring(math.floor(os.clock() * 1000000))
    local source = game:HttpGet(
        REPOSITORY .. "BuildManifest.lua?squidnomo_manifest=" .. nonce
    )
    local chunk, compileError = loadstring(source)
    if not chunk then
        error("[Loader] Build manifest compile failed: " .. tostring(compileError))
    end
    local ok, manifest = pcall(chunk)
    if not ok or type(manifest) ~= "table" then
        error("[Loader] Build manifest load failed: " .. tostring(manifest))
    end
    Environment.__SquidNoMoBuildManifest = manifest
    return manifest
end

local BuildManifest = LoadBuildManifest()
local BUILD_VERSION = tostring(BuildManifest.Version or "SquidNoMo")
local BUILD_NUMBER = tonumber(BuildManifest.BuildNumber) or 0
local BUILD_REVISION = tostring(BuildManifest.Revision or "unknown")

local ExistingSession = Environment.__SquidNoMoSession

if type(ExistingSession) == "table" and ExistingSession.JobId == game.JobId then
    local existingApp = ExistingSession.App
    local sameVersion = ExistingSession.Version == BUILD_VERSION
        and ExistingSession.BuildNumber == BUILD_NUMBER
        and ExistingSession.Revision == BUILD_REVISION

    if sameVersion and existingApp and type(existingApp.BringToFront) == "function" then
        ExistingSession.UserClosed = false
        existingApp:BringToFront()
        return ExistingSession.Loader
    end

    -- Cleanly retire an older in-server build before loading the new version.
    local oldLoader = ExistingSession.Loader
    local oldManager = oldLoader and oldLoader.FeatureManager

    if oldManager and type(oldManager.SetCategoryEnabled) == "function" then
        for _, category in ipairs({"Safe", "SemiSafe", "Experimental"}) do
            pcall(function()
                oldManager:SetCategoryEnabled(category, false)
            end)
        end
    end

    if ExistingSession.CharacterConnection then
        pcall(function()
            ExistingSession.CharacterConnection:Disconnect()
        end)
        ExistingSession.CharacterConnection = nil
    end

    if existingApp and type(existingApp.Destroy) == "function" then
        pcall(function()
            existingApp:Destroy(true)
        end)
    end

    ExistingSession.Loader = nil
    ExistingSession.App = nil
    ExistingSession.UserClosed = false
    ExistingSession.FreeRoamEnabled = true
    ExistingSession.Version = BUILD_VERSION
    ExistingSession.BuildNumber = BUILD_NUMBER
    ExistingSession.Revision = BUILD_REVISION
end

local BUILD_TOKEN = tostring(BuildManifest.BuildToken or string.gsub(
    BUILD_VERSION .. "-" .. BUILD_REVISION,
    "[^%w_%-]",
    "_"
))

local function AddVersion(url)
    local separator = string.find(url, "?", 1, true) and "&" or "?"
    return url .. separator .. "squidnomo_build=" .. BUILD_TOKEN
end

local ConfigSource = game:HttpGet(AddVersion(REPOSITORY .. "Config.lua"))
local Config = loadstring(ConfigSource)()

local Loader = {}
Loader.Config = Config
Loader.BuildVersion = BUILD_VERSION
Loader.BuildNumber = BUILD_NUMBER
Loader.BuildRevision = BUILD_REVISION
Loader.Manifest = BuildManifest

local Bootstrap = Environment.__SquidNoMoBootstrap
local loadStep = 0
local estimatedSteps = 72

local function ReportLoading(message, progress)
    if type(Bootstrap) == "table" and type(Bootstrap.SetStatus) == "function" then
        Bootstrap:SetStatus(message, progress)
    end
end

ReportLoading("Configuration loaded...", 0.28)

local function EncodeRepositoryPath(path)
    path = tostring(path or "")
    -- Keep directory separators readable while encoding characters that can make
    -- raw GitHub URLs fail in some Roblox/executor HTTP implementations.
    path = string.gsub(path, "%%", "%%25")
    path = string.gsub(path, " ", "%%20")
    path = string.gsub(path, "#", "%%23")
    path = string.gsub(path, "?", "%%3F")
    return path
end

function Loader:GetRemoteUrl(path)
    return AddVersion(self.Config.Repository .. EncodeRepositoryPath(path))
end

function Loader:FetchSource(path)
    return game:HttpGet(self:GetRemoteUrl(path))
end

function Loader:LoadRemote(path)
    print("[Loader] " .. path)
    loadStep = loadStep + 1
    local readable = string.gsub(path, "%.lua$", "")
    readable = string.gsub(readable, "/", " › ")
    local progress = 0.28 + (math.min(loadStep, estimatedSteps) / estimatedSteps) * 0.58
    ReportLoading("Loading " .. readable .. "...", progress)

    local source = self:FetchSource(path)
    local chunk, compileError = loadstring(source)

    if not chunk then
        error(string.format(
            "[Loader] Compile failed for %s: %s",
            path,
            tostring(compileError)
        ))
    end

    local success, result = pcall(chunk)

    if not success then
        error(string.format(
            "[Loader] Execution failed for %s: %s",
            path,
            tostring(result)
        ))
    end

    return result
end

local function Load(path)
    return Loader:LoadRemote(path)
end

if type(Loader.Manifest) ~= "table"
    or Loader.Manifest.Version ~= BUILD_VERSION
    or tonumber(Loader.Manifest.BuildNumber) ~= BUILD_NUMBER
    or Loader.Manifest.Revision ~= BUILD_REVISION
then
    error(
        "[Loader] Repository build mismatch. Upload the complete "
        .. BUILD_VERSION
        .. " build "
        .. tostring(BUILD_NUMBER)
        .. " / "
        .. BUILD_REVISION
        .. " project before executing it."
    )
end

Loader.Theme = Load("Core/Theme.lua")
Loader.Components = Load("Core/Components.lua")
Loader.Navigation = Load("Core/Navigation.lua")
Loader.Utilities = Load("Core/Utilities.lua")
Loader.Notifications = Load("Core/Notifications.lua")
Loader.SettingsStore = Load("Core/SettingsStore.lua")
Loader.UIStyleManager = Load("Core/UIStyleManager.lua")
Loader.SavedSettings = Loader.SettingsStore:Load()

if Loader.SavedSettings
    and Loader.SavedSettings.BuildVersion
        ~= BUILD_VERSION
    and Loader.SavedSettings.App
    and Loader.SavedSettings.App.UIStyles
    and type(
        Loader.UIStyleManager
            .CreateColorPreservingProfile
    ) == "function"
then
    Loader.SavedSettings.App.UIStyles =
        Loader.UIStyleManager
            :CreateColorPreservingProfile(
                Loader.SavedSettings.App.UIStyles
            )
end

Loader.FeatureCatalog = Load("Modules/FeatureCatalog.lua")
Loader.FeatureManager = Load("Features/FeatureManager.lua")
Loader.App = Load("Core/App.lua")

Loader.Home = Load("Modules/Home.lua")
Loader.CategoryStrip = Load("Modules/CategoryStrip.lua")
Loader.FeatureFolder = Load("Modules/FeatureFolder.lua")
Loader.Games = Load("Modules/Games.lua")
Loader.Players = Load("Modules/Players.lua")
Loader.Guards = Load("Modules/Guards.lua")
Loader.Detective = Load("Modules/Detective.lua")
Loader.Farming = Load("Modules/Farming.lua")
Loader.UI = Load("Modules/UI.lua")

Loader.HeroBanner = Load("Modules/Home/HeroBanner.lua")
Loader.FeatureGroups = Load("Modules/Home/FeatureGroups.lua")
Loader.ServerStatus = Load("Modules/Home/ServerStatus.lua")
Loader.NOMOAI = Load("Modules/Home/NOMOAI.lua")
Loader.SupportDevelopment = Load("Modules/Home/SupportDevelopment.lua")
Loader.DevelopmentGoal = Load("Modules/Home/DevelopmentGoal.lua")
Loader.Supporters = Load("Modules/Home/Supporters.lua")
Loader.ImportantNotice = Load("Modules/Home/ImportantNotice.lua")
Loader.Footer = Load("Modules/Home/Footer.lua")

local function GetOrCreateSession()
    local session = Environment.__SquidNoMoSession

    if type(session) ~= "table"
        or session.JobId ~= game.JobId
    then
        session = {
            JobId = game.JobId,
            TermsAccepted = false,
            UserClosed = false,
            DetectionStatus = "UNKNOWN",
            DetectionDetail =
                "No status signal has been reported.",
            FreeRoamEnabled = true,
            FullScreenEnabled = false,
            ButtonGlowEnabled = true,
            NavigationGlowEnabled = true,
            CloseConfirmationEnabled = true,
            ReducedMotionEnabled = false,
            RememberLastPageEnabled = true,
            AutoCenterOnResizeEnabled = true,
            AutoApplyPerGameEnabled = false,
            LightweightModeEnabled = true,
            UserScale = 1.0,
            BubbleSize = nil,
            WindowOpacity = 0,
            LastPage = "Home",
            SelectedGameCategory =
                "Red Light, Green Light",
            SelectedGuardCategory = "Game Moderation",
            SelectedPlayerCategory =
                "Movement & Camera",
            SelectedFarmingCategory = "Player Farming",
            SelectedDetectiveCategory = "Island Navigation",
            SelectedUICategory = "Layout & Scale",
            UIEditScope = "Entire App",
            UIEditTargetPage = "Players",
            UIStyles = nil,
            LastSafePosition = nil,
        }
        Environment.__SquidNoMoSession = session
    end

    return session
end

local Session = GetOrCreateSession()
local savedApp = Loader.SavedSettings
    and Loader.SavedSettings.App

if type(savedApp) == "table" then
    local keys = {
        "FreeRoamEnabled",
        "FullScreenEnabled",
        "ButtonGlowEnabled",
        "NavigationGlowEnabled",
        "CloseConfirmationEnabled",
        "ReducedMotionEnabled",
        "RememberLastPageEnabled",
        "AutoCenterOnResizeEnabled",
        "UserScale",
        "BubbleSize",
        "WindowOpacity",
        "LastPage",
        "SelectedGameCategory",
        "SelectedGuardCategory",
        "SelectedPlayerCategory",
        "SelectedFarmingCategory",
        "SelectedDetectiveCategory",
        "SelectedUICategory",
        "UIEditScope",
        "UIEditTargetPage",
        "UIStyles",
    }

    for _, key in ipairs(keys) do
        if savedApp[key] ~= nil then
            Session[key] = savedApp[key]
        end
    end
end

ReportLoading("Initializing feature modules...", 0.88)

-- Features must exist before Players and UI pages capture their references.
local featuresLoaded, featuresOrError = pcall(function()
    return Loader.FeatureManager:Initialize(Loader)
end)

if featuresLoaded then
    Loader.Features = featuresOrError

    local shared = Loader.Features and Loader.Features.Shared
    local featureRuntime = shared and shared.Runtime
    local playerRuntime = shared and shared.PlayerRuntime
    if type(featureRuntime) ~= "table"
        or featureRuntime.Revision ~= Loader.Manifest.FeatureRuntimeRevision
        or tonumber(featureRuntime.BuildNumber) ~= BUILD_NUMBER
        or type(playerRuntime) ~= "table"
        or playerRuntime.Revision ~= Loader.Manifest.PlayerRuntimeRevision
        or tonumber(playerRuntime.BuildNumber) ~= BUILD_NUMBER
    then
        error(
            "[Loader] Shared runtime revision mismatch. Upload Runtime.lua, "
            .. "PlayerRuntime.lua, every feature wrapper, and BuildManifest.lua together."
        )
    end

    if Loader.SavedSettings
        and type(Loader.SavedSettings.Features) == "table"
        and type(Loader.FeatureManager.ApplySettings) == "function"
    then
        print(
            "[Loader] Restored feature settings:",
            Loader.FeatureManager:ApplySettings(
                Loader.SavedSettings.Features
            )
        )
    end

    local expectedTotal = Loader.Manifest
        and tonumber(
            Loader.Manifest.ExpectedRegistryTotal
        )
    local actualTotal = type(
        Loader.FeatureManager.GetTotalCount
    ) == "function"
        and Loader.FeatureManager:GetTotalCount()
        or 0

    if expectedTotal
        and actualTotal ~= expectedTotal
    then
        error(
            "[Loader] Feature registry mismatch. Expected "
            .. tostring(expectedTotal)
            .. " features but registered "
            .. tostring(actualTotal)
            .. ". Upload the complete repository build."
        )
    end

    print(
        "[Loader] Features initialized before page build:",
        actualTotal
    )
else
    error(
        "[Loader] Feature initialization failed: "
        .. tostring(featuresOrError)
    )
end

Loader.App.Features = Loader.Features
ReportLoading("Building the interface...", 0.94)
Loader.App:Build(Loader)
Loader.App:AttachFeatureManager(Loader.FeatureManager, Loader.Features)
ReportLoading("Finalizing startup...", 0.98)

Session.Version = BUILD_VERSION
Session.BuildNumber = BUILD_NUMBER
Session.Revision = BUILD_REVISION
Session.Loader = Loader
Session.App = Loader.App
Session.UserClosed = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if Session.CharacterConnection then
    pcall(function()
        Session.CharacterConnection:Disconnect()
    end)
end

if LocalPlayer then
    Session.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)

        if Session.JobId ~= game.JobId or Session.UserClosed then
            return
        end

        if not Loader.App:IsVisible() then
            Loader.App.Features = Loader.Features
            Loader.App:Build(Loader)
            Loader.App:AttachFeatureManager(
                Loader.FeatureManager,
                Loader.Features
            )
        end
    end)
end

return Loader
