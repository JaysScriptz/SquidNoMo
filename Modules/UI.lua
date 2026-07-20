local UIPage = {}

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
        TextSize = App:IsMobile() and 14 or 16,
        Color = accent,
        ZIndex = 1013,
    })
    App:CreateText(card, subtitle, UDim2.new(1, -28, 0, 34), UDim2.fromOffset(14, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 9 or 10,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local holder = Instance.new("Frame")
    holder.Position = UDim2.fromOffset(12, 80)
    holder.Size = UDim2.new(1, -24, 1, -92)
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
    row.Size = UDim2.new(1, 0, 0, colors and 102 or 88)
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
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })
    App:CreateText(row, description, UDim2.new(1, -106, 0, colors and 40 or 48), UDim2.fromOffset(48, 31), {
        Font = Enum.Font.Gotham,
        TextSize = App:IsMobile() and 8 or 9,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1014,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, -10, 0, 12)
    switch.Size = UDim2.fromOffset(48, 26)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1015
    switch.Parent = row
    corner(switch, 99)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(20, 20)
    knob.BackgroundColor3 = Color3.fromRGB(245, 242, 248)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = switch
    corner(knob, 99)

    local refs = {}

    if colors then
        local holder = Instance.new("Frame")
        holder.Position = UDim2.fromOffset(48, 74)
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
            swatch.MouseButton1Click:Connect(function()
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
    button.ZIndex = 1013
    button.Parent = row

    function refs:Refresh()
        local on = isEnabled(feature)
        local activeColor = accent
        if type(feature) == "table" and type(feature.GetColor) == "function" then
            local ok, value = pcall(feature.GetColor, feature)
            if ok and typeof(value) == "Color3" then activeColor = value end
        end
        switch.BackgroundColor3 = on and activeColor or Color3.fromRGB(68, 64, 78)
        knob.Position = UDim2.fromOffset(on and 25 or 3, 3)
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

    button.MouseButton1Click:Connect(function()
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

function UIPage:Create(Page, App)
    Page:ClearAllChildren()

    local padding = App.Profile.ContentPadding
    local root = Instance.new("Frame")
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 600)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local banner = App:CreateCard(root, UDim2.new(1, 0, 0, 72), {
        Color = Color3.fromRGB(15, 10, 23),
        BorderColor = App:GetPageAccent("UI"),
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 14 or 17,
    })
    App:CreateText(banner, "GAME UI ENHANCEMENTS", UDim2.new(1, -36, 0, 28), UDim2.fromOffset(18, 10), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 17 or 20,
        Color = App:GetPageAccent("UI"),
        ZIndex = 1013,
    })
    App:CreateText(banner, "In-game overlays, core-interface visibility, and visual clarity controls. App appearance remains under Settings.", UDim2.new(1, -36, 0, 24), UDim2.fromOffset(18, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 9 or 10,
        Color = App.Colors.Text,
        Wrapped = true,
        ZIndex = 1013,
    })

    local columns = App:CreateEqualThreeColumnRow(root, 84, 490, "GameUIUniversalColumns")
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

    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Chat", "Temporarily hides the built-in chat interface.", App.Colors.Info, features.HideChat, 1))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Player List", "Temporarily hides the player list.", App.Colors.Info, features.HidePlayerList, 2))
    table.insert(refreshers, createFeatureRow(App, visibility, "Hide Backpack", "Temporarily hides the backpack hotbar.", App.Colors.Info, features.HideBackpack, 3))

    table.insert(refreshers, createFeatureRow(App, clarity, "Remove Blur", "Disables local BlurEffect instances while active.", App.Colors.Success, features.RemoveBlur, 1))
    table.insert(refreshers, createFeatureRow(App, clarity, "Fullbright", "Raises local lighting visibility and restores it when disabled.", App.Colors.Warning, features.Fullbright, 2))
    table.insert(refreshers, createFeatureRow(App, clarity, "Disable Screen Effects", "Disables bloom, sun rays, depth of field, and color correction.", App.Colors.Error, features.ScreenEffects, 3))

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
