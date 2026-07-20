-- Runtime patch: navigation selection uses Lua closures, not custom TextButton methods.
--//========================================================--
--// SquidNoMo - Universal App Runtime (Mobile V2)
--// Core/App.lua
--// Designed for Roblox Studio and common client executors
--// Mobile-first target: Delta landscape
--//========================================================--

--[[
    PURPOSE
    -------
    This file owns only the application shell:
      • top-layer ScreenGui creation
      • mobile safe-zone placement
      • full-suite uniform scaling
      • mouse + touch dragging
      • navigation and page mounting
      • visible error reporting
      • compatibility with the existing modular Loader

    It does not contain game automation or feature logic.

    EXPECTED LOADER CALL
    --------------------
        local App = loadstring(game:HttpGet(URL_TO_THIS_FILE))()
        App:Build(Loader)

    DIRECT UI TEST
    --------------
        local App = loadstring(game:HttpGet(URL_TO_THIS_FILE))()
        App:Build({})
]]

----------------------------------------------------------
-- Services
----------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------
-- App
----------------------------------------------------------

local App = {}
App.__index = App

App.Name = "SquidNoMo"
App.Version = "v0.7.0-beta"
App.Runtime = "Universal Injector / Studio"

----------------------------------------------------------
-- Easy configuration
-- These values are intentionally grouped in one place.
----------------------------------------------------------

App.Config = {
    DeviceProfiles = {
        Phone = {
            DesignWidth = 1225,
            DesignHeight = 690,
            SidebarWidth = 232,
            TopbarHeight = 56,
            StatusbarHeight = 34,
            SafeFill = 1.0,
            RestoreFill = 0.82,
            WindowRadius = 14,
            ContentPadding = 8,
            HomeGap = 8,
            HeroHeight = 130,
            FeatureHeight = 196,
            BottomStatsHeight = 242,
            NavigationButtonHeight = 37,
            NavigationPadding = 4,
            SupportPanelHeight = 184,
            Margins = {Left = 0.010, Right = 0.010, Top = 0.012, Bottom = 0.012},
        },
        Tablet = {
            DesignWidth = 1280,
            DesignHeight = 800,
            SidebarWidth = 252,
            TopbarHeight = 58,
            StatusbarHeight = 36,
            SafeFill = 0.985,
            RestoreFill = 0.84,
            WindowRadius = 17,
            ContentPadding = 12,
            HomeGap = 10,
            HeroHeight = 168,
            FeatureHeight = 220,
            BottomStatsHeight = 274,
            NavigationButtonHeight = 42,
            NavigationPadding = 5,
            SupportPanelHeight = 196,
            Margins = {Left = 0.018, Right = 0.018, Top = 0.020, Bottom = 0.020},
        },
        Desktop = {
            DesignWidth = 1320,
            DesignHeight = 820,
            SidebarWidth = 260,
            TopbarHeight = 60,
            StatusbarHeight = 38,
            SafeFill = 0.96,
            RestoreFill = 0.86,
            WindowRadius = 18,
            ContentPadding = 14,
            HomeGap = 11,
            HeroHeight = 176,
            FeatureHeight = 224,
            BottomStatsHeight = 272,
            NavigationButtonHeight = 44,
            NavigationPadding = 6,
            SupportPanelHeight = 204,
            Margins = {Left = 0.020, Right = 0.020, Top = 0.025, Bottom = 0.025},
        },
    },

    -- Compatibility values are replaced by ApplyDeviceProfile before UI creation.
    DesignWidth = 1225,
    DesignHeight = 690,
    SidebarWidth = 232,
    TopbarHeight = 56,
    StatusbarHeight = 34,
    CornerRadius = 14,

    MinimumScale = 0.10,
    MaximumScale = 1.50,
    DisplayOrder = 999999,
    WindowEdgePadding = 6,
    AllowPartialOffscreenDrag = true,
    DragVisiblePixels = 48,
    FreeRoamAutoMinimizeVisibleRatio = 0.28,
    FreeRoamMinimumTitleWidth = 120,
    FreeRoamMinimumTitleHeight = 18,
    ForceMobile = false,
    AssetVersion = "v0.7.0-beta",
    RespectGuiInset = false,
    ShowHomeFooter = false,

    Support = {
        CashApp = "$thepettyqueen98",
        PayPal = "@thepettyqueen98",
        CashAppQR = "Images/CashAppQR.png",
        PayPalQR = "Images/PayPalQR.png",
    },

    Assets = {
        Logo = "Images/SquidNoMoLogo.png",
        BannerGuards = "Images/BannerGuards.png",
        Tabs = {
            Home = "Images/TabIcons/Home.png",
            Games = "Images/TabIcons/Games.png",
            Players = "Images/TabIcons/Players.png",
            Guards = "Images/TabIcons/Guards.png",
            Detective = "Images/TabIcons/Detective.png",
            Farming = "Images/TabIcons/Farming.png",
            UI = "Images/TabIcons/UI.png",
            Settings = "Images/TabIcons/Settings.png",
        },
    },
}

----------------------------------------------------------
-- Canonical palette from the approved rendering
----------------------------------------------------------

App.Colors = {
    Backdrop = Color3.fromRGB(8, 6, 12),
    Window = Color3.fromRGB(11, 9, 16),
    Sidebar = Color3.fromRGB(12, 10, 18),
    Topbar = Color3.fromRGB(14, 10, 20),
    Card = Color3.fromRGB(18, 13, 25),
    CardAlt = Color3.fromRGB(24, 18, 32),
    CardHover = Color3.fromRGB(34, 24, 44),
    Border = Color3.fromRGB(255, 58, 145),
    BorderSoft = Color3.fromRGB(92, 47, 77),
    Accent = Color3.fromRGB(255, 58, 145),
    AccentDark = Color3.fromRGB(194, 30, 109),
    AccentSoft = Color3.fromRGB(105, 39, 74),
    Pink = Color3.fromRGB(255, 58, 145),
    PinkDark = Color3.fromRGB(171, 26, 95),
    Warning = Color3.fromRGB(255, 196, 64),
    Error = Color3.fromRGB(255, 63, 86),
    Success = Color3.fromRGB(45, 232, 98),
    Info = Color3.fromRGB(0, 170, 255),
    Minimize = Color3.fromRGB(106, 78, 176),
    Maximize = Color3.fromRGB(0, 139, 214),
    Close = Color3.fromRGB(211, 42, 68),
    CashApp = Color3.fromRGB(0, 224, 106),
    PayPal = Color3.fromRGB(0, 99, 214),
    Text = Color3.fromRGB(244, 240, 246),
    Muted = Color3.fromRGB(177, 163, 184),
    Dim = Color3.fromRGB(116, 102, 126),
    Black = Color3.fromRGB(0, 0, 0),
}

App.PageAccents = {
    Home = Color3.fromRGB(255, 58, 145),
    Games = Color3.fromRGB(0, 205, 255),
    Players = Color3.fromRGB(166, 92, 255),
    Guards = Color3.fromRGB(255, 63, 86),
    Detective = Color3.fromRGB(50, 138, 255),
    Farming = Color3.fromRGB(45, 232, 98),
    UI = Color3.fromRGB(232, 67, 255),
    Settings = Color3.fromRGB(255, 196, 64),
}

----------------------------------------------------------
-- Runtime state
----------------------------------------------------------

App.Loader = nil
App.Theme = nil
App.Components = nil
App.Navigation = nil
App.Utilities = nil
App.Notifications = nil
App.Features = nil
App.FeatureManager = nil
App.Session = nil
App.DeviceClass = "Desktop"
App.Profile = nil

App.Gui = nil
App.Host = nil
App.Window = nil
App.WindowScale = nil
App.Sidebar = nil
App.Topbar = nil
App.Statusbar = nil
App.FooterLabels = {}
App.FeatureWidgets = {}
App.PageContainer = nil
App.ReopenButton = nil

App.Pages = {}
App.PageDefinitions = {}
App.NavigationButtons = {}
App.Connections = {}
App.ModuleErrors = {}
App.AssetCache = {}

App.CurrentPage = nil
App.CurrentScale = 1
App.CurrentDesignSize = Vector2.new(App.Config.DesignWidth, App.Config.DesignHeight)
App.CurrentVisualSize = App.CurrentDesignSize
App.CurrentSafePosition = Vector2.new(0, 0)
App.CurrentSafeSize = App.CurrentDesignSize
App.HasBeenDragged = false
App.IsMinimized = false
App.IsMaximized = false
App.IsFullScreen = false
App.FreeRoamEnabled = true
App.ButtonGlowEnabled = true
App.NavigationGlowEnabled = true
App.CloseConfirmationEnabled = true
App.ReducedMotionEnabled = false
App.RememberLastPageEnabled = true
App.AutoCenterOnResizeEnabled = true
App.UserScale = 1.0
App.BubbleSize = nil
App.WindowOpacity = 0
App.LastSafePosition = nil
App.MinimizedByFreeRoam = false
App.WindowSettingsWidgets = {}
App.DetectionStatus = "UNKNOWN"
App.DetectionDetail = "No status signal has been reported."
App.AppStatus = "STARTING"
App.ReopenButtonHasBeenDragged = false
App._building = false

----------------------------------------------------------
-- Small utilities
----------------------------------------------------------

local function isGuiObject(value)
    return typeof(value) == "Instance" and value:IsA("GuiObject")
end

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function makePadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
end

local function makeGradient(parent, colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function safeDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

function App:Track(connection)
    table.insert(self.Connections, connection)
    return connection
end

function App:Tween(instance, properties, duration)
    if not instance or not instance.Parent then
        return nil
    end

    if self.ReducedMotionEnabled then
        for property, value in pairs(properties or {}) do
            pcall(function()
                instance[property] = value
            end)
        end
        return nil
    end

    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )

    tween:Play()
    return tween
end

function App:GetPageAccent(pageName)
    return self.PageAccents[pageName] or self.Colors.Accent
end

function App:PulseGlow(guiObject, color)
    if not self.ButtonGlowEnabled then
        return
    end

    if not guiObject or not guiObject.Parent then
        return
    end

    local pulse = Instance.new("Frame")
    pulse.Name = "ClickGlow"
    pulse.AnchorPoint = Vector2.new(0.5, 0.5)
    pulse.Position = UDim2.fromScale(0.5, 0.5)
    pulse.Size = UDim2.new(1, 2, 1, 2)
    pulse.BackgroundTransparency = 1
    pulse.BorderSizePixel = 0
    pulse.ZIndex = math.max(1, guiObject.ZIndex - 1)
    pulse.Parent = guiObject
    makeCorner(pulse, 12)

    local stroke = makeStroke(pulse, color or self.Colors.Accent, 3, 0.10)

    if self.ReducedMotionEnabled then
        task.delay(0.08, function()
            if pulse then
                pcall(function()
                    pulse:Destroy()
                end)
            end
        end)
        return
    end

    self:Tween(pulse, {Size = UDim2.new(1, 18, 1, 18)}, 0.22)
    self:Tween(stroke, {Transparency = 1, Thickness = 1}, 0.22)

    task.delay(0.24, function()
        if pulse then
            pcall(function()
                pulse:Destroy()
            end)
        end
    end)
end

function App:BindButtonFeedback(button, color)
    if not button or button:GetAttribute("SquidNoMoFeedback") then
        return
    end

    button:SetAttribute("SquidNoMoFeedback", true)

    local baseTransparency = button.BackgroundTransparency

    local function isPressInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    self:Track(button.InputBegan:Connect(function(input)
        if not isPressInput(input) then
            return
        end

        self:PulseGlow(button, color or self.Colors.Accent)

        -- Transparent hit targets stay transparent. Visible buttons receive
        -- only a subtle pressed-state fade.
        if baseTransparency < 0.98 then
            self:Tween(
                button,
                {
                    BackgroundTransparency = math.min(
                        1,
                        baseTransparency + 0.08
                    ),
                },
                0.08
            )
        end
    end))

    self:Track(button.InputEnded:Connect(function(input)
        if not isPressInput(input) then
            return
        end

        if button and button.Parent then
            self:Tween(
                button,
                {BackgroundTransparency = baseTransparency},
                0.12
            )
        end
    end))
end

function App:SafeCall(label, callback)
    local ok, result = xpcall(callback, function(message)
        return debug.traceback(tostring(message), 2)
    end)

    if not ok then
        self.ModuleErrors[label] = result
        warn("[SquidNoMo][" .. tostring(label) .. "] " .. tostring(result))
    end

    return ok, result
end

----------------------------------------------------------
-- Parent selection
-- Studio uses PlayerGui. Executors prefer gethui/CoreGui.
----------------------------------------------------------

function App:GetSessionEnvironment()
    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return environment
        end
    end

    return _G
end

function App:GetOrCreateSession()
    local environment = self:GetSessionEnvironment()
    local session = environment.__SquidNoMoSession

    if type(session) ~= "table" or session.JobId ~= game.JobId then
        if type(session) == "table" and session.CharacterConnection then
            pcall(function()
                session.CharacterConnection:Disconnect()
            end)
        end

        session = {
            JobId = game.JobId,
            TermsAccepted = false,
            UserClosed = false,
            DetectionStatus = "UNKNOWN",
            DetectionDetail = "No status signal has been reported.",
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
            LastSafePosition = nil,
        }
        environment.__SquidNoMoSession = session
    end

    return session
end

function App:GetDeviceClass(viewport)
    viewport = viewport or self:GetViewportSize()

    if not (self.Config.ForceMobile or UserInputService.TouchEnabled) then
        return "Desktop"
    end

    local shortSide = math.min(viewport.X, viewport.Y)
    if shortSide < 760 then
        return "Phone"
    end

    return "Tablet"
end

function App:ApplyDeviceProfile(viewport)
    viewport = viewport or self:GetViewportSize()
    local deviceClass = self:GetDeviceClass(viewport)
    local profile = self.Config.DeviceProfiles[deviceClass] or self.Config.DeviceProfiles.Desktop

    self.DeviceClass = deviceClass
    self.Profile = profile
    self.Config.DesignWidth = profile.DesignWidth
    self.Config.DesignHeight = profile.DesignHeight
    self.Config.SidebarWidth = profile.SidebarWidth
    self.Config.TopbarHeight = profile.TopbarHeight
    self.Config.StatusbarHeight = profile.StatusbarHeight
    self.Config.CornerRadius = profile.WindowRadius

    return profile
end

function App:GetLayoutMetric(name, fallback)
    local profile = self.Profile or self:ApplyDeviceProfile()
    local value = profile and profile[name]
    if value == nil then
        return fallback
    end
    return value
end

function App:AttachFeatureManager(manager, features)
    if manager then
        self.FeatureManager = manager
    end
    if features then
        self.Features = features
    end

    self:StartFeatureTracking()
    self:RefreshFeatureDashboard()
end

function App:GetPlayerGui()
    if not LocalPlayer then
        LocalPlayer = Players.LocalPlayer
    end

    if not LocalPlayer then
        return nil
    end

    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
        or LocalPlayer:WaitForChild("PlayerGui", 10)
end

function App:GetGuiParent()
    if RunService:IsStudio() then
        return self:GetPlayerGui()
    end

    local executorParent = nil

    if type(gethui) == "function" then
        pcall(function()
            executorParent = gethui()
        end)
    end

    if executorParent then
        return executorParent
    end

    local protectedCoreGui = CoreGui

    if type(cloneref) == "function" then
        pcall(function()
            protectedCoreGui = cloneref(CoreGui)
        end)
    end

    if protectedCoreGui then
        return protectedCoreGui
    end

    return self:GetPlayerGui()
end

function App:DestroyOldCopies()
    local parents = {}

    local function addParent(parent)
        if parent and not table.find(parents, parent) then
            table.insert(parents, parent)
        end
    end

    addParent(self:GetPlayerGui())
    addParent(CoreGui)

    if type(gethui) == "function" then
        pcall(function()
            addParent(gethui())
        end)
    end

    for _, parent in ipairs(parents) do
        local existing = parent:FindFirstChild(self.Name)
        if existing then
            pcall(function()
                existing:Destroy()
            end)
        end
    end
end

----------------------------------------------------------
-- Loader and component compatibility
----------------------------------------------------------

function App:Init(loader)
    self.Loader = loader or {}

    self.Theme = self.Loader.Theme
    self.Components = self.Loader.Components
    self.Navigation = self.Loader.Navigation
    self.Utilities = self.Loader.Utilities
    self.Notifications = self.Loader.Notifications
    self.FeatureManager = self.Loader.FeatureManager
    self.Features = self.Loader.Features or {}

    self.Session = self:GetOrCreateSession()
    self.Session.UserClosed = false
    self.TermsAccepted = self.Session.TermsAccepted == true
    self.DetectionStatus = self.Session.DetectionStatus or "UNKNOWN"
    self.DetectionDetail = self.Session.DetectionDetail or "No status signal has been reported."
    self.FreeRoamEnabled = self.Session.FreeRoamEnabled ~= false
    self.IsFullScreen = self.Session.FullScreenEnabled == true
    self.ButtonGlowEnabled = self.Session.ButtonGlowEnabled ~= false
    self.NavigationGlowEnabled = self.Session.NavigationGlowEnabled ~= false
    self.CloseConfirmationEnabled = self.Session.CloseConfirmationEnabled ~= false
    self.ReducedMotionEnabled = self.Session.ReducedMotionEnabled == true
    self.RememberLastPageEnabled = self.Session.RememberLastPageEnabled ~= false
    self.AutoCenterOnResizeEnabled = self.Session.AutoCenterOnResizeEnabled ~= false
    self.UserScale = math.clamp(tonumber(self.Session.UserScale) or 1.0, 0.75, 1.15)
    self.BubbleSize = tonumber(self.Session.BubbleSize)
    self.WindowOpacity = math.clamp(tonumber(self.Session.WindowOpacity) or 0, 0, 0.35)
    self.LastSafePosition = self.Session.LastSafePosition
    self.MinimizedByFreeRoam = false
    self.AppStatus = "STARTING"

    self:ApplyDeviceProfile()

    if self.Loader.Home and type(self.Loader.Home.Load) ~= "function" then
        self.Loader.Home.Load = function()
            return true
        end
    end

    self:PatchComponents()
end

function App:PatchComponents()
    local components = self.Components

    if not components then
        return
    end

    if type(components.Initialize) == "function" then
        pcall(function()
            components:Initialize(self.Theme or self.Colors)
        end)
    else
        components.Theme = self.Theme or self.Colors
    end

    if components.__SquidNoMoUniversalCompatibility then
        return
    end

    components.__SquidNoMoUniversalCompatibility = true
    components.__SquidNoMoRawMethods = components.__SquidNoMoRawMethods or {}

    local raw = components.__SquidNoMoRawMethods

    local function save(name)
        if type(components[name]) == "function" and not raw[name] then
            raw[name] = components[name]
        end
    end

    save("CreateCard")
    save("CreateSection")
    save("CreateButton")
    save("CreateToggle")
    save("CreateSlider")
    save("CreateDropdown")
    save("CreateTextbox")
    save("CreateLabel")
    save("CreateSpacer")
    save("CreateDivider")

    if raw.CreateCard then
        components.CreateCard = function(this, parent, second, third)
            local size = nil

            if typeof(second) == "UDim2" then
                size = second
            elseif typeof(third) == "UDim2" then
                size = third
            end

            size = size or UDim2.new(1, 0, 0, 120)
            return raw.CreateCard(this, parent, size)
        end
    end

    if raw.CreateSection then
        components.CreateSection = function(this, parent, second, third)
            local title = type(second) == "string" and second or third
            return raw.CreateSection(this, parent, tostring(title or "Section"))
        end
    end

    if raw.CreateButton then
        components.CreateButton = function(this, parent, second, third)
            local text = type(second) == "string" and second or third
            return raw.CreateButton(this, parent, tostring(text or "Button"))
        end
    end

    if raw.CreateToggle then
        components.CreateToggle = function(this, parent, second, third)
            local text = type(second) == "string" and second or third
            return raw.CreateToggle(this, parent, tostring(text or "Toggle"))
        end
    end

    if raw.CreateSlider then
        components.CreateSlider = function(this, parent, a, b, c, d, e)
            if type(a) == "string" then
                return raw.CreateSlider(this, parent, a, b, c, d)
            end

            return raw.CreateSlider(this, parent, b, c, d, e)
        end
    end

    if raw.CreateDropdown then
        components.CreateDropdown = function(this, parent, a, b, c)
            if type(a) == "string" then
                return raw.CreateDropdown(this, parent, a, b)
            end

            return raw.CreateDropdown(this, parent, b, c)
        end
    end

    if raw.CreateTextbox then
        components.CreateTextbox = function(this, parent, second, third)
            local placeholder = type(second) == "string" and second or third
            return raw.CreateTextbox(this, parent, tostring(placeholder or "Enter text"))
        end
    end

    if raw.CreateLabel then
        components.CreateLabel = function(this, parent, second, third)
            local text = type(second) == "string" and second or third
            return raw.CreateLabel(this, parent, tostring(text or ""))
        end
    end

    if raw.CreateSpacer then
        components.CreateSpacer = function(this, parent, second, third)
            local height = type(second) == "number" and second or third
            return raw.CreateSpacer(this, parent, height)
        end
    end

    if raw.CreateDivider then
        components.CreateDivider = function(this, parent)
            return raw.CreateDivider(this, parent)
        end
    end

    if type(components.CreateTitle) ~= "function" then
        function components:CreateTitle(parent, second, third)
            local theme = self.Theme or App.Theme or App.Colors
            local text = type(second) == "string" and second or third

            local label = Instance.new("TextLabel")
            label.Name = "Title"
            label.BackgroundTransparency = 1
            label.Position = UDim2.fromOffset(18, 14)
            label.Size = UDim2.new(1, -36, 0, 26)
            label.Font = theme.FontBlack or Enum.Font.GothamBold
            label.Text = tostring(text or "")
            label.TextSize = 19
            label.TextColor3 = theme.Text or App.Colors.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = parent
            return label
        end
    end
end

----------------------------------------------------------
-- Screen and safe region calculations
----------------------------------------------------------

function App:GetViewportSize()
    local camera = workspace.CurrentCamera

    if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
        return camera.ViewportSize
    end

    return Vector2.new(1280, 720)
end

function App:IsMobile(viewport)
    viewport = viewport or self:GetViewportSize()
    return self.Config.ForceMobile or UserInputService.TouchEnabled
end

function App:GetDesignSize(viewport)
    viewport = viewport or self:GetViewportSize()
    local expectedClass = self:GetDeviceClass(viewport)

    if not self.Profile or expectedClass ~= self.DeviceClass then
        self:ApplyDeviceProfile(viewport)
    end

    return Vector2.new(self.Profile.DesignWidth, self.Profile.DesignHeight)
end

function App:GetSafeRect()
    local viewport = self:GetViewportSize()
    local expectedClass = self:GetDeviceClass(viewport)

    if not self.Profile or expectedClass ~= self.DeviceClass then
        self:ApplyDeviceProfile(viewport)
    end

    local margins = self.Profile.Margins
    local left = viewport.X * margins.Left
    local right = viewport.X * margins.Right
    local top = viewport.Y * margins.Top
    local bottom = viewport.Y * margins.Bottom

    if self.Config.RespectGuiInset then
        local ok, insetTopLeft, insetBottomRight = pcall(function()
            return GuiService:GetGuiInset()
        end)

        if ok then
            left = math.max(left, insetTopLeft.X)
            top = math.max(top, insetTopLeft.Y)
            right = math.max(right, insetBottomRight.X)
            bottom = math.max(bottom, insetBottomRight.Y)
        end
    end

    local position = Vector2.new(math.floor(left), math.floor(top))
    local size = Vector2.new(
        math.max(260, math.floor(viewport.X - left - right)),
        math.max(240, math.floor(viewport.Y - top - bottom))
    )

    return position, size
end

function App:CalculateScale()
    local viewport = self:GetViewportSize()
    local safePosition, safeSize = self:GetSafeRect()
    local baseDesignSize = self:GetDesignSize(viewport)

    if self.IsFullScreen then
        local scale = viewport.Y / baseDesignSize.Y
        local dynamicWidth = viewport.X / scale
        local designSize = Vector2.new(dynamicWidth, baseDesignSize.Y)

        if dynamicWidth < baseDesignSize.X then
            scale = viewport.X / baseDesignSize.X
            designSize = Vector2.new(baseDesignSize.X, viewport.Y / scale)
        end

        return scale, Vector2.new(0, 0), viewport, viewport, designSize
    end

    local targetPosition = safePosition
    local targetSize = safeSize
    local fill = self.Profile.RestoreFill

    if self.IsMaximized then
        targetPosition = Vector2.new(0, 0)
        targetSize = viewport
        fill = 1
    end

    local targetWidth = targetSize.X * fill
    local targetHeight = targetSize.Y * fill
    local fitScale = math.min(
        targetWidth / baseDesignSize.X,
        targetHeight / baseDesignSize.Y
    )

    local scale = math.min(fitScale, self.Config.MaximumScale)
    scale = math.max(scale, math.min(self.Config.MinimumScale, fitScale))

    local userScale = math.clamp(tonumber(self.UserScale) or 1.0, 0.75, 1.15)
    scale = math.min(fitScale, scale * userScale)

    local visualSize = Vector2.new(
        math.max(1, math.floor(baseDesignSize.X * scale)),
        math.max(1, math.floor(baseDesignSize.Y * scale))
    )

    if self.IsMaximized then
        scale = viewport.Y / baseDesignSize.Y
        visualSize = Vector2.new(
            math.floor(baseDesignSize.X * scale),
            viewport.Y
        )
    end

    return scale, targetPosition, targetSize, visualSize, baseDesignSize
end

function App:GetBoundedHostPosition(position)
    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize
    local padding = self.Config.WindowEdgePadding or 4

    local minX = padding
    local minY = padding
    local maxX = math.max(minX, viewport.X - visualSize.X - padding)
    local maxY = math.max(minY, viewport.Y - visualSize.Y - padding)

    return Vector2.new(
        math.clamp(position.X, minX, maxX),
        math.clamp(position.Y, minY, maxY)
    )
end

function App:IsPositionFullyUsable(position)
    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize
    local padding = self.Config.WindowEdgePadding or 4

    return position.X >= padding
        and position.Y >= padding
        and position.X + visualSize.X <= viewport.X - padding
        and position.Y + visualSize.Y <= viewport.Y - padding
end

function App:SaveLastSafePosition(position)
    if not position or self.IsFullScreen or self.IsMaximized then
        return
    end

    local safe = self:GetBoundedHostPosition(position)
    self.LastSafePosition = safe

    if self.Session then
        self.Session.LastSafePosition = safe
    end
end

function App:GetRecoveryPosition()
    if typeof(self.LastSafePosition) == "Vector2" then
        return self:GetBoundedHostPosition(self.LastSafePosition)
    end

    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize
    return self:GetBoundedHostPosition(Vector2.new(
        (viewport.X - visualSize.X) / 2,
        (viewport.Y - visualSize.Y) / 2
    ))
end

function App:GetVisibleWindowRatio(position)
    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize

    local left = math.max(0, position.X)
    local top = math.max(0, position.Y)
    local right = math.min(viewport.X, position.X + visualSize.X)
    local bottom = math.min(viewport.Y, position.Y + visualSize.Y)
    local width = math.max(0, right - left)
    local height = math.max(0, bottom - top)
    local totalArea = math.max(1, visualSize.X * visualSize.Y)

    return (width * height) / totalArea
end

function App:ShouldAutoMinimizeFreeRoam(position)
    if not self.FreeRoamEnabled or self.IsFullScreen or self.IsMaximized then
        return false
    end

    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize
    local titleHeight = math.max(1, self.Config.TopbarHeight * self.CurrentScale)

    local titleLeft = math.max(0, position.X)
    local titleTop = math.max(0, position.Y)
    local titleRight = math.min(viewport.X, position.X + visualSize.X)
    local titleBottom = math.min(viewport.Y, position.Y + titleHeight)
    local visibleTitleWidth = math.max(0, titleRight - titleLeft)
    local visibleTitleHeight = math.max(0, titleBottom - titleTop)

    return self:GetVisibleWindowRatio(position) < self.Config.FreeRoamAutoMinimizeVisibleRatio
        or visibleTitleWidth < self.Config.FreeRoamMinimumTitleWidth
        or visibleTitleHeight < self.Config.FreeRoamMinimumTitleHeight
end

function App:ClampHostPosition(position)
    local viewport = self:GetViewportSize()
    local visualSize = self.CurrentVisualSize

    if self.IsFullScreen then
        return Vector2.new(0, 0)
    end

    if self.IsMaximized then
        local maxX = math.max(0, viewport.X - visualSize.X)
        return Vector2.new(math.clamp(position.X, 0, maxX), 0)
    end

    if not self.FreeRoamEnabled then
        return self:GetBoundedHostPosition(position)
    end

    local visible = self.Config.DragVisiblePixels or 48
    return Vector2.new(
        math.clamp(position.X, -visualSize.X + visible, viewport.X - visible),
        math.clamp(position.Y, -visualSize.Y + visible, viewport.Y - visible)
    )
end

function App:UpdateResponsive(forceCenter)
    if not self.Host or not self.WindowScale then
        return
    end

    local viewport = self:GetViewportSize()
    local expectedClass = self:GetDeviceClass(viewport)

    if expectedClass ~= self.DeviceClass and not self._building then
        task.defer(function()
            if self.Gui and not self._building then
                self:Build(self.Loader)
            end
        end)
        return
    end

    local scale, safePosition, safeSize, visualSize, designSize = self:CalculateScale()

    self.CurrentScale = scale
    self.CurrentDesignSize = designSize
    self.CurrentSafePosition = safePosition
    self.CurrentSafeSize = safeSize
    self.CurrentVisualSize = visualSize

    self.Window.Size = UDim2.fromOffset(designSize.X, designSize.Y)
    self.WindowScale.Scale = scale
    self.Host.Size = UDim2.fromOffset(visualSize.X, visualSize.Y)

    local targetPosition

    if self.IsFullScreen then
        targetPosition = Vector2.new(0, 0)
    elseif self.IsMaximized then
        targetPosition = Vector2.new(
            (viewport.X - visualSize.X) / 2,
            0
        )
    elseif forceCenter or not self.HasBeenDragged then
        targetPosition = Vector2.new(
            (viewport.X - visualSize.X) / 2,
            (viewport.Y - visualSize.Y) / 2
        )
    else
        targetPosition = Vector2.new(
            self.Host.Position.X.Offset,
            self.Host.Position.Y.Offset
        )
    end

    targetPosition = self:ClampHostPosition(targetPosition)
    self.Host.Position = UDim2.fromOffset(targetPosition.X, targetPosition.Y)

    if self:IsPositionFullyUsable(targetPosition) then
        self:SaveLastSafePosition(targetPosition)
    end

    if self.ReopenButton and self.ReopenButton.Visible then
        self:PositionReopenButton(false)
    end
end

function App:CreateGui()
    self:DestroyOldCopies()

    local gui = Instance.new("ScreenGui")
    gui.Name = self.Name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = self.Config.DisplayOrder
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    pcall(function()
        gui.ScreenInsets = Enum.ScreenInsets.None
    end)

    pcall(function()
        gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
    end)

    pcall(function()
        gui.ClipToDeviceSafeArea = false
    end)

    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        pcall(function()
            syn.protect_gui(gui)
        end)
    end

    local parent = self:GetGuiParent()
    assert(parent, "No valid GUI parent was available")

    gui.Parent = parent
    self.Gui = gui

    if self.Notifications and type(self.Notifications.Init) == "function" then
        pcall(function()
            self.Notifications:Init(gui, self.Theme or self.Colors)
        end)
    end
end

function App:CreateWindow()
    local host = Instance.new("Frame")
    host.Name = "FloatingHost"
    host.BackgroundTransparency = 1
    host.BorderSizePixel = 0
    host.Active = true
    host.ZIndex = 1000
    host.Parent = self.Gui
    self.Host = host

    local designSize = self:GetDesignSize()
    self.CurrentDesignSize = designSize

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.fromOffset(designSize.X, designSize.Y)
    window.BackgroundColor3 = self.Colors.Window
    window.BackgroundTransparency = self.WindowOpacity or 0
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Active = true
    window.ZIndex = 1001
    window.Parent = host
    makeCorner(window, self.Config.CornerRadius)
    makeStroke(window, self.Colors.Border, 1, 0.15)

    local scale = Instance.new("UIScale")
    scale.Name = "ResponsiveScale"
    scale.Scale = 1
    scale.Parent = window

    local blocker = Instance.new("Frame")
    blocker.Name = "InputShield"
    blocker.Size = UDim2.fromScale(1, 1)
    blocker.BackgroundTransparency = 1
    blocker.BorderSizePixel = 0
    blocker.Active = true
    blocker.ZIndex = 1001
    blocker.Parent = window

    self.Window = window
    self.WindowScale = scale
end

----------------------------------------------------------
-- Topbar, dragging, minimize, close
----------------------------------------------------------

function App:CreateTopbar()
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Position = UDim2.fromOffset(self.Config.SidebarWidth, 0)
    topbar.Size = UDim2.new(1, -self.Config.SidebarWidth, 0, self.Config.TopbarHeight)
    topbar.BackgroundColor3 = self.Colors.Topbar
    topbar.BackgroundTransparency = math.min(0.45, 0.10 + ((self.WindowOpacity or 0) * 0.65))
    topbar.BorderSizePixel = 0
    topbar.ZIndex = 1020
    topbar.Parent = self.Window

    local accentLine = Instance.new("Frame")
    accentLine.AnchorPoint = Vector2.new(0, 1)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.Size = UDim2.new(1, 0, 0, 1)
    accentLine.BackgroundColor3 = self.Colors.BorderSoft
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 1021
    accentLine.Parent = topbar

    local mobile = self:IsMobile()
    local buttonSize = mobile and 44 or 40
    local gap = mobile and 10 or 9
    local rightPadding = mobile and 14 or 12

    local closeOffset = rightPadding
    local maximizeOffset = rightPadding + buttonSize + gap
    local minimizeOffset = rightPadding + (buttonSize + gap) * 2

    local moveHandle = Instance.new("TextButton")
    moveHandle.Name = "MoveHandle"
    moveHandle.Position = UDim2.fromOffset(8, 4)
    moveHandle.Size = UDim2.new(1, -(minimizeOffset + buttonSize + 16), 1, -8)
    moveHandle.BackgroundTransparency = 1
    moveHandle.BorderSizePixel = 0
    moveHandle.AutoButtonColor = false
    moveHandle.Text = ""
    moveHandle.ZIndex = 1022
    moveHandle.Parent = topbar

    local grip = Instance.new("Frame")
    grip.Name = "DragGrip"
    grip.AnchorPoint = Vector2.new(0.5, 0.5)
    grip.Position = UDim2.fromScale(0.5, 0.5)
    grip.Size = UDim2.fromOffset(30, 16)
    grip.BackgroundTransparency = 1
    grip.BorderSizePixel = 0
    grip.ZIndex = 1023
    grip.Parent = moveHandle

    for row = 0, 1 do
        for column = 0, 2 do
            local dot = Instance.new("Frame")
            dot.Position = UDim2.fromOffset(5 + (column * 9), 3 + (row * 9))
            dot.Size = UDim2.fromOffset(4, 4)
            dot.BackgroundColor3 = self.Colors.Muted
            dot.BackgroundTransparency = 0.22
            dot.BorderSizePixel = 0
            dot.ZIndex = 1024
            dot.Parent = grip
            makeCorner(dot, 999)
        end
    end

    self:EnableDragging(moveHandle)

    local minimize = self:CreateTopbarButton(topbar, "Minimize", "—", minimizeOffset, self.Colors.Minimize)
    local maximize = self:CreateTopbarButton(topbar, "MaximizeRestore", (self.IsMaximized or self.IsFullScreen) and "❐" or "□", maximizeOffset, self.Colors.Maximize)
    local close = self:CreateTopbarButton(topbar, "Close", "×", closeOffset, self.Colors.Close)

    minimize.MouseButton1Click:Connect(function()
        self:SetMinimized(true)
    end)

    maximize.MouseButton1Click:Connect(function()
        if self.IsFullScreen then
            self:SetFullScreen(false)
        else
            self:SetMaximized(not self.IsMaximized)
        end
    end)

    close.MouseButton1Click:Connect(function()
        self:ShowCloseConfirmation()
    end)

    self.Topbar = topbar
    self.MaximizeButton = maximize
    self:RefreshWindowModeControls()
end

function App:CreateTopbarButton(parent, name, textValue, rightOffset, baseColor)
    local mobile = self:IsMobile()
    local width = mobile and 44 or 40
    local height = mobile and 40 or 34

    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -rightOffset, 0.5, 0)
    button.Size = UDim2.fromOffset(width, height)
    button.BackgroundColor3 = baseColor
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBlack
    button.Text = textValue
    button.TextSize = mobile and 21 or 19
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.ZIndex = 1030
    button.Parent = parent
    makeCorner(button, 9)
    makeStroke(button, Color3.fromRGB(255, 255, 255), 1, 0.72)

    button.MouseEnter:Connect(function()
        self:Tween(button, {BackgroundTransparency = 0.12}, 0.12)
    end)

    button.MouseLeave:Connect(function()
        self:Tween(button, {BackgroundTransparency = 0}, 0.12)
    end)

    self:BindButtonFeedback(button, baseColor)
    return button
end

function App:EnableDragging(dragBar)
    if not dragBar then
        return
    end

    dragBar.Active = true

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local shouldAutoMinimize = false

    self:Track(dragBar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then
            return
        end

        if self.IsFullScreen or self.IsMaximized or self.IsMinimized then
            return
        end

        dragging = true
        shouldAutoMinimize = false
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Vector2.new(
            self.Host.Position.X.Offset,
            self.Host.Position.Y.Offset
        )

        if self:IsPositionFullyUsable(startPosition) then
            self:SaveLastSafePosition(startPosition)
        end

        if inputType == Enum.UserInputType.Touch then
            dragInput = input
        end

        self:Track(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil

                if shouldAutoMinimize then
                    task.defer(function()
                        self:AutoMinimizeFromFreeRoam()
                    end)
                end
            end
        end))
    end))

    self:Track(dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput or not dragStart or not startPosition then
            return
        end

        local current = Vector2.new(input.Position.X, input.Position.Y)
        local delta = current - dragStart
        local target = self:ClampHostPosition(startPosition + delta)

        self.Host.Position = UDim2.fromOffset(target.X, target.Y)
        self.HasBeenDragged = true

        if self:IsPositionFullyUsable(target) then
            self:SaveLastSafePosition(target)
        end

        shouldAutoMinimize = self:ShouldAutoMinimizeFreeRoam(target)
    end))
end

function App:AutoMinimizeFromFreeRoam()
    if not self.FreeRoamEnabled or self.IsMinimized then
        return
    end

    self.MinimizedByFreeRoam = true
    self:SetMinimized(true)
end

function App:ClampReopenButtonPosition(position)
    local viewport = self:GetViewportSize()
    local size = 64
    local padding = 8

    if self.ReopenButton then
        size = math.max(
            self.ReopenButton.AbsoluteSize.X,
            self.ReopenButton.AbsoluteSize.Y,
            size
        )
    end

    return Vector2.new(
        math.clamp(position.X, padding, math.max(padding, viewport.X - size - padding)),
        math.clamp(position.Y, padding, math.max(padding, viewport.Y - size - padding))
    )
end

function App:EnableReopenButtonDragging(button)
    local dragging = false
    local activeInput = nil
    local startInput = nil
    local startPosition = nil
    local moved = false

    self:Track(button.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        moved = false
        activeInput = input
        startInput = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Vector2.new(button.Position.X.Offset, button.Position.Y.Offset)
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeInput then
            return
        end

        local correctInput = input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement)

        if not correctInput then
            return
        end

        local current = Vector2.new(input.Position.X, input.Position.Y)
        local delta = current - startInput

        if delta.Magnitude >= 7 then
            moved = true
        end

        local target = self:ClampReopenButtonPosition(startPosition + delta)
        button.Position = UDim2.fromOffset(target.X, target.Y)
    end))

    self:Track(UserInputService.InputEnded:Connect(function(input)
        if not dragging then
            return
        end

        local finished = input == activeInput
            or input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch

        if not finished then
            return
        end

        dragging = false
        activeInput = nil

        if moved then
            self.ReopenButtonHasBeenDragged = true
        else
            self:SetMinimized(false)
        end
    end))
end

function App:CreateReopenButton()
    local mobile = self:IsMobile()
    local defaultSize = mobile and 66 or 60
    local buttonSize = math.clamp(math.floor(tonumber(self.BubbleSize) or defaultSize), 48, 92)

    local button = Instance.new("TextButton")
    button.Name = "Reopen"
    button.Size = UDim2.fromOffset(buttonSize, buttonSize)
    button.BackgroundColor3 = self.Colors.Window
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Visible = false
    button.Active = true
    button.ZIndex = 5000
    button.Parent = self.Gui
    makeCorner(button, 999)
    makeStroke(button, self.Colors.Accent, 2, 0.02)

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.5)
    logo.Size = UDim2.new(1, -8, 1, -8)
    logo.BackgroundTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Image = ""
    logo.ZIndex = 5002
    logo.Parent = button
    self:SetImageFromAsset(logo, self.Config.Assets and self.Config.Assets.Logo, "SN")

    self.ReopenButton = button
    self:EnableReopenButtonDragging(button)
end

function App:PositionReopenButton(forceDefault)
    if not self.ReopenButton then
        return
    end

    if self.ReopenButtonHasBeenDragged and not forceDefault then
        local current = Vector2.new(
            self.ReopenButton.Position.X.Offset,
            self.ReopenButton.Position.Y.Offset
        )
        local clamped = self:ClampReopenButtonPosition(current)
        self.ReopenButton.Position = UDim2.fromOffset(clamped.X, clamped.Y)
        return
    end

    local safePosition, safeSize = self:GetSafeRect()
    local buttonSize = self.ReopenButton.Size.X.Offset
    local defaultPosition = Vector2.new(
        safePosition.X + 10,
        safePosition.Y + math.max(10, (safeSize.Y - buttonSize) / 2)
    )
    local clamped = self:ClampReopenButtonPosition(defaultPosition)
    self.ReopenButton.Position = UDim2.fromOffset(clamped.X, clamped.Y)
end

function App:SetMinimized(state)
    self.IsMinimized = state and true or false

    if not self.IsMinimized and self.MinimizedByFreeRoam and self.Host then
        local recovery = self:GetRecoveryPosition()
        self.Host.Position = UDim2.fromOffset(recovery.X, recovery.Y)
        self.HasBeenDragged = true
        self.MinimizedByFreeRoam = false
    end

    if self.Host then
        self.Host.Visible = not self.IsMinimized
    end

    if self.ReopenButton then
        self.ReopenButton.Visible = self.IsMinimized
        if self.IsMinimized then
            self:PositionReopenButton(false)
        end
    end
end

----------------------------------------------------------
-- Sidebar and important notice
----------------------------------------------------------

function App:RefreshWindowModeControls()
    if self.MaximizeButton then
        self.MaximizeButton.Text = (self.IsMaximized or self.IsFullScreen) and "❐" or "□"
    end

    self:RefreshWindowSettings()
end

function App:SetFreeRoamEnabled(state)
    self.FreeRoamEnabled = state and true or false

    if self.Session then
        self.Session.FreeRoamEnabled = self.FreeRoamEnabled
    end

    if not self.FreeRoamEnabled and self.Host and not self.IsMaximized and not self.IsFullScreen then
        local current = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)
        local bounded = self:GetBoundedHostPosition(current)
        self.Host.Position = UDim2.fromOffset(bounded.X, bounded.Y)
        self:SaveLastSafePosition(bounded)
    end

    self:RefreshWindowSettings()
end

function App:SetFullScreen(state)
    local desired = state and true or false
    local recovery = nil

    if desired and self.Host and not self.IsMaximized then
        local current = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)
        if self:IsPositionFullyUsable(current) then
            self:SaveLastSafePosition(current)
        end
    elseif not desired then
        recovery = self:GetRecoveryPosition()
    end

    self.IsFullScreen = desired
    if desired then
        self.IsMaximized = false
    end

    if self.Session then
        self.Session.FullScreenEnabled = self.IsFullScreen
    end

    self.HasBeenDragged = false
    self:UpdateResponsive(true)

    if not desired and self.Host and recovery then
        local bounded = self:GetBoundedHostPosition(recovery)
        self.Host.Position = UDim2.fromOffset(bounded.X, bounded.Y)
        self.HasBeenDragged = true
        self:SaveLastSafePosition(bounded)
    end

    self:RefreshWindowModeControls()
end

function App:SetMaximized(state)
    local desired = state and true or false
    local recovery = nil

    if desired and self.Host and not self.IsFullScreen then
        local current = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)
        if self:IsPositionFullyUsable(current) then
            self:SaveLastSafePosition(current)
        end
    elseif not desired then
        recovery = self:GetRecoveryPosition()
    end

    self.IsMaximized = desired
    if desired then
        self.IsFullScreen = false
        if self.Session then
            self.Session.FullScreenEnabled = false
        end
    end

    self.HasBeenDragged = false
    self:UpdateResponsive(true)

    if not desired and self.Host and recovery then
        local bounded = self:GetBoundedHostPosition(recovery)
        self.Host.Position = UDim2.fromOffset(bounded.X, bounded.Y)
        self.HasBeenDragged = true
        self:SaveLastSafePosition(bounded)
    end

    self:RefreshWindowModeControls()
end

function App:ResetWindowPosition()
    if self.IsFullScreen then
        self:SetFullScreen(false)
    elseif self.IsMaximized then
        self:SetMaximized(false)
    end

    self.HasBeenDragged = false
    self:UpdateResponsive(true)

    if self.Host then
        local position = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)
        self:SaveLastSafePosition(position)
    end

    self:RefreshWindowSettings()
end

function App:BringToFront()
    if self.Gui then
        self.Gui.DisplayOrder = self.Config.DisplayOrder + 1
        task.defer(function()
            if self.Gui then
                self.Gui.DisplayOrder = self.Config.DisplayOrder
            end
        end)
    end

    self:SetMinimized(false)
end

function App:ShowCloseConfirmation()
    if not self.Window then
        return
    end

    if not self.CloseConfirmationEnabled then
        if self.Session then
            self.Session.UserClosed = true
        end
        self:Destroy(true)
        return
    end

    if self.CloseModal and self.CloseModal.Parent then
        self.CloseModal:Destroy()
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "CloseConfirmation"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.30
    overlay.BorderSizePixel = 0
    overlay.Active = true
    overlay.ZIndex = 3600
    overlay.Parent = self.Window

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(self:IsMobile() and 470 or 440, 210)
    panel.BackgroundColor3 = self.Colors.Card
    panel.BorderSizePixel = 0
    panel.ZIndex = 3601
    panel.Parent = overlay
    makeCorner(panel, 18)
    makeStroke(panel, self.Colors.Close, 2, 0.04)

    self:CreateText(panel, "CLOSE SQUIDNOMO?", UDim2.new(1, -40, 0, 34), UDim2.fromOffset(20, 22), {
        Font = Enum.Font.GothamBlack,
        TextSize = 21,
        Color = self.Colors.Close,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3602,
    })

    self:CreateText(panel, "The app will stay closed until you run the loader again in this server.", UDim2.new(1, -48, 0, 54), UDim2.fromOffset(24, 66), {
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Color = self.Colors.Text,
        Wrapped = true,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3602,
    })

    local cancel = Instance.new("TextButton")
    cancel.Position = UDim2.fromOffset(24, 142)
    cancel.Size = UDim2.new(0.5, -30, 0, 46)
    cancel.BackgroundColor3 = self.Colors.CardAlt
    cancel.BorderSizePixel = 0
    cancel.Font = Enum.Font.GothamBold
    cancel.Text = "CANCEL"
    cancel.TextSize = 15
    cancel.TextColor3 = self.Colors.Text
    cancel.ZIndex = 3602
    cancel.Parent = panel
    makeCorner(cancel, 11)

    local confirm = Instance.new("TextButton")
    confirm.Position = UDim2.new(0.5, 6, 0, 142)
    confirm.Size = UDim2.new(0.5, -30, 0, 46)
    confirm.BackgroundColor3 = self.Colors.Close
    confirm.BorderSizePixel = 0
    confirm.Font = Enum.Font.GothamBold
    confirm.Text = "CLOSE APP"
    confirm.TextSize = 15
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.ZIndex = 3602
    confirm.Parent = panel
    makeCorner(confirm, 11)
    self:BindButtonFeedback(cancel, self.Colors.Muted)
    self:BindButtonFeedback(confirm, self.Colors.Close)

    cancel.MouseButton1Click:Connect(function()
        overlay:Destroy()
        self.CloseModal = nil
    end)

    confirm.MouseButton1Click:Connect(function()
        if self.Session then
            self.Session.UserClosed = true
        end
        overlay:Destroy()
        self.CloseModal = nil
        self:Destroy(true)
    end)

    self.CloseModal = overlay
end

function App:SetDetectionStatus(status, detail)
    local normalized = string.upper(tostring(status or "UNKNOWN"))
    local allowed = {
        UNKNOWN = true,
        NO_DETECTION_SIGNALS = true,
        POSSIBLE_DETECTION = true,
        DETECTED = true,
    }

    if not allowed[normalized] then
        normalized = "UNKNOWN"
    end

    self.DetectionStatus = normalized
    self.DetectionDetail = tostring(detail or "")

    if self.Session then
        self.Session.DetectionStatus = normalized
        self.Session.DetectionDetail = self.DetectionDetail
    end

    self:RefreshStatusbar()
end

function App:ReportDetectionSignal(level, detail)
    local normalized = string.upper(tostring(level or "UNKNOWN"))
    if normalized == "POSSIBLE" then
        normalized = "POSSIBLE_DETECTION"
    elseif normalized == "NONE" or normalized == "CLEAR" then
        normalized = "NO_DETECTION_SIGNALS"
    end

    self:SetDetectionStatus(normalized, detail)
end

function App:SetAppStatus(status)
    self.AppStatus = string.upper(tostring(status or "READY"))
    self:RefreshStatusbar()
end

function App:RefreshStatusbar()
    if not self.FooterLabels then
        return
    end

    local display = {
        UNKNOWN = {Text = "STATUS: UNKNOWN", Color = self.Colors.Muted},
        NO_DETECTION_SIGNALS = {Text = "STATUS: NO DETECTION SIGNALS", Color = self.Colors.Success},
        POSSIBLE_DETECTION = {Text = "STATUS: POSSIBLE DETECTION", Color = self.Colors.Warning},
        DETECTED = {Text = "STATUS: DETECTED", Color = self.Colors.Error},
    }

    local current = display[self.DetectionStatus] or display.UNKNOWN

    if self.FooterLabels.Detection then
        self.FooterLabels.Detection.Text = current.Text
        self.FooterLabels.Detection.TextColor3 = current.Color
    end

    if self.FooterLabels.App then
        self.FooterLabels.App.Text = "APP: " .. tostring(self.AppStatus or "READY")
        self.FooterLabels.App.TextColor3 = self.AppStatus == "READY" and self.Colors.Success or self.Colors.Warning
    end
end

function App:CreateStatusbar()
    local bar = Instance.new("Frame")
    bar.Name = "Statusbar"
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.Position = UDim2.new(0, 0, 1, 0)
    bar.Size = UDim2.new(1, 0, 0, self.Config.StatusbarHeight)
    bar.BackgroundColor3 = self.Colors.Topbar
    bar.BackgroundTransparency = math.min(0.45, 0.03 + ((self.WindowOpacity or 0) * 0.65))
    bar.BorderSizePixel = 0
    bar.ZIndex = 1040
    bar.Parent = self.Window

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = self.Colors.BorderSoft
    line.BorderSizePixel = 0
    line.ZIndex = 1041
    line.Parent = bar

    local copyright = self:CreateText(bar, "© 2026 SquidNoMo. All rights reserved.", UDim2.fromOffset(self.Config.SidebarWidth - 16, self.Config.StatusbarHeight), UDim2.fromOffset(16, 0), {
        Font = Enum.Font.Gotham,
        TextSize = self:IsMobile() and 9 or 10,
        Color = self.Colors.Muted,
        ZIndex = 1042,
    })

    local keyless = self:CreateText(bar, "FULLY KEYLESS", UDim2.fromOffset(180, self.Config.StatusbarHeight), UDim2.fromOffset(self.Config.SidebarWidth + 24, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = self:IsMobile() and 10 or 11,
        Color = self.Colors.Success,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1042,
    })

    local detection = self:CreateText(bar, "STATUS: UNKNOWN", UDim2.new(1, -(self.Config.SidebarWidth + 390), 1, 0), UDim2.fromOffset(self.Config.SidebarWidth + 205, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = self:IsMobile() and 10 or 11,
        Color = self.Colors.Muted,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1042,
    })

    local appStatus = self:CreateText(bar, "APP: STARTING", UDim2.fromOffset(180, self.Config.StatusbarHeight), UDim2.new(1, -196, 0, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = self:IsMobile() and 10 or 11,
        Color = self.Colors.Warning,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1042,
    })

    self.Statusbar = bar
    self.FooterLabels = {
        Copyright = copyright,
        Keyless = keyless,
        Detection = detection,
        App = appStatus,
    }
    self:RefreshStatusbar()
end

function App:StartDetectionMonitor()
    pcall(function()
        self:Track(GuiService.ErrorMessageChanged:Connect(function(message)
            local value = string.lower(tostring(message or ""))
            if value == "" then
                return
            end

            if string.find(value, "detected", 1, true)
                or string.find(value, "anti-cheat", 1, true)
                or string.find(value, "exploit", 1, true)
                or string.find(value, "unauthorized", 1, true) then
                self:SetDetectionStatus("DETECTED", message)
            elseif string.find(value, "banned", 1, true)
                or string.find(value, "suspended", 1, true)
                or string.find(value, "kicked", 1, true) then
                self:SetDetectionStatus("POSSIBLE_DETECTION", message)
            end
        end))
    end)

    task.delay(2, function()
        if self.Gui and self.DetectionStatus == "UNKNOWN" then
            self:SetDetectionStatus("NO_DETECTION_SIGNALS", "No explicit detection message has been observed.")
        end
    end)
end

function App:CreateSidebar()
    local mobile = self:IsMobile()
    local sidebarWidth = self.Config.SidebarWidth
    local headerHeight = mobile and 86 or 92

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -self.Config.StatusbarHeight)
    sidebar.BackgroundColor3 = self.Colors.Sidebar
    sidebar.BackgroundTransparency = (self.WindowOpacity or 0) * 0.65
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 1010
    sidebar.Parent = self.Window

    local rightBorder = Instance.new("Frame")
    rightBorder.AnchorPoint = Vector2.new(1, 0)
    rightBorder.Position = UDim2.new(1, 0, 0, 0)
    rightBorder.Size = UDim2.new(0, 1, 1, 0)
    rightBorder.BackgroundColor3 = self.Colors.BorderSoft
    rightBorder.BorderSizePixel = 0
    rightBorder.ZIndex = 1011
    rightBorder.Parent = sidebar

    local logoSize = mobile and 54 or 60
    local logoFrame = Instance.new("Frame")
    logoFrame.Position = UDim2.fromOffset(16, mobile and 13 or 16)
    logoFrame.Size = UDim2.fromOffset(logoSize, logoSize)
    logoFrame.BackgroundColor3 = Color3.fromRGB(14, 10, 21)
    logoFrame.BorderSizePixel = 0
    logoFrame.ZIndex = 1012
    logoFrame.Parent = sidebar
    makeCorner(logoFrame, 999)
    makeStroke(logoFrame, self.Colors.Accent, 2, 0.04)

    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "LogoImage"
    logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImage.Position = UDim2.fromScale(0.5, 0.5)
    logoImage.Size = UDim2.new(1, -6, 1, -6)
    logoImage.BackgroundTransparency = 1
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.Image = ""
    logoImage.ZIndex = 1014
    logoImage.Parent = logoFrame
    self:SetImageFromAsset(logoImage, self.Config.Assets and self.Config.Assets.Logo, "SN")

    local brandX = 82
    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Position = UDim2.fromOffset(brandX, mobile and 16 or 18)
    brand.Size = UDim2.new(1, -(brandX + 10), 0, 27)
    brand.Font = Enum.Font.GothamBlack
    brand.Text = "SQUIDNOMO"
    brand.TextSize = mobile and 15 or 17
    brand.TextColor3 = self.Colors.Text
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.ZIndex = 1012
    brand.Parent = sidebar

    local keyless = Instance.new("TextLabel")
    keyless.BackgroundTransparency = 1
    keyless.Position = UDim2.fromOffset(brandX, mobile and 40 or 44)
    keyless.Size = UDim2.new(1, -(brandX + 10), 0, 16)
    keyless.Font = Enum.Font.GothamBold
    keyless.Text = "FULLY KEYLESS"
    keyless.TextSize = mobile and 10 or 11
    keyless.TextColor3 = self.Colors.Accent
    keyless.TextXAlignment = Enum.TextXAlignment.Left
    keyless.ZIndex = 1012
    keyless.Parent = sidebar

    local version = Instance.new("TextLabel")
    version.BackgroundTransparency = 1
    version.Position = UDim2.fromOffset(brandX, mobile and 56 or 61)
    version.Size = UDim2.new(1, -(brandX + 10), 0, 15)
    version.Font = Enum.Font.GothamMedium
    version.Text = self.Version
    version.TextSize = 9
    version.TextColor3 = self.Colors.Muted
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 1012
    version.Parent = sidebar

    local sidebarDragHandle = Instance.new("TextButton")
    sidebarDragHandle.Name = "SidebarDragHandle"
    sidebarDragHandle.Position = UDim2.fromOffset(0, 0)
    sidebarDragHandle.Size = UDim2.fromOffset(sidebarWidth, headerHeight)
    sidebarDragHandle.BackgroundTransparency = 1
    sidebarDragHandle.BorderSizePixel = 0
    sidebarDragHandle.AutoButtonColor = false
    sidebarDragHandle.Text = ""
    sidebarDragHandle.ZIndex = 1018
    sidebarDragHandle.Parent = sidebar
    self:EnableDragging(sidebarDragHandle)

    self.NavigationButtonHeight = self.Profile.NavigationButtonHeight
    self.NavigationButtonPadding = self.Profile.NavigationPadding

    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.Position = UDim2.fromOffset(12, headerHeight + 4)
    nav.Size = UDim2.new(1, -24, 0, (self.NavigationButtonHeight * 8) + (self.NavigationButtonPadding * 7))
    nav.BackgroundTransparency = 1
    nav.ZIndex = 1012
    nav.Parent = sidebar

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.NavigationButtonPadding)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = nav

    self.Sidebar = sidebar
    self.NavigationHolder = nav
    self:CreateSidebarNotice(sidebar)
end

function App:ResolveImageAsset(relativePath)
    if not relativePath or relativePath == "" then
        return nil
    end

    if self.AssetCache[relativePath] then
        return self.AssetCache[relativePath]
    end

    local customAsset = nil
    if type(getcustomasset) == "function" then
        customAsset = getcustomasset
    elseif type(getsynasset) == "function" then
        customAsset = getsynasset
    end

    if not customAsset or type(writefile) ~= "function" then
        return nil
    end

    local folder = "SquidNoMo"
    local imageFolder = folder .. "/Images"
    local filename = string.match(relativePath, "([^/]+)$") or "Asset.png"
    local cacheVersion = tostring(self.Config.AssetVersion or self.Version or "current")
        :gsub("[^%w_%-]", "_")
    local localPath = imageFolder .. "/" .. cacheVersion .. "_" .. filename

    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder(folder) then makefolder(folder) end
            if not isfolder(imageFolder) then makefolder(imageFolder) end
        end
    end)

    local shouldDownload = true
    if type(isfile) == "function" then
        pcall(function()
            shouldDownload = not isfile(localPath)
        end)
    end

    if shouldDownload then
        local base = self.Loader and self.Loader.Config and self.Loader.Config.Repository
        if not base then
            return nil
        end

        local ok, data = pcall(function()
            return game:HttpGet(base .. relativePath)
        end)

        if not ok or type(data) ~= "string" or #data == 0 then
            return nil
        end

        local wrote = pcall(function()
            writefile(localPath, data)
        end)

        if not wrote then
            return nil
        end
    end

    local ok, asset = pcall(function()
        return customAsset(localPath)
    end)

    if ok and asset then
        self.AssetCache[relativePath] = asset
        return asset
    end

    return nil
end

function App:ResolveSupportImage(relativePath)
    return self:ResolveImageAsset(relativePath)
end

function App:SetImageFromAsset(imageLabel, relativePath, fallbackText)
    if not imageLabel then
        return
    end

    local fallback = nil
    if fallbackText and fallbackText ~= "" then
        fallback = Instance.new("TextLabel")
        fallback.Name = "AssetFallback"
        fallback.Size = UDim2.fromScale(1, 1)
        fallback.BackgroundTransparency = 1
        fallback.Font = Enum.Font.GothamBold
        fallback.Text = fallbackText
        fallback.TextScaled = true
        fallback.TextColor3 = self.Colors.Text
        fallback.ZIndex = imageLabel.ZIndex + 1
        fallback.Parent = imageLabel
    end

    task.spawn(function()
        local asset = self:ResolveImageAsset(relativePath)
        if not imageLabel.Parent then
            return
        end

        if asset then
            imageLabel.Image = asset
            imageLabel.Visible = true
            if fallback then
                fallback:Destroy()
            end
        else
            imageLabel.Visible = true
        end
    end)
end

function App:ShowSupportQR(serviceName, tag, relativePath, accentColor)
    if not self.Window then
        return
    end

    if self.SupportModal and self.SupportModal.Parent then
        self.SupportModal:Destroy()
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "SupportOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.36
    overlay.BorderSizePixel = 0
    overlay.Active = true
    overlay.ZIndex = 3200
    overlay.Parent = self.Window

    local modalWidth = self:IsMobile() and 430 or 420
    local qrHolderSize = modalWidth - 56
    local qrHolderY = 62
    local tagY = qrHolderY + qrHolderSize + 8
    local buttonY = tagY + 36
    local modalHeight = buttonY + 48

    local modal = Instance.new("Frame")
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.fromScale(0.5, 0.52)
    modal.Size = UDim2.fromOffset(modalWidth, modalHeight)
    modal.BackgroundColor3 = Color3.fromRGB(15, 11, 23)
    modal.BorderSizePixel = 0
    modal.ZIndex = 3201
    modal.Parent = overlay
    makeCorner(modal, 20)
    makeStroke(modal, accentColor or self.Colors.Accent, 1.5, 0.02)

    local supportDragHandle = Instance.new("TextButton")
    supportDragHandle.Name = "SupportDragHandle"
    supportDragHandle.Position = UDim2.fromOffset(0, 0)
    supportDragHandle.Size = UDim2.new(1, -74, 0, 58)
    supportDragHandle.BackgroundTransparency = 1
    supportDragHandle.BorderSizePixel = 0
    supportDragHandle.AutoButtonColor = false
    supportDragHandle.Text = ""
    supportDragHandle.ZIndex = 3204
    supportDragHandle.Parent = modal
    self:EnableDragging(supportDragHandle)

    self:CreateText(modal, "SUPPORT VIA " .. string.upper(serviceName), UDim2.new(1, -80, 0, 34), UDim2.fromOffset(24, 18), {
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        Color = accentColor or self.Colors.Accent,
        ZIndex = 3202,
    })

    local close = Instance.new("TextButton")
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -18, 0, 16)
    close.Size = UDim2.fromOffset(36, 36)
    close.BackgroundColor3 = self.Colors.CardAlt
    close.BorderSizePixel = 0
    close.AutoButtonColor = false
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextSize = 20
    close.TextColor3 = self.Colors.Text
    close.ZIndex = 3202
    close.Parent = modal
    makeCorner(close, 10)

    local imageHolder = Instance.new("Frame")
    imageHolder.Position = UDim2.fromOffset(28, qrHolderY)
    imageHolder.Size = UDim2.fromOffset(qrHolderSize, qrHolderSize)
    imageHolder.BackgroundColor3 = Color3.fromRGB(255,255,255)
    imageHolder.BorderSizePixel = 0
    imageHolder.ClipsDescendants = true
    imageHolder.ZIndex = 3202
    imageHolder.Parent = modal
    makeCorner(imageHolder, 16)

    local qrImage = Instance.new("ImageLabel")
    qrImage.BackgroundTransparency = 1
    qrImage.Position = UDim2.fromOffset(4, 4)
    qrImage.Size = UDim2.new(1, -8, 1, -8)
    qrImage.ScaleType = Enum.ScaleType.Fit
    pcall(function()
        qrImage.ResampleMode = Enum.ResamplerMode.Pixelated
    end)
    qrImage.Image = ""
    qrImage.ZIndex = 3203
    qrImage.Parent = imageHolder

    local loading = self:CreateText(imageHolder, "Loading QR code...", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), {
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Color = self.Colors.Dim,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3204,
    })

    self:CreateText(modal, serviceName .. ": " .. tostring(tag or ""), UDim2.new(1, -56, 0, 28), UDim2.fromOffset(28, tagY), {
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3202,
    })

    local copyButton = Instance.new("TextButton")
    copyButton.Position = UDim2.fromOffset(28, buttonY)
    copyButton.Size = UDim2.new(1, -56, 0, 34)
    copyButton.BackgroundColor3 = accentColor or self.Colors.Accent
    copyButton.BorderSizePixel = 0
    copyButton.AutoButtonColor = false
    copyButton.Font = Enum.Font.GothamBold
    copyButton.Text = "COPY " .. string.upper(serviceName)
    copyButton.TextSize = 13
    copyButton.TextColor3 = Color3.fromRGB(255,255,255)
    copyButton.ZIndex = 3202
    copyButton.Parent = modal
    makeCorner(copyButton, 10)
    self:BindButtonFeedback(close, self.Colors.Close)
    self:BindButtonFeedback(copyButton, accentColor or self.Colors.Accent)

    close.MouseButton1Click:Connect(function()
        overlay:Destroy()
        self.SupportModal = nil
    end)

    copyButton.MouseButton1Click:Connect(function()
        local copied = false
        if type(setclipboard) == "function" then
            pcall(function()
                setclipboard(tostring(tag or ""))
                copied = true
            end)
        end

        if self.Notifications then
            if copied and type(self.Notifications.Success) == "function" then
                self.Notifications:Success("Support", serviceName .. " copied to clipboard", 3)
            elseif type(self.Notifications.Info) == "function" then
                self.Notifications:Info("Support", serviceName .. ": " .. tostring(tag or ""), 4)
            end
        end
    end)

    task.spawn(function()
        local asset = self:ResolveSupportImage(relativePath)
        if not imageHolder.Parent then
            return
        end

        if asset then
            qrImage.Image = asset
            loading.Visible = false
        else
            loading.Text = "QR image unavailable in this runtime. Use the tag below."
            loading.TextWrapped = true
            loading.Size = UDim2.new(1, -40, 1, -40)
            loading.Position = UDim2.fromOffset(20, 20)
        end
    end)

    self.SupportModal = overlay
end

function App:CreateSidebarNotice(sidebar)
    local mobile = self:IsMobile()
    local panelHeight = self.Profile.SupportPanelHeight

    local panel = Instance.new("Frame")
    panel.Name = "SupportPanel"
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(0, 12, 1, -10)
    panel.Size = UDim2.new(1, -24, 0, panelHeight)
    panel.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
    panel.BorderSizePixel = 0
    panel.ZIndex = 1012
    panel.Parent = sidebar
    makeCorner(panel, 14)
    makeStroke(panel, self.Colors.Border, 1.2, 0.10)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(14, 11)
    title.Size = UDim2.new(1, -28, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.Text = "SUPPORT THE PROJECT"
    title.TextSize = mobile and 12 or 13
    title.TextColor3 = self.Colors.Accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 1013
    title.Parent = panel

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(14, 37)
    body.Size = UDim2.new(1, -28, 0, mobile and 62 or 70)
    body.Font = Enum.Font.Gotham
    body.Text = "Your support helps fund updates, hosting, and testing. Every contribution keeps SquidNoMo improving."
    body.TextWrapped = true
    body.TextSize = mobile and 10 or 11
    body.TextColor3 = self.Colors.Text
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.ZIndex = 1013
    body.Parent = panel

    local function notifySupport(titleText, message, kind)
        if self.Notifications and type(self.Notifications[kind or "Info"]) == "function" then
            pcall(function()
                self.Notifications[kind or "Info"](self.Notifications, titleText, message, 4)
            end)
        end
    end

    local buttonHeight = mobile and 32 or 34
    local gap = 6
    local paypalY = panelHeight - 12 - buttonHeight
    local cashY = paypalY - gap - buttonHeight

    local function createSupportButton(y, labelText, buttonColor, value, qrPath)
        local button = Instance.new("TextButton")
        button.Position = UDim2.fromOffset(14, y)
        button.Size = UDim2.new(1, -28, 0, buttonHeight)
        button.BackgroundColor3 = buttonColor
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBold
        button.Text = labelText
        button.TextSize = mobile and 11 or 12
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.ZIndex = 1013
        button.Parent = panel
        makeCorner(button, 9)
        makeStroke(button, buttonColor, 1, 0.25)

        button.MouseButton1Click:Connect(function()
            if value and value ~= "" and not string.find(value, "REPLACE_") then
                self:ShowSupportQR(labelText, value, qrPath, buttonColor)
            else
                notifySupport("Support", "Update App.Config.Support with your real " .. labelText .. " details.", "Warning")
            end
        end)
    end

    createSupportButton(cashY, "Cash App", self.Colors.CashApp, self.Config.Support and self.Config.Support.CashApp, self.Config.Support and self.Config.Support.CashAppQR)
    createSupportButton(paypalY, "PayPal", self.Colors.PayPal, self.Config.Support and self.Config.Support.PayPal, self.Config.Support and self.Config.Support.PayPalQR)
end

function App:CreateNavigationButton(definition)
    local button = Instance.new("TextButton")
    button.Name = definition.Name
    local mobile = self:IsMobile()
    local buttonHeight = self.NavigationButtonHeight or 48
    local accent = self:GetPageAccent(definition.Name)

    button.Size = UDim2.new(1, 0, 0, buttonHeight)
    button.BackgroundColor3 = self.Colors.Sidebar
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = definition.Order or 0
    button.ZIndex = 1014
    button.Parent = self.NavigationHolder
    makeCorner(button, 12)

    local selectedStroke = makeStroke(button, accent, 2, 1)

    local selectedGlow = Instance.new("Frame")
    selectedGlow.Name = "SelectedGlow"
    selectedGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    selectedGlow.Position = UDim2.fromScale(0.5, 0.5)
    selectedGlow.Size = UDim2.new(1, 8, 1, 8)
    selectedGlow.BackgroundColor3 = accent
    selectedGlow.BackgroundTransparency = 0.86
    selectedGlow.BorderSizePixel = 0
    selectedGlow.Visible = false
    selectedGlow.ZIndex = 1013
    selectedGlow.Parent = button
    makeCorner(selectedGlow, 14)

    local icon = Instance.new("Frame")
    local iconSize = mobile and 28 or 30
    icon.Position = UDim2.fromOffset(12, math.floor((buttonHeight - iconSize) / 2))
    icon.Size = UDim2.fromOffset(iconSize, iconSize)
    icon.BackgroundColor3 = self.Colors.CardAlt
    icon.BorderSizePixel = 0
    icon.ZIndex = 1015
    icon.Parent = button
    makeCorner(icon, 9)

    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "TabIcon"
    iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImage.Position = UDim2.fromScale(0.5, 0.5)
    iconImage.Size = UDim2.new(1, -7, 1, -7)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = ""
    iconImage.ImageColor3 = self.Colors.Text
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.ZIndex = 1016
    iconImage.Parent = icon

    local tabPath = self.Config.Assets
        and self.Config.Assets.Tabs
        and self.Config.Assets.Tabs[definition.Name]
    self:SetImageFromAsset(iconImage, tabPath, string.sub(definition.Name, 1, 1))

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(52, 0)
    label.Size = UDim2.new(1, -62, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = definition.Name
    label.TextSize = 13
    label.TextColor3 = self.Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1015
    label.Parent = button

    local function setSelected(selected)
        selectedGlow.Visible = selected and self.NavigationGlowEnabled
        self:Tween(button, {
            BackgroundColor3 = selected and accent or self.Colors.Sidebar,
            BackgroundTransparency = selected and 0.72 or 0,
        }, 0.16)
        self:Tween(selectedStroke, {
            Color = accent,
            Transparency = selected and 0.04 or 1,
            Thickness = selected and 2 or 1,
        }, 0.16)
        self:Tween(icon, {
            BackgroundColor3 = selected and Color3.fromRGB(255, 255, 255) or self.Colors.CardAlt,
        }, 0.16)
        self:Tween(iconImage, {
            ImageColor3 = selected and accent or self.Colors.Text,
        }, 0.16)
        self:Tween(label, {
            TextColor3 = selected and Color3.fromRGB(255, 255, 255) or self.Colors.Text,
        }, 0.16)
    end

    button.MouseEnter:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {BackgroundColor3 = self.Colors.Card}, 0.12)
        end
    end)

    button.MouseLeave:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {
                BackgroundColor3 = self.Colors.Sidebar,
                BackgroundTransparency = 0,
            }, 0.12)
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:PulseGlow(button, accent)
        self:OpenPage(definition.Name)
    end)

    self.NavigationButtons[definition.Name] = {
        Instance = button,
        SetSelected = setSelected,
        Accent = accent,
    }
end

----------------------------------------------------------
-- Page container and modular registry
----------------------------------------------------------

function App:CreatePageContainer()
    local container = Instance.new("Frame")
    container.Name = "PageContainer"
    container.Position = UDim2.fromOffset(
        self.Config.SidebarWidth,
        self.Config.TopbarHeight
    )
    container.Size = UDim2.new(
        1,
        -self.Config.SidebarWidth,
        1,
        -(self.Config.TopbarHeight + self.Config.StatusbarHeight)
    )
    container.BackgroundColor3 = self.Colors.Backdrop
    container.BackgroundTransparency = (self.WindowOpacity or 0) * 0.65
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.ZIndex = 1005
    container.Parent = self.Window

    self.PageContainer = container
end

function App:RegisterPage(name, icon, builder, order)
    for index, definition in ipairs(self.PageDefinitions) do
        if definition.Name == name then
            definition.Icon = icon or definition.Icon
            definition.Builder = builder or definition.Builder
            definition.Order = order or definition.Order
            return definition
        end
    end

    local definition = {
        Name = name,
        Icon = icon or string.sub(name, 1, 1),
        Builder = builder,
        Order = order or (#self.PageDefinitions + 1),
    }

    table.insert(self.PageDefinitions, definition)
    return definition
end

function App:CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = self.Colors.AccentDark
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    page.Active = true
    page.Visible = false
    page.ZIndex = 1006
    page.Parent = self.PageContainer

    self.Pages[name] = page
    return page
end

function App:BuildPageDefinitions()
    self.PageDefinitions = {}

    self:RegisterPage("Home", "H", function(page)
        self:BuildHome(page)
    end, 1)

    self:RegisterPage("Games", "GM", function(page)
        self:BuildExternalPage(page, self.Loader.Games, "Games")
    end, 2)

    self:RegisterPage("Players", "PL", function(page)
        self:BuildExternalPage(page, self.Loader.Players, "Players")
    end, 3)

    self:RegisterPage("Guards", "GD", function(page)
        self:BuildExternalPage(page, self.Loader.Guards, "Guards")
    end, 4)

    self:RegisterPage("Detective", "DT", function(page)
        self:BuildExternalPage(page, self.Loader.Detective, "Detective")
    end, 5)

    self:RegisterPage("Farming", "FM", function(page)
        self:BuildExternalPage(page, self.Loader.Farming, "Farming")
    end, 6)

    self:RegisterPage("UI", "UI", function(page)
        self:BuildExternalPage(page, self.Loader.UI or self.Loader.VIP, "UI")
    end, 7)

    self:RegisterPage("Settings", "ST", function(page)
        self:BuildSettingsPage(page)
    end, 8)

    if type(self.Loader.Pages) == "table" then
        for _, entry in ipairs(self.Loader.Pages) do
            if type(entry) == "table" and entry.Name then
                self:RegisterPage(entry.Name, entry.Icon, entry.Builder, entry.Order)
            end
        end
    end

    table.sort(self.PageDefinitions, function(a, b)
        return (a.Order or 0) < (b.Order or 0)
    end)
end

function App:BuildPages()
    for _, definition in ipairs(self.PageDefinitions) do
        self:CreateNavigationButton(definition)
        local page = self:CreatePage(definition.Name)

        local ok, err = self:SafeCall(definition.Name .. " page", function()
            if type(definition.Builder) == "function" then
                definition.Builder(page, self)
            else
                self:BuildPlaceholder(page, definition.Name, "No page builder was registered.")
            end
        end)

        if not ok then
            page:ClearAllChildren()
            self:BuildErrorPage(page, definition.Name, err)
        end
    end
end

function App:BuildExternalPage(page, module, pageName)
    if type(module) == "table" and type(module.Create) == "function" then
        module:Create(page, self)
        return
    end

    self:BuildPlaceholder(
        page,
        pageName,
        "This module has not been connected yet. The universal app shell is running correctly."
    )
end

function App:CreateWindowToggleCard(parent, title, description, color, layoutOrder, getter, setter)
    local phone = self.DeviceClass == "Phone"
    local card = self:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.14,
        Radius = phone and 12 or 15,
    })
    card.LayoutOrder = layoutOrder

    self:CreateText(card, title, UDim2.new(1, -94, 0, 24), UDim2.fromOffset(16, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 12 or 14,
        Color = color,
        ZIndex = 1013,
    })

    local descriptionLabel = self:CreateText(card, description, UDim2.new(1, -32, 0, phone and 58 or 64), UDim2.fromOffset(16, 46), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 9 or 10,
        Color = self.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, -16, 0, 14)
    switch.Size = UDim2.fromOffset(phone and 48 or 52, phone and 26 or 28)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1013
    switch.Parent = card
    makeCorner(switch, 999)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(phone and 20 or 22, phone and 20 or 22)
    knob.BackgroundColor3 = Color3.fromRGB(245, 242, 248)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1014
    knob.Parent = switch
    makeCorner(knob, 999)

    local stateLabel = self:CreateText(card, "OFF", UDim2.new(1, -32, 0, 22), UDim2.new(0, 16, 1, -34), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 10 or 11,
        Color = self.Colors.Muted,
        ZIndex = 1013,
    })

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 1015
    button.Parent = card

    button.MouseButton1Click:Connect(function()
        self:PulseGlow(card, color)
        setter(not getter())
    end)

    return {
        Card = card,
        Switch = switch,
        Knob = knob,
        State = stateLabel,
        Color = color,
        Getter = getter,
        Description = descriptionLabel,
    }
end

function App:CreateWindowActionCard(parent, title, description, color, layoutOrder, buttonText, callback)
    local phone = self.DeviceClass == "Phone"
    local card = self:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.14,
        Radius = phone and 12 or 15,
    })
    card.LayoutOrder = layoutOrder

    self:CreateText(card, title, UDim2.new(1, -32, 0, 24), UDim2.fromOffset(16, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 12 or 14,
        Color = color,
        ZIndex = 1013,
    })

    self:CreateText(card, description, UDim2.new(1, -32, 0, phone and 54 or 60), UDim2.fromOffset(16, 46), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 9 or 10,
        Color = self.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local action = Instance.new("TextButton")
    action.AnchorPoint = Vector2.new(0.5, 1)
    action.Position = UDim2.new(0.5, 0, 1, -14)
    action.Size = UDim2.new(1, -32, 0, phone and 36 or 40)
    action.BackgroundColor3 = color
    action.BackgroundTransparency = 0.08
    action.BorderSizePixel = 0
    action.AutoButtonColor = false
    action.Font = Enum.Font.GothamBold
    action.Text = buttonText
    action.TextSize = phone and 10 or 11
    action.TextColor3 = Color3.fromRGB(255, 255, 255)
    action.ZIndex = 1014
    action.Parent = card
    makeCorner(action, 10)
    makeStroke(action, Color3.fromRGB(255, 255, 255), 1, 0.70)
    self:BindButtonFeedback(action, color)

    action.MouseButton1Click:Connect(function()
        callback()
    end)

    return {Card = card, Button = action}
end

function App:CreateWindowSliderCard(parent, title, description, color, layoutOrder, minimum, maximum, getter, setter, formatter)
    local phone = self.DeviceClass == "Phone"
    local card = self:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.14,
        Radius = phone and 12 or 15,
    })
    card.LayoutOrder = layoutOrder

    self:CreateText(card, title, UDim2.new(1, -92, 0, 24), UDim2.fromOffset(16, 12), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 12 or 14,
        Color = color,
        ZIndex = 1013,
    })

    self:CreateText(card, description, UDim2.new(1, -32, 0, phone and 46 or 50), UDim2.fromOffset(16, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 8 or 9,
        Color = self.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local valueLabel = self:CreateText(card, "", UDim2.fromOffset(78, 22), UDim2.new(1, -94, 0, phone and 87 or 91), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 10 or 11,
        Color = color,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1014,
    })

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 16, 1, phone and -30 or -32)
    track.Size = UDim2.new(1, -32, 0, 8)
    track.BackgroundColor3 = Color3.fromRGB(55, 48, 65)
    track.BorderSizePixel = 0
    track.ZIndex = 1013
    track.Parent = card
    makeCorner(track, 999)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.ZIndex = 1014
    fill.Parent = track
    makeCorner(fill, 999)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(phone and 16 or 18, phone and 16 or 18)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1015
    knob.Parent = track
    makeCorner(knob, 999)
    makeStroke(knob, color, 2, 0.05)

    local hitbox = Instance.new("TextButton")
    hitbox.Position = UDim2.fromOffset(0, -14)
    hitbox.Size = UDim2.new(1, 0, 0, 36)
    hitbox.BackgroundTransparency = 1
    hitbox.BorderSizePixel = 0
    hitbox.AutoButtonColor = false
    hitbox.Text = ""
    hitbox.ZIndex = 1016
    hitbox.Parent = track

    local dragging = false

    local function render(value)
        value = math.clamp(tonumber(value) or minimum, minimum, maximum)
        local alpha = (value - minimum) / math.max(0.001, maximum - minimum)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        if type(formatter) == "function" then
            valueLabel.Text = tostring(formatter(value))
        else
            valueLabel.Text = tostring(math.floor(value + 0.5))
        end
    end

    local function updateFromInput(input)
        local width = math.max(1, track.AbsoluteSize.X)
        local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
        local value = minimum + ((maximum - minimum) * alpha)
        setter(value)
        render(getter())
    end

    self:Track(hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end))

    self:Track(hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end))

    render(getter())

    return {
        Card = card,
        Fill = fill,
        Knob = knob,
        Value = valueLabel,
        Color = color,
        Minimum = minimum,
        Maximum = maximum,
        Getter = getter,
        Formatter = formatter,
        Render = render,
    }
end

function App:RefreshNavigationAppearance()
    for pageName, entry in pairs(self.NavigationButtons or {}) do
        if type(entry) == "table" and type(entry.SetSelected) == "function" then
            entry.SetSelected(pageName == self.CurrentPage)
        end
    end
end

function App:SetButtonGlowEnabled(state)
    self.ButtonGlowEnabled = state and true or false
    if self.Session then self.Session.ButtonGlowEnabled = self.ButtonGlowEnabled end
    self:RefreshWindowSettings()
end

function App:SetNavigationGlowEnabled(state)
    self.NavigationGlowEnabled = state and true or false
    if self.Session then self.Session.NavigationGlowEnabled = self.NavigationGlowEnabled end
    self:RefreshNavigationAppearance()
    self:RefreshWindowSettings()
end

function App:SetCloseConfirmationEnabled(state)
    self.CloseConfirmationEnabled = state and true or false
    if self.Session then self.Session.CloseConfirmationEnabled = self.CloseConfirmationEnabled end
    self:RefreshWindowSettings()
end

function App:SetReducedMotionEnabled(state)
    self.ReducedMotionEnabled = state and true or false
    if self.Session then self.Session.ReducedMotionEnabled = self.ReducedMotionEnabled end
    self:RefreshWindowSettings()
end

function App:SetRememberLastPageEnabled(state)
    self.RememberLastPageEnabled = state and true or false
    if self.Session then
        self.Session.RememberLastPageEnabled = self.RememberLastPageEnabled
        if not self.RememberLastPageEnabled then
            self.Session.LastPage = "Home"
        elseif self.CurrentPage then
            self.Session.LastPage = self.CurrentPage
        end
    end
    self:RefreshWindowSettings()
end

function App:SetAutoCenterOnResizeEnabled(state)
    self.AutoCenterOnResizeEnabled = state and true or false
    if self.Session then self.Session.AutoCenterOnResizeEnabled = self.AutoCenterOnResizeEnabled end
    self:RefreshWindowSettings()
end

function App:SetUserScale(value)
    self.UserScale = math.clamp(tonumber(value) or 1.0, 0.75, 1.15)
    if self.Session then self.Session.UserScale = self.UserScale end
    if self.Host and not self.IsFullScreen and not self.IsMaximized then
        self:UpdateResponsive(true)
    end
    self:RefreshWindowSettings()
end

function App:SetBubbleSize(value)
    local defaultSize = self:IsMobile() and 66 or 60
    self.BubbleSize = math.clamp(math.floor(tonumber(value) or defaultSize), 48, 92)
    if self.Session then self.Session.BubbleSize = self.BubbleSize end
    if self.ReopenButton then
        self.ReopenButton.Size = UDim2.fromOffset(self.BubbleSize, self.BubbleSize)
        self:PositionReopenButton(false)
    end
    self:RefreshWindowSettings()
end

function App:SetWindowOpacity(value)
    self.WindowOpacity = math.clamp(tonumber(value) or 0, 0, 0.35)
    if self.Session then self.Session.WindowOpacity = self.WindowOpacity end
    if self.Window then
        self.Window.BackgroundTransparency = self.WindowOpacity
    end
    if self.Sidebar then
        self.Sidebar.BackgroundTransparency = self.WindowOpacity * 0.65
    end
    if self.Topbar then
        self.Topbar.BackgroundTransparency = math.min(0.45, 0.10 + (self.WindowOpacity * 0.65))
    end
    if self.Statusbar then
        self.Statusbar.BackgroundTransparency = math.min(0.45, 0.03 + (self.WindowOpacity * 0.65))
    end
    if self.PageContainer then
        self.PageContainer.BackgroundTransparency = self.WindowOpacity * 0.65
    end
    self:RefreshWindowSettings()
end

function App:ResetApplicationPreferences()
    self:SetFreeRoamEnabled(true)
    self:SetFullScreen(false)
    self:SetButtonGlowEnabled(true)
    self:SetNavigationGlowEnabled(true)
    self:SetCloseConfirmationEnabled(true)
    self:SetReducedMotionEnabled(false)
    self:SetRememberLastPageEnabled(true)
    self:SetAutoCenterOnResizeEnabled(true)
    self:SetUserScale(1.0)
    self:SetBubbleSize(self:IsMobile() and 66 or 60)
    self:SetWindowOpacity(0)
    self:ResetWindowPosition()
end

function App:RefreshWindowSettings()
    local widgets = self.WindowSettingsWidgets
    if not widgets then
        return
    end

    local function refreshToggle(refs, enabled)
        if not refs or not refs.Card or not refs.Card.Parent then
            return
        end

        local trackWidth = refs.Switch.Size.X.Offset
        local knobWidth = refs.Knob.Size.X.Offset
        refs.Switch.BackgroundColor3 = enabled and refs.Color or Color3.fromRGB(68, 64, 78)
        refs.Knob.Position = UDim2.fromOffset(enabled and (trackWidth - knobWidth - 3) or 3, 3)
        refs.State.Text = enabled and "ON" or "OFF"
        refs.State.TextColor3 = enabled and refs.Color or self.Colors.Muted
    end

    local function refreshSlider(refs, value)
        if refs and refs.Card and refs.Card.Parent and type(refs.Render) == "function" then
            refs.Render(value)
        end
    end

    refreshToggle(widgets.FreeRoam, self.FreeRoamEnabled)
    refreshToggle(widgets.FullScreen, self.IsFullScreen)
    refreshToggle(widgets.ButtonGlow, self.ButtonGlowEnabled)
    refreshToggle(widgets.NavigationGlow, self.NavigationGlowEnabled)
    refreshToggle(widgets.CloseConfirmation, self.CloseConfirmationEnabled)
    refreshToggle(widgets.ReducedMotion, self.ReducedMotionEnabled)
    refreshToggle(widgets.RememberLastPage, self.RememberLastPageEnabled)
    refreshToggle(widgets.AutoCenter, self.AutoCenterOnResizeEnabled)

    refreshSlider(widgets.UserScale, self.UserScale)
    refreshSlider(widgets.BubbleSize, self.BubbleSize or (self:IsMobile() and 66 or 60))
    refreshSlider(widgets.WindowOpacity, self.WindowOpacity)
end

function App:BuildSettingsPage(page)
    page:ClearAllChildren()

    local padding = self.Profile.ContentPadding
    local root = Instance.new("Frame")
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 910)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = page

    self:CreateText(root, "WINDOW & DISPLAY", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(0, 0), {
        Font = Enum.Font.GothamBlack,
        TextSize = self.DeviceClass == "Phone" and 17 or 20,
        Color = self:GetPageAccent("Settings"),
        ZIndex = 1012,
    })

    self:CreateText(root, "Application behavior and recovery controls. Game enhancements remain under UI.", UDim2.new(1, 0, 0, 22), UDim2.fromOffset(0, 30), {
        Font = Enum.Font.GothamMedium,
        TextSize = self.DeviceClass == "Phone" and 10 or 11,
        Color = self.Colors.Muted,
        ZIndex = 1012,
    })

    local windowRow = self:CreateEqualThreeColumnRow(root, 62, 154, "WindowSettingsRow")

    local freeRoam = self:CreateWindowToggleCard(
        windowRow,
        "FREE ROAM WINDOW",
        "Move across the game screen. If the app leaves the usable area, it minimizes and restores at the last safe position.",
        self:GetPageAccent("Players"),
        1,
        function() return self.FreeRoamEnabled end,
        function(value) self:SetFreeRoamEnabled(value) end
    )

    local fullScreen = self:CreateWindowToggleCard(
        windowRow,
        "FULL SCREEN MODE",
        "Fill the complete usable viewport while preserving the internal three-column layout.",
        self:GetPageAccent("Detective"),
        2,
        function() return self.IsFullScreen end,
        function(value) self:SetFullScreen(value) end
    )

    local reset = self:CreateWindowActionCard(
        windowRow,
        "RESET WINDOW",
        "Return to a centered, safe, movable position and leave maximized or full-screen mode.",
        self:GetPageAccent("Settings"),
        3,
        "RESET POSITION",
        function() self:ResetWindowPosition() end
    )

    self:CreateText(root, "INTERFACE FEEDBACK", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 232), {
        Font = Enum.Font.GothamBlack,
        TextSize = self.DeviceClass == "Phone" and 15 or 18,
        Color = self:GetPageAccent("Settings"),
        ZIndex = 1012,
    })

    self:CreateText(root, "General SquidNoMo interaction preferences.", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 259), {
        Font = Enum.Font.GothamMedium,
        TextSize = self.DeviceClass == "Phone" and 9 or 10,
        Color = self.Colors.Muted,
        ZIndex = 1012,
    })

    local interfaceRow = self:CreateEqualThreeColumnRow(root, 290, 140, "InterfaceSettingsRow")

    local buttonGlow = self:CreateWindowToggleCard(
        interfaceRow,
        "BUTTON CLICK GLOW",
        "Show the short themed glow pulse when application buttons are pressed.",
        self:GetPageAccent("UI"),
        1,
        function() return self.ButtonGlowEnabled end,
        function(value) self:SetButtonGlowEnabled(value) end
    )

    local navigationGlow = self:CreateWindowToggleCard(
        interfaceRow,
        "SELECTED PAGE GLOW",
        "Keep the active navigation tab highlighted with its page-specific accent.",
        self:GetPageAccent("Home"),
        2,
        function() return self.NavigationGlowEnabled end,
        function(value) self:SetNavigationGlowEnabled(value) end
    )

    local closeConfirmation = self:CreateWindowToggleCard(
        interfaceRow,
        "CONFIRM BEFORE CLOSE",
        "Require confirmation before closing the application to prevent accidental taps.",
        self.Colors.Close,
        3,
        function() return self.CloseConfirmationEnabled end,
        function(value) self:SetCloseConfirmationEnabled(value) end
    )

    self:CreateText(root, "ACCESSIBILITY & SESSION", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 456), {
        Font = Enum.Font.GothamBlack,
        TextSize = self.DeviceClass == "Phone" and 15 or 18,
        Color = self:GetPageAccent("Settings"),
        ZIndex = 1012,
    })

    self:CreateText(root, "Motion, page memory, and orientation behavior.", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 483), {
        Font = Enum.Font.GothamMedium,
        TextSize = self.DeviceClass == "Phone" and 9 or 10,
        Color = self.Colors.Muted,
        ZIndex = 1012,
    })

    local accessibilityRow = self:CreateEqualThreeColumnRow(root, 514, 140, "AccessibilitySettingsRow")

    local reducedMotion = self:CreateWindowToggleCard(
        accessibilityRow,
        "REDUCED MOTION",
        "Use immediate state changes instead of application tween animations.",
        self:GetPageAccent("UI"),
        1,
        function() return self.ReducedMotionEnabled end,
        function(value) self:SetReducedMotionEnabled(value) end
    )

    local rememberLastPage = self:CreateWindowToggleCard(
        accessibilityRow,
        "REMEMBER LAST PAGE",
        "Reopen the page you used most recently during the current server session.",
        self:GetPageAccent("Players"),
        2,
        function() return self.RememberLastPageEnabled end,
        function(value) self:SetRememberLastPageEnabled(value) end
    )

    local autoCenter = self:CreateWindowToggleCard(
        accessibilityRow,
        "CENTER ON RESIZE",
        "Recenter the restored window after orientation or viewport-size changes.",
        self:GetPageAccent("Detective"),
        3,
        function() return self.AutoCenterOnResizeEnabled end,
        function(value) self:SetAutoCenterOnResizeEnabled(value) end
    )

    self:CreateText(root, "SIZE & TRANSPARENCY", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 680), {
        Font = Enum.Font.GothamBlack,
        TextSize = self.DeviceClass == "Phone" and 15 or 18,
        Color = self:GetPageAccent("Settings"),
        ZIndex = 1012,
    })

    self:CreateText(root, "Fine-tune the restored app, recovery bubble, and window background.", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 707), {
        Font = Enum.Font.GothamMedium,
        TextSize = self.DeviceClass == "Phone" and 9 or 10,
        Color = self.Colors.Muted,
        ZIndex = 1012,
    })

    local sizeRow = self:CreateEqualThreeColumnRow(root, 738, 154, "SizeSettingsRow")

    local userScale = self:CreateWindowSliderCard(
        sizeRow,
        "RESTORED APP SCALE",
        "Adjust restored-mode size without exceeding the usable viewport.",
        self:GetPageAccent("Settings"),
        1,
        0.75,
        1.15,
        function() return self.UserScale end,
        function(value) self:SetUserScale(value) end,
        function(value) return tostring(math.floor(value * 100 + 0.5)) .. "%" end
    )

    local bubbleSize = self:CreateWindowSliderCard(
        sizeRow,
        "FLOATING BUBBLE SIZE",
        "Adjust the minimized recovery bubble for touch comfort.",
        self:GetPageAccent("Home"),
        2,
        48,
        92,
        function() return self.BubbleSize or (self:IsMobile() and 66 or 60) end,
        function(value) self:SetBubbleSize(value) end,
        function(value) return tostring(math.floor(value + 0.5)) .. " px" end
    )

    local windowOpacity = self:CreateWindowSliderCard(
        sizeRow,
        "WINDOW TRANSPARENCY",
        "Adjust the main application background while keeping cards readable.",
        self:GetPageAccent("UI"),
        3,
        0,
        0.35,
        function() return self.WindowOpacity end,
        function(value) self:SetWindowOpacity(value) end,
        function(value) return tostring(math.floor(value * 100 + 0.5)) .. "%" end
    )

    self.WindowSettingsWidgets = {
        Root = root,
        FreeRoam = freeRoam,
        FullScreen = fullScreen,
        Reset = reset,
        ButtonGlow = buttonGlow,
        NavigationGlow = navigationGlow,
        CloseConfirmation = closeConfirmation,
        ReducedMotion = reducedMotion,
        RememberLastPage = rememberLastPage,
        AutoCenter = autoCenter,
        UserScale = userScale,
        BubbleSize = bubbleSize,
        WindowOpacity = windowOpacity,
    }

    self:RefreshWindowSettings()
end

function App:OpenPage(name)
    if not self.Pages[name] then
        return false
    end

    for pageName, page in pairs(self.Pages) do
        page.Visible = pageName == name
    end

    for pageName, navigationEntry in pairs(self.NavigationButtons) do
        if type(navigationEntry) == "table"
            and type(navigationEntry.SetSelected) == "function"
        then
            navigationEntry.SetSelected(pageName == name)
        end
    end

    self.CurrentPage = name

    if self.Session and self.RememberLastPageEnabled then
        self.Session.LastPage = name
    end

    if self.PageTitle then
        self.PageTitle.Text = string.upper(name)
    end

    return true
end

----------------------------------------------------------
-- Generic UI builders for the canonical dashboard
----------------------------------------------------------

function App:CreateCard(parent, size, options)
    options = options or {}

    local card = Instance.new("Frame")
    card.Size = size
    card.BackgroundColor3 = options.Color or self.Colors.Card
    card.BackgroundTransparency = options.Transparency or 0
    card.BorderSizePixel = 0
    card.ClipsDescendants = options.ClipsDescendants ~= false
    card.ZIndex = options.ZIndex or 1010
    card.Parent = parent
    makeCorner(card, options.Radius or 14)
    makeStroke(
        card,
        options.BorderColor or self.Colors.BorderSoft,
        options.BorderThickness or 1,
        options.BorderTransparency or 0.15
    )

    return card
end

function App:CreateText(parent, text, size, position, options)
    options = options or {}

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position or UDim2.fromOffset(0, 0)
    label.Font = options.Font or Enum.Font.Gotham
    label.Text = tostring(text or "")
    local requestedTextSize = options.TextSize or 13
    if self.Config.MobileTextBoost and self:IsMobile() then
        if requestedTextSize <= 9 then
            requestedTextSize = 10
        elseif requestedTextSize <= 10 then
            requestedTextSize = 11
        elseif requestedTextSize <= 12 then
            requestedTextSize = requestedTextSize + 1
        end
    end
    label.TextSize = requestedTextSize
    label.TextColor3 = options.Color or self.Colors.Text
    label.TextTransparency = options.Transparency or 0
    label.TextWrapped = options.Wrapped or false
    label.TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = options.YAlignment or Enum.TextYAlignment.Center
    label.RichText = options.RichText or false
    label.ZIndex = options.ZIndex or 1012
    label.Parent = parent
    return label
end

function App:CreatePill(parent, text, color, position, width)
    local pill = Instance.new("Frame")
    pill.Position = position
    pill.Size = UDim2.fromOffset(width or 90, 24)
    pill.BackgroundColor3 = color
    pill.BackgroundTransparency = 0.82
    pill.BorderSizePixel = 0
    pill.ZIndex = 1013
    pill.Parent = parent
    makeCorner(pill, 99)
    makeStroke(pill, color, 1, 0.28)

    self:CreateText(
        pill,
        text,
        UDim2.fromScale(1, 1),
        UDim2.fromOffset(0, 0),
        {
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            Color = color,
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1014,
        }
    )

    return pill
end

function App:CreateSectionTitle(parent, title, subtitle)
    self:CreateText(
        parent,
        title,
        UDim2.new(1, -28, 0, 24),
        UDim2.fromOffset(14, 12),
        {
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Color = self.Colors.Text,
        }
    )

    if subtitle then
        self:CreateText(
            parent,
            subtitle,
            UDim2.new(1, -28, 0, 18),
            UDim2.fromOffset(14, 35),
            {
                Font = Enum.Font.Gotham,
                TextSize = 9,
                Color = self.Colors.Muted,
            }
        )
    end
end

function App:GetFeatureOverview()
    local summary = nil

    if self.FeatureManager and type(self.FeatureManager.GetSnapshot) == "function" then
        local ok, result = pcall(function()
            return self.FeatureManager:GetSnapshot()
        end)
        if ok and type(result) == "table" then
            summary = result
        end
    end

    summary = summary or {
        FullyOn = 0,
        Partial = 0,
        Off = 0,
        Total = 0,
        Categories = {},
    }

    summary.FullyOn = tonumber(summary.FullyOn) or 0
    summary.Partial = tonumber(summary.Partial) or 0
    summary.Off = tonumber(summary.Off) or 0
    summary.Total = tonumber(summary.Total) or (summary.FullyOn + summary.Partial + summary.Off)

    if summary.Total > 0 then
        summary.FullyPercent = math.floor((summary.FullyOn / summary.Total) * 100 + 0.5)
        summary.PartialPercent = math.floor((summary.Partial / summary.Total) * 100 + 0.5)
        summary.OffPercent = math.max(0, 100 - summary.FullyPercent - summary.PartialPercent)
    else
        summary.FullyPercent = 0
        summary.PartialPercent = 0
        summary.OffPercent = 0
    end

    summary.Categories = summary.Categories or {}
    for _, category in ipairs({"Safe", "SemiSafe", "Experimental"}) do
        summary.Categories[category] = summary.Categories[category] or {
            Total = 0,
            On = 0,
            Partial = 0,
            Off = 0,
            State = "empty",
        }
    end

    return summary
end

function App:CreateStatLine(parent, y, leftText, rightText, rightColor)
    local line = Instance.new("Frame")
    line.Position = UDim2.fromOffset(20, y)
    line.Size = UDim2.new(1, -40, 0, 34)
    line.BackgroundTransparency = 1
    line.BorderSizePixel = 0
    line.ZIndex = 1012
    line.Parent = parent

    local divider = Instance.new("Frame")
    divider.AnchorPoint = Vector2.new(0, 1)
    divider.Position = UDim2.new(0, 0, 1, 0)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = self.Colors.BorderSoft
    divider.BackgroundTransparency = 0.45
    divider.BorderSizePixel = 0
    divider.ZIndex = 1012
    divider.Parent = line

    local leftLabel = self:CreateText(line, leftText, UDim2.new(0.58, 0, 1, 0), UDim2.fromOffset(0, 0), {
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })

    local rightLabel = self:CreateText(line, rightText, UDim2.new(0.42, 0, 1, 0), UDim2.new(0.58, 0, 0, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Color = rightColor or self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    return line, leftLabel, rightLabel
end

function App:CreateEqualThreeColumnRow(parent, y, height, name)
    local row = Instance.new("Frame")
    row.Name = name or "ThreeColumnRow"
    row.Position = UDim2.fromOffset(16, y)
    row.Size = UDim2.new(1, -32, 0, height)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.ZIndex = 1010
    row.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = row

    return row
end

function App:CreateFeatureStateCard(parent, position, widthScale, color, title, count, percent, description, height)
    local phone = self.DeviceClass == "Phone"
    height = height or (phone and 98 or 118)

    local card = self:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.08,
        Radius = phone and 12 or 14,
        ZIndex = 1011,
    })
    card.LayoutOrder = widthScale or 1

    local iconSize = phone and 42 or 52
    local iconRing = Instance.new("Frame")
    iconRing.Position = UDim2.fromOffset(phone and 12 or 18, phone and 18 or 22)
    iconRing.Size = UDim2.fromOffset(iconSize, iconSize)
    iconRing.BackgroundTransparency = 1
    iconRing.BorderSizePixel = 0
    iconRing.ZIndex = 1012
    iconRing.Parent = card
    makeCorner(iconRing, 999)
    makeStroke(iconRing, color, 2, 0.04)

    local glyph = Instance.new("TextLabel")
    glyph.BackgroundTransparency = 1
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.Font = Enum.Font.GothamBold
    glyph.Text = title == "FULLY ON" and "✓" or (title == "PARTIALLY ON" and "~" or "X")
    glyph.TextSize = phone and 20 or 24
    glyph.TextColor3 = color
    glyph.ZIndex = 1013
    glyph.Parent = iconRing

    local textX = phone and 64 or 84
    local titleLabel = self:CreateText(card, title, UDim2.new(1, -(textX + 10), 0, 18), UDim2.fromOffset(textX, phone and 12 or 16), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 9 or 10,
        Color = color,
        ZIndex = 1013,
    })
    local countLabel = self:CreateText(card, tostring(count), UDim2.fromOffset(72, 34), UDim2.fromOffset(textX, phone and 29 or 36), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 24 or 28,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })
    local featureLabel = self:CreateText(card, "Features", UDim2.fromOffset(100, 17), UDim2.fromOffset(textX, phone and 61 or 74), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 10 or 12,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })
    local descriptionLabel = self:CreateText(card, description, UDim2.new(1, -(textX + 8), 0, 16), UDim2.fromOffset(textX, height - (phone and 22 or 25)), {
        Font = Enum.Font.Gotham,
        TextSize = phone and 8 or 9,
        Color = self.Colors.Muted,
        ZIndex = 1013,
    })
    local percentLabel = self:CreateText(card, tostring(percent) .. "%", UDim2.fromOffset(48, 16), UDim2.new(1, -58, 1, -21), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 8 or 9,
        Color = color,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    return card, {
        Count = countLabel,
        Percent = percentLabel,
        Description = descriptionLabel,
        FeatureLabel = featureLabel,
        Title = titleLabel,
    }
end

function App:BuildHome(page)
    local content = Instance.new("Frame")
    content.Name = "HomeContent"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 1007
    content.Parent = page

    local padding = self.Profile.ContentPadding
    makePadding(content, padding, padding, padding, padding)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.Profile.HomeGap)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content

    self:BuildHero(content)
    self:BuildFeatureStats(content)
    self:BuildBottomStatsRow(content)
end

function App:BuildHero(parent)
    local height = self.Profile.HeroHeight
    local phone = self.DeviceClass == "Phone"

    local hero = self:CreateCard(parent, UDim2.new(1, 0, 0, height), {
        Color = Color3.fromRGB(16, 11, 24),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.04,
        Radius = self.DeviceClass == "Phone" and 14 or 18,
    })
    hero.LayoutOrder = 1

    makeGradient(hero, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 12, 28)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(23, 9, 19)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 8, 16)),
    }), 0)

    local guardArtwork = Instance.new("ImageLabel")
    guardArtwork.Name = "BannerGuards"
    guardArtwork.AnchorPoint = Vector2.new(1, 0.5)
    guardArtwork.Position = UDim2.new(1, -6, 0.5, 0)
    guardArtwork.Size = UDim2.new(phone and 0.53 or 0.56, 0, 1, -6)
    guardArtwork.BackgroundTransparency = 1
    guardArtwork.Image = ""
    guardArtwork.ScaleType = Enum.ScaleType.Crop
    guardArtwork.ZIndex = 1011
    guardArtwork.Parent = hero
    self:SetImageFromAsset(guardArtwork, self.Config.Assets and self.Config.Assets.BannerGuards, nil)

    local logoSize = phone and 92 or 116
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "HeroLogo"
    logoImage.Position = UDim2.fromOffset(phone and 22 or 24, math.floor((height - logoSize) / 2))
    logoImage.Size = UDim2.fromOffset(logoSize, logoSize)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = ""
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 1014
    logoImage.Parent = hero
    self:SetImageFromAsset(logoImage, self.Config.Assets and self.Config.Assets.Logo, "SN")

    local textX = phone and 132 or 166
    self:CreateText(hero, "WELCOME TO", UDim2.fromOffset(190, 24), UDim2.fromOffset(textX, phone and 24 or 36), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 14 or 16,
        Color = self.Colors.Text,
        ZIndex = 1014,
    })
    self:CreateText(hero, "SQUIDNOMO", UDim2.fromOffset(420, 44), UDim2.fromOffset(textX, phone and 46 or 60), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 29 or 34,
        Color = self.Colors.Text,
        ZIndex = 1014,
    })
    self:CreateText(hero, "THE ULTIMATE SQUID GAME EXPERIENCE", UDim2.fromOffset(480, 24), UDim2.fromOffset(textX, phone and 91 or 110), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 10 or 12,
        Color = self.Colors.Accent,
        ZIndex = 1014,
    })

    local version = Instance.new("TextLabel")
    version.AnchorPoint = Vector2.new(1, 1)
    version.Position = UDim2.new(1, -14, 1, -14)
    version.Size = UDim2.fromOffset(phone and 76 or 90, phone and 30 or 34)
    version.BackgroundColor3 = self.Colors.AccentDark
    version.BorderSizePixel = 0
    version.Font = Enum.Font.GothamBold
    version.Text = self.Version
    version.TextSize = phone and 12 or 15
    version.TextColor3 = self.Colors.Text
    version.ZIndex = 1014
    version.Parent = hero
    makeCorner(version, 9)
end

function App:CreateFeatureCategoryCard(parent, categoryKey, title, description, color, position, widthScale, height)
    local phone = self.DeviceClass == "Phone"
    local card = self:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.10,
        Radius = phone and 12 or 14,
        ZIndex = 1011,
    })
    card.LayoutOrder = widthScale or 1

    local button = Instance.new("TextButton")
    button.Name = categoryKey .. "CategoryToggle"
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 1015
    button.Parent = card

    local glyph = self:CreateText(card, categoryKey == "Safe" and "✓" or (categoryKey == "SemiSafe" and "!" or "X"), UDim2.fromOffset(phone and 38 or 44, height - 16), UDim2.fromOffset(phone and 12 or 16, 8), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 27 or 31,
        Color = color,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1013,
    })

    local textX = phone and 56 or 66
    self:CreateText(card, string.upper(title), UDim2.new(1, -(textX + (phone and 76 or 70)), 0, 18), UDim2.fromOffset(textX, phone and 11 or 14), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 9 or 10,
        Color = color,
        ZIndex = 1013,
    })

    local available = self:CreateText(card, "0 Available", UDim2.new(1, -(textX + (phone and 76 or 70)), 0, 18), UDim2.fromOffset(textX, phone and 31 or 38), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 9 or 10,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })

    local descriptionLabel = self:CreateText(card, description, UDim2.new(1, -(textX + 16), 0, phone and 30 or 34), UDim2.fromOffset(textX, phone and 51 or 60), {
        Font = Enum.Font.Gotham,
        TextSize = phone and 8 or 9,
        Color = self.Colors.Muted,
        Wrapped = true,
        ZIndex = 1013,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, phone and -12 or -16, 0, phone and 15 or 18)
    switch.Size = UDim2.fromOffset(phone and 46 or 50, phone and 24 or 26)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1013
    switch.Parent = card
    makeCorner(switch, 999)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(phone and 18 or 20, phone and 18 or 20)
    knob.BackgroundColor3 = Color3.fromRGB(215, 211, 222)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1014
    knob.Parent = switch
    makeCorner(knob, 999)

    button.MouseButton1Click:Connect(function()
        self:PulseGlow(card, color)
        local summary = self:GetFeatureOverview()
        local category = summary.Categories[categoryKey]

        if not category or category.Total <= 0 then
            if self.Notifications and type(self.Notifications.Info) == "function" then
                self.Notifications:Info("Feature Categories", "No " .. title .. " are registered yet.", 3)
            end
            return
        end

        if self.FeatureManager and type(self.FeatureManager.SetCategoryEnabled) == "function" then
            local desired = category.State ~= "on"
            self.FeatureManager:SetCategoryEnabled(categoryKey, desired)
            task.defer(function()
                self:RefreshFeatureDashboard()
            end)
        end
    end)

    return {
        Card = card,
        Available = available,
        Description = descriptionLabel,
        Switch = switch,
        Knob = knob,
        Color = color,
        Glyph = glyph,
        Button = button,
    }
end

function App:RefreshFeatureDashboard()
    local widgets = self.FeatureWidgets
    if not widgets or not widgets.Root or not widgets.Root.Parent then
        return
    end

    local summary = self:GetFeatureOverview()

    if widgets.Total then
        widgets.Total.Text = "Total Features: " .. tostring(summary.Total)
    end

    local stateValues = {
        FullyOn = {Count = summary.FullyOn, Percent = summary.FullyPercent, Description = summary.Total == 0 and "No features registered" or "Enabled features"},
        Partial = {Count = summary.Partial, Percent = summary.PartialPercent, Description = summary.Total == 0 and "No features registered" or "Partially enabled features"},
        Off = {Count = summary.Off, Percent = summary.OffPercent, Description = summary.Total == 0 and "No features registered" or "Disabled features"},
    }

    for key, values in pairs(stateValues) do
        local refs = widgets.States and widgets.States[key]
        if refs then
            refs.Count.Text = tostring(values.Count)
            refs.Percent.Text = tostring(values.Percent) .. "%"
            refs.Description.Text = values.Description
        end
    end

    for categoryKey, refs in pairs(widgets.Categories or {}) do
        local category = summary.Categories[categoryKey] or {Total = 0, State = "empty"}
        refs.Available.Text = tostring(category.Total or 0) .. " Available"

        local state = category.State or "empty"
        local on = state == "on"
        local partial = state == "partial"
        local disabled = (category.Total or 0) == 0

        refs.Button.Active = not disabled
        refs.Card.BackgroundTransparency = disabled and 0.20 or 0
        refs.Switch.BackgroundColor3 = on and refs.Color or (partial and self.Colors.Warning or Color3.fromRGB(68, 64, 78))
        refs.Knob.BackgroundColor3 = disabled and self.Colors.Dim or Color3.fromRGB(245, 242, 248)

        local knobWidth = refs.Knob.Size.X.Offset
        local trackWidth = refs.Switch.Size.X.Offset
        local knobX = on and (trackWidth - knobWidth - 3) or (partial and math.floor((trackWidth - knobWidth) / 2) or 3)
        refs.Knob.Position = UDim2.fromOffset(knobX, 3)
    end

    if widgets.LoadedValue then
        widgets.LoadedValue.Text = tostring(summary.Total)
    end
end

function App:StartFeatureTracking()
    if self._featureTrackingStarted then
        return
    end
    self._featureTrackingStarted = true

    if self.FeatureManager and type(self.FeatureManager.Subscribe) == "function" then
        local ok, connection = pcall(function()
            return self.FeatureManager:Subscribe(function()
                task.defer(function()
                    self:RefreshFeatureDashboard()
                end)
            end)
        end)
        if ok and connection then
            self:Track(connection)
        end
    end

    task.spawn(function()
        while self.Gui and self.Gui.Parent do
            task.wait(0.5)
            self:RefreshFeatureDashboard()
        end
    end)
end

function App:BuildFeatureStats(parent)
    local summary = self:GetFeatureOverview()
    local phone = self.DeviceClass == "Phone"
    local cardHeight = self.Profile.FeatureHeight
    local stateHeight = phone and 104 or 118
    local stateY = phone and 46 or 52

    local card = self:CreateCard(parent, UDim2.new(1, 0, 0, cardHeight), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.08,
        Radius = phone and 14 or 18,
    })
    card.LayoutOrder = 2

    self:CreateText(card, "FEATURE STATS", UDim2.fromOffset(220, 26), UDim2.fromOffset(16, phone and 10 or 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 16 or 18,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })

    local totalLabel = self:CreateText(card, "Total Features: " .. tostring(summary.Total), UDim2.fromOffset(200, 24), UDim2.new(1, -216, 0, phone and 11 or 16), {
        Font = Enum.Font.GothamBold,
        TextSize = phone and 11 or 12,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    local stateRow = self:CreateEqualThreeColumnRow(card, stateY, stateHeight, "FeatureStateRow")
    local _, fullyRefs = self:CreateFeatureStateCard(stateRow, nil, 1, self.Colors.Success, "FULLY ON", summary.FullyOn, summary.FullyPercent, "Enabled features", stateHeight)
    local _, partialRefs = self:CreateFeatureStateCard(stateRow, nil, 2, self.Colors.Warning, "PARTIALLY ON", summary.Partial, summary.PartialPercent, "Partially enabled", stateHeight)
    local _, offRefs = self:CreateFeatureStateCard(stateRow, nil, 3, self.Colors.Error, "NOT ON", summary.Off, summary.OffPercent, "Disabled features", stateHeight)

    local registryY = stateY + stateHeight + (phone and 7 or 9)
    local registry = Instance.new("Frame")
    registry.Position = UDim2.fromOffset(16, registryY)
    registry.Size = UDim2.new(1, -32, 0, phone and 25 or 28)
    registry.BackgroundColor3 = self.Colors.CardAlt
    registry.BackgroundTransparency = 0.28
    registry.BorderSizePixel = 0
    registry.ZIndex = 1012
    registry.Parent = card
    makeCorner(registry, 9)
    makeStroke(registry, self.Colors.BorderSoft, 1, 0.46)

    self:CreateText(registry, "LIVE REGISTRY", UDim2.fromOffset(110, 20), UDim2.fromOffset(10, 2), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 9 or 10,
        Color = self.Colors.Success,
        ZIndex = 1013,
    })

    self:CreateText(registry, "Updates automatically as features change on their dedicated pages.", UDim2.new(1, -130, 1, 0), UDim2.fromOffset(120, 0), {
        Font = Enum.Font.GothamMedium,
        TextSize = phone and 9 or 10,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    self.FeatureWidgets = {
        Root = card,
        Total = totalLabel,
        States = {
            FullyOn = fullyRefs,
            Partial = partialRefs,
            Off = offRefs,
        },
        Categories = {},
    }

    self:StartFeatureTracking()
    self:RefreshFeatureDashboard()
end

function App:CreateEqualTwoColumnRow(parent, height, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "TwoColumnStatsRow"
    row.Size = UDim2.new(1, 0, 0, height or 170)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder or 1
    row.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = row

    return row
end

function App:CreateThreeColumnRow(parent, height, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "StatsRow"
    row.Size = UDim2.new(1, 0, 0, height or 208)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder or 1
    row.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = row

    return row
end

function App:CreateCompactMetric(
    parent,
    position,
    widthScale,
    labelText,
    valueText,
    valueColor,
    detailText,
    height
)
    local phone = self.DeviceClass == "Phone"
    local metricHeight = height or (phone and 76 or 90)

    local frame = Instance.new("Frame")
    frame.Position = position
    frame.Size = UDim2.new(widthScale, -18, 0, metricHeight)
    frame.BackgroundColor3 = self.Colors.CardAlt
    frame.BackgroundTransparency = 0.22
    frame.BorderSizePixel = 0
    frame.ZIndex = 1012
    frame.Parent = parent
    makeCorner(frame, 12)
    makeStroke(frame, self.Colors.BorderSoft, 1, 0.62)

    self:CreateText(
        frame,
        labelText,
        UDim2.new(1, -18, 0, 22),
        UDim2.fromOffset(9, 14),
        {
            Font = Enum.Font.GothamBold,
            TextSize = phone and 11 or 12,
            Color = self.Colors.Muted,
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1013,
        }
    )

    local value = self:CreateText(
        frame,
        valueText,
        UDim2.new(1, -18, 0, 42),
        UDim2.new(0, 9, 0.5, -20),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = phone and 24 or 28,
            Color = valueColor or self.Colors.Text,
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1013,
        }
    )

    self:CreateText(
        frame,
        string.upper(detailText or "LIVE"),
        UDim2.new(1, -18, 0, 20),
        UDim2.new(0, 9, 1, -34),
        {
            Font = Enum.Font.GothamBold,
            TextSize = phone and 9 or 10,
            Color = self.Colors.Accent,
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1013,
        }
    )

    return value
end

function App:BuildBottomStatsRow(parent)
    local rowHeight = self.Profile.BottomStatsHeight
    local row = self:CreateEqualTwoColumnRow(parent, rowHeight, 3)
    local phone = self.DeviceClass == "Phone"

    local left = self:CreateCard(row, UDim2.new(0.5, -8, 1, 0), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.14,
        Radius = phone and 14 or 18,
    })
    left.LayoutOrder = 1

    local right = self:CreateCard(row, UDim2.new(0.5, -8, 1, 0), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.14,
        Radius = phone and 14 or 18,
    })
    right.LayoutOrder = 2

    self:CreateText(left, "SERVER STATS", UDim2.fromOffset(220, 24), UDim2.fromOffset(16, phone and 10 or 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 13 or 16,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })
    self:CreateText(right, "NOMO STATS", UDim2.fromOffset(220, 24), UDim2.fromOffset(16, phone and 10 or 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = phone and 13 or 16,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })

    local metricY = phone and 46 or 52
    local metricHeight = rowHeight - metricY - (phone and 12 or 14)

    local playersValue = self:CreateCompactMetric(
        left,
        UDim2.fromOffset(14, metricY),
        0.333,
        "Players",
        tostring(#Players:GetPlayers()),
        self.Colors.Text,
        "In Server",
        metricHeight
    )
    local pingValue = self:CreateCompactMetric(
        left,
        UDim2.new(0.333333, 7, 0, metricY),
        0.333333,
        "Ping",
        "-- ms",
        self.Colors.Text,
        "Network",
        metricHeight
    )
    local fpsValue = self:CreateCompactMetric(
        left,
        UDim2.new(0.666666, 0, 0, metricY),
        0.333334,
        "FPS",
        "--",
        self.Colors.Text,
        "Rendering",
        metricHeight
    )

    local uptimeValue = self:CreateCompactMetric(
        right,
        UDim2.fromOffset(14, metricY),
        0.333,
        "Uptime",
        "00:00",
        self.Colors.Text,
        "Session",
        metricHeight
    )
    local memoryValue = self:CreateCompactMetric(
        right,
        UDim2.new(0.333333, 7, 0, metricY),
        0.333333,
        "Memory",
        "-- MB",
        self.Colors.Text,
        "Client",
        metricHeight
    )
    local versionValue = self:CreateCompactMetric(
        right,
        UDim2.new(0.666666, 0, 0, metricY),
        0.333334,
        "Version",
        self.Version,
        self.Colors.Text,
        "Current Build",
        metricHeight
    )

    self.FeatureWidgets.LoadedValue = nil

    task.spawn(function()
        local startedAt = os.clock()
        while left.Parent and right.Parent and self.Gui do
            task.wait(1)
            local ping = "-- ms"
            local fps = "--"
            local memory = "-- MB"

            pcall(function()
                ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
            end)
            if self.Utilities and type(self.Utilities.GetFPS) == "function" then
                pcall(function()
                    fps = tostring(self.Utilities:GetFPS())
                end)
            end
            pcall(function()
                memory = string.format("%.0f MB", Stats:GetTotalMemoryUsageMb())
            end)

            local elapsed = math.floor(os.clock() - startedAt)
            local uptime = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)

            playersValue.Text = tostring(#Players:GetPlayers())
            pingValue.Text = ping
            fpsValue.Text = fps
            uptimeValue.Text = uptime
            memoryValue.Text = memory
            versionValue.Text = self.Version
        end
    end)
end

function App:BuildPlaceholder(page, title, message)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = page
    makePadding(content, 16, 16, 16, 16)

    local card = self:CreateCard(content, UDim2.new(1, 0, 0, 190), {
        BorderColor = self.Colors.AccentDark,
    })

    self:CreateText(card, string.upper(title), UDim2.new(1, -40, 0, 35), UDim2.fromOffset(20, 20), {
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        Color = self.Colors.Text,
    })

    self:CreateText(card, message, UDim2.new(1, -40, 0, 70), UDim2.fromOffset(20, 67), {
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Color = self.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
    })

    self:CreatePill(card, "APP SHELL READY", self.Colors.Accent, UDim2.fromOffset(20, 145), 120)
end

function App:BuildErrorPage(page, title, errorText)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = page
    makePadding(content, 16, 16, 16, 16)

    local card = self:CreateCard(content, UDim2.new(1, 0, 0, 260), {
        Color = Color3.fromRGB(35, 15, 15),
        BorderColor = self.Colors.Error,
        BorderTransparency = 0.05,
    })

    self:CreateText(card, "MODULE COULD NOT BUILD: " .. string.upper(title), UDim2.new(1, -40, 0, 30), UDim2.fromOffset(20, 18), {
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Color = self.Colors.Error,
    })

    self:CreateText(card, "The main app is still running. Copy the message below when asking for help.", UDim2.new(1, -40, 0, 38), UDim2.fromOffset(20, 52), {
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Color = self.Colors.Muted,
        Wrapped = true,
    })

    local errorBox = Instance.new("TextBox")
    errorBox.Position = UDim2.fromOffset(20, 100)
    errorBox.Size = UDim2.new(1, -40, 0, 135)
    errorBox.BackgroundColor3 = Color3.fromRGB(15, 8, 8)
    errorBox.BorderSizePixel = 0
    errorBox.ClearTextOnFocus = false
    errorBox.MultiLine = true
    errorBox.TextEditable = false
    errorBox.TextWrapped = true
    errorBox.Font = Enum.Font.Code
    errorBox.Text = tostring(errorText or "Unknown module error")
    errorBox.TextSize = 10
    errorBox.TextColor3 = self.Colors.Text
    errorBox.TextXAlignment = Enum.TextXAlignment.Left
    errorBox.TextYAlignment = Enum.TextYAlignment.Top
    errorBox.ZIndex = 1013
    errorBox.Parent = card
    makeCorner(errorBox, 9)
    makePadding(errorBox, 10, 10, 8, 8)
end

function App:GetModuleErrorCount()
    local count = 0
    for _ in pairs(self.ModuleErrors) do
        count = count + 1
    end
    return count
end


function App:CreateTermsModal()
    if self.TermsAccepted or not self.Window then
        return
    end

    local mobile = self:IsMobile()

    local overlay = Instance.new("Frame")
    overlay.Name = "TermsOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.20
    overlay.BorderSizePixel = 0
    overlay.Active = true
    overlay.ZIndex = 3000
    overlay.Parent = self.Window

    local modalWidth = mobile and 820 or 760
    local headerHeight = 112
    local bodyHeight = mobile and 244 or 224
    local bodyY = headerHeight + 8
    local acceptY = bodyY + bodyHeight + 14
    local acceptHeight = 58
    local buttonsY = acceptY + acceptHeight + 16
    local buttonHeight = 60
    local footerY = buttonsY + buttonHeight + 10
    local modalHeight = footerY + 28

    local modal = Instance.new("Frame")
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.fromScale(0.5, 0.5)
    modal.Size = UDim2.fromOffset(modalWidth, modalHeight)
    modal.BackgroundColor3 = Color3.fromRGB(15, 11, 23)
    modal.BorderSizePixel = 0
    modal.ClipsDescendants = true
    modal.ZIndex = 3001
    modal.Parent = overlay
    makeCorner(modal, 22)
    makeStroke(modal, self.Colors.Border, 2, 0.02)

    self:CreateText(modal, "!   BEFORE YOU CONTINUE   !", UDim2.new(1, -48, 0, 42), UDim2.fromOffset(24, 18), {
        Font = Enum.Font.GothamBlack,
        TextSize = mobile and 30 or 28,
        Color = self.Colors.Warning,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3003,
    })

    self:CreateText(modal, "!   READ AND ACCEPT THESE RISKS BEFORE ACCESSING SQUIDNOMO   !", UDim2.new(1, -56, 0, 30), UDim2.fromOffset(28, 64), {
        Font = Enum.Font.GothamBold,
        TextSize = mobile and 15 or 14,
        Color = self.Colors.Accent,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3003,
    })

    local headerDragHandle = Instance.new("TextButton")
    headerDragHandle.Name = "TermsDragHandle"
    headerDragHandle.Position = UDim2.fromOffset(0, 0)
    headerDragHandle.Size = UDim2.new(1, 0, 0, headerHeight)
    headerDragHandle.BackgroundTransparency = 1
    headerDragHandle.BorderSizePixel = 0
    headerDragHandle.AutoButtonColor = false
    headerDragHandle.Text = ""
    headerDragHandle.ZIndex = 3004
    headerDragHandle.Parent = modal
    self:EnableDragging(headerDragHandle)

    local divider = Instance.new("Frame")
    divider.Position = UDim2.fromOffset(28, headerHeight - 1)
    divider.Size = UDim2.new(1, -56, 0, 1)
    divider.BackgroundColor3 = self.Colors.BorderSoft
    divider.BorderSizePixel = 0
    divider.ZIndex = 3002
    divider.Parent = modal

    local bodyCard = Instance.new("Frame")
    bodyCard.Position = UDim2.fromOffset(32, bodyY)
    bodyCard.Size = UDim2.new(1, -64, 0, bodyHeight)
    bodyCard.BackgroundColor3 = self.Colors.Card
    bodyCard.BorderSizePixel = 0
    bodyCard.ZIndex = 3002
    bodyCard.Parent = modal
    makeCorner(bodyCard, 14)
    makeStroke(bodyCard, self.Colors.BorderSoft, 1, 0.14)

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(24, 18)
    body.Size = UDim2.new(1, -48, 1, -36)
    body.Font = Enum.Font.GothamMedium
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Center
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.TextSize = mobile and 18 or 17
    body.TextColor3 = self.Colors.Text
    body.Text = [=[Using this software may violate the game's Terms of Service. Your account may be warned, restricted, suspended, or banned.

Use it entirely at your own risk. The developers are not responsible for account actions, lost progress or data, crashes, interrupted gameplay, device problems, or any other consequences resulting from its use.

Only continue if you fully understand and accept these risks.]=]
    body.ZIndex = 3003
    body.Parent = bodyCard
    pcall(function()
        body.LineHeight = 1.12
    end)

    local acceptRow = Instance.new("TextButton")
    acceptRow.Position = UDim2.fromOffset(32, acceptY)
    acceptRow.Size = UDim2.new(1, -64, 0, acceptHeight)
    acceptRow.BackgroundColor3 = self.Colors.CardAlt
    acceptRow.BorderSizePixel = 0
    acceptRow.AutoButtonColor = false
    acceptRow.Text = ""
    acceptRow.ZIndex = 3002
    acceptRow.Parent = modal
    makeCorner(acceptRow, 13)
    local acceptStroke = makeStroke(acceptRow, self.Colors.BorderSoft, 1.2, 0.12)

    local checkbox = Instance.new("Frame")
    checkbox.AnchorPoint = Vector2.new(0, 0.5)
    checkbox.Position = UDim2.new(0, 16, 0.5, 0)
    checkbox.Size = UDim2.fromOffset(34, 34)
    checkbox.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
    checkbox.BorderSizePixel = 0
    checkbox.ZIndex = 3003
    checkbox.Parent = acceptRow
    makeCorner(checkbox, 9)
    local checkboxStroke = makeStroke(checkbox, self.Colors.Border, 1.5, 0.08)

    local check = Instance.new("TextLabel")
    check.BackgroundTransparency = 1
    check.Size = UDim2.fromScale(1, 1)
    check.Font = Enum.Font.GothamBlack
    check.Text = "✓"
    check.TextSize = 22
    check.TextColor3 = Color3.fromRGB(255, 255, 255)
    check.Visible = false
    check.ZIndex = 3004
    check.Parent = checkbox

    self:CreateText(acceptRow, "I UNDERSTAND AND ACCEPT THESE RISKS", UDim2.new(1, -78, 1, 0), UDim2.fromOffset(66, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = mobile and 17 or 16,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3003,
    })

    local buttonRow = Instance.new("Frame")
    buttonRow.Position = UDim2.fromOffset(32, buttonsY)
    buttonRow.Size = UDim2.new(1, -64, 0, buttonHeight)
    buttonRow.BackgroundTransparency = 1
    buttonRow.BorderSizePixel = 0
    buttonRow.ZIndex = 3002
    buttonRow.Parent = modal

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 16)
    buttonLayout.Parent = buttonRow

    local exitButton = Instance.new("TextButton")
    exitButton.Size = UDim2.new(0.34, -8, 1, 0)
    exitButton.BackgroundColor3 = self.Colors.CardAlt
    exitButton.BorderSizePixel = 0
    exitButton.AutoButtonColor = false
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Text = "EXIT"
    exitButton.TextSize = mobile and 18 or 17
    exitButton.TextColor3 = self.Colors.Text
    exitButton.LayoutOrder = 1
    exitButton.ZIndex = 3002
    exitButton.Parent = buttonRow
    makeCorner(exitButton, 13)
    makeStroke(exitButton, self.Colors.Close, 1.5, 0.12)
    self:BindButtonFeedback(exitButton, self.Colors.Close)

    local continueButton = Instance.new("TextButton")
    continueButton.Size = UDim2.new(0.66, -8, 1, 0)
    continueButton.BackgroundColor3 = self.Colors.CardAlt
    continueButton.BorderSizePixel = 0
    continueButton.AutoButtonColor = false
    continueButton.Font = Enum.Font.GothamBold
    continueButton.Text = "I UNDERSTAND — CONTINUE"
    continueButton.TextSize = mobile and 18 or 17
    continueButton.TextColor3 = self.Colors.Text
    continueButton.LayoutOrder = 2
    continueButton.ZIndex = 3002
    continueButton.Parent = buttonRow
    makeCorner(continueButton, 13)
    local continueStroke = makeStroke(continueButton, self.Colors.BorderSoft, 1.5, 0.12)
    self:BindButtonFeedback(continueButton, self.Colors.Accent)
    self:BindButtonFeedback(acceptRow, self.Colors.Accent)

    self:CreateText(modal, self.Version .. "  •  TERMS VERSION 1.2  •  ACCEPTANCE REQUIRED", UDim2.new(1, -64, 0, 18), UDim2.fromOffset(32, footerY), {
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        Color = self.Colors.Muted,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3002,
    })

    local accepted = false

    local function refresh()
        check.Visible = accepted
        checkbox.BackgroundColor3 = accepted and self.Colors.Accent or Color3.fromRGB(10, 8, 15)
        checkboxStroke.Color = accepted and self.Colors.Accent or self.Colors.Border
        acceptStroke.Color = accepted and self.Colors.Accent or self.Colors.BorderSoft
        continueButton.BackgroundColor3 = accepted and self.Colors.Accent or self.Colors.CardAlt
        continueButton.TextTransparency = accepted and 0 or 0.24
        continueStroke.Color = accepted and self.Colors.Accent or self.Colors.BorderSoft
    end

    acceptRow.MouseButton1Click:Connect(function()
        accepted = not accepted
        refresh()
    end)

    exitButton.MouseButton1Click:Connect(function()
        if self.Session then
            self.Session.UserClosed = true
        end
        self:Destroy(true)
    end)

    continueButton.MouseButton1Click:Connect(function()
        if not accepted then
            if self.Notifications and type(self.Notifications.Warning) == "function" then
                pcall(function()
                    self.Notifications:Warning("Terms", "Tap the acceptance box before continuing.", 3)
                end)
            end
            return
        end

        self.TermsAccepted = true
        if self.Session then
            self.Session.TermsAccepted = true
        end
        overlay:Destroy()
        self.TermsModal = nil
    end)

    refresh()
    self.TermsModal = overlay
end

----------------------------------------------------------
-- Responsive event binding
----------------------------------------------------------

function App:StartResponsive()
    local cameraConnection = nil

    local function bindCamera()
        safeDisconnect(cameraConnection)
        cameraConnection = nil

        local camera = workspace.CurrentCamera
        if camera then
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                task.defer(function()
                    self:UpdateResponsive(self.AutoCenterOnResizeEnabled)
                end)
            end)
            table.insert(self.Connections, cameraConnection)
        end
    end

    bindCamera()

    self:Track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        bindCamera()
        task.defer(function()
            self:UpdateResponsive(self.AutoCenterOnResizeEnabled)
        end)
    end))

    self:Track(UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
        task.defer(function()
            self:UpdateResponsive(self.AutoCenterOnResizeEnabled)
        end)
    end))
end

----------------------------------------------------------
-- Visible emergency launch screen
----------------------------------------------------------

function App:CreateEmergencyGui(errorText)
    pcall(function()
        self:DestroyOldCopies()

        local gui = Instance.new("ScreenGui")
        gui.Name = self.Name
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = self.Config.DisplayOrder
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.Parent = self:GetGuiParent() or self:GetPlayerGui()

        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(0.5, 0.5)
        box.Position = UDim2.fromScale(0.5, 0.5)
        box.Size = UDim2.fromOffset(520, 260)
        box.BackgroundColor3 = Color3.fromRGB(27, 12, 12)
        box.BorderSizePixel = 0
        box.ZIndex = 9000
        box.Parent = gui
        makeCorner(box, 16)
        makeStroke(box, self.Colors.Error, 2, 0)

        self:CreateText(box, "SQUIDNOMO APP LAUNCH ERROR", UDim2.new(1, -40, 0, 35), UDim2.fromOffset(20, 18), {
            Font = Enum.Font.GothamBlack,
            TextSize = 18,
            Color = self.Colors.Error,
            ZIndex = 9001,
        })

        self:CreateText(box, "Delta may hide console errors, so this message is shown inside the game.", UDim2.new(1, -40, 0, 40), UDim2.fromOffset(20, 55), {
            Font = Enum.Font.Gotham,
            TextSize = 11,
            Color = self.Colors.Muted,
            Wrapped = true,
            ZIndex = 9001,
        })

        local message = Instance.new("TextBox")
        message.Position = UDim2.fromOffset(20, 105)
        message.Size = UDim2.new(1, -40, 0, 130)
        message.BackgroundColor3 = Color3.fromRGB(12, 6, 6)
        message.BorderSizePixel = 0
        message.ClearTextOnFocus = false
        message.MultiLine = true
        message.TextEditable = false
        message.TextWrapped = true
        message.Font = Enum.Font.Code
        message.Text = tostring(errorText)
        message.TextSize = 10
        message.TextColor3 = self.Colors.Text
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.ZIndex = 9001
        message.Parent = box
        makeCorner(message, 10)
        makePadding(message, 10, 10, 8, 8)

        self.Gui = gui
    end)
end

----------------------------------------------------------
-- Public lifecycle
----------------------------------------------------------

function App:Build(loader)
    if self._building then
        return self
    end

    self._building = true
    self:Destroy(true)
    self.ModuleErrors = {}

    local ok, err = xpcall(function()
        self:Init(loader or {})
        self:CreateGui()
        self:CreateWindow()
        self:CreateSidebar()
        self:CreateTopbar()
        self:CreateStatusbar()
        self:CreatePageContainer()
        self:CreateReopenButton()
        self:BuildPageDefinitions()
        self:BuildPages()

        local initialPage = "Home"
        if self.RememberLastPageEnabled and self.Session and self.Session.LastPage and self.Pages[self.Session.LastPage] then
            initialPage = self.Session.LastPage
        end
        self:OpenPage(initialPage)
        self:UpdateResponsive(true)
        self:StartResponsive()
        self:StartDetectionMonitor()
        self:CreateTermsModal()
        self:SetAppStatus("READY")

        if self.Session then
            self.Session.Loader = self.Loader
            self.Session.App = self
            self.Session.UserClosed = false
        end

        if self.Notifications and type(self.Notifications.Success) == "function" then
            pcall(function()
                self.Notifications:Success("SquidNoMo", "Responsive app shell loaded")
            end)
        end
    end, function(message)
        return debug.traceback(tostring(message), 2)
    end)

    self._building = false

    if not ok then
        warn("[SquidNoMo] Launch failed: " .. tostring(err))
        self:SetAppStatus("ERROR")
        self:Destroy(true)
        self:CreateEmergencyGui(err)
    end

    return self
end

function App:Destroy(keepSession)
    for _, connection in ipairs(self.Connections) do
        safeDisconnect(connection)
    end

    self.Connections = {}

    if self.Gui then
        pcall(function()
            self.Gui:Destroy()
        end)
    end

    self.Gui = nil
    self.Host = nil
    self.Window = nil
    self.WindowScale = nil
    self.Sidebar = nil
    self.Topbar = nil
    self.Statusbar = nil
    self.PageContainer = nil
    self.ReopenButton = nil
    self.PageTitle = nil
    self.TermsModal = nil
    self.SupportModal = nil
    self.CloseModal = nil
    self.MaximizeButton = nil
    self.Pages = {}
    self.PageDefinitions = {}
    self.NavigationButtons = {}
    self.AssetCache = {}
    self.FeatureWidgets = {}
    self.FooterLabels = {}
    self.CurrentPage = nil
    self.HasBeenDragged = false
    self.IsMinimized = false
    self.MinimizedByFreeRoam = false
    self.WindowSettingsWidgets = {}
    self.ReopenButtonHasBeenDragged = false
    self._featureTrackingStarted = false

    if not keepSession then
        self.TermsAccepted = false
    elseif self.Session then
        self.TermsAccepted = self.Session.TermsAccepted == true
    end
end

function App:GetPage(name)
    return self.Pages[name]
end

function App:GetWindow()
    return self.Window
end

function App:GetTheme()
    return self.Theme or self.Colors
end

function App:IsVisible()
    return self.Gui ~= nil and self.Gui.Parent ~= nil
end

return App
