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
App.Version = "v0.5.0"
App.Runtime = "Universal Injector / Studio"

----------------------------------------------------------
-- Easy configuration
-- These values are intentionally grouped in one place.
----------------------------------------------------------

App.Config = {
    -- Desktop keeps the full reference composition.
    DesktopDesignWidth = 1225,
    DesktopDesignHeight = 730,

    -- Delta mobile landscape gets its own denser canvas. It contains the
    -- same pages and dashboard cards, but starts larger and uses less dead space.
    MobileDesignWidth = 1100,
    MobileDesignHeight = 620,

    -- Kept for compatibility with modules that read these older names.
    DesignWidth = 1225,
    DesignHeight = 730,

    DesktopFill = 0.80,
    MobileSafeFill = 0.995,

    MinimumScale = 0.55,
    MaximumScale = 1.25,

    -- Safe zone based on the supplied Delta landscape screenshots.
    MobileLandscapeMargins = {
        Left = 0.130,
        Right = 0.170,
        Top = 0.095,
        Bottom = 0.012,
    },

    MobilePortraitMargins = {
        Left = 0.035,
        Right = 0.035,
        Top = 0.080,
        Bottom = 0.080,
    },

    DesktopMargins = {
        Left = 0.025,
        Right = 0.025,
        Top = 0.035,
        Bottom = 0.035,
    },

    DisplayOrder = 999999,
    SidebarWidth = 248,
    TopbarHeight = 42,
    CornerRadius = 18,

    -- Larger small text on touch devices without changing desktop typography.
    MobileTextBoost = true,

    -- The bottom status banner is intentionally removed on mobile and desktop
    -- to give the dashboard more usable vertical space.
    ShowHomeFooter = false,

    -- Set true only when testing mobile behavior in Studio device emulation.
    ForceMobile = false,

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
    CashApp = Color3.fromRGB(0, 224, 106),
    PayPal = Color3.fromRGB(0, 99, 214),
    Text = Color3.fromRGB(244, 240, 246),
    Muted = Color3.fromRGB(177, 163, 184),
    Dim = Color3.fromRGB(116, 102, 126),
    Black = Color3.fromRGB(0, 0, 0),
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

App.Gui = nil
App.Host = nil
App.Window = nil
App.WindowScale = nil
App.Sidebar = nil
App.Topbar = nil
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
App.CurrentDesignSize = Vector2.new(App.Config.DesktopDesignWidth, App.Config.DesktopDesignHeight)
App.CurrentVisualSize = App.CurrentDesignSize
App.CurrentSafePosition = Vector2.new(0, 0)
App.CurrentSafeSize = App.CurrentDesignSize
App.HasBeenDragged = false
App.IsMinimized = false
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

    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )

    tween:Play()
    return tween
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
    self.Features = self.Loader.Features or self.Loader.FeatureManager

    -- Main.lua in the current project calls Loader.Home.Load().
    -- Add a harmless compatibility method so that call cannot kill launch.
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

    if self:IsMobile(viewport) then
        return Vector2.new(
            self.Config.MobileDesignWidth,
            self.Config.MobileDesignHeight
        )
    end

    return Vector2.new(
        self.Config.DesktopDesignWidth,
        self.Config.DesktopDesignHeight
    )
end

function App:GetSafeRect()
    local viewport = self:GetViewportSize()
    local mobile = self:IsMobile(viewport)
    local landscape = viewport.X >= viewport.Y

    local margins
    if mobile and landscape then
        margins = self.Config.MobileLandscapeMargins
    elseif mobile then
        margins = self.Config.MobilePortraitMargins
    else
        margins = self.Config.DesktopMargins
    end

    local left = viewport.X * margins.Left
    local right = viewport.X * margins.Right
    local top = viewport.Y * margins.Top
    local bottom = viewport.Y * margins.Bottom

    local ok, insetTopLeft, insetBottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if ok then
        left = math.max(left, insetTopLeft.X)
        top = math.max(top, insetTopLeft.Y)
        right = math.max(right, insetBottomRight.X)
        bottom = math.max(bottom, insetBottomRight.Y)
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
    local mobile = self:IsMobile(viewport)
    local safePosition, safeSize = self:GetSafeRect()
    local designSize = self:GetDesignSize(viewport)

    local fill = mobile and self.Config.MobileSafeFill or self.Config.DesktopFill
    local targetWidth = safeSize.X * fill
    local targetHeight = safeSize.Y * fill

    local scale = math.min(
        targetWidth / designSize.X,
        targetHeight / designSize.Y
    )

    scale = math.clamp(scale, self.Config.MinimumScale, self.Config.MaximumScale)

    local visualSize = Vector2.new(
        math.floor(designSize.X * scale),
        math.floor(designSize.Y * scale)
    )

    return scale, safePosition, safeSize, visualSize, designSize
end

function App:ClampHostPosition(position)
    local safePosition = self.CurrentSafePosition
    local safeSize = self.CurrentSafeSize
    local visualSize = self.CurrentVisualSize

    local minX = safePosition.X
    local minY = safePosition.Y
    local maxX = safePosition.X + math.max(0, safeSize.X - visualSize.X)
    local maxY = safePosition.Y + math.max(0, safeSize.Y - visualSize.Y)

    return Vector2.new(
        math.clamp(position.X, minX, maxX),
        math.clamp(position.Y, minY, maxY)
    )
end

function App:UpdateResponsive(forceCenter)
    if not self.Host or not self.WindowScale then
        return
    end

    local oldSafePosition = self.CurrentSafePosition
    local oldSafeSize = self.CurrentSafeSize
    local oldVisualSize = self.CurrentVisualSize

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

    if forceCenter or not self.HasBeenDragged then
        targetPosition = Vector2.new(
            safePosition.X + ((safeSize.X - visualSize.X) / 2),
            safePosition.Y + ((safeSize.Y - visualSize.Y) / 2)
        )
    else
        local current = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)

        if oldSafeSize.X > 0 and oldSafeSize.Y > 0 then
            local oldTravel = Vector2.new(
                math.max(1, oldSafeSize.X - oldVisualSize.X),
                math.max(1, oldSafeSize.Y - oldVisualSize.Y)
            )

            local normalized = Vector2.new(
                math.clamp((current.X - oldSafePosition.X) / oldTravel.X, 0, 1),
                math.clamp((current.Y - oldSafePosition.Y) / oldTravel.Y, 0, 1)
            )

            local newTravel = Vector2.new(
                math.max(0, safeSize.X - visualSize.X),
                math.max(0, safeSize.Y - visualSize.Y)
            )

            targetPosition = Vector2.new(
                safePosition.X + (newTravel.X * normalized.X),
                safePosition.Y + (newTravel.Y * normalized.Y)
            )
        else
            targetPosition = current
        end
    end

    targetPosition = self:ClampHostPosition(targetPosition)
    self.Host.Position = UDim2.fromOffset(targetPosition.X, targetPosition.Y)

    if self.ReopenButton and self.ReopenButton.Visible then
        self:PositionReopenButton(false)
    end
end

----------------------------------------------------------
-- Gui creation
----------------------------------------------------------

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
    topbar.BackgroundTransparency = 0.18
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

    local minimize = self:CreateTopbarButton(topbar, "—", self:IsMobile() and 62 or 54)
    local close = self:CreateTopbarButton(topbar, "×", self:IsMobile() and 14 or 12)

    minimize.MouseButton1Click:Connect(function()
        self:SetMinimized(true)
    end)

    close.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    self:EnableDragging(topbar)
    self.Topbar = topbar
end

function App:CreateTopbarButton(parent, text, rightOffset)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -rightOffset, 0.5, 0)
    local mobile = self:IsMobile()
    button.Size = UDim2.fromOffset(mobile and 44 or 38, mobile and 38 or 32)
    button.BackgroundColor3 = self.Colors.CardAlt
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextSize = 18
    button.TextColor3 = self.Colors.Text
    button.ZIndex = 1030
    button.Parent = parent
    makeCorner(button, 9)
    makeStroke(button, self.Colors.BorderSoft, 1, 0.25)

    button.MouseEnter:Connect(function()
        self:Tween(button, {BackgroundColor3 = self.Colors.CardHover}, 0.14)
    end)

    button.MouseLeave:Connect(function()
        self:Tween(button, {BackgroundColor3 = self.Colors.CardAlt}, 0.14)
    end)

    return button
end

function App:EnableDragging(dragBar)
    local dragging = false
    local activeInput = nil
    local startInput = nil
    local startPosition = nil

    self:Track(dragBar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        activeInput = input
        startInput = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Vector2.new(self.Host.Position.X.Offset, self.Host.Position.Y.Offset)
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
        local target = self:ClampHostPosition(startPosition + delta)

        self.Host.Position = UDim2.fromOffset(target.X, target.Y)
        self.HasBeenDragged = true
    end))

    self:Track(UserInputService.InputEnded:Connect(function(input)
        if not dragging then
            return
        end

        if input == activeInput
            or input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            activeInput = nil
        end
    end))
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
    local buttonSize = mobile and 66 or 60

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

function App:CreateSidebar()
    local mobile = self:IsMobile()
    local sidebarWidth = self.Config.SidebarWidth

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = self.Colors.Sidebar
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

    local logoFrame = Instance.new("Frame")
    logoFrame.Position = UDim2.fromOffset(16, mobile and 14 or 16)
    logoFrame.Size = UDim2.fromOffset(mobile and 56 or 60, mobile and 56 or 60)
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

    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Position = UDim2.fromOffset(88, mobile and 18 or 18)
    brand.Size = UDim2.new(1, -100, 0, 28)
    brand.Font = Enum.Font.GothamBlack
    brand.Text = "SQUIDNOMO"
    brand.TextSize = mobile and 16 or 17
    brand.TextColor3 = self.Colors.Text
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.ZIndex = 1012
    brand.Parent = sidebar

    local version = Instance.new("TextLabel")
    version.BackgroundTransparency = 1
    version.Position = UDim2.fromOffset(90, mobile and 43 or 43)
    version.Size = UDim2.new(1, -102, 0, 17)
    version.Font = Enum.Font.GothamBold
    version.Text = "PREMIUM " .. self.Version
    version.TextSize = 10
    version.TextColor3 = self.Colors.Accent
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 1012
    version.Parent = sidebar

    self.NavigationButtonHeight = mobile and 42 or 44
    self.NavigationButtonPadding = 6

    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.Position = UDim2.fromOffset(12, mobile and 92 or 94)
    nav.Size = UDim2.new(1, -24, 0, mobile and 382 or 404)
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
    local localPath = imageFolder .. "/" .. filename

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

    local modal = Instance.new("Frame")
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.fromScale(0.5, 0.52)
    modal.Size = self:IsMobile() and UDim2.fromOffset(430, 500) or UDim2.fromOffset(420, 490)
    modal.BackgroundColor3 = Color3.fromRGB(15, 11, 23)
    modal.BorderSizePixel = 0
    modal.ZIndex = 3201
    modal.Parent = overlay
    makeCorner(modal, 20)
    makeStroke(modal, accentColor or self.Colors.Accent, 1.5, 0.02)

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
    imageHolder.Position = UDim2.fromOffset(28, 66)
    imageHolder.Size = UDim2.new(1, -56, 0, 336)
    imageHolder.BackgroundColor3 = Color3.fromRGB(255,255,255)
    imageHolder.BorderSizePixel = 0
    imageHolder.ZIndex = 3202
    imageHolder.Parent = modal
    makeCorner(imageHolder, 16)

    local qrImage = Instance.new("ImageLabel")
    qrImage.BackgroundTransparency = 1
    qrImage.Position = UDim2.fromOffset(12, 12)
    qrImage.Size = UDim2.new(1, -24, 1, -24)
    qrImage.ScaleType = Enum.ScaleType.Fit
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

    self:CreateText(modal, serviceName .. ": " .. tostring(tag or ""), UDim2.new(1, -56, 0, 28), UDim2.fromOffset(28, 414), {
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3202,
    })

    local copyButton = Instance.new("TextButton")
    copyButton.Position = UDim2.fromOffset(28, 450)
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
    local panelHeight = mobile and 196 or 204

    local panel = Instance.new("Frame")
    panel.Name = "SupportPanel"
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(0, 12, 1, -12)
    panel.Size = UDim2.new(1, -24, 0, panelHeight)
    panel.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
    panel.BorderSizePixel = 0
    panel.ZIndex = 1012
    panel.Parent = sidebar
    makeCorner(panel, 14)
    makeStroke(panel, self.Colors.Border, 1.2, 0.10)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(16, 14)
    title.Size = UDim2.new(1, -32, 0, 24)
    title.Font = Enum.Font.GothamBold
    title.Text = "SUPPORT US"
    title.TextSize = mobile and 13 or 13
    title.TextColor3 = self.Colors.Accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 1013
    title.Parent = panel

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(16, 44)
    body.Size = UDim2.new(1, -32, 0, 78)
    body.Font = Enum.Font.Gotham
    body.Text = "Help support development, hosting, updates, and testing. Every contribution helps keep SquidNoMo improving."
    body.TextWrapped = true
    body.TextSize = mobile and 12 or 12
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

    local function createSupportButton(y, labelText, buttonColor, value, qrPath)
        local button = Instance.new("TextButton")
        button.Position = UDim2.fromOffset(16, y)
        button.Size = UDim2.new(1, -32, 0, 34)
        button.BackgroundColor3 = buttonColor
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBold
        button.Text = labelText
        button.TextSize = 13
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.ZIndex = 1013
        button.Parent = panel
        makeCorner(button, 10)
        makeStroke(button, buttonColor, 1, 0.25)

        button.MouseEnter:Connect(function()
            self:Tween(button, {BackgroundTransparency = 0.08}, 0.12)
        end)
        button.MouseLeave:Connect(function()
            self:Tween(button, {BackgroundTransparency = 0}, 0.12)
        end)

        button.MouseButton1Click:Connect(function()
            if value and value ~= "" and not string.find(value, "REPLACE_") then
                self:ShowSupportQR(labelText, value, qrPath, buttonColor)
            else
                notifySupport("Support", "Update App.Config.Support with your real " .. labelText .. " details.", "Warning")
            end
        end)
    end

    createSupportButton(panelHeight - 76, "Cash App", self.Colors.CashApp, self.Config.Support and self.Config.Support.CashApp, self.Config.Support and self.Config.Support.CashAppQR)
    createSupportButton(panelHeight - 36, "PayPal", self.Colors.PayPal, self.Config.Support and self.Config.Support.PayPal, self.Config.Support and self.Config.Support.PayPalQR)
end

function App:CreateNavigationButton(definition)
    local button = Instance.new("TextButton")
    button.Name = definition.Name
    local mobile = self:IsMobile()
    local buttonHeight = self.NavigationButtonHeight or 48
    button.Size = UDim2.new(1, 0, 0, buttonHeight)
    button.BackgroundColor3 = self.Colors.Sidebar
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = definition.Order or 0
    button.ZIndex = 1014
    button.Parent = self.NavigationHolder
    makeCorner(button, 12)

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
    label.TextSize = mobile and 13 or 13
    label.TextColor3 = self.Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1015
    label.Parent = button

    local function setSelected(selected)
        self:Tween(button, {
            BackgroundColor3 = selected and self.Colors.Accent or self.Colors.Sidebar,
        }, 0.16)
        self:Tween(icon, {
            BackgroundColor3 = selected and Color3.fromRGB(255,255,255) or self.Colors.CardAlt,
        }, 0.16)
        self:Tween(iconImage, {
            ImageColor3 = selected and self.Colors.Accent or self.Colors.Text,
        }, 0.16)
        self:Tween(label, {
            TextColor3 = Color3.fromRGB(255,255,255),
        }, 0.16)
    end

    button.MouseEnter:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {BackgroundColor3 = self.Colors.Card}, 0.12)
        end
    end)

    button.MouseLeave:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {BackgroundColor3 = self.Colors.Sidebar}, 0.12)
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:OpenPage(definition.Name)
    end)

    self.NavigationButtons[definition.Name] = {
        Instance = button,
        SetSelected = setSelected,
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
        -self.Config.TopbarHeight
    )
    container.BackgroundColor3 = self.Colors.Backdrop
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
        self:BuildExternalPage(page, self.Loader.Settings, "Settings")
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
    local summary = {
        FullyOn = 22,
        Partial = 4,
        Off = 16,
    }
    summary.Total = summary.FullyOn + summary.Partial + summary.Off
    summary.FullyPercent = math.floor((summary.FullyOn / summary.Total) * 100 + 0.5)
    summary.PartialPercent = math.floor((summary.Partial / summary.Total) * 100 + 0.5)
    summary.OffPercent = math.max(0, 100 - summary.FullyPercent - summary.PartialPercent)
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

function App:CreateFeatureStateCard(parent, position, widthScale, color, title, count, percent, description)
    local card = self:CreateCard(parent, UDim2.new(widthScale, -10, 0, 118), {
        Color = Color3.fromRGB(17, 12, 24),
        BorderColor = color,
        BorderTransparency = 0.08,
        Radius = 14,
        ZIndex = 1011,
    })
    card.Position = position

    local iconRing = Instance.new("Frame")
    iconRing.Position = UDim2.fromOffset(18, 22)
    iconRing.Size = UDim2.fromOffset(52, 52)
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
    glyph.TextSize = 24
    glyph.TextColor3 = color
    glyph.ZIndex = 1013
    glyph.Parent = iconRing

    self:CreateText(card, title, UDim2.new(1, -96, 0, 20), UDim2.fromOffset(84, 16), {
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Color = color,
        ZIndex = 1013,
    })
    self:CreateText(card, tostring(count), UDim2.fromOffset(72, 40), UDim2.fromOffset(84, 36), {
        Font = Enum.Font.GothamBlack,
        TextSize = 28,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })
    self:CreateText(card, "Features", UDim2.fromOffset(110, 18), UDim2.fromOffset(84, 74), {
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        Color = self.Colors.Text,
        ZIndex = 1013,
    })
    self:CreateText(card, description, UDim2.new(1, -96, 0, 18), UDim2.fromOffset(84, 93), {
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Color = self.Colors.Muted,
        ZIndex = 1013,
    })
    self:CreateText(card, tostring(percent) .. "%", UDim2.fromOffset(56, 18), UDim2.new(1, -66, 1, -24), {
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Color = color,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })
    return card
end

function App:BuildHome(page)
    local content = Instance.new("Frame")
    content.Name = "HomeContent"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 1007
    content.Parent = page

    makePadding(content, 16, 16, 16, 18)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 14)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content

    self:BuildHero(content)
    self:BuildFeatureStats(content)
    self:BuildBottomStatsRow(content)
end

function App:BuildHero(parent)
    local hero = self:CreateCard(parent, UDim2.new(1, 0, 0, 182), {
        Color = Color3.fromRGB(16, 11, 24),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.04,
        Radius = 18,
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
    guardArtwork.Position = UDim2.new(1, -8, 0.5, 0)
    guardArtwork.Size = UDim2.new(0.54, 0, 1, -8)
    guardArtwork.BackgroundTransparency = 1
    guardArtwork.Image = ""
    guardArtwork.ScaleType = Enum.ScaleType.Crop
    guardArtwork.ZIndex = 1011
    guardArtwork.Parent = hero
    self:SetImageFromAsset(guardArtwork, self.Config.Assets and self.Config.Assets.BannerGuards, nil)

    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "HeroLogo"
    logoImage.Position = UDim2.fromOffset(24, 30)
    logoImage.Size = UDim2.fromOffset(116, 116)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = ""
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 1014
    logoImage.Parent = hero
    self:SetImageFromAsset(logoImage, self.Config.Assets and self.Config.Assets.Logo, "SN")

    self:CreateText(hero, "WELCOME TO", UDim2.fromOffset(190, 26), UDim2.fromOffset(166, 36), {
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        Color = self.Colors.Text,
        ZIndex = 1014,
    })
    self:CreateText(hero, "SQUIDNOMO", UDim2.fromOffset(420, 48), UDim2.fromOffset(166, 60), {
        Font = Enum.Font.GothamBlack,
        TextSize = 34,
        Color = self.Colors.Text,
        ZIndex = 1014,
    })
    self:CreateText(hero, "THE ULTIMATE SQUID GAME EXPERIENCE", UDim2.fromOffset(480, 26), UDim2.fromOffset(166, 110), {
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Color = self.Colors.Accent,
        ZIndex = 1014,
    })

    local version = Instance.new("TextLabel")
    version.AnchorPoint = Vector2.new(1, 1)
    version.Position = UDim2.new(1, -16, 1, -16)
    version.Size = UDim2.fromOffset(90, 34)
    version.BackgroundColor3 = self.Colors.AccentDark
    version.BorderSizePixel = 0
    version.Font = Enum.Font.GothamBold
    version.Text = self.Version
    version.TextSize = 15
    version.TextColor3 = self.Colors.Text
    version.ZIndex = 1014
    version.Parent = hero
    makeCorner(version, 10)
end

function App:BuildFeatureStats(parent)
    local summary = self:GetFeatureOverview()

    local card = self:CreateCard(parent, UDim2.new(1, 0, 0, 276), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.08,
        Radius = 18,
    })
    card.LayoutOrder = 2

    self:CreateText(card, "FEATURE STATS", UDim2.fromOffset(220, 28), UDim2.fromOffset(18, 16), {
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })

    self:CreateText(card, "These stats update in real-time as you enable or disable features.", UDim2.new(1, -40, 0, 22), UDim2.fromOffset(18, 20), {
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Color = self.Colors.Muted,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    self:CreateFeatureStateCard(card, UDim2.fromOffset(18, 58), 0.33, self.Colors.Success, "FULLY ON", summary.FullyOn, summary.FullyPercent, "All features are enabled")
    self:CreateFeatureStateCard(card, UDim2.new(0.333, 8, 0, 58), 0.33, self.Colors.Warning, "PARTIALLY ON", summary.Partial, summary.PartialPercent, "Some features are enabled")
    self:CreateFeatureStateCard(card, UDim2.new(0.666, -2, 0, 58), 0.334, self.Colors.Error, "NOT ON", summary.Off, summary.OffPercent, "No features are enabled")

    self:CreateText(card, "FEATURE DISTRIBUTION", UDim2.fromOffset(220, 20), UDim2.fromOffset(18, 186), {
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })

    self:CreateText(card, "Total: " .. tostring(summary.Total), UDim2.fromOffset(120, 20), UDim2.new(1, -138, 0, 186), {
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Color = self.Colors.Text,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1013,
    })

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(18, 220)
    track.Size = UDim2.new(1, -36, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    track.BorderSizePixel = 0
    track.ZIndex = 1012
    track.Parent = card
    makeCorner(track, 12)
    makeStroke(track, self.Colors.BorderSoft, 1, 0.35)

    local segments = {
        {summary.FullyPercent / 100, self.Colors.Success, tostring(summary.FullyPercent) .. "%"},
        {summary.PartialPercent / 100, self.Colors.Warning, tostring(summary.PartialPercent) .. "%"},
        {summary.OffPercent / 100, self.Colors.Error, tostring(summary.OffPercent) .. "%"},
    }

    local x = 0
    for index, segment in ipairs(segments) do
        local bar = Instance.new("Frame")
        bar.Position = UDim2.new(x, 0, 0, 0)
        bar.Size = UDim2.new(segment[1], 0, 1, 0)
        bar.BackgroundColor3 = segment[2]
        bar.BorderSizePixel = 0
        bar.ZIndex = 1013
        bar.Parent = track
        if index == 1 or index == #segments then
            makeCorner(bar, 12)
        end
        self:CreateText(bar, segment[3], UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), {
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Color = Color3.fromRGB(255,255,255),
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1014,
        })
        x = x + segment[1]
    end
end

function App:BuildBottomStatsRow(parent)
    local row = self:CreateThreeColumnRow(parent, 208, 3)
    local left = self:CreateCard(row, UDim2.new(0.5, -6, 1, 0), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.14,
        Radius = 18,
    })
    left.LayoutOrder = 1

    local right = self:CreateCard(row, UDim2.new(0.5, -6, 1, 0), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.14,
        Radius = 18,
    })
    right.LayoutOrder = 2

    self:CreateText(left, "SERVER STATS", UDim2.fromOffset(220, 28), UDim2.fromOffset(20, 16), {
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })
    self:CreateText(right, "NOMO STATS", UDim2.fromOffset(220, 28), UDim2.fromOffset(20, 16), {
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Color = self.Colors.Accent,
        ZIndex = 1013,
    })

    local _, _, playersValue = self:CreateStatLine(left, 52, "Players Online", tostring(#Players:GetPlayers()), self.Colors.Text)
    local _, _, pingValue = self:CreateStatLine(left, 86, "Ping", "--", self.Colors.Text)
    local _, _, fpsValue = self:CreateStatLine(left, 120, "FPS", "--", self.Colors.Text)
    local _, _, uptimeValue = self:CreateStatLine(left, 154, "Uptime", "00:00", self.Colors.Success)

    local _, _, platformValue = self:CreateStatLine(right, 52, "Platform", UserInputService.TouchEnabled and "Mobile" or "Desktop", self.Colors.Text)
    local _, _, versionValue = self:CreateStatLine(right, 86, "Version", self.Version, self.Colors.Text)
    local _, _, loadedValue = self:CreateStatLine(right, 120, "Features Loaded", tostring(self:GetFeatureOverview().Total), self.Colors.Accent)
    local _, _, updateValue = self:CreateStatLine(right, 154, "Last Update", os.date("%b %d, %Y"), self.Colors.Text)

    task.spawn(function()
        local startedAt = os.clock()
        while left.Parent and right.Parent and self.Gui do
            task.wait(1)
            local ping = "--"
            local fps = "--"
            pcall(function()
                ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
            end)
            if self.Utilities and type(self.Utilities.GetFPS) == "function" then
                pcall(function()
                    fps = tostring(self.Utilities:GetFPS())
                end)
            end
            local elapsed = math.floor(os.clock() - startedAt)
            local uptime = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)

            playersValue.Text = tostring(#Players:GetPlayers())
            pingValue.Text = ping
            fpsValue.Text = fps
            uptimeValue.Text = uptime
            platformValue.Text = UserInputService.TouchEnabled and "Mobile" or "Desktop"
            versionValue.Text = self.Version
            loadedValue.Text = tostring(self:GetFeatureOverview().Total)
            updateValue.Text = os.date("%b %d, %Y")
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

    local overlay = Instance.new("Frame")
    overlay.Name = "TermsOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.38
    overlay.BorderSizePixel = 0
    overlay.Active = true
    overlay.ZIndex = 3000
    overlay.Parent = self.Window

    local modal = Instance.new("Frame")
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.fromScale(0.5, 0.52)
    modal.Size = self:IsMobile() and UDim2.fromOffset(600, 360) or UDim2.fromOffset(560, 350)
    modal.BackgroundColor3 = Color3.fromRGB(15, 11, 23)
    modal.BorderSizePixel = 0
    modal.ZIndex = 3001
    modal.Parent = overlay
    makeCorner(modal, 20)
    makeStroke(modal, self.Colors.Border, 1.5, 0.02)

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.fromOffset(26, 18)
    icon.Size = UDim2.fromOffset(80, 80)
    icon.Font = Enum.Font.SourceSansBold
    icon.Text = "⚠"
    icon.TextSize = 50
    icon.TextColor3 = self.Colors.Accent
    icon.ZIndex = 3002
    icon.Parent = modal

    self:CreateText(modal, "BEFORE YOU CONTINUE", UDim2.new(1, -130, 0, 44), UDim2.fromOffset(110, 28), {
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Color = self.Colors.Text,
        ZIndex = 3002,
    })

    local divider = Instance.new("Frame")
    divider.Position = UDim2.fromOffset(26, 94)
    divider.Size = UDim2.new(1, -52, 0, 1)
    divider.BackgroundColor3 = self.Colors.BorderSoft
    divider.BorderSizePixel = 0
    divider.ZIndex = 3002
    divider.Parent = modal

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(34, 112)
    body.Size = UDim2.new(1, -68, 0, 132)
    body.Font = Enum.Font.Gotham
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextSize = 14
    body.TextColor3 = self.Colors.Text
    body.Text = "This software may violate the game's Terms of Service and could result in account restrictions or other consequences.\n\nUse it entirely at your own risk. The developers are not responsible for account actions, data loss, interrupted functionality, or other outcomes resulting from its use."
    body.ZIndex = 3002
    body.Parent = modal

    local checkbox = Instance.new("TextButton")
    checkbox.Position = UDim2.fromOffset(34, 248)
    checkbox.Size = UDim2.fromOffset(28, 28)
    checkbox.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
    checkbox.BorderSizePixel = 0
    checkbox.AutoButtonColor = false
    checkbox.Text = ""
    checkbox.ZIndex = 3002
    checkbox.Parent = modal
    makeCorner(checkbox, 8)
    makeStroke(checkbox, self.Colors.Border, 1.2, 0.12)

    local check = Instance.new("TextLabel")
    check.BackgroundTransparency = 1
    check.Size = UDim2.fromScale(1, 1)
    check.Font = Enum.Font.GothamBold
    check.Text = "✓"
    check.TextSize = 19
    check.TextColor3 = self.Colors.Accent
    check.Visible = false
    check.ZIndex = 3003
    check.Parent = checkbox

    self:CreateText(modal, "I understand and accept these risks.", UDim2.new(1, -84, 0, 28), UDim2.fromOffset(74, 248), {
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Color = self.Colors.Text,
        ZIndex = 3002,
    })

    local exitButton = Instance.new("TextButton")
    exitButton.Position = UDim2.fromOffset(34, 294)
    exitButton.Size = UDim2.new(0.36, -10, 0, 42)
    exitButton.BackgroundColor3 = self.Colors.CardAlt
    exitButton.BorderSizePixel = 0
    exitButton.AutoButtonColor = false
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Text = "EXIT"
    exitButton.TextSize = 15
    exitButton.TextColor3 = self.Colors.Text
    exitButton.ZIndex = 3002
    exitButton.Parent = modal
    makeCorner(exitButton, 12)
    makeStroke(exitButton, self.Colors.BorderSoft, 1, 0.15)

    local continueButton = Instance.new("TextButton")
    continueButton.Position = UDim2.new(0.36, 8, 0, 294)
    continueButton.Size = UDim2.new(0.64, -42, 0, 42)
    continueButton.BackgroundColor3 = self.Colors.CardAlt
    continueButton.BorderSizePixel = 0
    continueButton.AutoButtonColor = false
    continueButton.Font = Enum.Font.GothamBold
    continueButton.Text = "I UNDERSTAND — CONTINUE"
    continueButton.TextSize = 15
    continueButton.TextColor3 = self.Colors.Text
    continueButton.ZIndex = 3002
    continueButton.Parent = modal
    makeCorner(continueButton, 12)
    local continueStroke = makeStroke(continueButton, self.Colors.BorderSoft, 1, 0.15)

    local accepted = false
    local function refresh()
        check.Visible = accepted
        continueButton.BackgroundColor3 = accepted and self.Colors.Accent or self.Colors.CardAlt
        continueButton.TextTransparency = accepted and 0 or 0.28
        continueStroke.Color = accepted and self.Colors.Accent or self.Colors.BorderSoft
    end

    checkbox.MouseButton1Click:Connect(function()
        accepted = not accepted
        refresh()
    end)

    exitButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    continueButton.MouseButton1Click:Connect(function()
        if not accepted then
            if self.Notifications and type(self.Notifications.Warning) == "function" then
                pcall(function()
                    self.Notifications:Warning("Terms", "Please accept the risks before continuing", 3)
                end)
            end
            return
        end

        self.TermsAccepted = true
        overlay:Destroy()
        self.TermsModal = nil
    self.SupportModal = nil
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
                    self:UpdateResponsive(false)
                end)
            end)
            table.insert(self.Connections, cameraConnection)
        end
    end

    bindCamera()

    self:Track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        bindCamera()
        task.defer(function()
            self:UpdateResponsive(false)
        end)
    end))

    self:Track(UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
        task.defer(function()
            self:UpdateResponsive(false)
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
    self:Destroy()
    self.ModuleErrors = {}

    local ok, err = xpcall(function()
        self:Init(loader or {})
        self:CreateGui()
        self:CreateWindow()
        self:CreateSidebar()
        self:CreateTopbar()
        self:CreatePageContainer()
        self:CreateReopenButton()
        self:BuildPageDefinitions()
        self:BuildPages()
        self:OpenPage("Home")
        self:UpdateResponsive(true)
        self:StartResponsive()
        self:CreateTermsModal()

        if self.Notifications and type(self.Notifications.Success) == "function" then
            pcall(function()
                self.Notifications:Success("SquidNoMo", "Universal app shell loaded")
            end)
        end
    end, function(message)
        return debug.traceback(tostring(message), 2)
    end)

    self._building = false

    if not ok then
        warn("[SquidNoMo] Launch failed: " .. tostring(err))
        self:Destroy()
        self:CreateEmergencyGui(err)
    end

    return self
end

function App:Destroy()
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
    self.PageContainer = nil
    self.ReopenButton = nil
    self.PageTitle = nil
    self.TermsModal = nil
    self.TermsAccepted = false
    self.Pages = {}
    self.PageDefinitions = {}
    self.NavigationButtons = {}
    self.AssetCache = {}
    self.CurrentPage = nil
    self.HasBeenDragged = false
    self.IsMinimized = false
    self.ReopenButtonHasBeenDragged = false
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
