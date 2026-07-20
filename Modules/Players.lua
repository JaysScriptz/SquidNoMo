local PlayersPage = {}

local function resolveFeature(App, id)
    local manager = App.FeatureManager
    if not manager or not manager.Registry then
        return nil
    end
    local entry = manager.Registry[id]
    return entry and entry.Feature or nil
end

local function notifyManager(App)
    if App.FeatureManager and type(App.FeatureManager.Notify) == "function" then
        App.FeatureManager:Notify()
    end
end

local function createColumnShell(App, parent, title, subtitle, accent, order)
    local column = App:CreateCard(parent, UDim2.new(0, 0, 1, 0), {
        Color = App.Colors.Card,
        BorderColor = accent,
        BorderTransparency = 0.14,
        Radius = App:IsMobile() and 14 or 16,
    })
    column.Name = title:gsub("%s+", "") .. "Column"
    column.LayoutOrder = order or 1

    App:CreateText(
        column,
        string.upper(title),
        UDim2.new(1, -24, 0, 26),
        UDim2.fromOffset(14, 12),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 14 or 17,
            Color = accent,
            ZIndex = 1012,
        }
    )

    App:CreateText(
        column,
        subtitle,
        UDim2.new(1, -24, 0, 34),
        UDim2.fromOffset(14, 38),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 10 or 11,
            Color = App.Colors.Muted,
            Wrapped = true,
            ZIndex = 1012,
        }
    )

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Position = UDim2.fromOffset(10, 82)
    scroll.Size = UDim2.new(1, -20, 1, -92)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.fromOffset(0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = App:IsMobile() and 6 or 8
    scroll.ScrollBarImageColor3 = accent
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = column

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = scroll

    return column, scroll
end

local function createActionToggle(App, parent, title, description, accent, featureId)
    local card = App:CreateCard(parent, UDim2.new(1, 0, 0, 104), {
        Color = App.Colors.CardAlt,
        BorderColor = accent,
        BorderTransparency = 0.22,
        Radius = 14,
    })

    App:CreateText(card, title, UDim2.new(1, -88, 0, 22), UDim2.fromOffset(14, 12), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    App:CreateText(card, description, UDim2.new(1, -100, 0, 42), UDim2.fromOffset(14, 36), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Muted,
        Wrapped = true,
        ZIndex = 1014,
    })

    local toggle = App:CreateToggle(card, UDim2.fromOffset(60, 30), UDim2.new(1, -74, 0, 14), false, {
        AccentColor = accent,
        ZIndex = 1015,
    })

    local feature = resolveFeature(App, featureId)
    if feature and type(feature.IsEnabled) == "function" then
        local ok, enabled = pcall(feature.IsEnabled, feature)
        if ok and enabled then
            toggle:Set(true)
        end
    end

    toggle.Changed:Connect(function(state)
        if not feature then
            feature = resolveFeature(App, featureId)
        end
        if not feature then
            return
        end

        if state then
            if type(feature.Enable) == "function" then
                pcall(feature.Enable, feature)
            end
        else
            if type(feature.Disable) == "function" then
                pcall(feature.Disable, feature)
            end
        end
        notifyManager(App)
    end)

    return card
end

local function createSliderCard(App, parent, title, accent, featureId, minValue, maxValue, step)
    local card = App:CreateCard(parent, UDim2.new(1, 0, 0, 132), {
        Color = App.Colors.CardAlt,
        BorderColor = accent,
        BorderTransparency = 0.22,
        Radius = 14,
    })

    local valueLabel = App:CreateText(card, "0", UDim2.fromOffset(58, 22), UDim2.new(1, -72, 0, 12), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 13 or 14,
        Color = accent,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1014,
    })

    App:CreateText(card, title, UDim2.new(1, -80, 0, 22), UDim2.fromOffset(14, 12), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    local feature = resolveFeature(App, featureId)
    local currentValue = minValue

    if feature and type(feature.Get) == "function" then
        local ok, value = pcall(feature.Get, feature)
        if ok and type(value) == "number" then
            currentValue = value
        end
    end

    local function applyValue(value)
        local rounded = math.clamp(math.floor((value / step) + 0.5) * step, minValue, maxValue)
        currentValue = rounded
        valueLabel.Text = tostring(rounded)
        if not feature then
            feature = resolveFeature(App, featureId)
        end
        if feature and type(feature.Set) == "function" then
            pcall(feature.Set, feature, rounded)
            notifyManager(App)
        end
    end

    local slider = App:CreateSlider(card, {
        Position = UDim2.fromOffset(14, 42),
        Size = UDim2.new(1, -28, 0, 26),
        Min = minValue,
        Max = maxValue,
        Value = currentValue,
        AccentColor = accent,
        TrackHeight = 12,
        KnobSize = 24,
        TouchMultiplier = 0.45,
        OnChanged = function(value)
            applyValue(value)
        end,
    })

    local row = Instance.new("Frame")
    row.Name = "AdjustRow"
    row.Position = UDim2.fromOffset(14, 82)
    row.Size = UDim2.new(1, -28, 0, 34)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = row

    local adjusters = {
        {-10, "-10"},
        {-5, "-5"},
        {-1, "-1"},
        {1, "+1"},
        {5, "+5"},
        {10, "+10"},
    }

    for _, info in ipairs(adjusters) do
        local delta, label = info[1], info[2]
        local button = App:CreateQuickButton(row, label, UDim2.fromOffset(48, 34), accent)
        button.Activated:Connect(function()
            local nextValue = currentValue + (delta * step)
            applyValue(nextValue)
            if slider and slider.SetValue then
                slider:SetValue(currentValue)
            end
        end)
    end

    applyValue(currentValue)
    return card
end

local function createColorEspCard(App, parent, title, description, accent, featureId, swatches)
    local card = createActionToggle(App, parent, title, description, accent, featureId)
    card.Size = UDim2.new(1, 0, 0, 126)

    local row = Instance.new("Frame")
    row.Name = "Swatches"
    row.Position = UDim2.fromOffset(14, 82)
    row.Size = UDim2.new(1, -28, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 10)
    layout.Parent = row

    local feature = resolveFeature(App, featureId)
    for _, color in ipairs(swatches or {}) do
        local sw = Instance.new("TextButton")
        sw.AutoButtonColor = false
        sw.Text = ""
        sw.Size = UDim2.fromOffset(22, 22)
        sw.BackgroundColor3 = color
        sw.BorderSizePixel = 0
        sw.Parent = row

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = sw

        sw.Activated:Connect(function()
            if not feature then
                feature = resolveFeature(App, featureId)
            end
            if feature and type(feature.SetColor) == "function" then
                pcall(feature.SetColor, feature, color)
                notifyManager(App)
            end
        end)
    end

    return card
end

function PlayersPage:Create(Page, App)
    Page:ClearAllChildren()

    local padding = App.Profile.ContentPadding

    local header = App:CreateCard(Page, UDim2.new(1, -(padding * 2), 0, 88), {
        Color = App.Colors.PagePanel or App.Colors.Card,
        BorderColor = App:GetPageAccent("Players"),
        BorderTransparency = 0.12,
        Radius = App:IsMobile() and 14 or 16,
    })
    header.Position = UDim2.fromOffset(padding, padding)

    App:CreateText(header, "PLAYER FEATURES", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(18, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 18 or 22,
        Color = App:GetPageAccent("Players"),
        ZIndex = 1012,
    })

    App:CreateText(
        header,
        "Stable local movement, player overlays, and quality-of-life utilities in a balanced three-column layout.",
        UDim2.new(1, -24, 0, 32),
        UDim2.fromOffset(18, 46),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 10 or 11,
            Color = App.Colors.Muted,
            Wrapped = true,
            ZIndex = 1012,
        }
    )

    local bodyY = padding + 100
    local bodyH = Page.AbsoluteSize.Y - bodyY - padding
    if bodyH < 260 then
        bodyH = 260
    end

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Position = UDim2.fromOffset(padding, bodyY)
    body.Size = UDim2.new(1, -(padding * 2), 1, -(bodyY + padding))
    body.BackgroundTransparency = 1
    body.Parent = Page

    local grid = Instance.new("UIGridLayout")
    grid.CellPadding = UDim2.fromOffset(14, 0)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.VerticalAlignment = Enum.VerticalAlignment.Top
    grid.Parent = body

    local function refreshGrid()
        local width = body.AbsoluteSize.X
        local gap = 14
        local colWidth = math.floor((width - (gap * 2)) / 3)
        if colWidth < 220 then
            colWidth = 220
        end
        grid.CellSize = UDim2.fromOffset(colWidth, body.AbsoluteSize.Y)
    end

    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshGrid)
    refreshGrid()

    local moveCol, moveScroll = createColumnShell(
        App,
        body,
        "Movement & Camera",
        "Smooth sliders, jump helpers, and stable local character control.",
        Color3.fromRGB(0, 190, 255),
        1
    )

    local espCol, espScroll = createColumnShell(
        App,
        body,
        "Player ESP",
        "Role, distance, and health overlays with color selection.",
        Color3.fromRGB(0, 255, 120),
        2
    )

    local utilCol, utilScroll = createColumnShell(
        App,
        body,
        "Local Utilities",
        "Lightweight client-side helpers that improve session comfort.",
        Color3.fromRGB(255, 193, 58),
        3
    )

    createSliderCard(App, moveScroll, "Walk Speed", Color3.fromRGB(0,190,255), "player.walk_speed", 16, 120, 1)
    createSliderCard(App, moveScroll, "Jump Power", Color3.fromRGB(188,84,255), "player.jump_power", 50, 220, 1)
    createSliderCard(App, moveScroll, "Gravity", Color3.fromRGB(255,199,74), "player.gravity", 50, 196, 1)
    createActionToggle(App, moveScroll, "Infinite Jump", "Allows repeated jumps while airborne.", Color3.fromRGB(255,95,95), "player.infinite_jump")
    createActionToggle(App, moveScroll, "Auto Jump", "Retries jump input in a stable loop while enabled.", Color3.fromRGB(255,142,78), "player.auto_jump")

    createColorEspCard(App, espScroll, "Player ESP", "Highlights standard players.", Color3.fromRGB(0,170,255), "player.player_esp", {
        Color3.fromRGB(0,170,255), Color3.fromRGB(66,255,105), Color3.fromRGB(255,255,255)
    })
    createColorEspCard(App, espScroll, "Guard ESP", "Highlights detected guards.", Color3.fromRGB(235,55,70), "player.guard_esp", {
        Color3.fromRGB(235,55,70), Color3.fromRGB(255,146,54), Color3.fromRGB(255,64,164)
    })
    createColorEspCard(App, espScroll, "Detective ESP", "Highlights detected detectives.", Color3.fromRGB(0,230,150), "player.detective_esp", {
        Color3.fromRGB(0,230,150), Color3.fromRGB(0,198,255), Color3.fromRGB(255,214,74)
    })
    createColorEspCard(App, espScroll, "Frontman ESP", "Highlights detected frontmen.", Color3.fromRGB(172,76,255), "player.frontman_esp", {
        Color3.fromRGB(172,76,255), Color3.fromRGB(225,73,255), Color3.fromRGB(240,240,255)
    })
    createColorEspCard(App, espScroll, "Distance ESP", "Displays distance readouts for nearby tracked roles.", Color3.fromRGB(0,205,255), "player.distance_esp", {
        Color3.fromRGB(0,205,255), Color3.fromRGB(90,255,210), Color3.fromRGB(255,255,255)
    })
    createColorEspCard(App, espScroll, "Health ESP", "Shows health bars or health readouts for tracked roles.", Color3.fromRGB(255,82,82), "player.health_esp", {
        Color3.fromRGB(255,82,82), Color3.fromRGB(255,172,64), Color3.fromRGB(85,255,127)
    })

    createActionToggle(App, utilScroll, "Anti AFK", "Prevents idle disconnects during the session.", Color3.fromRGB(66,255,130), "player.anti_afk")
    createActionToggle(App, utilScroll, "Anti Lag", "Reduces local terrain water and explosion effects.", Color3.fromRGB(0,170,255), "player.anti_lag")
    createActionToggle(App, utilScroll, "Hide Other Players", "Makes other characters invisible only on your client.", Color3.fromRGB(188,84,255), "player.hide_others")
    createActionToggle(App, utilScroll, "Hide Local Character", "Hides your own character locally without affecting others.", Color3.fromRGB(255,159,67), "player.hide_local_character")
    createActionToggle(App, utilScroll, "Tool ESP", "Highlights dropped tools and important interactables.", Color3.fromRGB(255,210,60), "player.tool_esp")
end

return PlayersPage
