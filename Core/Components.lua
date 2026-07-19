--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Core/Components.lua
--// Shared touch-friendly controls for category pages.
--//========================================================--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Components = {}
Components.Theme = nil

local function isTheme(value)
    return type(value) == "table"
        and value.Card ~= nil
        and value.Text ~= nil
        and value.Accent ~= nil
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
    return item
end

local function stroke(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = parent
    return item
end

local function tween(instance, properties, duration)
    local item = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    item:Play()
    return item
end

function Components:Initialize(theme)
    assert(theme, "[Components] Theme is required")
    self.Theme = theme
end

----------------------------------------------------------
-- Card and section
----------------------------------------------------------

function Components:CreateCard(parent, themeOrSize, maybeSize)
    local theme = isTheme(themeOrSize) and themeOrSize or self.Theme
    local size = maybeSize or themeOrSize

    assert(theme, "[Components] Components:Initialize(theme) was not called")
    assert(typeof(size) == "UDim2", "[Components] CreateCard requires a UDim2 size")

    local card = Instance.new("Frame")
    card.Size = size
    card.BackgroundColor3 = theme.Card
    card.BorderSizePixel = 0
    card.ClipsDescendants = false
    card.Parent = parent
    corner(card, theme.CardRadius or 16)
    stroke(card, theme.Border or theme.BorderDark, 1, 0.22)

    return card
end

function Components:CreateSection(parent, themeOrTitle, maybeTitle)
    local theme = isTheme(themeOrTitle) and themeOrTitle or self.Theme
    local titleText = maybeTitle or themeOrTitle

    local section = Instance.new("Frame")
    section.Position = UDim2.fromOffset(18, 15)
    section.Size = UDim2.new(1, -36, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundTransparency = 1
    section.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = section

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundTransparency = 1
    header.Font = theme.FontBlack
    header.Text = tostring(titleText or "Section")
    header.TextSize = 18
    header.TextColor3 = theme.Text
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 1
    header.Parent = section

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = theme.BorderSoft or theme.BorderDark
    divider.BorderSizePixel = 0
    divider.LayoutOrder = 2
    divider.Parent = section

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.LayoutOrder = 3
    content.Parent = section

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 7)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    return content
end

----------------------------------------------------------
-- Basic text and buttons
----------------------------------------------------------

function Components:CreateTitle(parent, themeOrText, maybeText)
    local theme = isTheme(themeOrText) and themeOrText or self.Theme
    local text = maybeText or themeOrText

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(20, 14)
    title.Size = UDim2.new(1, -40, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = theme.FontBlack
    title.Text = tostring(text or "")
    title.TextSize = 20
    title.TextColor3 = theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = parent

    return title
end

function Components:CreateButton(parent, themeOrText, maybeText)
    local theme = isTheme(themeOrText) and themeOrText or self.Theme
    local text = maybeText or themeOrText

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = theme.Accent
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = theme.FontBold
    button.Text = tostring(text or "Button")
    button.TextSize = 14
    button.TextColor3 = theme.Black or Color3.new(0, 0, 0)
    button.Parent = parent
    corner(button, theme.ButtonRadius or 10)

    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = theme.AccentHover or theme.Accent}, 0.12)
    end)

    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = theme.Accent}, 0.12)
    end)

    return button
end

----------------------------------------------------------
-- Toggle
----------------------------------------------------------

function Components:CreateToggle(parent, themeOrText, maybeText)
    local theme = isTheme(themeOrText) and themeOrText or self.Theme
    local text = maybeText or themeOrText

    local controller = {
        Enabled = false,
        Callback = nil,
    }

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 42)
    holder.BackgroundColor3 = theme.RowAlt or theme.CardAlt or theme.Card
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder, 9)
    stroke(holder, theme.BorderSoft or theme.BorderDark, 1, 0.35)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(13, 0)
    label.Size = UDim2.new(1, -78, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = theme.FontMedium or theme.Font
    label.Text = tostring(text or "Toggle")
    label.TextSize = 14
    label.TextColor3 = theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -10, 0.5, 0)
    switch.Size = UDim2.fromOffset(54, 28)
    switch.BackgroundColor3 = theme.BorderDark
    switch.BorderSizePixel = 0
    switch.Parent = holder
    corner(switch, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 4, 0.5, 0)
    knob.Size = UDim2.fromOffset(20, 20)
    knob.BackgroundColor3 = theme.SubText
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 99)

    local click = Instance.new("TextButton")
    click.Size = UDim2.fromScale(1, 1)
    click.BackgroundTransparency = 1
    click.BorderSizePixel = 0
    click.AutoButtonColor = false
    click.Text = ""
    click.Parent = holder

    local function refresh(animated)
        local duration = animated and 0.15 or 0
        local switchColor = controller.Enabled and theme.Accent or theme.BorderDark
        local knobColor = controller.Enabled and (theme.Black or Color3.new(0, 0, 0)) or theme.SubText
        local knobPosition = controller.Enabled and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)

        if duration > 0 then
            tween(switch, {BackgroundColor3 = switchColor}, duration)
            tween(knob, {BackgroundColor3 = knobColor, Position = knobPosition}, duration)
        else
            switch.BackgroundColor3 = switchColor
            knob.BackgroundColor3 = knobColor
            knob.Position = knobPosition
        end
    end

    click.MouseButton1Click:Connect(function()
        controller.Enabled = not controller.Enabled
        refresh(true)

        if controller.Callback then
            controller.Callback(controller.Enabled)
        end
    end)

    function controller:Set(value, fireCallback)
        controller.Enabled = value and true or false
        refresh(true)

        if fireCallback and controller.Callback then
            controller.Callback(controller.Enabled)
        end
    end

    function controller:Get()
        return controller.Enabled
    end

    function controller:OnChanged(callback)
        controller.Callback = callback
    end

    refresh(false)
    return holder, controller
end

----------------------------------------------------------
-- Slider
----------------------------------------------------------

function Components:CreateSlider(parent, themeOrTitle, titleOrMin, minOrMax, maxOrDefault, maybeDefault)
    local theme
    local titleText
    local minimum
    local maximum
    local default

    if isTheme(themeOrTitle) then
        theme = themeOrTitle
        titleText = titleOrMin
        minimum = minOrMax
        maximum = maxOrDefault
        default = maybeDefault
    else
        theme = self.Theme
        titleText = themeOrTitle
        minimum = titleOrMin
        maximum = minOrMax
        default = maxOrDefault
    end

    minimum = tonumber(minimum) or 0
    maximum = tonumber(maximum) or 100
    default = tonumber(default) or minimum

    local controller = {
        Value = math.clamp(default, minimum, maximum),
        Callback = nil,
    }

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -72, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = theme.FontMedium or theme.Font
    label.Text = tostring(titleText or "Slider")
    label.TextSize = 14
    label.TextColor3 = theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.Size = UDim2.fromOffset(64, 20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = theme.FontBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = theme.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local trackHitbox = Instance.new("TextButton")
    trackHitbox.Position = UDim2.fromOffset(0, 24)
    trackHitbox.Size = UDim2.new(1, 0, 0, 28)
    trackHitbox.BackgroundTransparency = 1
    trackHitbox.BorderSizePixel = 0
    trackHitbox.AutoButtonColor = false
    trackHitbox.Text = ""
    trackHitbox.Parent = holder

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.Position = UDim2.new(0, 0, 0.5, 0)
    track.Size = UDim2.new(1, 0, 0, 7)
    track.BackgroundColor3 = theme.BorderDark
    track.BorderSizePixel = 0
    track.Parent = trackHitbox
    corner(track, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.BackgroundColor3 = theme.Accent
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 99)
    stroke(knob, theme.Text, 1, 0.25)

    local function refresh()
        local range = maximum - minimum
        local percent = range == 0 and 0 or ((controller.Value - minimum) / range)
        percent = math.clamp(percent, 0, 1)

        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)
        valueLabel.Text = tostring(controller.Value)
    end

    local function setFromX(x, fireCallback)
        if track.AbsoluteSize.X <= 0 then
            return
        end

        local percent = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minimum + ((maximum - minimum) * percent) + 0.5)

        if value ~= controller.Value then
            controller.Value = value
            refresh()

            if fireCallback and controller.Callback then
                controller.Callback(controller.Value)
            end
        end
    end

    local dragging = false

    trackHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X, true)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X, true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    function controller:Set(value, fireCallback)
        value = tonumber(value) or controller.Value
        controller.Value = math.clamp(math.floor(value + 0.5), minimum, maximum)
        refresh()

        if fireCallback and controller.Callback then
            controller.Callback(controller.Value)
        end
    end

    function controller:Get()
        return controller.Value
    end

    function controller:OnChanged(callback)
        controller.Callback = callback
    end

    refresh()
    return holder, controller
end

----------------------------------------------------------
-- Dropdown
----------------------------------------------------------

function Components:CreateDropdown(parent, themeOrTitle, titleOrOptions, maybeOptions)
    local theme
    local titleText
    local options

    if isTheme(themeOrTitle) then
        theme = themeOrTitle
        titleText = titleOrOptions
        options = maybeOptions
    else
        theme = self.Theme
        titleText = themeOrTitle
        options = titleOrOptions
    end

    options = options or {}

    local controller = {
        Value = nil,
        Callback = nil,
    }

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = theme.RowAlt or theme.CardAlt
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = theme.FontMedium
    button.TextSize = 14
    button.TextColor3 = theme.Text
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = parent
    corner(button, 9)
    stroke(button, theme.BorderSoft, 1, 0.35)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 13)
    padding.PaddingRight = UDim.new(0, 13)
    padding.Parent = button

    local function refresh()
        if controller.Value == nil then
            button.Text = tostring(titleText or "Select") .. "  ▾"
        else
            button.Text = tostring(titleText or "Select") .. ":  " .. tostring(controller.Value) .. "  ▾"
        end
    end

    button.MouseButton1Click:Connect(function()
        if #options == 0 then
            return
        end

        local index = 1
        if controller.Value ~= nil then
            for optionIndex, option in ipairs(options) do
                if option == controller.Value then
                    index = optionIndex + 1
                    break
                end
            end
        end

        if index > #options then
            index = 1
        end

        controller:Set(options[index], true)
    end)

    function controller:Set(value, fireCallback)
        controller.Value = value
        refresh()

        if fireCallback and controller.Callback then
            controller.Callback(controller.Value)
        end
    end

    function controller:Get()
        return controller.Value
    end

    function controller:OnChanged(callback)
        controller.Callback = callback
    end

    refresh()
    return button, controller
end

----------------------------------------------------------
-- Textbox and utility controls
----------------------------------------------------------

function Components:CreateTextbox(parent, themeOrPlaceholder, maybePlaceholder)
    local theme = isTheme(themeOrPlaceholder) and themeOrPlaceholder or self.Theme
    local placeholder = maybePlaceholder or themeOrPlaceholder

    local controller = {
        Callback = nil,
    }

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 0, 42)
    textBox.BackgroundColor3 = theme.RowAlt or theme.CardAlt
    textBox.BorderSizePixel = 0
    textBox.ClearTextOnFocus = false
    textBox.PlaceholderText = tostring(placeholder or "Enter text")
    textBox.Text = ""
    textBox.Font = theme.FontMedium
    textBox.TextSize = 14
    textBox.TextColor3 = theme.Text
    textBox.PlaceholderColor3 = theme.SubText
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = parent
    corner(textBox, 9)
    stroke(textBox, theme.BorderSoft, 1, 0.35)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 13)
    padding.PaddingRight = UDim.new(0, 13)
    padding.Parent = textBox

    textBox.FocusLost:Connect(function()
        if controller.Callback then
            controller.Callback(textBox.Text)
        end
    end)

    function controller:Get()
        return textBox.Text
    end

    function controller:Set(value)
        textBox.Text = tostring(value or "")
    end

    function controller:OnChanged(callback)
        controller.Callback = callback
    end

    return textBox, controller
end

function Components:CreateLabel(parent, themeOrText, maybeText)
    local theme = isTheme(themeOrText) and themeOrText or self.Theme
    local text = maybeText or themeOrText

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Font = theme.Font
    label.Text = tostring(text or "")
    label.TextSize = 14
    label.TextColor3 = theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

function Components:CreateSpacer(parent, height)
    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, height or 8)
    spacer.BackgroundTransparency = 1
    spacer.Parent = parent
    return spacer
end

function Components:CreateDivider(parent, maybeTheme)
    local theme = isTheme(maybeTheme) and maybeTheme or self.Theme

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = theme.BorderSoft or theme.BorderDark
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

function Components:CreateHorizontalContainer(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    return container
end

----------------------------------------------------------
-- Legacy sidebar helper retained for compatibility
----------------------------------------------------------

function Components:SidebarButton(parent, name, icon)
    local theme = self.Theme
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 46)
    button.BackgroundColor3 = theme.CardAlt
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = theme.FontMedium
    button.Text = tostring(icon or "") .. "   " .. tostring(name or "")
    button.TextSize = 14
    button.TextColor3 = theme.Text
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = parent
    corner(button, 9)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = button

    local selected = false

    function button:SetSelected(state)
        selected = state and true or false
        tween(button, {
            BackgroundColor3 = selected and theme.AccentDark or theme.CardAlt,
        }, 0.15)
    end

    function button:SetCompact(_state)
        -- Retained for older callers; the new shell does not collapse the sidebar.
    end

    return button
end

return Components
