local PlayersPage = {}

local CATEGORIES = {
    {
        Name = "Movement & Camera",
        Short = "MOVE",
    },
    {
        Name = "Player ESP",
        Short = "ESP",
    },
    {
        Name = "Local Utilities",
        Short = "TOOLS",
    },
}

local function getFeature(App, id)
    local manager = App.FeatureManager
    local entry = manager
        and manager.Registry
        and manager.Registry[id]
    return entry and entry.Feature or nil
end

local function notify(App)
    if App.FeatureManager
        and type(App.FeatureManager.Notify)
            == "function"
    then
        App.FeatureManager:Notify()
    end
end

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius =
        UDim.new(0, radius or 12)
    corner.Parent = parent
end

local function createRoot(
    Page,
    App,
    topY,
    cardHeight
)
    local padding = App:GetUIStyleValue(
        "Players",
        "PagePadding",
        "MainPage"
    ) or App.Profile.ContentPadding

    local root = Instance.new("Frame")
    root.Name = "PlayerSubpageContent"
    root:SetAttribute(
        "SquidNoMoSubpage",
        true
    )
    root.Position =
        UDim2.fromOffset(padding, topY)
    root.Size = UDim2.new(
        1,
        -(padding * 2),
        0,
        10
    )
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local grid = Instance.new("UIGridLayout")
    grid.SortOrder =
        Enum.SortOrder.LayoutOrder
    grid.CellPadding =
        UDim2.fromOffset(12, 12)
    grid.CellSize = UDim2.new(
        0.5,
        -6,
        0,
        cardHeight
    )
    grid.Parent = root

    Page.AutomaticCanvasSize =
        Enum.AutomaticSize.None

    local function updateCanvas()
        local height = math.max(
            cardHeight,
            grid.AbsoluteContentSize.Y
        )
        root.Size = UDim2.new(
            1,
            -(padding * 2),
            0,
            height
        )
        Page.CanvasSize = UDim2.fromOffset(
            0,
            topY + height + 36
        )
    end

    grid:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(updateCanvas)
    Page:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(updateCanvas)
    task.defer(updateCanvas)
    task.delay(0.15, updateCanvas)

    return root
end

local function createToggle(
    App,
    parent,
    title,
    description,
    accent,
    featureId,
    order
)
    local card = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, 132),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.18,
            Radius = 14,
        }
    )
    card.LayoutOrder = order

    App:CreateText(
        card,
        title,
        UDim2.new(1, -92, 0, 24),
        UDim2.fromOffset(14, 14),
        {
            Font = Enum.Font.GothamBold,
            TextSize =
                App:IsMobile() and 13 or 14,
            Color = App.Colors.Text,
            ZIndex = 1014,
        }
    )

    App:CreateText(
        card,
        description,
        UDim2.new(1, -98, 0, 58),
        UDim2.fromOffset(14, 44),
        {
            Font = Enum.Font.GothamMedium,
            TextSize =
                App:IsMobile() and 10 or 11,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment =
                Enum.TextYAlignment.Top,
            ZIndex = 1014,
        }
    )

    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position =
        UDim2.new(1, -14, 0, 14)
    button.Size = UDim2.fromOffset(58, 32)
    button.BackgroundColor3 =
        Color3.fromRGB(70, 66, 80)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 1015
    button.Parent = card
    makeCorner(button, 999)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(26, 26)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 =
        Color3.fromRGB(242, 239, 247)
    knob.BorderSizePixel = 0
    knob.ZIndex = 1016
    knob.Parent = button
    makeCorner(knob, 999)

    local feature =
        getFeature(App, featureId)

    local function isEnabled()
        if feature
            and type(feature.IsEnabled)
                == "function"
        then
            local ok, state = pcall(
                feature.IsEnabled,
                feature
            )
            return ok and state == true
        end

        return false
    end

    local function render()
        local enabled = isEnabled()
        button.BackgroundColor3 =
            enabled
            and accent
            or Color3.fromRGB(70, 66, 80)
        knob.Position = UDim2.fromOffset(
            enabled and 29 or 3,
            3
        )
    end

    button.Activated:Connect(function()
        feature =
            feature
            or getFeature(App, featureId)

        if not feature then
            return
        end

        local method = isEnabled()
            and feature.Disable
            or feature.Enable

        if type(method) == "function" then
            local ok, result, detail =
                pcall(method, feature)
            if not ok or result == false then
                local message = not ok
                    and tostring(result)
                    or tostring(
                        detail
                        or "The feature rejected the toggle."
                    )
                warn(
                    "[SquidNoMo] "
                    .. title
                    .. " failed: "
                    .. message
                )
                if App.Notifications
                    and type(
                        App.Notifications.Error
                    ) == "function"
                then
                    App.Notifications:Error(
                        title,
                        message,
                        5
                    )
                end
            end
            notify(App)
            render()
        end
    end)

    App:BindButtonFeedback(button, accent)
    render()
    return card
end

local function createSliderCard(
    App,
    parent,
    title,
    accent,
    featureId,
    minimum,
    maximum,
    defaultValue,
    order
)
    local cardHeight = App:IsMobile() and 164 or 156
    local card = App:CreateCard(
        parent,
        UDim2.new(1, 0, 0, cardHeight),
        {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.18,
            Radius = 14,
        }
    )
    card.LayoutOrder = order

    App:CreateText(
        card,
        title,
        UDim2.new(1, -86, 0, 24),
        UDim2.fromOffset(14, 12),
        {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 15 or 14,
            Color = App.Colors.Text,
            ZIndex = 1014,
        }
    )

    local valueLabel = App:CreateText(
        card,
        tostring(defaultValue),
        UDim2.fromOffset(72, 24),
        UDim2.new(1, -86, 0, 12),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 15 or 14,
            Color = accent,
            XAlignment = Enum.TextXAlignment.Right,
            ZIndex = 1014,
        }
    )

    local feature = getFeature(App, featureId)
    local current = defaultValue

    if feature and type(feature.Get) == "function" then
        local ok, value = pcall(feature.Get, feature)
        if ok and type(value) == "number" then
            current = value
        end
    end

    local controller

    local function applyValue(nextValue)
        current = math.clamp(
            math.floor((tonumber(nextValue) or current) + 0.5),
            minimum,
            maximum
        )
        valueLabel.Text = tostring(current)

        feature = feature or getFeature(App, featureId)
        if feature and type(feature.Set) == "function" then
            local ok, result = pcall(feature.Set, feature, current)
            if not ok then
                warn("[SquidNoMo] " .. title .. " failed: " .. tostring(result))
            end
            notify(App)
        end
    end

    local controls = Instance.new("Frame")
    controls.Name = "TouchSliderControls"
    controls.Position = UDim2.fromOffset(12, 46)
    controls.Size = UDim2.new(1, -24, 0, App:IsMobile() and 58 or 54)
    controls.BackgroundTransparency = 1
    controls.BorderSizePixel = 0
    controls.Parent = card

    local buttonSize = App:IsMobile() and 48 or 44
    local buttonGap = App:IsMobile() and 6 or 5
    local totalButtonWidth = (buttonSize * 4) + (buttonGap * 4)

    local sliderHost = Instance.new("Frame")
    sliderHost.Name = "GrabBarHost"
    sliderHost.Position = UDim2.fromOffset(
        (buttonSize * 2) + (buttonGap * 2),
        0
    )
    sliderHost.Size = UDim2.new(
        1,
        -totalButtonWidth,
        1,
        0
    )
    sliderHost.BackgroundTransparency = 1
    sliderHost.BorderSizePixel = 0
    sliderHost.Parent = controls

    controller = App:CreateSlider(sliderHost, {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        Min = minimum,
        Max = maximum,
        Value = current,
        AccentColor = accent,
        TrackHeight = App:IsMobile() and 18 or 16,
        KnobSize = App:IsMobile() and 40 or 36,
        OnChanged = applyValue,
    })

    local range = maximum - minimum
    local smallStep = 1
    local largeStep = math.max(5, math.floor((range * 0.05) + 0.5))
    if featureId == "player.gravity" then
        largeStep = 10
    end

    local function makeStepButton(label, position, delta)
        local button = App:CreateQuickButton(
            controls,
            label,
            UDim2.fromOffset(buttonSize, buttonSize),
            accent
        )
        button.Position = position
        button.AnchorPoint = Vector2.new(0, 0.5)
        button.TextSize = App:IsMobile() and 20 or 18
        button.ZIndex = 1018

        local held = false
        local holdToken = 0

        local function step()
            applyValue(current + delta)
            controller:SetValue(current, false)
        end

        button.Activated:Connect(step)
        button.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch
                and input.UserInputType ~= Enum.UserInputType.MouseButton1
            then
                return
            end
            held = true
            holdToken = holdToken + 1
            local token = holdToken
            task.delay(0.42, function()
                while held and token == holdToken do
                    step()
                    task.wait(App:IsMobile() and 0.11 or 0.08)
                end
            end)
        end)
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1
            then
                held = false
                holdToken = holdToken + 1
            end
        end)
        return button
    end

    local centerY = UDim2.new(0, 0, 0.5, 0)
    makeStepButton("◀", centerY, -smallStep)
    makeStepButton(
        "⏪",
        UDim2.new(0, buttonSize + buttonGap, 0.5, 0),
        -largeStep
    )
    makeStepButton(
        "⏩",
        UDim2.new(1, -(buttonSize * 2 + buttonGap), 0.5, 0),
        largeStep
    )
    makeStepButton(
        "▶",
        UDim2.new(1, -buttonSize, 0.5, 0),
        smallStep
    )

    local hint = App:CreateText(
        card,
        "Tap arrows for precise steps, hold to repeat, or drag the large center handle.",
        UDim2.new(1, -28, 0, 34),
        UDim2.fromOffset(14, App:IsMobile() and 112 or 108),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 11 or 10,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1014,
        }
    )
    hint.Name = "SliderHelp"

    controller:SetValue(current, false)
    return card
end

local function addColorSwatches(
    App,
    card,
    featureId,
    colors
)
    local row = Instance.new("Frame")
    row.Position =
        UDim2.fromOffset(14, 94)
    row.Size =
        UDim2.new(1, -28, 0, 26)
    row.BackgroundTransparency = 1
    row.Parent = card

    local layout =
        Instance.new("UIListLayout")
    layout.FillDirection =
        Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 10)
    layout.Parent = row

    local feature =
        getFeature(App, featureId)

    for _, color in ipairs(colors) do
        local swatch =
            Instance.new("TextButton")
        swatch.Size =
            UDim2.fromOffset(24, 24)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.AutoButtonColor = false
        swatch.Text = ""
        swatch.Parent = row
        makeCorner(swatch, 7)

        swatch.Activated:Connect(
            function()
                feature =
                    feature
                    or getFeature(
                        App,
                        featureId
                    )

                if feature
                    and type(
                        feature.SetColor
                    ) == "function"
                then
                    pcall(
                        feature.SetColor,
                        feature,
                        color
                    )
                    notify(App)
                end
            end
        )
    end
end

local function buildMovement(
    Page,
    App,
    topY
)
    local root =
        createRoot(Page, App, topY, App:IsMobile() and 164 or 156)

    createSliderCard(
        App,
        root,
        "Walk Speed",
        Color3.fromRGB(0, 190, 255),
        "player.walk_speed",
        16,
        120,
        16,
        1
    )
    createSliderCard(
        App,
        root,
        "Jump Power",
        Color3.fromRGB(180, 76, 255),
        "player.jump_power",
        50,
        220,
        50,
        2
    )
    createSliderCard(
        App,
        root,
        "Gravity",
        Color3.fromRGB(255, 190, 58),
        "player.gravity",
        50,
        196,
        196,
        3
    )
    createToggle(
        App,
        root,
        "Infinite Jump",
        "Allows repeated jumps while airborne.",
        Color3.fromRGB(255, 88, 110),
        "player.infinite_jump",
        4
    )
    createToggle(
        App,
        root,
        "Auto Jump",
        "Automatically jumps while moving and grounded.",
        Color3.fromRGB(255, 140, 70),
        "player.auto_jump",
        5
    )
    createToggle(
        App,
        root,
        "Noclip",
        "Disables local character collision.",
        Color3.fromRGB(130, 110, 255),
        "player.noclip",
        6
    )
    createToggle(
        App,
        root,
        "Force Third Person",
        "Keeps the camera in a readable third-person range.",
        Color3.fromRGB(58, 210, 255),
        "player.force_third_person",
        7
    )
    createToggle(
        App,
        root,
        "Unlock Camera Zoom",
        "Raises the local maximum camera zoom distance.",
        Color3.fromRGB(255, 180, 70),
        "player.unlock_zoom",
        8
    )
    createToggle(
        App,
        root,
        "Auto Stand",
        "Recovers from sitting and platform-stand states.",
        Color3.fromRGB(80, 255, 150),
        "player.auto_stand",
        9
    )
end

local function buildESP(Page, App, topY)
    local root =
        createRoot(Page, App, topY, 132)

    local definitions = {
        {
            "Player ESP",
            "Highlights standard players.",
            Color3.fromRGB(0, 170, 255),
            "player.player_esp",
            {
                Color3.fromRGB(0, 170, 255),
                Color3.fromRGB(66, 255, 105),
                Color3.fromRGB(
                    255,
                    255,
                    255
                ),
            },
        },
        {
            "Guard ESP",
            "Highlights detected guards.",
            Color3.fromRGB(235, 55, 70),
            "player.guard_esp",
            {
                Color3.fromRGB(235, 55, 70),
                Color3.fromRGB(
                    255,
                    146,
                    54
                ),
                Color3.fromRGB(
                    255,
                    64,
                    164
                ),
            },
        },
        {
            "Detective ESP",
            "Highlights detected detectives.",
            Color3.fromRGB(0, 230, 150),
            "player.detective_esp",
            {
                Color3.fromRGB(
                    0,
                    230,
                    150
                ),
                Color3.fromRGB(
                    0,
                    198,
                    255
                ),
                Color3.fromRGB(
                    255,
                    214,
                    74
                ),
            },
        },
        {
            "Frontman ESP",
            "Highlights detected frontmen.",
            Color3.fromRGB(
                172,
                76,
                255
            ),
            "player.frontman_esp",
            {
                Color3.fromRGB(
                    172,
                    76,
                    255
                ),
                Color3.fromRGB(
                    225,
                    73,
                    255
                ),
                Color3.fromRGB(
                    240,
                    240,
                    255
                ),
            },
        },
        {
            "Distance ESP",
            "Displays distance information.",
            Color3.fromRGB(0, 205, 255),
            "player.distance_esp",
            {
                Color3.fromRGB(
                    0,
                    205,
                    255
                ),
                Color3.fromRGB(
                    90,
                    255,
                    210
                ),
                Color3.fromRGB(
                    255,
                    255,
                    255
                ),
            },
        },
        {
            "Health ESP",
            "Displays health information.",
            Color3.fromRGB(255, 82, 82),
            "player.health_esp",
            {
                Color3.fromRGB(
                    255,
                    82,
                    82
                ),
                Color3.fromRGB(
                    255,
                    172,
                    64
                ),
                Color3.fromRGB(
                    85,
                    255,
                    127
                ),
            },
        },
        {
            "Name ESP",
            "Displays player names above characters.",
            Color3.fromRGB(245, 245, 255),
            "player.name_esp",
            {
                Color3.fromRGB(245, 245, 255),
                Color3.fromRGB(80, 220, 255),
                Color3.fromRGB(255, 210, 70),
            },
        },
        {
            "Box ESP",
            "Draws an always-visible player outline.",
            Color3.fromRGB(255, 210, 70),
            "player.box_esp",
            {
                Color3.fromRGB(255, 210, 70),
                Color3.fromRGB(255, 82, 110),
                Color3.fromRGB(80, 255, 150),
            },
        },
    }

    for index, definition in ipairs(
        definitions
    ) do
        local card = createToggle(
            App,
            root,
            definition[1],
            definition[2],
            definition[3],
            definition[4],
            index
        )
        addColorSwatches(
            App,
            card,
            definition[4],
            definition[5]
        )
    end
end

local function buildUtilities(
    Page,
    App,
    topY
)
    local root =
        createRoot(Page, App, topY, 132)

    local definitions = {
        {
            "Anti AFK",
            "Prevents idle disconnects.",
            Color3.fromRGB(
                66,
                255,
                130
            ),
            "player.anti_afk",
        },
        {
            "Anti Lag",
            "Reduces expensive local effects.",
            Color3.fromRGB(
                0,
                170,
                255
            ),
            "player.anti_lag",
        },
        {
            "Hide Other Players",
            "Hides other characters locally.",
            Color3.fromRGB(
                188,
                84,
                255
            ),
            "player.hide_others",
        },
        {
            "Hide Local Character",
            "Hides your character locally.",
            Color3.fromRGB(
                255,
                159,
                67
            ),
            "player.hide_self",
        },
        {
            "Tool ESP",
            "Highlights tools and interactables.",
            Color3.fromRGB(
                255,
                210,
                60
            ),
            "player.tool_esp",
        },
        {
            "Mute Character Sounds",
            "Mutes character sounds locally.",
            Color3.fromRGB(
                100,
                200,
                255
            ),
            "player.mute_character_sounds",
        },
        {
            "Reset Character",
            "Requests one local character reset.",
            Color3.fromRGB(255, 105, 105),
            "player.reset",
        },
        {
            "Rejoin Server",
            "Requests a rejoin to the current server.",
            Color3.fromRGB(90, 205, 255),
            "player.rejoin",
        },
    }

    for index, definition in ipairs(
        definitions
    ) do
        createToggle(
            App,
            root,
            definition[1],
            definition[2],
            definition[3],
            definition[4],
            index
        )
    end
end

function PlayersPage:Create(Page, App)
    -- Explicit mobile scrolling setup. The page uses a manual canvas because
    -- its two-column grid is rebuilt whenever a subpage changes.
    Page.Active = true
    Page.ScrollingEnabled = true
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    Page.ScrollBarThickness = App:IsMobile() and 10 or 7
    Page.ScrollBarImageTransparency = 0.05
    Page.AutomaticCanvasSize = Enum.AutomaticSize.None

    local selected =
        App.Session.SelectedPlayerCategory
        or "Movement & Camera"

    local selector =
        App.Loader.CategoryStrip:Create(
            Page,
            App,
            {
                PageName = "Players",
                SessionKey =
                    "SelectedPlayerCategory",
                DefaultName =
                    "Movement & Camera",
                ScrollerName =
                    "PlayerCategoryScroller",
                ButtonWidth = 220,
                Items = CATEGORIES,
                OnSelected = function(item)
                    selected = item.Name

                    local old =
                        Page:FindFirstChild(
                            "PlayerSubpageContent"
                        )
                    if old then
                        old:Destroy()
                    end

                    Page.CanvasPosition = Vector2.new(0, 0)
                    Page.ScrollingEnabled = true

                    local selectorRoot =
                        Page:FindFirstChild(
                            "PlayersCategoryRoot"
                        )
                    local topY = 128

                    if selectorRoot then
                        topY =
                            selectorRoot
                                .Position.Y.Offset
                            + selectorRoot
                                .Size.Y.Offset
                            + 12
                    end

                    if item.Name
                        == "Movement & Camera"
                    then
                        buildMovement(
                            Page,
                            App,
                            topY
                        )
                    elseif item.Name
                        == "Player ESP"
                    then
                        buildESP(
                            Page,
                            App,
                            topY
                        )
                    else
                        buildUtilities(
                            Page,
                            App,
                            topY
                        )
                    end
                end,
            }
        )

    if selector and selector.Select then
        local index = 1

        for itemIndex, item in ipairs(
            CATEGORIES
        ) do
            if item.Name == selected then
                index = itemIndex
                break
            end
        end

        selector.Select(index)
    end
end

return PlayersPage
