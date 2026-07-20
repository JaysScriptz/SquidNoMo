local PlayersPage = {}

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

local function notifyManager(App)
    if App.FeatureManager and type(App.FeatureManager.Notify) == "function" then
        pcall(function()
            App.FeatureManager:Notify()
        end)
    end
end

local function isEnabled(feature)
    if type(feature) ~= "table" then
        return false
    end

    local ok, result = pcall(function()
        if type(feature.IsEnabled) == "function" then
            return feature:IsEnabled()
        end
        if type(feature.GetState) == "function" then
            local state = feature:GetState()
            return state == true or state == "on" or state == "enabled"
        end
        return false
    end)

    return ok and result == true
end

local function setEnabled(feature, state)
    if type(feature) ~= "table" then
        return false
    end

    local method = state and feature.Enable or feature.Disable
    if type(method) ~= "function" then
        return false
    end

    local ok, result = pcall(method, feature)
    return ok and result ~= false
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
    holder.ZIndex = 1012
    holder.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = holder

    return card, holder
end

local function createToggleRow(App, parent, title, description, accent, feature, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 98)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 1013
    row.Parent = parent
    corner(row, 11)
    local outline = stroke(row, accent, 1, 0.72)

    App:CreateText(row, title, UDim2.new(1, -82, 0, 20), UDim2.fromOffset(12, 8), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    local detail = App:CreateText(row, description, UDim2.new(1, -84, 0, 28), UDim2.fromOffset(12, 31), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 11 or 12,
        Color = App.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1014,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.fromOffset(54, 30)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1014
    switch.Parent = row
    corner(switch, 99)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(24, 24)
    knob.BackgroundColor3 = Color3.fromRGB(245, 242, 248)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1015
    knob.Parent = switch
    corner(knob, 99)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 1016
    button.Parent = row
    App:BindButtonFeedback(button, accent)

    local refs = {Feature = feature, Row = row, Switch = switch, Knob = knob, Outline = outline, Detail = detail}

    function refs:Refresh()
        local on = isEnabled(feature)
        switch.BackgroundColor3 = on and accent or Color3.fromRGB(68, 64, 78)
        knob.Position = UDim2.fromOffset(on and 27 or 3, 3)
        outline.Transparency = on and 0.20 or 0.72
    end

    button.Activated:Connect(function()
        local desired = not isEnabled(feature)
        if setEnabled(feature, desired) then
            notifyManager(App)
            refs:Refresh()
        elseif App.Notifications and type(App.Notifications.Warning) == "function" then
            App.Notifications:Warning("Players", title .. " is unavailable in this runtime.", 3)
        end
    end)

    refs:Refresh()
    return refs
end

local function createSliderRow(App, parent, title, minimum, maximum, defaultValue, feature, accent, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 82)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 1013
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

local function createActionButton(App, parent, title, description, accent, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 90)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 1013
    row.Parent = parent
    corner(row, 11)
    stroke(row, accent, 1, 0.58)

    App:CreateText(row, title, UDim2.new(1, -112, 0, 20), UDim2.fromOffset(12, 9), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    App:CreateText(row, description, UDim2.new(1, -116, 0, 34), UDim2.fromOffset(12, 32), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 11 or 12,
        Color = App.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1014,
    })

    local action = Instance.new("TextButton")
    action.AnchorPoint = Vector2.new(1, 0.5)
    action.Position = UDim2.new(1, -10, 0.5, 0)
    action.Size = UDim2.fromOffset(94, 38)
    action.BackgroundColor3 = accent
    action.BackgroundTransparency = 0.08
    action.BorderSizePixel = 0
    action.AutoButtonColor = false
    action.Font = Enum.Font.GothamBold
    action.Text = "RUN"
    action.TextSize = 10
    action.TextColor3 = Color3.fromRGB(255, 255, 255)
    action.ZIndex = 1015
    action.Parent = row
    corner(action, 9)
    App:BindButtonFeedback(action, accent)

    action.Activated:Connect(function()
        local ok = pcall(callback)
        if not ok and App.Notifications and type(App.Notifications.Warning) == "function" then
            App.Notifications:Warning("Players", title .. " could not run.", 3)
        end
    end)
end

local function createESPRow(App, parent, title, description, accent, feature, colors, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 112)
    row.BackgroundColor3 = App.Colors.CardAlt
    row.BackgroundTransparency = 0.20
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 1013
    row.Parent = parent
    corner(row, 11)
    local outline = stroke(row, accent, 1, 0.72)

    local icon = Instance.new("TextLabel")
    icon.Position = UDim2.fromOffset(10, 8)
    icon.Size = UDim2.fromOffset(28, 28)
    icon.BackgroundColor3 = accent
    icon.BackgroundTransparency = 0.78
    icon.BorderSizePixel = 0
    icon.Font = Enum.Font.GothamBlack
    icon.Text = "●"
    icon.TextSize = 15
    icon.TextColor3 = accent
    icon.ZIndex = 1014
    icon.Parent = row
    corner(icon, 9)

    App:CreateText(row, title, UDim2.new(1, -104, 0, 20), UDim2.fromOffset(44, 8), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 13 or 14,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })

    App:CreateText(row, description, UDim2.new(1, -104, 0, 23), UDim2.fromOffset(44, 29), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 11 or 12,
        Color = App.Colors.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1014,
    })

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, -10, 0, 10)
    switch.Size = UDim2.fromOffset(54, 30)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1014
    switch.Parent = row
    corner(switch, 99)

    local knob = Instance.new("Frame")
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(24, 24)
    knob.BackgroundColor3 = Color3.fromRGB(245, 242, 248)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1015
    knob.Parent = switch
    corner(knob, 99)

    local swatchHolder = Instance.new("Frame")
    swatchHolder.Position = UDim2.fromOffset(44, 82)
    swatchHolder.Size = UDim2.new(1, -56, 0, 20)
    swatchHolder.BackgroundTransparency = 1
    swatchHolder.ZIndex = 1014
    swatchHolder.Parent = row

    local swatchLayout = Instance.new("UIListLayout")
    swatchLayout.FillDirection = Enum.FillDirection.Horizontal
    swatchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    swatchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    swatchLayout.Padding = UDim.new(0, 7)
    swatchLayout.Parent = swatchHolder

    local swatches = {}
    for index, color in ipairs(colors) do
        local swatch = Instance.new("TextButton")
        swatch.Size = UDim2.fromOffset(20, 20)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.AutoButtonColor = false
        swatch.Text = ""
        swatch.LayoutOrder = index
        swatch.ZIndex = 1015
        swatch.Parent = swatchHolder
        corner(swatch, 6)
        local swatchStroke = stroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.72)
        App:BindButtonFeedback(swatch, color)

        swatch.Activated:Connect(function()
            if type(feature) == "table" and type(feature.SetColor) == "function" then
                pcall(feature.SetColor, feature, color)
                for _, item in ipairs(swatches) do
                    item.Stroke.Transparency = item.Color == color and 0.08 or 0.72
                    item.Stroke.Thickness = item.Color == color and 2 or 1
                end
            end
        end)
        table.insert(swatches, {Button = swatch, Stroke = swatchStroke, Color = color})
    end

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromScale(1, 1)
    toggle.BackgroundTransparency = 1
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.ZIndex = 1013
    toggle.Parent = row

    -- Keep color swatches clickable above the row toggle.
    swatchHolder.ZIndex = 1017
    for _, item in ipairs(swatches) do
        item.Button.ZIndex = 1018
    end
    switch.ZIndex = 1017
    knob.ZIndex = 1018

    local refs = {}
    function refs:Refresh()
        local on = isEnabled(feature)
        local currentColor = accent
        if type(feature) == "table" and type(feature.GetColor) == "function" then
            local ok, result = pcall(feature.GetColor, feature)
            if ok and typeof(result) == "Color3" then
                currentColor = result
            end
        end
        icon.TextColor3 = currentColor
        icon.BackgroundColor3 = currentColor
        switch.BackgroundColor3 = on and currentColor or Color3.fromRGB(68, 64, 78)
        knob.Position = UDim2.fromOffset(on and 27 or 3, 3)
        outline.Color = currentColor
        outline.Transparency = on and 0.20 or 0.72
        for _, item in ipairs(swatches) do
            local selected = item.Color == currentColor
            item.Stroke.Transparency = selected and 0.08 or 0.72
            item.Stroke.Thickness = selected and 2 or 1
        end
    end

    toggle.Activated:Connect(function()
        local desired = not isEnabled(feature)
        if setEnabled(feature, desired) then
            notifyManager(App)
            refs:Refresh()
        end
    end)

    refs:Refresh()
    return refs
end

function PlayersPage:Create(Page, App)
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
        BorderColor = App:GetPageAccent("Players"),
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 14 or 17,
    })
    banner.Position = UDim2.fromOffset(0, 0)

    App:CreateText(banner, "PLAYER FEATURES", UDim2.new(1, -36, 0, 28), UDim2.fromOffset(18, 10), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 20 or 23,
        Color = App:GetPageAccent("Players"),
        ZIndex = 1013,
    })
    App:CreateText(banner, "Stable local movement, player information, camera controls, and session utilities linked to the live feature registry.", UDim2.new(1, -36, 0, 24), UDim2.fromOffset(18, 39), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 12 or 13,
        Color = App.Colors.Text,
        Wrapped = true,
        ZIndex = 1013,
    })

    local columns = App:CreateEqualThreeColumnRow(root, 100, 1390, "PlayersUniversalColumns")

    local _, movement = createColumn(App, columns, "MOVEMENT & CAMERA", "Local character and camera behavior.", App.Colors.Info, 1)
    local _, esp = createColumn(App, columns, "PLAYER ESP", "Role, distance, health, and box overlays.", App.Colors.Success, 2)
    local _, utilities = createColumn(App, columns, "LOCAL UTILITIES", "Stable quality-of-life controls and actions.", App.Colors.Warning, 3)

    local features = App.Features and App.Features.Player or {}
    local refreshers = {}

    table.insert(refreshers, createSliderRow(App, movement, "Walk Speed", 16, 100, 16, features.WalkSpeed, App.Colors.Info, 1))
    table.insert(refreshers, createSliderRow(App, movement, "Jump Power", 50, 200, 50, features.JumpPower, App:GetPageAccent("Players"), 2))
    table.insert(refreshers, createSliderRow(App, movement, "Gravity", 20, 300, 196, features.Gravity, App.Colors.Warning, 3))
    table.insert(refreshers, createToggleRow(App, movement, "Infinite Jump", "Allows repeated jumps while airborne.", App.Colors.Warning, features.InfiniteJump, 4))
    table.insert(refreshers, createToggleRow(App, movement, "Auto Jump", "Jumps automatically while moving on the ground.", App.Colors.Success, features.AutoJump, 5))
    table.insert(refreshers, createToggleRow(App, movement, "Noclip", "Disables local character collisions.", App.Colors.Error, features.Noclip, 6))
    table.insert(refreshers, createToggleRow(App, movement, "Force Third Person", "Keeps the local camera in third-person view.", App.Colors.Info, features.ForceThirdPerson, 7))
    table.insert(refreshers, createToggleRow(App, movement, "Unlock Camera Zoom", "Expands the local camera zoom range.", App:GetPageAccent("Players"), features.UnlockZoom, 8))
    table.insert(refreshers, createToggleRow(App, movement, "Auto Stand", "Automatically exits seated states.", App.Colors.Success, features.AutoStand, 9))

    table.insert(refreshers, createESPRow(App, esp, "Player ESP", "Highlights standard players.", Color3.fromRGB(0, 170, 255), features.PlayerESP, {
        Color3.fromRGB(0, 170, 255), Color3.fromRGB(45, 232, 98), Color3.fromRGB(245, 245, 255),
    }, 1))
    table.insert(refreshers, createESPRow(App, esp, "Guard ESP", "Highlights detected guards.", Color3.fromRGB(235, 55, 70), features.GuardESP, {
        Color3.fromRGB(235, 55, 70), Color3.fromRGB(255, 132, 40), Color3.fromRGB(255, 58, 145),
    }, 2))
    table.insert(refreshers, createESPRow(App, esp, "Detective ESP", "Highlights detected detectives.", Color3.fromRGB(0, 230, 150), features.DetectiveESP, {
        Color3.fromRGB(0, 230, 150), Color3.fromRGB(0, 205, 255), Color3.fromRGB(255, 214, 70),
    }, 3))
    table.insert(refreshers, createESPRow(App, esp, "Frontman ESP", "Highlights detected frontmen.", Color3.fromRGB(172, 76, 255), features.FrontmanESP, {
        Color3.fromRGB(172, 76, 255), Color3.fromRGB(232, 67, 255), Color3.fromRGB(245, 245, 255),
    }, 4))
    table.insert(refreshers, createESPRow(App, esp, "Distance ESP", "Shows distance from the local character.", Color3.fromRGB(0, 205, 255), features.DistanceESP, {
        Color3.fromRGB(0, 205, 255), Color3.fromRGB(255, 196, 64), Color3.fromRGB(245, 245, 255),
    }, 5))
    table.insert(refreshers, createToggleRow(App, esp, "Health ESP", "Shows live health with green, yellow, and red states.", App.Colors.Success, features.HealthESP, 6))
    table.insert(refreshers, createESPRow(App, esp, "Box ESP", "Draws a clean outline around every player.", App:GetPageAccent("Players"), features.BoxESP, {
        Color3.fromRGB(255, 58, 145), Color3.fromRGB(172, 76, 255), Color3.fromRGB(255, 255, 255),
    }, 7))

    table.insert(refreshers, createToggleRow(App, utilities, "Anti AFK", "Prevents idle disconnects during the session.", App.Colors.Success, features.AntiAFK, 1))
    table.insert(refreshers, createToggleRow(App, utilities, "Anti Lag", "Reduces local terrain water and explosion effects.", App.Colors.Info, features.AntiLag, 2))
    table.insert(refreshers, createToggleRow(App, utilities, "Hide Other Players", "Makes other characters invisible only on your client.", App:GetPageAccent("Players"), features.HideOthers, 3))
    table.insert(refreshers, createToggleRow(App, utilities, "Hide Local Character", "Hides your own character locally without affecting others.", App.Colors.Info, features.HideSelf, 4))
    table.insert(refreshers, createToggleRow(App, utilities, "Mute Character Sounds", "Mutes sounds attached to your local character.", App.Colors.Warning, features.MuteCharacterSounds, 5))

    createActionButton(App, utilities, "Reset Character", "Respawns the local character.", App.Colors.Error, 6, function()
        if features.Reset and type(features.Reset.Execute) == "function" then
            features.Reset:Execute()
        end
    end)
    createActionButton(App, utilities, "Rejoin Server", "Reconnects to the current place.", App:GetPageAccent("Players"), 7, function()
        if features.Rejoin and type(features.Rejoin.Execute) == "function" then
            features.Rejoin:Execute()
        end
    end)


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


return PlayersPage
