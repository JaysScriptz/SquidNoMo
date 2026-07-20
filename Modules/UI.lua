local UIPage = {}

local UserInputService = game:GetService("UserInputService")

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 12)
    value.Parent = parent
    return value
end

local function stroke(parent, color, thickness, transparency)
    local value = Instance.new("UIStroke")
    value.Color = color
    value.Thickness = thickness or 1
    value.Transparency = transparency or 0
    value.Parent = parent
    return value
end

local function isEnabled(feature)
    if type(feature) ~= "table" or type(feature.IsEnabled) ~= "function" then
        return false
    end
    local ok, result = pcall(feature.IsEnabled, feature)
    return ok and result == true
end

local function notifyManager(App)
    if App.FeatureManager and type(App.FeatureManager.Notify) == "function" then
        pcall(function() App.FeatureManager:Notify() end)
    end
end

local function createColumn(App, row, title, subtitle, accent, order)
    local card = App:CreateCard(row, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(14, 10, 20),
        BorderColor = accent,
        BorderTransparency = 0.12,
        Radius = App:IsMobile() and 13 or 16,
    })
    card.LayoutOrder = order
    card.ClipsDescendants = true

    App:CreateText(card, title, UDim2.new(1, -28, 0, 25), UDim2.fromOffset(14, 12), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 17 or 19,
        Color = accent,
        ZIndex = 1013,
    })
    App:CreateText(card, subtitle, UDim2.new(1, -28, 0, 34), UDim2.fromOffset(14, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 12 or 13,
        Color = App.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local holder = Instance.new("Frame")
    holder.Position = UDim2.fromOffset(12, 88)
    holder.Size = UDim2.new(1, -24, 1, -100)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = holder

    return holder
end

local function createFeatureRow(App, parent, title, description, accent, feature, order, colors)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, colors and 124 or 98)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    corner(row, 11)
    local outline = stroke(row, accent, 1, 0.72)

    local icon = Instance.new("TextLabel")
    icon.Position = UDim2.fromOffset(10, 10)
    icon.Size = UDim2.fromOffset(30, 30)
    icon.BackgroundColor3 = accent
    icon.BackgroundTransparency = 0.80
    icon.BorderSizePixel = 0
    icon.Font = Enum.Font.GothamBlack
    icon.Text = "UI"
    icon.TextSize = 10
    icon.TextColor3 = accent
    icon.ZIndex = 1014
    icon.Parent = row
    corner(icon, 9)

    App:CreateText(row, title, UDim2.new(1, -106, 0, 21), UDim2.fromOffset(48, 9), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })
    App:CreateText(row, description, UDim2.new(1, -106, 0, colors and 40 or 48), UDim2.fromOffset(48, 31), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 11 or 12,
        Color = App.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1014,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, -10, 0, 12)
    switch.Size = UDim2.fromOffset(54, 30)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1015
    switch.Parent = row
    corner(switch, 99)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(24, 24)
    knob.BackgroundColor3 = Color3.fromRGB(245, 242, 248)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = switch
    corner(knob, 99)

    local refs = {}

    if colors then
        local holder = Instance.new("Frame")
        holder.Position = UDim2.fromOffset(48, 92)
        holder.Size = UDim2.new(1, -60, 0, 20)
        holder.BackgroundTransparency = 1
        holder.ZIndex = 1017
        holder.Parent = row
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 7)
        layout.Parent = holder

        refs.Swatches = {}
        for index, color in ipairs(colors) do
            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.fromOffset(20, 20)
            swatch.BackgroundColor3 = color
            swatch.BorderSizePixel = 0
            swatch.AutoButtonColor = false
            swatch.Text = ""
            swatch.LayoutOrder = index
            swatch.ZIndex = 1018
            swatch.Parent = holder
            corner(swatch, 6)
            local swatchStroke = stroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.72)
            App:BindButtonFeedback(swatch, color)
            swatch.Activated:Connect(function()
                if type(feature) == "table" and type(feature.SetColor) == "function" then
                    pcall(feature.SetColor, feature, color)
                    refs:Refresh()
                end
            end)
            table.insert(refs.Swatches, {Color = color, Stroke = swatchStroke})
        end
    end

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 1017
    button.Parent = row

    function refs:Refresh()
        local on = isEnabled(feature)
        local activeColor = accent
        if type(feature) == "table" and type(feature.GetColor) == "function" then
            local ok, value = pcall(feature.GetColor, feature)
            if ok and typeof(value) == "Color3" then activeColor = value end
        end
        switch.BackgroundColor3 = on and activeColor or Color3.fromRGB(68, 64, 78)
        knob.Position = UDim2.fromOffset(on and 27 or 3, 3)
        outline.Color = activeColor
        outline.Transparency = on and 0.20 or 0.72
        icon.BackgroundColor3 = activeColor
        icon.TextColor3 = activeColor
        for _, swatch in ipairs(refs.Swatches or {}) do
            local selected = swatch.Color == activeColor
            swatch.Stroke.Transparency = selected and 0.08 or 0.72
            swatch.Stroke.Thickness = selected and 2 or 1
        end
    end

    button.Activated:Connect(function()
        local desired = not isEnabled(feature)
        local method = desired and feature and feature.Enable or feature and feature.Disable
        if type(method) == "function" then
            local ok = pcall(method, feature)
            if ok then
                notifyManager(App)
                refs:Refresh()
            end
        end
    end)

    refs:Refresh()
    return refs
end


local function createSliderRow(App, parent, title, minimum, maximum, defaultValue, feature, accent, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 98)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    corner(row, 11)
    stroke(row, accent, 1, 0.72)

    App:CreateText(row, title, UDim2.new(1, -90, 0, 20), UDim2.fromOffset(12, 8), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    local valueLabel = App:CreateText(row, tostring(defaultValue), UDim2.fromOffset(68, 20), UDim2.new(1, -80, 0, 8), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 13 or 14,
        Color = accent,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 1014,
    })

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(12, 57)
    track.Size = UDim2.new(1, -24, 0, 8)
    track.BackgroundColor3 = Color3.fromRGB(55, 48, 65)
    track.BorderSizePixel = 0
    track.ZIndex = 1014
    track.Parent = row
    corner(track, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 1015
    fill.Parent = track
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = track
    corner(knob, 99)
    stroke(knob, accent, 2, 0.05)

    local hitbox = Instance.new("TextButton")
    hitbox.Position = UDim2.fromOffset(0, -12)
    hitbox.Size = UDim2.new(1, 0, 0, 32)
    hitbox.BackgroundTransparency = 1
    hitbox.BorderSizePixel = 0
    hitbox.AutoButtonColor = false
    hitbox.Text = ""
    hitbox.ZIndex = 1017
    hitbox.Parent = track

    local current = defaultValue
    local dragging = false

    local function getValue()
        if type(feature) == "table" and type(feature.Get) == "function" then
            local ok, value = pcall(feature.Get, feature)
            if ok and type(value) == "number" then
                return value
            end
        end
        return current
    end

    local function render(value)
        current = math.clamp(math.floor(value + 0.5), minimum, maximum)
        local alpha = (current - minimum) / math.max(1, maximum - minimum)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(current)
    end

    local function setFromInput(input)
        local width = math.max(1, track.AbsoluteSize.X)
        local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
        local value = minimum + ((maximum - minimum) * alpha)
        render(value)
        if type(feature) == "table" and type(feature.Set) == "function" then
            pcall(feature.Set, feature, current)
            notifyManager(App)
        end
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromInput(input)
        end
    end)

    hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromInput(input)
        end
    end)

    render(getValue())

    return {
        Refresh = function()
            render(getValue())
        end,
    }
end

function UIPage:Create(Page, App)
    Page:ClearAllChildren()

    local padding = App.Profile.ContentPadding
    local root = Instance.new("Frame")
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 1510)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local banner = App:CreateCard(root, UDim2.new(1, 0, 0, 88), {
        Color = Color3.fromRGB(15, 10, 23),
        BorderColor = App:GetPageAccent("UI"),
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 14 or 17,
    })
    App:CreateText(banner, "GAME UI ENHANCEMENTS", UDim2.new(1, -36, 0, 28), UDim2.fromOffset(18, 10), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 20 or 23,
        Color = App:GetPageAccent("UI"),
        ZIndex = 1013,
    })
    App:CreateText(banner, "Gameplay overlays, core-interface visibility, and local visual clarity. Application appearance remains under Settings.", UDim2.new(1, -36, 0, 24), UDim2.fromOffset(18, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 12 or 13,
        Color = App.Colors.Text,
        Wrapped = true,
        ZIndex = 1013,
    })
    App:CreatePill(banner, "LOCAL UI ONLY", App:GetPageAccent("UI"), UDim2.new(1, -148, 0, 18), 130)

    local columns = App:CreateEqualThreeColumnRow(root, 100, 1390, "GameUIUniversalColumns")
    local overlays = createColumn(App, columns, "HUD OVERLAYS", "Optional information layered over gameplay.", App:GetPageAccent("UI"), 1)
    local visibility = createColumn(App, columns, "CORE UI VISIBILITY", "Choose which built-in interface elements stay visible.", App.Colors.Info, 2)
    local clarity = createColumn(App, columns, "VISUAL CLARITY", "Reduce obstructive visual effects locally.", App.Colors.Success, 3)

    local features = App.Features and App.Features.UI or {}
    local refreshers = {}

    table.insert(refreshers, createFeatureRow(App, overlays, "Crosshair", "Adds a centered gameplay crosshair.", App:GetPageAccent("UI"), features.Crosshair, 1, {
        Color3.fromRGB(255, 58, 145), Color3.fromRGB(0, 205, 255), Color3.fromRGB(245, 245, 255),
    }))
    table.insert(refreshers, createFeatureRow(App, overlays, "Performance HUD", "Displays FPS, ping, and player count.", App.Colors.Info, features.PerformanceHUD, 2))
    table.insert(refreshers, createFeatureRow(App, overlays, "Role Legend", "Shows the configured role-color legend.", App.Colors.Warning, features.RoleLegend, 3))
    table.insert(refreshers, createFeatureRow(App, overlays, "Session Timer", "Shows elapsed time for the current app session.", App:GetPageAccent("Players"), features.SessionHUD, 4))
    table.insert(refreshers, createFeatureRow(App, overlays, "Coordinates HUD", "Displays the local character's X, Y, and Z position.", App.Colors.Success, features.CoordinatesHUD, 5))
    table.insert(refreshers, createFeatureRow(App, overlays, "Speed HUD", "Shows current horizontal movement speed.", App.Colors.Warning, features.SpeedHUD, 6))
    table.insert(refreshers, createFeatureRow(App, overlays, "Compass HUD", "Shows camera heading and cardinal direction.", App:GetPageAccent("UI"), features.CompassHUD, 7))
    table.insert(refreshers, createFeatureRow(App, overlays, "Server Info HUD", "Shows place, server identifier, and player count.", App.Colors.Info, features.ServerHUD, 8))
    table.insert(refreshers, createFeatureRow(App, overlays, "Clock HUD", "Shows the device's current local time.", App:GetPageAccent("Home"), features.ClockHUD, 9))

    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Chat", "Temporarily hides the built-in chat interface.", App.Colors.Info, features.HideChat, 1))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Player List", "Temporarily hides the player list.", App.Colors.Info, features.HidePlayerList, 2))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Backpack", "Temporarily hides the backpack hotbar.", App.Colors.Info, features.HideBackpack, 3))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Health UI", "Temporarily hides the built-in health display.", App.Colors.Success, features.HideHealth, 4))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Emotes UI", "Temporarily hides the built-in emotes interface when supported.", App:GetPageAccent("Players"), features.HideEmotes, 5))

    table.insert(refreshers, createFeatureRow(App, clarity, "Remove Blur", "Disables local BlurEffect instances while active.", App.Colors.Success, features.RemoveBlur, 1))
    table.insert(refreshers, createFeatureRow(App, clarity, "Fullbright", "Raises local lighting visibility and restores it when disabled.", App.Colors.Warning, features.Fullbright, 2))
    table.insert(refreshers, createFeatureRow(App, clarity, "Disable Screen Effects", "Disables bloom, sun rays, depth of field, and color correction.", App.Colors.Error, features.ScreenEffects, 3))
    table.insert(refreshers, createFeatureRow(App, clarity, "Remove Atmosphere", "Removes local atmosphere density, haze, and glare.", App.Colors.Info, features.RemoveAtmosphere, 4))
    table.insert(refreshers, createFeatureRow(App, clarity, "Remove Fog", "Extends local fog distances for a clearer view.", App.Colors.Success, features.RemoveFog, 5))
    table.insert(refreshers, createFeatureRow(App, clarity, "Disable Shadows", "Disables local global shadows and restores them later.", App.Colors.Warning, features.DisableShadows, 6))
    table.insert(refreshers, createFeatureRow(App, clarity, "Disable Particles", "Disables local particles, trails, beams, smoke, and fire.", App.Colors.Error, features.DisableParticles, 7))
    table.insert(refreshers, createFeatureRow(App, clarity, "High Contrast", "Adds a clean local contrast filter for visibility.", App:GetPageAccent("UI"), features.HighContrast, 8))
    table.insert(refreshers, createSliderRow(App, clarity, "Camera Field of View", 40, 120, 70, features.CameraFOV, App.Colors.Info, 9))

    task.spawn(function()
        while Page and Page.Parent do
            task.wait(0.5)
            for _, refs in ipairs(refreshers) do
                if refs and type(refs.Refresh) == "function" then
                    pcall(refs.Refresh, refs)
                end
            end
        end
    end)
end


return UIPage
