--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Core/App.lua
--// Responsive application shell matching the approved dashboard.
--//========================================================--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local App = {}
App.__index = App

App.Name = "SquidNoMo"
App.Version = "v0.5.0 Beta"
App.DisplayOrder = 999999

----------------------------------------------------------
-- Primitive helpers
----------------------------------------------------------

local function makeCorner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
    return item
end

local function makeStroke(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = parent
    return item
end

local function makePadding(parent, left, right, top, bottom)
    local item = Instance.new("UIPadding")
    item.PaddingLeft = UDim.new(0, left or 0)
    item.PaddingRight = UDim.new(0, right or 0)
    item.PaddingTop = UDim.new(0, top or 0)
    item.PaddingBottom = UDim.new(0, bottom or 0)
    item.Parent = parent
    return item
end

local function makeGradient(parent, colors, rotation, transparency)
    local item = Instance.new("UIGradient")
    item.Color = colors
    item.Rotation = rotation or 0
    if transparency then
        item.Transparency = transparency
    end
    item.Parent = parent
    return item
end

local function vector2FromPosition(position)
    return Vector2.new(position.X.Offset, position.Y.Offset)
end

local function isGuiObject(value)
    return typeof(value) == "Instance" and value:IsA("GuiObject")
end

----------------------------------------------------------
-- Lifecycle and state
----------------------------------------------------------

function App.new()
    local self = setmetatable({}, App)

    self.Loader = nil
    self.Theme = nil
    self.Icons = nil
    self.Components = nil
    self.Notifications = nil
    self.Features = nil
    self.FeatureRegistry = nil
    self.RuntimeStats = nil

    self.Gui = nil
    self.Host = nil
    self.Window = nil
    self.WindowScale = nil
    self.Sidebar = nil
    self.PageContainer = nil
    self.ReopenButton = nil

    self.Pages = {}
    self.NavigationButtons = {}
    self.PageDefinitions = {}
    self.Connections = {}
    self.ModuleErrors = {}

    self.CurrentPage = nil
    self.IsMinimized = false
    self.HasBeenDragged = false
    self.ReopenButtonDragged = false

    self.CurrentScale = 1
    self.CurrentSafePosition = Vector2.new(0, 0)
    self.CurrentSafeSize = Vector2.new(1, 1)
    self.CurrentVisualSize = Vector2.new(1, 1)

    return self
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
        warn(string.format("[SquidNoMo] %s failed:\n%s", tostring(label), tostring(result)))
    end

    return ok, result
end

function App:GetErrorCount()
    local count = 0

    for _ in pairs(self.ModuleErrors) do
        count = count + 1
    end

    if self.FeatureRegistry and type(self.FeatureRegistry.GetReadErrorCount) == "function" then
        count = count + self.FeatureRegistry:GetReadErrorCount()
    end

    return count
end

function App:Notify(kind, title, message, duration)
    local notifications = self.Notifications

    if not notifications then
        return
    end

    local method = notifications[kind]
    if type(method) == "function" then
        pcall(function()
            method(notifications, title, message, duration or 3)
        end)
    end
end

----------------------------------------------------------
-- Public UI helpers used by page modules
----------------------------------------------------------

function App:CreateFrame(parent, size, position, color, options)
    options = options or {}

    local item = Instance.new("Frame")
    item.Size = size
    item.Position = position or UDim2.fromOffset(0, 0)
    item.BackgroundColor3 = color or self.Theme.Card
    item.BackgroundTransparency = options.Transparency or 0
    item.BorderSizePixel = 0
    item.ClipsDescendants = options.ClipsDescendants or false
    item.Active = options.Active or false
    item.ZIndex = options.ZIndex or 1
    item.Parent = parent

    if options.Radius then
        makeCorner(item, options.Radius)
    end

    if options.StrokeColor then
        makeStroke(
            item,
            options.StrokeColor,
            options.StrokeThickness or 1,
            options.StrokeTransparency or 0
        )
    end

    return item
end

function App:CreateCard(parent, size, options)
    options = options or {}

    return self:CreateFrame(
        parent,
        size,
        options.Position,
        options.Color or self.Theme.Card,
        {
            Radius = options.Radius or self.Theme.CardRadius,
            StrokeColor = options.StrokeColor or self.Theme.Border,
            StrokeThickness = options.StrokeThickness or 1,
            StrokeTransparency = options.StrokeTransparency or 0.20,
            Transparency = options.Transparency or 0,
            ClipsDescendants = options.ClipsDescendants or false,
            Active = options.Active or false,
            ZIndex = options.ZIndex or 10,
        }
    )
end

function App:CreateText(parent, text, size, position, options)
    options = options or {}

    local item = Instance.new("TextLabel")
    item.Size = size
    item.Position = position or UDim2.fromOffset(0, 0)
    item.BackgroundTransparency = 1
    item.BorderSizePixel = 0
    item.Font = options.Font or self.Theme.Font
    item.Text = tostring(text or "")
    item.TextSize = options.TextSize or 14
    item.TextColor3 = options.Color or self.Theme.Text
    item.TextTransparency = options.TextTransparency or 0
    item.TextWrapped = options.Wrapped or false
    item.RichText = options.RichText or false
    item.TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left
    item.TextYAlignment = options.YAlignment or Enum.TextYAlignment.Center
    item.ZIndex = options.ZIndex or 20
    item.Parent = parent

    if options.AutomaticSize then
        item.AutomaticSize = options.AutomaticSize
    end

    return item
end

function App:CreateButton(parent, text, size, position, options)
    options = options or {}

    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position or UDim2.fromOffset(0, 0)
    button.BackgroundColor3 = options.Color or self.Theme.Accent
    button.BackgroundTransparency = options.Transparency or 0
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = options.Font or self.Theme.FontBold
    button.Text = tostring(text or "")
    button.TextSize = options.TextSize or 14
    button.TextColor3 = options.TextColor or self.Theme.Black
    button.ZIndex = options.ZIndex or 30
    button.Parent = parent
    makeCorner(button, options.Radius or self.Theme.ButtonRadius)

    if options.StrokeColor then
        makeStroke(button, options.StrokeColor, options.StrokeThickness or 1, options.StrokeTransparency or 0)
    end

    local baseColor = button.BackgroundColor3
    local hoverColor = options.HoverColor or self.Theme.AccentHover

    self:Track(button.MouseEnter:Connect(function()
        self:Tween(button, {BackgroundColor3 = hoverColor}, 0.12)
    end))

    self:Track(button.MouseLeave:Connect(function()
        self:Tween(button, {BackgroundColor3 = baseColor}, 0.12)
    end))

    return button
end

function App:CreateStatusRow(parent, iconName, labelText, valueText, order)
    local row = self:CreateFrame(
        parent,
        UDim2.new(1, 0, 0, 36),
        nil,
        self.Theme.Row,
        {
            Radius = 8,
            StrokeColor = self.Theme.BorderSoft,
            StrokeTransparency = 0.42,
            ZIndex = 15,
        }
    )
    row.LayoutOrder = order or 0

    local iconHolder = self:CreateFrame(
        row,
        UDim2.fromOffset(24, 24),
        UDim2.fromOffset(10, 6),
        self.Theme.Accent,
        {
            Transparency = 1,
            ZIndex = 17,
        }
    )
    self.Icons:Create(iconHolder, iconName, 22, self.Theme.Text, 18)

    self:CreateText(row, labelText, UDim2.new(0.50, -8, 1, 0), UDim2.fromOffset(42, 0), {
        Font = self.Theme.FontMedium,
        TextSize = 14,
        Color = self.Theme.Text,
        ZIndex = 18,
    })

    local value = self:CreateText(row, valueText, UDim2.new(0.48, -12, 1, 0), UDim2.new(0.52, 0, 0, 0), {
        Font = self.Theme.FontMedium,
        TextSize = 14,
        Color = self.Theme.Accent,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 18,
    })

    return row, value
end

----------------------------------------------------------
-- Screen placement and responsiveness
----------------------------------------------------------

function App:GetViewportSize()
    local camera = workspace.CurrentCamera

    if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
        return camera.ViewportSize
    end

    return Vector2.new(1280, 720)
end

function App:IsMobile()
    return UserInputService.TouchEnabled
end

function App:GetSafeRect()
    local viewport = self:GetViewportSize()
    local mobile = self:IsMobile()
    local landscape = viewport.X >= viewport.Y
    local margins

    if mobile and landscape then
        margins = self.Theme.MobileLandscapeMargins
    elseif mobile then
        margins = self.Theme.MobilePortraitMargins
    else
        margins = self.Theme.DesktopMargins
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
        math.max(320, math.floor(viewport.X - left - right)),
        math.max(260, math.floor(viewport.Y - top - bottom))
    )

    return position, size
end

function App:CalculateScale()
    local safePosition, safeSize = self:GetSafeRect()
    local designWidth = self.Theme.DesignWidth
    local designHeight = self.Theme.DesignHeight

    local scale = math.min(safeSize.X / designWidth, safeSize.Y / designHeight)
    scale = math.clamp(scale, 0.46, 1.25)

    local visualSize = Vector2.new(
        math.floor(designWidth * scale),
        math.floor(designHeight * scale)
    )

    return scale, safePosition, safeSize, visualSize
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

    local scale, safePosition, safeSize, visualSize = self:CalculateScale()

    self.CurrentScale = scale
    self.CurrentSafePosition = safePosition
    self.CurrentSafeSize = safeSize
    self.CurrentVisualSize = visualSize

    self.Window.Size = UDim2.fromOffset(self.Theme.DesignWidth, self.Theme.DesignHeight)
    self.WindowScale.Scale = scale
    self.Host.Size = UDim2.fromOffset(visualSize.X, visualSize.Y)

    local position

    if forceCenter or not self.HasBeenDragged then
        position = Vector2.new(
            safePosition.X + ((safeSize.X - visualSize.X) / 2),
            safePosition.Y + ((safeSize.Y - visualSize.Y) / 2)
        )
    else
        position = self:ClampHostPosition(vector2FromPosition(self.Host.Position))
    end

    self.Host.Position = UDim2.fromOffset(math.floor(position.X), math.floor(position.Y))
    self:PositionReopenButton(false)
end

function App:StartResponsive()
    local camera = workspace.CurrentCamera

    if camera then
        self:Track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            self:UpdateResponsive(false)
        end))
    end

    self:Track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        task.defer(function()
            self:UpdateResponsive(false)
        end)
    end))

    self:UpdateResponsive(true)
end

----------------------------------------------------------
-- GUI creation
----------------------------------------------------------

function App:GetGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            return playerGui
        end
    end

    if CoreGui then
        return CoreGui
    end

    return nil
end

function App:DestroyOldCopies()
    local parents = {CoreGui}

    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            table.insert(parents, playerGui)
        end
    end

    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            table.insert(parents, result)
        end
    end

    for _, parent in ipairs(parents) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == self.Name and child:IsA("ScreenGui") then
                    child:Destroy()
                end
            end
        end
    end
end

function App:CreateGui()
    self:DestroyOldCopies()

    local gui = Instance.new("ScreenGui")
    gui.Name = self.Name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = self.DisplayOrder
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    pcall(function()
        gui.ScreenInsets = Enum.ScreenInsets.None
        gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
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
            self.Notifications.Container = nil
            self.Notifications:Init(gui, self.Theme)
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

    local window = self:CreateFrame(
        host,
        UDim2.fromOffset(self.Theme.DesignWidth, self.Theme.DesignHeight),
        UDim2.fromOffset(0, 0),
        self.Theme.Window,
        {
            Radius = self.Theme.WindowRadius,
            StrokeColor = self.Theme.Border,
            StrokeThickness = 1.3,
            StrokeTransparency = 0.05,
            ClipsDescendants = true,
            Active = true,
            ZIndex = 1001,
        }
    )
    window.Name = "Window"

    local scale = Instance.new("UIScale")
    scale.Name = "ResponsiveScale"
    scale.Scale = 1
    scale.Parent = window

    self.Window = window
    self.WindowScale = scale
end

----------------------------------------------------------
-- Dragging and minimize behavior
----------------------------------------------------------

function App:EnableDragging(target)
    local dragging = false
    local activeInput = nil
    local startInput = nil
    local startPosition = nil

    self:Track(target.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        activeInput = input
        startInput = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = vector2FromPosition(self.Host.Position)
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeInput then
            return
        end

        local valid = input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement)

        if not valid then
            return
        end

        local current = Vector2.new(input.Position.X, input.Position.Y)
        local delta = current - startInput
        local targetPosition = self:ClampHostPosition(startPosition + delta)

        self.Host.Position = UDim2.fromOffset(targetPosition.X, targetPosition.Y)
        self.HasBeenDragged = true
    end))

    self:Track(UserInputService.InputEnded:Connect(function(input)
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
    local size = self.ReopenButton and self.ReopenButton.AbsoluteSize.X or 68
    local padding = 8

    return Vector2.new(
        math.clamp(position.X, padding, math.max(padding, viewport.X - size - padding)),
        math.clamp(position.Y, padding, math.max(padding, viewport.Y - size - padding))
    )
end

function App:EnableReopenDragging(button)
    local dragging = false
    local activeInput = nil
    local startInput = nil
    local startPosition = nil
    local moved = false

    self:Track(button.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        activeInput = input
        moved = false
        startInput = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = vector2FromPosition(button.Position)
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeInput then
            return
        end

        local valid = input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement)

        if not valid then
            return
        end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - startInput
        if delta.Magnitude >= 7 then
            moved = true
        end

        local targetPosition = self:ClampReopenButtonPosition(startPosition + delta)
        button.Position = UDim2.fromOffset(targetPosition.X, targetPosition.Y)
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

            if moved then
                self.ReopenButtonDragged = true
            else
                self:SetMinimized(not self.IsMinimized)
            end
        end
    end))
end

function App:CreateReopenButton()
    local size = self:IsMobile() and 72 or 66

    local button = Instance.new("TextButton")
    button.Name = "ReopenButton"
    button.Size = UDim2.fromOffset(size, size)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Active = true
    button.Visible = true
    button.ZIndex = 5000
    button.Parent = self.Gui

    self.Icons:CreateLogo(button, size, {
        Color = self.Theme.Accent,
        BackgroundColor = self.Theme.Window,
        Glow = true,
        ZIndex = 5001,
    })

    self.ReopenButton = button
    self:EnableReopenDragging(button)
end

function App:PositionReopenButton(forceDefault)
    if not self.ReopenButton then
        return
    end

    if self.ReopenButtonDragged and not forceDefault then
        local current = vector2FromPosition(self.ReopenButton.Position)
        local clamped = self:ClampReopenButtonPosition(current)
        self.ReopenButton.Position = UDim2.fromOffset(clamped.X, clamped.Y)
        return
    end

    local target = Vector2.new(10, 10)
    target = self:ClampReopenButtonPosition(target)
    self.ReopenButton.Position = UDim2.fromOffset(target.X, target.Y)
end

function App:SetMinimized(state)
    self.IsMinimized = state and true or false

    if self.Host then
        self.Host.Visible = not self.IsMinimized
    end

    if self.ReopenButton then
        self.ReopenButton.Visible = true
        self:PositionReopenButton(false)
    end
end

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

function App:CreateSidebar()
    local sidebar = self:CreateFrame(
        self.Window,
        UDim2.new(0, self.Theme.SidebarWidth, 1, 0),
        UDim2.fromOffset(0, 0),
        self.Theme.Sidebar,
        {
            ZIndex = 1010,
        }
    )
    sidebar.Name = "Sidebar"

    local divider = self:CreateFrame(
        sidebar,
        UDim2.new(0, 1, 1, 0),
        UDim2.new(1, -1, 0, 0),
        self.Theme.Border,
        {
            Transparency = 0.35,
            ZIndex = 1012,
        }
    )
    divider.Name = "Divider"

    local logo = self.Icons:CreateLogo(sidebar, 78, {
        Position = UDim2.fromOffset(24, 18),
        Color = self.Theme.Accent,
        BackgroundColor = self.Theme.Window,
        Glow = true,
        ZIndex = 1014,
    })

    self:CreateText(sidebar, "SQUIDNOMO", UDim2.new(1, -132, 0, 34), UDim2.fromOffset(118, 28), {
        Font = self.Theme.FontBlack,
        TextSize = 25,
        Color = self.Theme.Text,
        ZIndex = 1015,
    })

    self:CreateText(sidebar, "VERSION: 0.5.0 BETA", UDim2.new(1, -132, 0, 22), UDim2.fromOffset(120, 62), {
        Font = self.Theme.FontBold,
        TextSize = 12,
        Color = self.Theme.Accent,
        ZIndex = 1015,
    })

    local brandDrag = self:CreateFrame(
        sidebar,
        UDim2.new(1, -12, 0, 106),
        UDim2.fromOffset(0, 0),
        self.Theme.Sidebar,
        {
            Transparency = 1,
            Active = true,
            ZIndex = 1022,
        }
    )
    brandDrag.Name = "BrandDragHandle"
    self:EnableDragging(brandDrag)

    logo.ZIndex = 1014

    local nav = self:CreateFrame(
        sidebar,
        UDim2.new(1, -34, 0, 424),
        UDim2.fromOffset(17, 112),
        self.Theme.Sidebar,
        {
            Transparency = 1,
            ZIndex = 1013,
        }
    )
    nav.Name = "Navigation"

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = nav

    self.Sidebar = sidebar
    self.NavigationHolder = nav

    self:CreateSidebarWarning(sidebar)
    self:CreateSidebarSupport(sidebar)
end

function App:CreateSidebarWarning(sidebar)
    local card = self:CreateCard(sidebar, UDim2.new(1, -34, 0, 132), {
        Position = UDim2.fromOffset(17, 542),
        Color = Color3.fromRGB(27, 10, 14),
        StrokeColor = self.Theme.Error,
        StrokeTransparency = 0.02,
        Radius = 14,
        ZIndex = 1015,
    })

    local iconHolder = self:CreateFrame(card, UDim2.fromOffset(46, 46), UDim2.fromOffset(16, 10), self.Theme.Error, {
        Transparency = 1,
        ZIndex = 1017,
    })
    self.Icons:CreateTriangleStatus(iconHolder, 42, self.Theme.ErrorBright, 1018)
    self:CreateText(iconHolder, "!", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 3), {
        Font = self.Theme.FontBlack,
        TextSize = 20,
        Color = self.Theme.ErrorBright,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1020,
    })

    self:CreateText(card, "WARNING", UDim2.new(1, -84, 0, 36), UDim2.fromOffset(68, 14), {
        Font = self.Theme.FontBlack,
        TextSize = 22,
        Color = self.Theme.ErrorBright,
        ZIndex = 1018,
    })

    self:CreateText(card, "We are not responsible for\nyour account or any outcomes.", UDim2.new(1, -32, 0, 48), UDim2.fromOffset(16, 54), {
        Font = self.Theme.FontMedium,
        TextSize = 14,
        Color = self.Theme.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1018,
    })

    self:CreateText(card, "Use at your own risk.", UDim2.new(1, -32, 0, 24), UDim2.fromOffset(16, 101), {
        Font = self.Theme.FontBold,
        TextSize = 15,
        Color = self.Theme.ErrorBright,
        ZIndex = 1018,
    })
end

function App:CreateSidebarSupport(sidebar)
    local card = self:CreateCard(sidebar, UDim2.new(1, -34, 0, 138), {
        Position = UDim2.fromOffset(17, 687),
        Color = Color3.fromRGB(24, 11, 24),
        StrokeColor = self.Theme.Pink,
        StrokeTransparency = 0.18,
        Radius = 14,
        ZIndex = 1015,
    })

    local heart = self:CreateText(card, "♥", UDim2.fromOffset(40, 36), UDim2.fromOffset(16, 12), {
        Font = self.Theme.FontBlack,
        TextSize = 30,
        Color = self.Theme.PinkBright,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1018,
    })
    heart.TextYAlignment = Enum.TextYAlignment.Center

    self:CreateText(card, "SUPPORT THE DEVELOPMENT", UDim2.new(1, -68, 0, 30), UDim2.fromOffset(58, 14), {
        Font = self.Theme.FontBold,
        TextSize = 13,
        Color = self.Theme.Text,
        ZIndex = 1018,
    })

    self:CreateText(card, "Your support helps keep servers\nrunning and funds future updates.", UDim2.new(1, -32, 0, 42), UDim2.fromOffset(16, 48), {
        Font = self.Theme.FontMedium,
        TextSize = 12,
        Color = self.Theme.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1018,
    })

    local button = self:CreateButton(card, "♥  SUPPORT PROJECT", UDim2.new(1, -32, 0, 38), UDim2.fromOffset(16, 91), {
        Color = self.Theme.Pink,
        HoverColor = self.Theme.PinkBright,
        TextColor = self.Theme.Text,
        TextSize = 13,
        Radius = 9,
        ZIndex = 1019,
    })

    self:Track(button.MouseButton1Click:Connect(function()
        local supportUrl = self.Loader.Config and self.Loader.Config.SupportUrl

        if type(supportUrl) == "string" and supportUrl ~= "" and type(setclipboard) == "function" then
            pcall(setclipboard, supportUrl)
            self:Notify("Success", "Support", "Support link copied to your clipboard.", 3)
        else
            self:Notify("Info", "Support", "A support link has not been configured yet.", 3)
        end
    end))
end

function App:RenderNavigationIcon(iconRoot, name, color)
    iconRoot:ClearAllChildren()
    self.Icons:Create(iconRoot, name, 30, color, 1020)
end

function App:CreateNavigationButton(definition)
    local button = Instance.new("TextButton")
    button.Name = definition.Name
    button.Size = UDim2.new(1, 0, 0, 49)
    button.BackgroundColor3 = self.Theme.CardAlt
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = definition.Order
    button.ZIndex = 1017
    button.Parent = self.NavigationHolder
    makeCorner(button, 11)
    makeStroke(button, self.Theme.BorderSoft, 1, 0.55)

    local iconBox = self:CreateFrame(button, UDim2.fromOffset(38, 38), UDim2.fromOffset(8, 5), self.Theme.CardAlt, {
        Radius = 9,
        Transparency = 0,
        ZIndex = 1018,
    })

    local iconRoot = self:CreateFrame(iconBox, UDim2.fromOffset(30, 30), UDim2.fromOffset(4, 4), self.Theme.CardAlt, {
        Transparency = 1,
        ZIndex = 1019,
    })

    local label = self:CreateText(button, definition.Name, UDim2.new(1, -62, 1, 0), UDim2.fromOffset(58, 0), {
        Font = self.Theme.FontMedium,
        TextSize = 16,
        Color = self.Theme.Text,
        ZIndex = 1019,
    })

    local function setSelected(selected)
        if selected then
            self:Tween(button, {
                BackgroundColor3 = Color3.fromRGB(0, 76, 38),
                BackgroundTransparency = 0.04,
            }, 0.16)
            self:Tween(iconBox, {BackgroundColor3 = self.Theme.Accent}, 0.16)
            self:Tween(label, {TextColor3 = self.Theme.Text}, 0.16)
            self:RenderNavigationIcon(iconRoot, definition.Icon, self.Theme.Black)
        else
            self:Tween(button, {
                BackgroundColor3 = self.Theme.CardAlt,
                BackgroundTransparency = 1,
            }, 0.16)
            self:Tween(iconBox, {BackgroundColor3 = self.Theme.CardAlt}, 0.16)
            self:Tween(label, {TextColor3 = self.Theme.Text}, 0.16)
            self:RenderNavigationIcon(iconRoot, definition.Icon, self.Theme.SubText)
        end
    end

    self:RenderNavigationIcon(iconRoot, definition.Icon, self.Theme.SubText)

    self:Track(button.MouseEnter:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {BackgroundTransparency = 0.25}, 0.12)
        end
    end))

    self:Track(button.MouseLeave:Connect(function()
        if self.CurrentPage ~= definition.Name then
            self:Tween(button, {BackgroundTransparency = 1}, 0.12)
        end
    end))

    self:Track(button.MouseButton1Click:Connect(function()
        self:OpenPage(definition.Name)
    end))

    self.NavigationButtons[definition.Name] = {
        Button = button,
        SetSelected = setSelected,
    }
end

----------------------------------------------------------
-- Pages
----------------------------------------------------------

function App:CreatePageContainer()
    local container = self:CreateFrame(
        self.Window,
        UDim2.new(1, -self.Theme.SidebarWidth, 1, 0),
        UDim2.fromOffset(self.Theme.SidebarWidth, 0),
        self.Theme.Background,
        {
            ZIndex = 1005,
            ClipsDescendants = true,
        }
    )
    container.Name = "PageContainer"
    self.PageContainer = container
end

function App:RegisterPage(name, icon, module, order, fixed)
    table.insert(self.PageDefinitions, {
        Name = name,
        Icon = icon,
        Module = module,
        Order = order,
        Fixed = fixed or false,
    })
end

function App:BuildPageDefinitions()
    self.PageDefinitions = {}

    self:RegisterPage("Home", "Home", self.Loader.Home, 1, true)
    self:RegisterPage("Games", "Games", self.Loader.Games, 2)
    self:RegisterPage("Players", "Players", self.Loader.Players, 3)
    self:RegisterPage("Guards", "Guards", self.Loader.Guards, 4)
    self:RegisterPage("Detective", "Detective", self.Loader.Detective, 5)
    self:RegisterPage("Farming", "Farming", self.Loader.Farming, 6)
    self:RegisterPage("UI", "UI", self.Loader.UI, 7)
    self:RegisterPage("Settings", "Settings", self.Loader.Settings, 8)
end

function App:CreatePage(definition)
    local page

    if definition.Fixed then
        page = Instance.new("Frame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
    else
        page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.CanvasSize = UDim2.fromOffset(0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = self.Theme.AccentDark
        page.ScrollBarImageTransparency = 0.15
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        page.Active = true

        makePadding(page, 16, 16, 16, 16)

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = page
    end

    page.Name = definition.Name
    page.Visible = false
    page.ZIndex = 1006
    page.Parent = self.PageContainer

    self.Pages[definition.Name] = page
    return page
end

function App:BuildPages()
    for _, definition in ipairs(self.PageDefinitions) do
        self:CreateNavigationButton(definition)
        local page = self:CreatePage(definition)

        local ok, errorText = self:SafeCall(definition.Name .. " page", function()
            if type(definition.Module) == "table" and type(definition.Module.Create) == "function" then
                definition.Module:Create(page, self)
            else
                self:BuildComingSoonPage(page, definition.Name, "This page is ready for its feature set.")
            end
        end)

        if not ok then
            page:ClearAllChildren()
            self:BuildErrorPage(page, definition.Name, errorText)
        end
    end
end

function App:OpenPage(name)
    if not self.Pages[name] then
        return false
    end

    for pageName, page in pairs(self.Pages) do
        page.Visible = pageName == name
    end

    for pageName, entry in pairs(self.NavigationButtons) do
        entry.SetSelected(pageName == name)
    end

    self.CurrentPage = name
    return true
end

function App:BuildComingSoonPage(page, title, message)
    local banner = self:CreateCard(page, UDim2.new(1, 0, 0, 150), {
        Color = Color3.fromRGB(8, 22, 15),
        StrokeColor = self.Theme.AccentDark,
        StrokeTransparency = 0.08,
        Radius = 16,
        ZIndex = 10,
    })
    banner.LayoutOrder = 1

    self:CreateText(banner, string.upper(title), UDim2.new(1, -160, 0, 42), UDim2.fromOffset(24, 25), {
        Font = self.Theme.FontBlack,
        TextSize = 30,
        Color = self.Theme.Text,
        ZIndex = 14,
    })

    self:CreateText(banner, message, UDim2.new(1, -160, 0, 44), UDim2.fromOffset(25, 76), {
        Font = self.Theme.FontMedium,
        TextSize = 14,
        Color = self.Theme.SubText,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 14,
    })

    local logo = self.Icons:CreateLogo(banner, 92, {
        Position = UDim2.new(1, -118, 0, 28),
        Color = self.Theme.Accent,
        BackgroundColor = self.Theme.Window,
        Glow = true,
        ZIndex = 15,
    })
    logo.Name = "PageLogo"

    local card = self:CreateCard(page, UDim2.new(1, 0, 0, 210), {
        StrokeColor = self.Theme.Border,
        StrokeTransparency = 0.25,
        ZIndex = 10,
    })
    card.LayoutOrder = 2

    self:CreateText(card, "PAGE SHELL READY", UDim2.new(1, -48, 0, 34), UDim2.fromOffset(24, 24), {
        Font = self.Theme.FontBlack,
        TextSize = 21,
        Color = self.Theme.Accent,
        ZIndex = 14,
    })

    self:CreateText(card, "The visual shell, navigation, touch scaling, and diagnostics are stable. Feature controls for this category can be added next without changing the dashboard design.", UDim2.new(1, -48, 0, 92), UDim2.fromOffset(24, 72), {
        Font = self.Theme.FontMedium,
        TextSize = 14,
        Color = self.Theme.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 14,
    })
end

function App:BuildErrorPage(page, title, errorText)
    local card = self:CreateCard(page, UDim2.new(1, 0, 0, 250), {
        Color = self.Theme.ErrorDark,
        StrokeColor = self.Theme.Error,
        StrokeTransparency = 0,
        ZIndex = 10,
    })
    card.LayoutOrder = 1

    self:CreateText(card, string.upper(title) .. " FAILED TO LOAD", UDim2.new(1, -48, 0, 40), UDim2.fromOffset(24, 24), {
        Font = self.Theme.FontBlack,
        TextSize = 22,
        Color = self.Theme.ErrorBright,
        ZIndex = 14,
    })

    self:CreateText(card, tostring(errorText), UDim2.new(1, -48, 0, 150), UDim2.fromOffset(24, 78), {
        Font = self.Theme.FontCode,
        TextSize = 12,
        Color = self.Theme.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 14,
    })
end

----------------------------------------------------------
-- Build / destroy
----------------------------------------------------------

function App:Build(loader)
    self.Loader = loader or {}
    self.Theme = assert(self.Loader.Theme, "Theme was not loaded")
    self.Icons = assert(self.Loader.Icons, "Icons were not loaded")
    self.Components = self.Loader.Components
    self.Notifications = self.Loader.Notifications
    self.Features = self.Loader.Features or {}

    if self.Components and type(self.Components.Initialize) == "function" then
        pcall(function()
            self.Components:Initialize(self.Theme)
        end)
    end

    local featureRegistryClass = assert(self.Loader.FeatureRegistry, "FeatureRegistry was not loaded")
    self.FeatureRegistry = featureRegistryClass.new(self.Loader)

    local runtimeStatsClass = assert(self.Loader.RuntimeStats, "RuntimeStats was not loaded")
    self.RuntimeStats = runtimeStatsClass.new()
    self.RuntimeStats:Start()

    self:CreateGui()
    self:CreateWindow()
    self:CreateSidebar()
    self:CreatePageContainer()
    self:BuildPageDefinitions()
    self:BuildPages()
    self:CreateReopenButton()
    self:StartResponsive()
    self:OpenPage("Home")

    return self
end

function App:Destroy()
    if self.RuntimeStats then
        self.RuntimeStats:Destroy()
    end

    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    self.Connections = {}

    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

function App:GetPage(name)
    return self.Pages[name]
end

function App:GetWindow()
    return self.Window
end

function App:IsVisible()
    return self.Gui ~= nil and not self.IsMinimized
end

local singleton = App.new()
return singleton
