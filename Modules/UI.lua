local UIPage = {}

local UserInputService = game:GetService('UserInputService')

local CATEGORIES = {
    {Name = 'Layout & Scale', Short = 'LAYOUT'},
    {Name = 'Themes & Colors', Short = 'THEME'},
    {Name = 'Buttons & Effects', Short = 'STYLE'},
}

local PAGE_NAMES = {
    'Home',
    'Games',
    'Players',
    'Guards',
    'Detective',
    'Farming',
    'UI',
    'Settings',
}

local function corner(parent, radius)
    local value = Instance.new('UICorner')
    value.CornerRadius = UDim.new(0, radius or 12)
    value.Parent = parent
    return value
end

local function stroke(parent, color, thickness, transparency)
    local value = Instance.new('UIStroke')
    value.Color = color
    value.Thickness = thickness or 1
    value.Transparency = transparency or 0
    value.Parent = parent
    return value
end

local function formatNumber(value, suffix, decimals)
    decimals = decimals or 0
    local multiplier = 10 ^ decimals
    local rounded = math.floor(value * multiplier + 0.5)
        / multiplier
    return tostring(rounded) .. (suffix or '')
end

local function createColumn(App, row, title, subtitle, accent, order)
    local card = App:CreateCard(
        row,
        UDim2.new(0.333333, -8, 1, 0),
        {
            Color = App.Colors.Card,
            BorderColor = accent,
            BorderTransparency = 0.12,
            Radius = App:GetUIStyleValue(
                'UI',
                'CardRadius',
                'MainPage'
            ),
        }
    )
    card.LayoutOrder = order
    card.ClipsDescendants = true

    App:CreateText(
        card,
        title,
        UDim2.new(1, -28, 0, 25),
        UDim2.fromOffset(14, 12),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 15 or 18,
            Color = accent,
            ZIndex = 1013,
        }
    )

    App:CreateText(
        card,
        subtitle,
        UDim2.new(1, -28, 0, 40),
        UDim2.fromOffset(14, 39),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 10 or 11,
            Color = App.Colors.Text,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1013,
        }
    )

    local holder = Instance.new('ScrollingFrame')
    holder.Name = title .. 'Controls'
    holder.Position = UDim2.fromOffset(12, 88)
    holder.Size = UDim2.new(1, -24, 1, -100)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.CanvasSize = UDim2.fromOffset(0, 0)
    holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    holder.ScrollBarThickness = App:GetUIStyleValue(
        'UI',
        'ScrollbarThickness',
        'MainPage'
    )
    holder.ScrollBarImageColor3 = accent
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    holder.Active = true
    holder.ZIndex = 1012
    holder.Parent = card

    local layout = Instance.new('UIListLayout')
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = holder

    local padding = Instance.new('UIPadding')
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = holder

    return holder
end

local function createTouchSlider(
    App,
    parent,
    config,
    getValue,
    setValue,
    order
)
    local accent = config.Accent or App:GetPageAccent('UI')
    local minimum = config.Minimum
    local maximum = config.Maximum
    local step = config.Step or 1
    local row = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, 142),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.66,
            Radius = 11,
        }
    )
    row.LayoutOrder = order

    App:CreateText(
        row,
        config.Title,
        UDim2.new(1, -98, 0, 22),
        UDim2.fromOffset(12, 9),
        {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 12 or 13,
            Color = App.Colors.Text,
            ZIndex = 1014,
        }
    )

    local valueLabel = App:CreateText(
        row,
        '',
        UDim2.fromOffset(82, 22),
        UDim2.new(1, -94, 0, 9),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 12 or 13,
            Color = accent,
            XAlignment = Enum.TextXAlignment.Right,
            ZIndex = 1014,
        }
    )

    local track = Instance.new('Frame')
    track.Position = UDim2.fromOffset(14, 47)
    track.Size = UDim2.new(1, -28, 0, 10)
    track.BackgroundColor3 = Color3.fromRGB(61, 54, 70)
    track.BorderSizePixel = 0
    track.ZIndex = 1014
    track.Parent = row
    corner(track, 999)

    local fill = Instance.new('Frame')
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 1015
    fill.Parent = track
    corner(fill, 999)

    local knob = Instance.new('Frame')
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(24, 24)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = track
    corner(knob, 999)
    stroke(knob, accent, 2, 0.04)

    local hitbox = Instance.new('TextButton')
    hitbox.Position = UDim2.fromOffset(0, -18)
    hitbox.Size = UDim2.new(1, 0, 0, 46)
    hitbox.BackgroundTransparency = 1
    hitbox.BorderSizePixel = 0
    hitbox.AutoButtonColor = false
    hitbox.Text = ''
    hitbox.ZIndex = 1017
    hitbox.Parent = track

    local quickRow = Instance.new('Frame')
    quickRow.Position = UDim2.fromOffset(10, 82)
    quickRow.Size = UDim2.new(1, -20, 0, 46)
    quickRow.BackgroundTransparency = 1
    quickRow.BorderSizePixel = 0
    quickRow.ZIndex = 1014
    quickRow.Parent = row

    local quickLayout = Instance.new('UIListLayout')
    quickLayout.FillDirection = Enum.FillDirection.Horizontal
    quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    quickLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    quickLayout.SortOrder = Enum.SortOrder.LayoutOrder
    quickLayout.Padding = UDim.new(0, 5)
    quickLayout.Parent = quickRow

    local value = tonumber(getValue()) or minimum
    local dragging = false

    local function format(valueToFormat)
        if type(config.Formatter) == 'function' then
            return config.Formatter(valueToFormat)
        end
        return formatNumber(valueToFormat)
    end

    local function render(newValue)
        value = math.clamp(
            tonumber(newValue) or minimum,
            minimum,
            maximum
        )
        local alpha = (value - minimum)
            / math.max(0.0001, maximum - minimum)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = format(value)
    end

    local function commit(newValue)
        local stepped = math.floor(
            ((newValue - minimum) / step) + 0.5
        ) * step + minimum
        stepped = math.clamp(stepped, minimum, maximum)
        setValue(stepped)
        render(stepped)
    end

    local function updateFromInput(input)
        local width = math.max(1, track.AbsoluteSize.X)
        local alpha = math.clamp(
            (input.Position.X - track.AbsolutePosition.X)
                / width,
            0,
            1
        )
        commit(minimum + ((maximum - minimum) * alpha))
    end

    App:Track(hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            updateFromInput(input)
        end
    end))

    App:Track(hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = false
        end
    end))

    App:Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType
                == Enum.UserInputType.MouseMovement
            or input.UserInputType
                == Enum.UserInputType.Touch
        ) then
            updateFromInput(input)
        end
    end))

    local adjustments = {-10, -5, -1, 1, 5, 10}
    for index, amount in ipairs(adjustments) do
        local button = Instance.new('TextButton')
        button.Size = UDim2.new(0.166667, -5, 1, 0)
        button.BackgroundColor3 = App.Colors.Card
        button.BackgroundTransparency = 0.12
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBlack
        button.Text = amount > 0
            and ('+' .. tostring(amount))
            or tostring(amount)
        button.TextSize = App:IsMobile() and 11 or 12
        button.TextColor3 = App.Colors.Text
        button.LayoutOrder = index
        button.ZIndex = 1015
        button.Parent = quickRow
        corner(button, 9)
        stroke(button, accent, 1, 0.34)
        App:BindButtonFeedback(button, accent)

        local held = false
        local function adjust()
            commit(value + (amount * step))
        end

        App:Track(button.InputBegan:Connect(function(input)
            if input.UserInputType
                    ~= Enum.UserInputType.MouseButton1
                and input.UserInputType
                    ~= Enum.UserInputType.Touch
            then
                return
            end

            held = true
            adjust()
            task.delay(0.38, function()
                while held and button.Parent do
                    task.wait(0.12)
                    if held then
                        adjust()
                    end
                end
            end)
        end))

        App:Track(button.InputEnded:Connect(function(input)
            if input.UserInputType
                    == Enum.UserInputType.MouseButton1
                or input.UserInputType
                    == Enum.UserInputType.Touch
            then
                held = false
            end
        end))
    end

    render(value)
    return {Render = render}
end

local function createToggle(
    App,
    parent,
    title,
    description,
    accent,
    getter,
    setter,
    order
)
    local row = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, 90),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.66,
            Radius = 11,
        }
    )
    row.LayoutOrder = order

    App:CreateText(
        row,
        title,
        UDim2.new(1, -92, 0, 22),
        UDim2.fromOffset(12, 10),
        {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 12 or 13,
            Color = App.Colors.Text,
            ZIndex = 1014,
        }
    )

    App:CreateText(
        row,
        description,
        UDim2.new(1, -104, 0, 40),
        UDim2.fromOffset(12, 35),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 9 or 10,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1014,
        }
    )

    local switch = Instance.new('Frame')
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.fromOffset(56, 32)
    switch.BackgroundColor3 = Color3.fromRGB(68, 64, 78)
    switch.BorderSizePixel = 0
    switch.ZIndex = 1015
    switch.Parent = row
    corner(switch, 999)

    local knob = Instance.new('Frame')
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(26, 26)
    knob.BackgroundColor3 = Color3.fromRGB(248, 246, 250)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = switch
    corner(knob, 999)

    local button = Instance.new('TextButton')
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ''
    button.ZIndex = 1017
    button.Parent = row
    App:BindButtonFeedback(button, accent)

    local function render()
        local enabled = getter() == true
        switch.BackgroundColor3 = enabled
            and accent
            or Color3.fromRGB(68, 64, 78)
        knob.Position = UDim2.fromOffset(
            enabled and 27 or 3,
            3
        )
    end

    button.Activated:Connect(function()
        setter(not getter())
        render()
    end)

    render()
end

local function createChoice(
    App,
    parent,
    title,
    choices,
    accent,
    getter,
    setter,
    order
)
    local row = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, 106),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.66,
            Radius = 11,
        }
    )
    row.LayoutOrder = order

    App:CreateText(
        row,
        title,
        UDim2.new(1, -24, 0, 22),
        UDim2.fromOffset(12, 9),
        {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 12 or 13,
            Color = App.Colors.Text,
            ZIndex = 1014,
        }
    )

    local holder = Instance.new('ScrollingFrame')
    holder.Position = UDim2.fromOffset(10, 43)
    holder.Size = UDim2.new(1, -20, 0, 50)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.CanvasSize = UDim2.fromOffset(0, 0)
    holder.AutomaticCanvasSize = Enum.AutomaticSize.X
    holder.ScrollingDirection = Enum.ScrollingDirection.X
    holder.ScrollBarThickness = 3
    holder.ScrollBarImageColor3 = accent
    holder.Active = true
    holder.ZIndex = 1014
    holder.Parent = row

    local layout = Instance.new('UIListLayout')
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = holder

    local refs = {}
    local function render()
        local selectedValue = getter()
        for _, ref in ipairs(refs) do
            local selected = ref.Value == selectedValue
            ref.Button.BackgroundColor3 = selected
                and accent
                or App.Colors.Card
            ref.Button.BackgroundTransparency = selected
                and 0.08
                or 0.24
            ref.Stroke.Transparency = selected
                and 0.02
                or 0.55
            ref.Stroke.Thickness = selected and 2 or 1
        end
    end

    for index, choice in ipairs(choices) do
        local button = Instance.new('TextButton')
        button.Size = UDim2.fromOffset(
            math.clamp(80 + (#choice * 4), 96, 152),
            42
        )
        button.BackgroundColor3 = App.Colors.Card
        button.BackgroundTransparency = 0.24
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBold
        button.Text = choice
        button.TextSize = App:IsMobile() and 10 or 11
        button.TextColor3 = App.Colors.Text
        button.LayoutOrder = index
        button.ZIndex = 1015
        button.Parent = holder
        corner(button, 9)
        local outline = stroke(button, accent, 1, 0.55)
        App:BindButtonFeedback(button, accent)

        button.Activated:Connect(function()
            setter(choice)
            render()
        end)

        table.insert(refs, {
            Button = button,
            Stroke = outline,
            Value = choice,
        })
    end

    render()
end

local function createPresetGrid(
    App,
    parent,
    manager,
    draft,
    accent,
    rerender,
    order
)
    local row = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, 250),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.66,
            Radius = 11,
        }
    )
    row.LayoutOrder = order

    App:CreateText(
        row,
        'THEME PRESETS',
        UDim2.new(1, -24, 0, 22),
        UDim2.fromOffset(12, 10),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 12 or 13,
            Color = accent,
            ZIndex = 1014,
        }
    )

    local grid = Instance.new('Frame')
    grid.Position = UDim2.fromOffset(10, 43)
    grid.Size = UDim2.new(1, -20, 1, -53)
    grid.BackgroundTransparency = 1
    grid.BorderSizePixel = 0
    grid.ZIndex = 1014
    grid.Parent = row

    local layout = Instance.new('UIGridLayout')
    layout.CellSize = UDim2.new(0.333333, -6, 0, 56)
    layout.CellPadding = UDim2.fromOffset(6, 6)
    layout.FillDirectionMaxCells = 3
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = grid

    local names = {
        'SquidNoMo',
        'Neon Pink',
        'Cyber Purple',
        'Ocean Blue',
        'Emerald',
        'Crimson',
        'Amber',
        'Monochrome',
        'High Contrast',
    }

    for index, name in ipairs(names) do
        local preset = manager.Themes[name]
        local color = Color3.fromHSV(
            (preset.AccentHue or 0) / 360,
            (preset.AccentSaturation or 0) / 100,
            (preset.AccentBrightness or 100) / 100
        )
        local button = Instance.new('TextButton')
        button.BackgroundColor3 = color
        button.BackgroundTransparency = 0.16
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBlack
        button.Text = name
        button.TextSize = App:IsMobile() and 9 or 10
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.LayoutOrder = index
        button.ZIndex = 1015
        button.Parent = grid
        corner(button, 9)
        stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.56)
        App:BindButtonFeedback(button, color)

        button.Activated:Connect(function()
            manager:ApplyTheme(draft, name)
            rerender()
        end)
    end
end

function UIPage:Create(Page, App)
    local manager = App.UIStyleManager
    if type(manager) ~= 'table' then
        Page:ClearAllChildren()
        App:BuildErrorPage(
            Page,
            'UI',
            'The UI style manager is unavailable.'
        )
        return
    end

    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = 'UI',
        HeaderHeight = App:IsMobile() and 100 or 106,
    })

    local draft = manager:Clone(App.UIStyleProfile)
    local selectedCategory = App.Session.SelectedUICategory
        or 'Layout & Scale'
    local selectedScope = App.Session.UIEditScope
        or 'Entire App'
    local targetPage = App.Session.UIEditTargetPage
        or 'Players'
    local contentRoot = nil

    local function read(key)
        return manager:GetEditableValue(
            draft,
            selectedScope,
            targetPage,
            key
        )
    end

    local function write(key, value)
        manager:SetValue(
            draft,
            selectedScope,
            targetPage,
            key,
            value
        )
    end

    local function saveEditorState()
        App.Session.SelectedUICategory = selectedCategory
        App.Session.UIEditScope = selectedScope
        App.Session.UIEditTargetPage = targetPage
        App:QueueSettingsSave()
    end

    local renderCategory

    local function createScopeToolbar(root, y)
        local accent = App:GetPageAccent('UI')
        local toolbar = App:CreateCard(
            root,
            UDim2.new(1, 0, 0, 76),
            {
                Color = App.Colors.Card,
                BorderColor = accent,
                BorderTransparency = 0.18,
                Radius = 13,
            }
        )
        toolbar.Position = UDim2.fromOffset(0, y)

        local scopeHolder = Instance.new('Frame')
        scopeHolder.Position = UDim2.fromOffset(12, 12)
        scopeHolder.Size = UDim2.new(0.68, -18, 0, 52)
        scopeHolder.BackgroundTransparency = 1
        scopeHolder.BorderSizePixel = 0
        scopeHolder.Parent = toolbar

        local scopeLayout = Instance.new('UIListLayout')
        scopeLayout.FillDirection = Enum.FillDirection.Horizontal
        scopeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        scopeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        scopeLayout.SortOrder = Enum.SortOrder.LayoutOrder
        scopeLayout.Padding = UDim.new(0, 6)
        scopeLayout.Parent = scopeHolder

        local scopeRefs = {}
        local function refreshScopes()
            for _, ref in ipairs(scopeRefs) do
                local selected = ref.Value == selectedScope
                ref.Button.BackgroundColor3 = selected
                    and accent
                    or App.Colors.CardAlt
                ref.Button.BackgroundTransparency = selected
                    and 0.08
                    or 0.24
                ref.Stroke.Transparency = selected
                    and 0.02
                    or 0.58
            end
        end

        for index, scopeName in ipairs(manager.Scopes) do
            local button = Instance.new('TextButton')
            button.Size = UDim2.new(0.25, -5, 0, 46)
            button.BackgroundColor3 = App.Colors.CardAlt
            button.BackgroundTransparency = 0.24
            button.BorderSizePixel = 0
            button.AutoButtonColor = false
            button.Font = Enum.Font.GothamBold
            button.Text = scopeName
            button.TextSize = App:IsMobile() and 9 or 10
            button.TextColor3 = App.Colors.Text
            button.LayoutOrder = index
            button.ZIndex = 1014
            button.Parent = scopeHolder
            corner(button, 9)
            local outline = stroke(button, accent, 1, 0.58)
            App:BindButtonFeedback(button, accent)

            button.Activated:Connect(function()
                selectedScope = scopeName
                saveEditorState()
                renderCategory(selectedCategory)
            end)

            table.insert(scopeRefs, {
                Button = button,
                Stroke = outline,
                Value = scopeName,
            })
        end
        refreshScopes()

        local targetHolder = Instance.new('Frame')
        targetHolder.AnchorPoint = Vector2.new(1, 0)
        targetHolder.Position = UDim2.new(1, -12, 0, 12)
        targetHolder.Size = UDim2.new(0.32, -2, 0, 52)
        targetHolder.BackgroundColor3 = App.Colors.CardAlt
        targetHolder.BackgroundTransparency = 0.18
        targetHolder.BorderSizePixel = 0
        targetHolder.Parent = toolbar
        corner(targetHolder, 9)
        stroke(targetHolder, accent, 1, 0.56)

        local previous = Instance.new('TextButton')
        previous.Size = UDim2.fromOffset(44, 44)
        previous.Position = UDim2.fromOffset(4, 4)
        previous.BackgroundColor3 = App.Colors.Card
        previous.BackgroundTransparency = 0.12
        previous.BorderSizePixel = 0
        previous.AutoButtonColor = false
        previous.Font = Enum.Font.GothamBlack
        previous.Text = '<'
        previous.TextSize = 18
        previous.TextColor3 = App.Colors.Text
        previous.ZIndex = 1015
        previous.Parent = targetHolder
        corner(previous, 8)
        App:BindButtonFeedback(previous, accent)

        local nextButton = previous:Clone()
        nextButton.AnchorPoint = Vector2.new(1, 0)
        nextButton.Position = UDim2.new(1, -4, 0, 4)
        nextButton.Text = '>'
        nextButton.Parent = targetHolder
        App:BindButtonFeedback(nextButton, accent)

        local targetLabel = App:CreateText(
            targetHolder,
            targetPage,
            UDim2.new(1, -104, 1, 0),
            UDim2.fromOffset(52, 0),
            {
                Font = Enum.Font.GothamBlack,
                TextSize = App:IsMobile() and 10 or 11,
                Color = accent,
                XAlignment = Enum.TextXAlignment.Center,
                ZIndex = 1015,
            }
        )

        local function cycle(direction)
            local current = table.find(PAGE_NAMES, targetPage) or 1
            current = ((current - 1 + direction) % #PAGE_NAMES) + 1
            targetPage = PAGE_NAMES[current]
            targetLabel.Text = targetPage
            saveEditorState()
            if selectedScope == 'Current Page' then
                renderCategory(selectedCategory)
            end
        end

        previous.Activated:Connect(function()
            cycle(-1)
        end)
        nextButton.Activated:Connect(function()
            cycle(1)
        end)

        targetHolder.Visible = selectedScope == 'Current Page'
    end

    local function createActionBar(root, y)
        local accent = App:GetPageAccent('UI')
        local bar = App:CreateCard(
            root,
            UDim2.new(1, 0, 0, 76),
            {
                Color = App.Colors.Card,
                BorderColor = accent,
                BorderTransparency = 0.18,
                Radius = 13,
            }
        )
        bar.Position = UDim2.fromOffset(0, y)

        local actions = {
            {
                Text = 'APPLY CHANGES',
                Color = App.Colors.Success,
                Callback = function()
                    App:SetUIStyleProfile(draft, true)
                end,
            },
            {
                Text = 'UNDO DRAFT',
                Color = App:GetPageAccent('Players'),
                Callback = function()
                    draft = manager:Clone(App.UIStyleProfile)
                    renderCategory(selectedCategory)
                end,
            },
            {
                Text = 'RESTORE SCOPE',
                Color = App.Colors.Error,
                Callback = function()
                    manager:ResetScope(
                        draft,
                        selectedScope,
                        targetPage
                    )
                    renderCategory(selectedCategory)
                end,
            },
        }

        for index, actionInfo in ipairs(actions) do
            local button = Instance.new('TextButton')
            button.Position = UDim2.new(
                (index - 1) / 3,
                index == 1 and 12 or 4,
                0,
                14
            )
            button.Size = UDim2.new(
                0.333333,
                -16,
                0,
                48
            )
            button.BackgroundColor3 = actionInfo.Color
            button.BackgroundTransparency = 0.08
            button.BorderSizePixel = 0
            button.AutoButtonColor = false
            button.Font = Enum.Font.GothamBlack
            button.Text = actionInfo.Text
            button.TextSize = App:IsMobile() and 10 or 11
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.ZIndex = 1014
            button.Parent = bar
            corner(button, 10)
            stroke(
                button,
                Color3.fromRGB(255, 255, 255),
                1,
                0.66
            )
            App:BindButtonFeedback(button, actionInfo.Color)
            button.Activated:Connect(actionInfo.Callback)
        end
    end

    local function buildLayout(columns)
        local accent = App:GetPageAccent('UI')
        local shell = createColumn(
            App,
            columns,
            'WINDOW & SHELL',
            'Global application dimensions and scale.',
            accent,
            1
        )
        local pages = createColumn(
            App,
            columns,
            'PAGE LAYOUT',
            'Spacing for the selected page scope.',
            App:GetPageAccent('Games'),
            2
        )
        local elements = createColumn(
            App,
            columns,
            'SUBPAGES & ELEMENTS',
            'Category bubbles, text, and scrolling.',
            App:GetPageAccent('Players'),
            3
        )

        local function slider(holder, config, key, order)
            createTouchSlider(
                App,
                holder,
                config,
                function()
                    return read(key)
                end,
                function(value)
                    write(key, value)
                end,
                order
            )
        end

        slider(shell, {
            Title = 'Window Width',
            Minimum = 900,
            Maximum = 1600,
            Step = 5,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = accent,
        }, 'WindowWidth', 1)
        slider(shell, {
            Title = 'Window Height',
            Minimum = 540,
            Maximum = 900,
            Step = 5,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = accent,
        }, 'WindowHeight', 2)
        slider(shell, {
            Title = 'Application Scale',
            Minimum = 0.75,
            Maximum = 1.15,
            Step = 0.01,
            Formatter = function(v)
                return formatNumber(v * 100, '%')
            end,
            Accent = accent,
        }, 'AppScale', 3)
        slider(shell, {
            Title = 'Sidebar Width',
            Minimum = 170,
            Maximum = 340,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = accent,
        }, 'SidebarWidth', 4)

        slider(pages, {
            Title = 'Top Bar Height',
            Minimum = 44,
            Maximum = 92,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'TopbarHeight', 1)
        slider(pages, {
            Title = 'Footer Height',
            Minimum = 24,
            Maximum = 64,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'FooterHeight', 2)
        slider(pages, {
            Title = 'Page Padding',
            Minimum = 4,
            Maximum = 36,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'PagePadding', 3)
        slider(pages, {
            Title = 'Column Gap',
            Minimum = 4,
            Maximum = 32,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'ColumnGap', 4)
        slider(pages, {
            Title = 'Section Spacing',
            Minimum = 4,
            Maximum = 36,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'SectionSpacing', 5)

        slider(elements, {
            Title = 'Category Bubble Width',
            Minimum = 145,
            Maximum = 300,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'CategoryBubbleWidth', 1)
        slider(elements, {
            Title = 'Category Bubble Height',
            Minimum = 50,
            Maximum = 92,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'CategoryBubbleHeight', 2)
        slider(elements, {
            Title = 'Category Bar Height',
            Minimum = 82,
            Maximum = 160,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'CategoryBarHeight', 3)
        slider(elements, {
            Title = 'Text Scale',
            Minimum = 0.80,
            Maximum = 1.45,
            Step = 0.01,
            Formatter = function(v)
                return formatNumber(v * 100, '%')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'TextScale', 4)
        slider(elements, {
            Title = 'Scrollbar Thickness',
            Minimum = 2,
            Maximum = 14,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'ScrollbarThickness', 5)
    end

    local function buildThemes(columns)
        local accent = App:GetPageAccent('UI')
        local presets = createColumn(
            App,
            columns,
            'THEME PRESETS',
            'Start with a complete professional palette.',
            accent,
            1
        )
        local primary = createColumn(
            App,
            columns,
            'PRIMARY COLORS',
            'Fine-tune the accent using HSV controls.',
            App:GetPageAccent('Games'),
            2
        )
        local surfaces = createColumn(
            App,
            columns,
            'SURFACES & PAGE ACCENTS',
            'Control contrast and page-specific color.',
            App:GetPageAccent('Settings'),
            3
        )

        createPresetGrid(
            App,
            presets,
            manager,
            draft,
            accent,
            function()
                renderCategory(selectedCategory)
            end,
            1
        )

        createChoice(
            App,
            presets,
            'Accent Mode',
            {'Page Colors', 'Uniform Accent'},
            accent,
            function()
                return read('UniformPageAccents')
                    and 'Uniform Accent'
                    or 'Page Colors'
            end,
            function(choice)
                write(
                    'UniformPageAccents',
                    choice == 'Uniform Accent'
                )
            end,
            2
        )

        local function slider(holder, config, key, order)
            createTouchSlider(
                App,
                holder,
                config,
                function()
                    return read(key)
                end,
                function(value)
                    write(key, value)
                end,
                order
            )
        end

        slider(primary, {
            Title = 'Accent Hue',
            Minimum = 0,
            Maximum = 360,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '°')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'AccentHue', 1)
        slider(primary, {
            Title = 'Accent Saturation',
            Minimum = 0,
            Maximum = 100,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'AccentSaturation', 2)
        slider(primary, {
            Title = 'Accent Brightness',
            Minimum = 40,
            Maximum = 100,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Games'),
        }, 'AccentBrightness', 3)

        slider(surfaces, {
            Title = 'Background Brightness',
            Minimum = 1,
            Maximum = 20,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'BackgroundBrightness', 1)
        slider(surfaces, {
            Title = 'Card Brightness',
            Minimum = 4,
            Maximum = 32,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'CardBrightness', 2)
        slider(surfaces, {
            Title = 'Text Brightness',
            Minimum = 65,
            Maximum = 100,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'TextBrightness', 3)
        slider(surfaces, {
            Title = 'Selected Page Accent Hue',
            Minimum = 0,
            Maximum = 360,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '°')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'PageAccentHue', 4)
    end

    local function buildButtons(columns)
        local accent = App:GetPageAccent('UI')
        local buttons = createColumn(
            App,
            columns,
            'BUTTON STYLES',
            'Shape, size, borders, and press behavior.',
            accent,
            1
        )
        local toggles = createColumn(
            App,
            columns,
            'TOGGLES',
            'Configure switch dimensions and spacing.',
            App:GetPageAccent('Players'),
            2
        )
        local effects = createColumn(
            App,
            columns,
            'SLIDERS & EFFECTS',
            'Touch controls, glow, and animation speed.',
            App:GetPageAccent('Settings'),
            3
        )

        createChoice(
            App,
            buttons,
            'Button Style',
            {'Filled', 'Outline', 'Soft Glow', 'Flat', 'Glass'},
            accent,
            function()
                return read('ButtonStyle')
            end,
            function(value)
                write('ButtonStyle', value)
            end,
            1
        )

        local function slider(holder, config, key, order)
            createTouchSlider(
                App,
                holder,
                config,
                function()
                    return read(key)
                end,
                function(value)
                    write(key, value)
                end,
                order
            )
        end

        slider(buttons, {
            Title = 'Button Height',
            Minimum = 32,
            Maximum = 72,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = accent,
        }, 'ButtonHeight', 2)
        slider(buttons, {
            Title = 'Button Radius',
            Minimum = 2,
            Maximum = 32,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = accent,
        }, 'ButtonRadius', 3)
        slider(buttons, {
            Title = 'Border Thickness',
            Minimum = 0,
            Maximum = 4,
            Step = 0.25,
            Formatter = function(v)
                return formatNumber(v, ' px', 2)
            end,
            Accent = accent,
        }, 'BorderThickness', 4)
        slider(buttons, {
            Title = 'Press Scale',
            Minimum = 90,
            Maximum = 100,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = accent,
        }, 'PressScale', 5)

        createChoice(
            App,
            toggles,
            'Toggle Style',
            {'Switch', 'Pill', 'Checkbox'},
            App:GetPageAccent('Players'),
            function()
                return read('ToggleStyle')
            end,
            function(value)
                write('ToggleStyle', value)
            end,
            1
        )
        slider(toggles, {
            Title = 'Toggle Width',
            Minimum = 42,
            Maximum = 86,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'ToggleWidth', 2)
        slider(toggles, {
            Title = 'Toggle Height',
            Minimum = 22,
            Maximum = 48,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'ToggleHeight', 3)
        slider(toggles, {
            Title = 'Toggle Spacing',
            Minimum = 2,
            Maximum = 24,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Players'),
        }, 'ToggleSpacing', 4)

        slider(effects, {
            Title = 'Slider Track Thickness',
            Minimum = 4,
            Maximum = 18,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'SliderTrack', 1)
        slider(effects, {
            Title = 'Slider Knob Size',
            Minimum = 14,
            Maximum = 34,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, ' px')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'SliderKnob', 2)
        slider(effects, {
            Title = 'Glow Intensity',
            Minimum = 0,
            Maximum = 100,
            Step = 1,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'GlowIntensity', 3)
        slider(effects, {
            Title = 'Animation Speed',
            Minimum = 50,
            Maximum = 200,
            Step = 5,
            Formatter = function(v)
                return formatNumber(v, '%')
            end,
            Accent = App:GetPageAccent('Settings'),
        }, 'AnimationSpeed', 4)
        createToggle(
            App,
            effects,
            'Quick Adjustment Buttons',
            'Show the -10, -5, -1, +1, +5, and +10 helpers on supported sliders.',
            App:GetPageAccent('Settings'),
            function()
                return read('QuickAdjust') == true
            end,
            function(value)
                write('QuickAdjust', value)
            end,
            5
        )
    end

    renderCategory = function(categoryName)
        selectedCategory = categoryName or selectedCategory
        saveEditorState()

        if contentRoot then
            contentRoot:Destroy()
        end

        local pagePadding = App:GetUIStyleValue(
            'UI',
            'PagePadding',
            'MainPage'
        )
        local barHeight = App:GetUIStyleValue(
            'UI',
            'CategoryBarHeight',
            'Subpage'
        )

        contentRoot = Instance.new('Frame')
        contentRoot.Name = 'UICustomizationContent'
        contentRoot.Position = UDim2.fromOffset(
            pagePadding,
            pagePadding
        )
        contentRoot.Size = UDim2.new(
            1,
            -(pagePadding * 2),
            0,
            1260
        )
        contentRoot.BackgroundTransparency = 1
        contentRoot.BorderSizePixel = 0
        contentRoot.Parent = shell.Content

        createScopeToolbar(contentRoot, 0)

        local columns = App:CreateEqualThreeColumnRow(
            contentRoot,
            90,
            1060,
            'UICustomizationColumns'
        )

        if selectedCategory == 'Themes & Colors' then
            buildThemes(columns)
        elseif selectedCategory == 'Buttons & Effects' then
            buildButtons(columns)
        else
            buildLayout(columns)
        end

        createActionBar(contentRoot, 1168)
        shell.Content.CanvasPosition = Vector2.zero
        shell:SetContentHeight(1260 + (pagePadding * 2), App:IsMobile() and 46 or 30)
    end

    App.Loader.CategoryStrip:Create(Page, App, {
        Parent = shell.Header,
        GestureOwner = Page,
        ClearParent = false,
        PageName = 'UI',
        SessionKey = 'SelectedUICategory',
        DefaultName = selectedCategory,
        ScrollerName = 'UICategoryScroller',
        ButtonWidth = 280,
        Items = CATEGORIES,
        OnSelected = function(item)
            renderCategory(item.Name)
        end,
    })
end

return UIPage
