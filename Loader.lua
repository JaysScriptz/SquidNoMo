--// SquidNoMo loader v0.8.2-beta

local BUILD_VERSION = "v0.8.2-beta"

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local ExistingSession = Environment.__SquidNoMoSession

if type(ExistingSession) == "table" and ExistingSession.JobId == game.JobId then
    local existingApp = ExistingSession.App
    local sameVersion = ExistingSession.Version == BUILD_VERSION

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
end

local BUILD_TOKEN = string.gsub(BUILD_VERSION, "[^%w_%-]", "_")

local function AddVersion(url)
    local separator = string.find(url, "?", 1, true) and "&" or "?"
    return url .. separator .. "squidnomo_build=" .. BUILD_TOKEN
end

local ConfigSource = game:HttpGet(AddVersion(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))
local Config = loadstring(ConfigSource)()

local Loader = {}
Loader.Config = Config
Loader.BuildVersion = BUILD_VERSION

function Loader:GetRemoteUrl(path)
    return AddVersion(self.Config.Repository .. path)
end

function Loader:FetchSource(path)
    return game:HttpGet(self:GetRemoteUrl(path))
end

function Loader:LoadRemote(path)
    print("[Loader] " .. path)

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
            UserScale = 1.0,
            BubbleSize = nil,
            WindowOpacity = 0,
            LastPage = "Home",
            SelectedGameCategory =
                "Red Light, Green Light",
            SelectedGuardCategory = "Moderation",
            SelectedPlayerCategory =
                "Movement & Camera",
            SelectedFarmingCategory = "Player Farming",
            SelectedDetectiveCategory = "Find Island",
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

-- Features must exist before Players and UI pages capture their references.
local featuresLoaded, featuresOrError = pcall(function()
    return Loader.FeatureManager:Initialize(Loader)
end)

if featuresLoaded then
    Loader.Features = featuresOrError

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

    print("[Loader] Features initialized before page build")
else
    warn("[Loader] Feature initialization failed:", featuresOrError)
    Loader.Features = {}
end

Loader.App.Features = Loader.Features
Loader.App:Build(Loader)
Loader.App:AttachFeatureManager(Loader.FeatureManager, Loader.Features)

Session.Version = BUILD_VERSION
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
