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
App.Version = "Beta 5.0"
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
    SidebarWidth = 220,
    TopbarHeight = 46,
    CornerRadius = 18,

    -- Larger small text on touch devices without changing desktop typography.
    MobileTextBoost = true,

    -- The bottom status banner is intentionally removed on mobile and desktop
    -- to give the dashboard more usable vertical space.
    ShowHomeFooter = false,

    -- Set true only when testing mobile behavior in Studio device emulation.
    ForceMobile = false,
}

----------------------------------------------------------
-- Canonical palette from the approved rendering
----------------------------------------------------------

App.Colors = {
    Backdrop = Color3.fromRGB(7, 10, 9),
    Window = Color3.fromRGB(11, 15, 13),
    Sidebar = Color3.fromRGB(15, 20, 17),
    Topbar = Color3.fromRGB(14, 19, 16),
    Card = Color3.fromRGB(19, 25, 21),
    CardAlt = Color3.fromRGB(23, 31, 26),
    CardHover = Color3.fromRGB(29, 39, 33),
    Border = Color3.fromRGB(48, 66, 56),
    BorderSoft = Color3.fromRGB(33, 47, 40),
    Accent = Color3.fromRGB(0, 255, 143),
    AccentDark = Color3.fromRGB(0, 161, 91),
    AccentSoft = Color3.fromRGB(38, 112, 78),
    Pink = Color3.fromRGB(255, 66, 145),
    PinkDark = Color3.fromRGB(150, 38, 85),
    Warning = Color3.fromRGB(255, 190, 65),
    Error = Color3.fromRGB(255, 76, 76),
    Text = Color3.fromRGB(240, 248, 243),
    Muted = Color3.fromRGB(151, 170, 160),
    Dim = Color3.fromRGB(95, 112, 103),
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
    topbar.BorderSizePixel = 0
    topbar.Active = true
    topbar.ZIndex = 1020
    topbar.Parent = self.Window

    local divider = Instance.new("Frame")
    divider.AnchorPoint = Vector2.new(0, 1)
    divider.Position = UDim2.new(0, 0, 1, 0)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = self.Colors.BorderSoft
    divider.BorderSizePixel = 0
    divider.ZIndex = 1021
    divider.Parent = topbar

    local title = Instance.new("TextLabel")
    title.Name = "PageTitle"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(18, 0)
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "HOME"
    title.TextSize = 14
    title.TextColor3 = self.Colors.Muted
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 1022
    title.Parent = topbar
    self.PageTitle = title

    local statusDot = Instance.new("Frame")
    statusDot.AnchorPoint = Vector2.new(1, 0.5)
    statusDot.Position = UDim2.new(1, -116, 0.5, 0)
    statusDot.Size = UDim2.fromOffset(7, 7)
    statusDot.BackgroundColor3 = self.Colors.Accent
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 1022
    statusDot.Parent = topbar
    makeCorner(statusDot, 99)

    local status = Instance.new("TextLabel")
    status.AnchorPoint = Vector2.new(1, 0.5)
    status.Position = UDim2.new(1, -72, 0.5, 0)
    status.Size = UDim2.fromOffset(38, 18)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.Text = "READY"
    status.TextSize = 10
    status.TextColor3 = self.Colors.Accent
    status.ZIndex = 1022
    status.Parent = topbar

    if self:IsMobile() then
        statusDot.Visible = false
        status.Visible = false
    end

    local minimize = self:CreateTopbarButton(topbar, "—", self:IsMobile() and 70 or 62)
    local close = self:CreateTopbarButton(topbar, "×", self:IsMobile() and 20 or 18)

    minimize.MouseButton1Click:Connect(function()
        self:SetMinimized(true)
    end)

    close.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "DragHandle"
    dragHandle.Size = UDim2.new(1, -142, 1, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.BorderSizePixel = 0
    dragHandle.Active = true
    dragHandle.ZIndex = 1021
    dragHandle.Parent = topbar

    -- Keep the visible title above the transparent drag handle.
    title.ZIndex = 1022

    self.Topbar = topbar
    self:EnableDragging(dragHandle)
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
    local buttonSize = mobile and 64 or 58

    local button = Instance.new("TextButton")
    button.Name = "Reopen"
    button.Size = UDim2.fromOffset(buttonSize, buttonSize)
    button.BackgroundColor3 = self.Colors.Window
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBlack
    button.Text = "SN"
    button.TextSize = mobile and 19 or 17
    button.TextColor3 = self.Colors.Accent
    button.Visible = false
    button.Active = true
    button.ZIndex = 5000
    button.Parent = self.Gui
    makeCorner(button, 18)
    makeStroke(button, self.Colors.Accent, 2, 0.05)

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

    local logoTop = mobile and 12 or 18
    local logoSize = mobile and 40 or 44

    local logoMark = Instance.new("Frame")
    logoMark.Position = UDim2.fromOffset(16, logoTop)
    logoMark.Size = UDim2.fromOffset(logoSize, logoSize)
    logoMark.BackgroundColor3 = self.Colors.Accent
    logoMark.BorderSizePixel = 0
    logoMark.ZIndex = 1012
    logoMark.Parent = sidebar
    makeCorner(logoMark, 12)

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.fromScale(1, 1)
    logoText.BackgroundTransparency = 1
    logoText.Font = Enum.Font.GothamBlack
    logoText.Text = "S"
    logoText.TextSize = mobile and 23 or 25
    logoText.TextColor3 = self.Colors.Black
    logoText.ZIndex = 1013
    logoText.Parent = logoMark

    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Position = UDim2.fromOffset(68, mobile and 12 or 17)
    brand.Size = UDim2.new(1, -80, 0, 24)
    brand.Font = Enum.Font.GothamBlack
    brand.Text = "SQUIDNOMO"
    brand.TextSize = mobile and 16 or 17
    brand.TextColor3 = self.Colors.Text
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.ZIndex = 1012
    brand.Parent = sidebar

    local version = Instance.new("TextLabel")
    version.BackgroundTransparency = 1
    version.Position = UDim2.fromOffset(69, mobile and 35 or 42)
    version.Size = UDim2.new(1, -81, 0, 17)
    version.Font = Enum.Font.GothamMedium
    version.Text = self.Version .. "  •  MOBILE READY"
    version.TextSize = mobile and 9 or 9
    version.TextColor3 = self.Colors.Accent
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 1012
    version.Parent = sidebar

    local navLabel = Instance.new("TextLabel")
    navLabel.BackgroundTransparency = 1
    navLabel.Position = UDim2.fromOffset(16, mobile and 65 or 82)
    navLabel.Size = UDim2.new(1, -32, 0, 18)
    navLabel.Font = Enum.Font.GothamBold
    navLabel.Text = "NAVIGATION"
    navLabel.TextSize = mobile and 9 or 9
    navLabel.TextColor3 = self.Colors.Dim
    navLabel.TextXAlignment = Enum.TextXAlignment.Left
    navLabel.ZIndex = 1012
    navLabel.Parent = sidebar

    self.NavigationButtonHeight = mobile and 38 or 42
    self.NavigationButtonPadding = mobile and 2 or 4

    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.Position = UDim2.fromOffset(12, mobile and 84 or 103)
    nav.Size = UDim2.new(1, -24, 0, mobile and 318 or 370)
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

function App:CreateSidebarNotice(sidebar)
    local mobile = self:IsMobile()
    local noticeHeight = mobile and 204 or 210

    local notice = Instance.new("Frame")
    notice.Name = "ImportantNotice"
    notice.AnchorPoint = Vector2.new(0, 1)
    notice.Position = UDim2.new(0, 12, 1, -12)
    notice.Size = UDim2.new(1, -24, 0, noticeHeight)
    notice.BackgroundColor3 = Color3.fromRGB(31, 23, 16)
    notice.BorderSizePixel = 0
    notice.ZIndex = 1012
    notice.Parent = sidebar
    makeCorner(notice, 13)
    makeStroke(notice, self.Colors.Warning, 1.25, 0.12)

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Position = UDim2.fromOffset(13, 11)
    heading.Size = UDim2.new(1, -26, 0, 24)
    heading.Font = Enum.Font.GothamBold
    heading.Text = "!  IMPORTANT NOTICE"
    heading.TextSize = mobile and 12 or 11
    heading.TextColor3 = self.Colors.Warning
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.ZIndex = 1013
    heading.Parent = notice

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(13, 40)
    body.Size = UDim2.new(1, -26, 0, mobile and 118 or 124)
    body.Font = Enum.Font.Gotham
    body.Text = "Third-party tools may violate a game's Terms of Service. No feature can guarantee protection from detection or enforcement. You are responsible for how this software is used."
    body.TextWrapped = true
    body.TextSize = mobile and 11 or 10
    body.TextColor3 = self.Colors.Text
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.ZIndex = 1013
    body.Parent = notice

    local reminder = Instance.new("TextLabel")
    reminder.BackgroundTransparency = 1
    reminder.Position = UDim2.fromOffset(13, noticeHeight - 39)
    reminder.Size = UDim2.new(1, -26, 0, 28)
    reminder.Font = Enum.Font.GothamBold
    reminder.Text = "USE RESPONSIBLY • YOU ACCEPT ALL CONSEQUENCES"
    reminder.TextWrapped = true
    reminder.TextSize = mobile and 9 or 9
    reminder.TextColor3 = self.Colors.Warning
    reminder.TextXAlignment = Enum.TextXAlignment.Left
    reminder.TextYAlignment = Enum.TextYAlignment.Center
    reminder.ZIndex = 1013
    reminder.Parent = notice
end

function App:CreateNavigationButton(definition)
    local button = Instance.new("TextButton")
    button.Name = definition.Name
    local mobile = self:IsMobile()
    local buttonHeight = self.NavigationButtonHeight or 42
    button.Size = UDim2.new(1, 0, 0, buttonHeight)
    button.BackgroundColor3 = self.Colors.Sidebar
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = definition.Order or 0
    button.ZIndex = 1014
    button.Parent = self.NavigationHolder
    makeCorner(button, 11)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.Size = UDim2.fromOffset(3, 20)
    indicator.BackgroundColor3 = self.Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 1015
    indicator.Parent = button
    makeCorner(indicator, 99)

    local icon = Instance.new("Frame")
    local iconSize = mobile and 26 or 28
    icon.Position = UDim2.fromOffset(10, math.floor((buttonHeight - iconSize) / 2))
    icon.Size = UDim2.fromOffset(iconSize, iconSize)
    icon.BackgroundColor3 = self.Colors.CardAlt
    icon.BorderSizePixel = 0
    icon.ZIndex = 1015
    icon.Parent = button
    makeCorner(icon, 8)

    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.fromScale(1, 1)
    iconText.BackgroundTransparency = 1
    iconText.Font = Enum.Font.GothamBold
    iconText.Text = definition.Icon or string.sub(definition.Name, 1, 1)
    iconText.TextSize = mobile and 11 or 11
    iconText.TextColor3 = self.Colors.Muted
    iconText.ZIndex = 1016
    iconText.Parent = icon

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(48, 0)
    label.Size = UDim2.new(1, -58, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = definition.Name
    label.TextSize = mobile and 12 or 12
    label.TextColor3 = self.Colors.Muted
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1015
    label.Parent = button

    -- Roblox Instances cannot receive custom Lua methods.
    -- Keep selection behavior in a normal Lua closure instead.
    local function setSelected(selected)
        indicator.Visible = selected
        App:Tween(button, {
            BackgroundColor3 = selected and App.Colors.CardAlt or App.Colors.Sidebar,
        }, 0.16)
        App:Tween(icon, {
            BackgroundColor3 = selected and App.Colors.Accent or App.Colors.CardAlt,
        }, 0.16)
        App:Tween(iconText, {
            TextColor3 = selected and App.Colors.Black or App.Colors.Muted,
        }, 0.16)
        App:Tween(label, {
            TextColor3 = selected and App.Colors.Text or App.Colors.Muted,
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

    return button
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

    self:RegisterPage("Players", "P", function(page)
        self:BuildExternalPage(page, self.Loader.Players, "Players")
    end, 2)

    self:RegisterPage("Guards", "G", function(page)
        self:BuildExternalPage(page, self.Loader.Guards, "Guards")
    end, 3)

    self:RegisterPage("Detective", "D", function(page)
        self:BuildExternalPage(page, self.Loader.Detective, "Detective")
    end, 4)

    self:RegisterPage("Farming", "F", function(page)
        self:BuildExternalPage(page, self.Loader.Farming, "Farming")
    end, 5)

    self:RegisterPage("VIP", "V", function(page)
        self:BuildExternalPage(page, self.Loader.VIP, "VIP")
    end, 6)

    self:RegisterPage("Games", "M", function(page)
        self:BuildExternalPage(page, self.Loader.Games, "Games")
    end, 7)

    self:RegisterPage("Settings", "S", function(page)
        self:BuildExternalPage(page, self.Loader.Settings, "Settings")
    end, 8)

    -- Optional custom modules can register pages through Loader.Pages.
    if type(self.Loader.Pages) == "table" then
        for _, entry in ipairs(self.Loader.Pages) do
            if type(entry) == "table" and entry.Name then
                self:RegisterPage(
                    entry.Name,
                    entry.Icon,
                    entry.Builder,
                    entry.Order
                )
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

function App:BuildHome(page)
    local content = Instance.new("Frame")
    content.Name = "HomeContent"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 1007
    content.Parent = page

    makePadding(content, 16, 16, 14, 18)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content

    self:BuildHero(content)
    self:BuildPrimaryDashboardRow(content)
    self:BuildSupportRow(content)
    if self.Config.ShowHomeFooter then
        self:BuildFooter(content)
    end
end

function App:BuildHero(parent)
    local hero = self:CreateCard(parent, UDim2.new(1, 0, 0, 148), {
        Color = Color3.fromRGB(13, 27, 20),
        BorderColor = self.Colors.AccentDark,
        BorderTransparency = 0.10,
        Radius = 16,
    })
    hero.Name = "HeroBanner"
    hero.LayoutOrder = 1

    makeGradient(
        hero,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 45, 30)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(10, 24, 18)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 12, 10)),
        }),
        18
    )

    local glow = Instance.new("Frame")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.78, 0, 0.48, 0)
    glow.Size = UDim2.fromOffset(270, 270)
    glow.BackgroundColor3 = self.Colors.Accent
    glow.BackgroundTransparency = 0.87
    glow.BorderSizePixel = 0
    glow.ZIndex = 1011
    glow.Parent = hero
    makeCorner(glow, 999)

    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.80, 0, 0.50, 0)
    ring.Size = UDim2.fromOffset(170, 170)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.ZIndex = 1012
    ring.Parent = hero
    makeCorner(ring, 999)
    makeStroke(ring, self.Colors.Accent, 2, 0.18)

    local triangle = Instance.new("TextLabel")
    triangle.AnchorPoint = Vector2.new(0.5, 0.5)
    triangle.Position = UDim2.new(0.80, 0, 0.50, 0)
    triangle.Size = UDim2.fromOffset(110, 110)
    triangle.BackgroundTransparency = 1
    triangle.Font = Enum.Font.GothamBlack
    triangle.Text = "△"
    triangle.TextSize = 82
    triangle.TextColor3 = self.Colors.Accent
    triangle.TextTransparency = 0.08
    triangle.ZIndex = 1013
    triangle.Parent = hero

    self:CreatePill(
        hero,
        "BETA 5.0",
        self.Colors.Accent,
        UDim2.fromOffset(22, 18),
        82
    )

    self:CreateText(
        hero,
        "SQUIDNOMO",
        UDim2.fromOffset(500, 42),
        UDim2.fromOffset(22, 45),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = 31,
            Color = self.Colors.Text,
            ZIndex = 1014,
        }
    )

    self:CreateText(
        hero,
        "MODERN  •  RESPONSIVE  •  MODULAR",
        UDim2.fromOffset(520, 22),
        UDim2.fromOffset(24, 86),
        {
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            Color = self.Colors.Accent,
            ZIndex = 1014,
        }
    )

    self:CreateText(
        hero,
        "A complete floating control suite designed for desktop and touch devices.",
        UDim2.fromOffset(560, 22),
        UDim2.fromOffset(24, 112),
        {
            Font = Enum.Font.Gotham,
            TextSize = 10,
            Color = self.Colors.Muted,
            ZIndex = 1014,
        }
    )
end

function App:CreateThreeColumnRow(parent, height, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 1008
    row.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = row

    return row
end

function App:BuildPrimaryDashboardRow(parent)
    local row = self:CreateThreeColumnRow(parent, 218, 2)
    local width = UDim2.new(1 / 3, -8, 1, 0)

    local features = self:CreateCard(row, width, {
        BorderColor = self.Colors.AccentDark,
        BorderTransparency = 0.30,
    })
    features.LayoutOrder = 1
    self:CreateSectionTitle(features, "FEATURE GROUP CONTROLS", "Quick access to the complete suite")

    local featureNames = {
        {"PLAYERS", "Players", "P"},
        {"GUARDS + DETECTIVE", "Guards", "G"},
        {"FARMING + GAMES", "Farming", "F"},
        {"VIP + SETTINGS", "VIP", "V"},
    }

    for index, item in ipairs(featureNames) do
        local button = Instance.new("TextButton")
        button.Position = UDim2.fromOffset(14, 56 + ((index - 1) * 37))
        button.Size = UDim2.new(1, -28, 0, 31)
        button.BackgroundColor3 = self.Colors.CardAlt
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamMedium
        button.Text = "     " .. item[1]
        button.TextSize = 10
        button.TextColor3 = self.Colors.Text
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.ZIndex = 1013
        button.Parent = features
        makeCorner(button, 8)
        makeStroke(button, self.Colors.BorderSoft, 1, 0.35)

        local badge = Instance.new("TextLabel")
        badge.Position = UDim2.fromOffset(7, 5)
        badge.Size = UDim2.fromOffset(21, 21)
        badge.BackgroundColor3 = self.Colors.Accent
        badge.BorderSizePixel = 0
        badge.Font = Enum.Font.GothamBold
        badge.Text = item[3]
        badge.TextSize = 9
        badge.TextColor3 = self.Colors.Black
        badge.ZIndex = 1014
        badge.Parent = button
        makeCorner(badge, 6)

        button.MouseButton1Click:Connect(function()
            self:OpenPage(item[2])
        end)

        button.MouseEnter:Connect(function()
            self:Tween(button, {BackgroundColor3 = self.Colors.CardHover}, 0.12)
        end)

        button.MouseLeave:Connect(function()
            self:Tween(button, {BackgroundColor3 = self.Colors.CardAlt}, 0.12)
        end)
    end

    local status = self:CreateCard(row, width, {
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.30,
    })
    status.LayoutOrder = 2
    self:CreateSectionTitle(status, "SERVER STATUS", "Live client and session information")

    local rows = {
        {"CLIENT", "READY"},
        {"FPS", "--"},
        {"PING", "--"},
        {"PLAYERS", tostring(#Players:GetPlayers())},
        {"SERVER AGE", "00:00"},
    }

    local statusLabels = {}

    for index, item in ipairs(rows) do
        local y = 58 + ((index - 1) * 29)
        self:CreateText(status, item[1], UDim2.fromOffset(126, 21), UDim2.fromOffset(15, y), {
            Font = Enum.Font.GothamMedium,
            TextSize = 9,
            Color = self.Colors.Muted,
        })

        local value = self:CreateText(status, item[2], UDim2.new(1, -160, 0, 21), UDim2.fromOffset(145, y), {
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Color = self.Colors.Accent,
            XAlignment = Enum.TextXAlignment.Right,
        })
        statusLabels[item[1]] = value
    end

    task.spawn(function()
        local startedAt = os.clock()

        while status.Parent and self.Gui do
            task.wait(1)

            local fps = "--"
            local ping = "--"

            if self.Utilities and type(self.Utilities.GetFPS) == "function" then
                pcall(function()
                    fps = tostring(self.Utilities:GetFPS())
                end)
            end

            if self.Utilities and type(self.Utilities.GetPing) == "function" then
                pcall(function()
                    ping = tostring(self.Utilities:GetPing()) .. " ms"
                end)
            else
                pcall(function()
                    ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
                end)
            end

            if statusLabels.FPS then
                statusLabels.FPS.Text = fps
            end
            if statusLabels.PING then
                statusLabels.PING.Text = ping
            end
            if statusLabels.PLAYERS then
                statusLabels.PLAYERS.Text = tostring(#Players:GetPlayers())
            end
            if statusLabels["SERVER AGE"] then
                local elapsed = math.floor(os.clock() - startedAt)
                statusLabels["SERVER AGE"].Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
            end
        end
    end)

    local ai = self:CreateCard(row, width, {
        BorderColor = self.Colors.Accent,
        BorderTransparency = 0.20,
    })
    ai.LayoutOrder = 3
    self:CreateSectionTitle(ai, "NOMO AI", "Runtime assistant and module diagnostics")
    self:CreatePill(ai, "ONLINE", self.Colors.Accent, UDim2.new(1, -86, 0, 13), 72)

    local terminal = Instance.new("Frame")
    terminal.Position = UDim2.fromOffset(14, 60)
    terminal.Size = UDim2.new(1, -28, 0, 104)
    terminal.BackgroundColor3 = Color3.fromRGB(8, 13, 10)
    terminal.BorderSizePixel = 0
    terminal.ZIndex = 1012
    terminal.Parent = ai
    makeCorner(terminal, 10)
    makeStroke(terminal, self.Colors.BorderSoft, 1, 0.25)

    self:CreateText(terminal, "> APP SHELL INITIALIZED", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 10), {
        Font = Enum.Font.Code,
        TextSize = 10,
        Color = self.Colors.Accent,
    })
    self:CreateText(terminal, "> SAFE-ZONE SCALING ACTIVE", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 34), {
        Font = Enum.Font.Code,
        TextSize = 10,
        Color = self.Colors.Muted,
    })
    self:CreateText(terminal, "> TOUCH DRAGGING READY", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 58), {
        Font = Enum.Font.Code,
        TextSize = 10,
        Color = self.Colors.Muted,
    })
    self:CreateText(terminal, "> MODULE ERRORS: " .. tostring(self:GetModuleErrorCount()), UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 82), {
        Font = Enum.Font.Code,
        TextSize = 10,
        Color = self:GetModuleErrorCount() > 0 and self.Colors.Warning or self.Colors.Accent,
    })

    local diagnostics = Instance.new("TextButton")
    diagnostics.Position = UDim2.fromOffset(14, 174)
    diagnostics.Size = UDim2.new(1, -28, 0, 30)
    diagnostics.BackgroundColor3 = self.Colors.Accent
    diagnostics.BorderSizePixel = 0
    diagnostics.AutoButtonColor = false
    diagnostics.Font = Enum.Font.GothamBold
    diagnostics.Text = "OPEN SETTINGS"
    diagnostics.TextSize = 10
    diagnostics.TextColor3 = self.Colors.Black
    diagnostics.ZIndex = 1013
    diagnostics.Parent = ai
    makeCorner(diagnostics, 8)

    diagnostics.MouseButton1Click:Connect(function()
        self:OpenPage("Settings")
    end)
end

function App:BuildSupportRow(parent)
    local row = self:CreateThreeColumnRow(parent, 165, 3)
    local width = UDim2.new(1 / 3, -8, 1, 0)

    local support = self:CreateCard(row, width, {
        BorderColor = self.Colors.Pink,
        BorderTransparency = 0.12,
        Color = Color3.fromRGB(30, 18, 25),
    })
    support.LayoutOrder = 1
    self:CreateSectionTitle(support, "SUPPORT THE DEVELOPMENT", "Help maintain and improve the project")

    local heart = self:CreateText(support, "♥", UDim2.fromOffset(45, 45), UDim2.fromOffset(15, 61), {
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        Color = self.Colors.Pink,
        XAlignment = Enum.TextXAlignment.Center,
    })
    heart.TextYAlignment = Enum.TextYAlignment.Center

    self:CreateText(support, "Every contribution supports testing, UI work, and future modules.", UDim2.new(1, -82, 0, 47), UDim2.fromOffset(68, 61), {
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Color = self.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
    })

    local supportButton = Instance.new("TextButton")
    supportButton.Position = UDim2.fromOffset(14, 118)
    supportButton.Size = UDim2.new(1, -28, 0, 32)
    supportButton.BackgroundColor3 = self.Colors.Pink
    supportButton.BorderSizePixel = 0
    supportButton.AutoButtonColor = false
    supportButton.Font = Enum.Font.GothamBold
    supportButton.Text = "SUPPORT PROJECT"
    supportButton.TextSize = 10
    supportButton.TextColor3 = self.Colors.Text
    supportButton.ZIndex = 1013
    supportButton.Parent = support
    makeCorner(supportButton, 9)

    local goal = self:CreateCard(row, width, {
        BorderColor = self.Colors.PinkDark,
        BorderTransparency = 0.18,
        Color = Color3.fromRGB(25, 20, 23),
    })
    goal.LayoutOrder = 2
    self:CreateSectionTitle(goal, "MONTHLY DEVELOPMENT GOAL", "Progress toward hosting and development costs")

    local progressText = self:CreateText(goal, "$0  /  $100", UDim2.new(1, -28, 0, 24), UDim2.fromOffset(14, 69), {
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Color = self.Colors.Text,
    })
    progressText.TextXAlignment = Enum.TextXAlignment.Center

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(14, 105)
    track.Size = UDim2.new(1, -28, 0, 10)
    track.BackgroundColor3 = self.Colors.CardAlt
    track.BorderSizePixel = 0
    track.ZIndex = 1012
    track.Parent = goal
    makeCorner(track, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.08, 0, 1, 0)
    fill.BackgroundColor3 = self.Colors.Pink
    fill.BorderSizePixel = 0
    fill.ZIndex = 1013
    fill.Parent = track
    makeCorner(fill, 99)

    self:CreateText(goal, "Goal resets monthly", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 126), {
        Font = Enum.Font.Gotham,
        TextSize = 9,
        Color = self.Colors.Muted,
        XAlignment = Enum.TextXAlignment.Center,
    })

    local supporters = self:CreateCard(row, width, {
        BorderColor = self.Colors.Border,
        BorderTransparency = 0.25,
    })
    supporters.LayoutOrder = 3
    self:CreateSectionTitle(supporters, "LATEST SUPPORTERS", "Thank you for helping the project grow")

    local names = {
        {"Anonymous", "FOUNDING SUPPORTER"},
        {"Community", "TESTING + FEEDBACK"},
        {"You", "NEXT SUPPORTER"},
    }

    for index, entry in ipairs(names) do
        local y = 59 + ((index - 1) * 33)
        local avatar = Instance.new("Frame")
        avatar.Position = UDim2.fromOffset(14, y)
        avatar.Size = UDim2.fromOffset(25, 25)
        avatar.BackgroundColor3 = index == 3 and self.Colors.PinkDark or self.Colors.AccentDark
        avatar.BorderSizePixel = 0
        avatar.ZIndex = 1012
        avatar.Parent = supporters
        makeCorner(avatar, 8)

        self:CreateText(avatar, string.sub(entry[1], 1, 1), UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), {
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Color = self.Colors.Text,
            XAlignment = Enum.TextXAlignment.Center,
        })

        self:CreateText(supporters, entry[1], UDim2.new(1, -60, 0, 15), UDim2.fromOffset(48, y - 1), {
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Color = self.Colors.Text,
        })

        self:CreateText(supporters, entry[2], UDim2.new(1, -60, 0, 13), UDim2.fromOffset(48, y + 12), {
            Font = Enum.Font.Gotham,
            TextSize = 8,
            Color = self.Colors.Muted,
        })
    end
end

function App:BuildFooter(parent)
    local footer = self:CreateCard(parent, UDim2.new(1, 0, 0, 54), {
        Color = Color3.fromRGB(13, 18, 15),
        BorderColor = self.Colors.BorderSoft,
        BorderTransparency = 0.30,
    })
    footer.LayoutOrder = 4

    self:CreateText(footer, "SQUIDNOMO  •  " .. self.Version, UDim2.fromOffset(300, 54), UDim2.fromOffset(16, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Color = self.Colors.Muted,
    })

    self:CreateText(footer, "FLOATING  •  TOUCH READY  •  UNIVERSAL", UDim2.new(1, -332, 0, 54), UDim2.fromOffset(316, 0), {
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Color = self.Colors.Accent,
        XAlignment = Enum.TextXAlignment.Right,
    })
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
    self.Pages = {}
    self.PageDefinitions = {}
    self.NavigationButtons = {}
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
