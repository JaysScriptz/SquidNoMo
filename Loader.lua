--// SquidNoMo loader v0.6.1-beta

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local ExistingSession = Environment.__SquidNoMoSession
if type(ExistingSession) == "table"
    and ExistingSession.JobId == game.JobId
    and ExistingSession.Loader
    and ExistingSession.App
    and type(ExistingSession.App.IsVisible) == "function"
    and ExistingSession.App:IsVisible() then

    ExistingSession.UserClosed = false
    if type(ExistingSession.App.BringToFront) == "function" then
        ExistingSession.App:BringToFront()
    elseif type(ExistingSession.App.SetMinimized) == "function" then
        ExistingSession.App:SetMinimized(false)
    end

    return ExistingSession.Loader
end

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local function Load(Path)
    print("[Loader] " .. Path)

    local Url = Config.Repository .. Path
    local Source = game:HttpGet(Url)
    local Chunk, CompileError = loadstring(Source)

    if not Chunk then
        error(string.format("[Loader] Compile failed for %s: %s", Path, tostring(CompileError)))
    end

    local Success, Result = pcall(Chunk)

    if not Success then
        error(string.format("[Loader] Execution failed for %s: %s", Path, tostring(Result)))
    end

    return Result
end

local Loader = {}
Loader.Config = Config

Loader.Theme = Load("Core/Theme.lua")
Loader.Components = Load("Core/Components.lua")
Loader.Navigation = Load("Core/Navigation.lua")
Loader.Utilities = Load("Core/Utilities.lua")
Loader.Notifications = Load("Core/Notifications.lua")

Loader.FeatureManager = Load("Features/FeatureManager.lua")
Loader.Features = {}
Loader.App = Load("Core/App.lua")

Loader.Home = Load("Modules/Home.lua")
Loader.Players = Load("Modules/Players.lua")
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

Loader.App:Build(Loader)

local FeaturesLoaded, FeaturesOrError = pcall(function()
    return Loader.FeatureManager:Initialize(Loader)
end)

if FeaturesLoaded then
    Loader.Features = FeaturesOrError
    Loader.App.Features = FeaturesOrError
    Loader.App:AttachFeatureManager(Loader.FeatureManager, FeaturesOrError)
    print("[Loader] Features ready")
else
    warn("[Loader] Feature initialization failed:", FeaturesOrError)
    Loader.Features = {}
    Loader.App.Features = Loader.Features
    Loader.App:AttachFeatureManager(Loader.FeatureManager, Loader.Features)
end

local Session = Environment.__SquidNoMoSession
if type(Session) ~= "table" or Session.JobId ~= game.JobId then
    Session = {
        JobId = game.JobId,
        TermsAccepted = false,
        UserClosed = false,
        FreeRoamEnabled = false,
        FullScreenEnabled = false,
        LastSafePosition = nil,
    }
    Environment.__SquidNoMoSession = Session
end

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
            Loader.App:Build(Loader)
            Loader.App:AttachFeatureManager(Loader.FeatureManager, Loader.Features)
        end
    end)
end

return Loader
