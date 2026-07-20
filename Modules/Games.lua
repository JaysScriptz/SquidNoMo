local GamesPage = {}

local GAME_DEFINITIONS = {
    {
        Name = "Red Light, Green Light",
        Short = "RLGL",
        Description = "Movement timing, stop-state assistance, and round information.",
    },
    {
        Name = "Honeycomb",
        Short = "HC",
        Description = "Precision and shape-focused tools for the Honeycomb round.",
    },
    {
        Name = "Pentathlon",
        Short = "PENTA",
        Description = "Round-specific assistance for the multi-stage Pentathlon.",
    },
    {
        Name = "Hide & Seek (Keys & Knives)",
        Short = "H&S",
        Description = "Key, knife, team, and survival information for Hide & Seek.",
    },
    {
        Name = "Jump Rope",
        Short = "ROPE",
        Description = "Timing and movement information for the Jump Rope round.",
    },
    {
        Name = "Sky Squid",
        Short = "SKY",
        Description = "Arena and player-state tools for Sky Squid.",
    },
    {
        Name = "Mingle",
        Short = "MINGLE",
        Description = "Room, group-size, and round-state information for Mingle.",
    },
    {
        Name = "Fight Nights",
        Short = "FIGHT",
        Description = "Local survival and player-awareness tools for Fight Nights.",
    },
    {
        Name = "Rebellion",
        Short = "REBELLION",
        Description = "Objective and player-awareness tools for Rebellion.",
    },
    {
        Name = "Tug of War",
        Short = "TUG",
        Description = "Timing and team-state information for Tug of War.",
    },
    {
        Name = "Marbles",
        Short = "MARBLES",
        Description = "Round information and stable assistance for Marbles.",
    },
    {
        Name = "Rock, Paper, Scissors Minus One",
        Short = "RPS-1",
        Description = "Choice and round-state information for RPS Minus One.",
    },
    {
        Name = "Glass Bridge",
        Short = "GLASS",
        Description = "Bridge progression and round information for Glass Bridge.",
    },
    {
        Name = "Squid Game",
        Short = "SQUID",
        Description = "Final-round player and objective information for Squid Game.",
    },
}

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function createInfoPanel(App, parent, title, accent, order)
    local panel = App:CreateCard(parent, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(14, 10, 20),
        BorderColor = accent,
        BorderTransparency = 0.14,
        Radius = App:IsMobile() and 13 or 16,
    })
    panel.LayoutOrder = order

    App:CreateText(
        panel,
        title,
        UDim2.new(1, -28, 0, 28),
        UDim2.fromOffset(14, 14),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 15 or 18,
            Color = accent,
            ZIndex = 1013,
        }
    )

    local body = App:CreateText(
        panel,
        "",
        UDim2.new(1, -28, 1, -66),
        UDim2.fromOffset(14, 52),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 12 or 13,
            Color = App.Colors.Text,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1013,
        }
    )

    return panel, body
end

function GamesPage:Create(Page, App)
    Page:ClearAllChildren()

    local padding = App.Profile.ContentPadding
    local accent = App:GetPageAccent("Games")

    local root = Instance.new("Frame")
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 720)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local header = App:CreateCard(root, UDim2.new(1, 0, 0, 70), {
        Color = Color3.fromRGB(15, 10, 23),
        BorderColor = accent,
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 14 or 17,
    })
    header.Position = UDim2.fromOffset(0, 0)

    App:CreateText(
        header,
        "GAMES",
        UDim2.new(1, -36, 0, 28),
        UDim2.fromOffset(18, 10),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 20 or 23,
            Color = accent,
            ZIndex = 1013,
        }
    )

    App:CreateText(
        header,
        "Choose a round below. Only tested, game-specific features will be added to each category.",
        UDim2.new(1, -36, 0, 24),
        UDim2.fromOffset(18, 38),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 11 or 12,
            Color = App.Colors.Text,
            Wrapped = true,
            ZIndex = 1013,
        }
    )

    -- 108 pixels tall: large enough to swipe and read, but well under
    -- one-quarter of the Games page content height.
    local categoryCard = App:CreateCard(root, UDim2.new(1, 0, 0, 108), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = App.Colors.Border,
        BorderTransparency = 0.14,
        Radius = App:IsMobile() and 13 or 16,
    })
    categoryCard.Position = UDim2.fromOffset(0, 82)
    categoryCard.ClipsDescendants = true

    local scroller = Instance.new("ScrollingFrame")
    scroller.Name = "GameCategoryScroller"
    scroller.Position = UDim2.fromOffset(12, 12)
    scroller.Size = UDim2.new(1, -24, 1, -24)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.CanvasSize = UDim2.fromOffset(0, 0)
    scroller.AutomaticCanvasSize = Enum.AutomaticSize.X
    scroller.ScrollingDirection = Enum.ScrollingDirection.X
    scroller.ScrollBarThickness = 5
    scroller.ScrollBarImageColor3 = accent
    scroller.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    scroller.Active = true
    scroller.ZIndex = 1012
    scroller.Parent = categoryCard

    local scrollerPadding = Instance.new("UIPadding")
    scrollerPadding.PaddingLeft = UDim.new(0, 2)
    scrollerPadding.PaddingRight = UDim.new(0, 2)
    scrollerPadding.PaddingTop = UDim.new(0, 5)
    scrollerPadding.PaddingBottom = UDim.new(0, 10)
    scrollerPadding.Parent = scroller

    local scrollerLayout = Instance.new("UIListLayout")
    scrollerLayout.FillDirection = Enum.FillDirection.Horizontal
    scrollerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    scrollerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    scrollerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollerLayout.Padding = UDim.new(0, 10)
    scrollerLayout.Parent = scroller

    local selectionCard = App:CreateCard(root, UDim2.new(1, 0, 0, 96), {
        Color = Color3.fromRGB(15, 10, 23),
        BorderColor = accent,
        BorderTransparency = 0.12,
        Radius = App:IsMobile() and 13 or 16,
    })
    selectionCard.Position = UDim2.fromOffset(0, 202)

    local selectedTitle = App:CreateText(
        selectionCard,
        "",
        UDim2.new(1, -36, 0, 30),
        UDim2.fromOffset(18, 14),
        {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 18 or 21,
            Color = accent,
            ZIndex = 1013,
        }
    )

    local selectedDescription = App:CreateText(
        selectionCard,
        "",
        UDim2.new(1, -36, 0, 38),
        UDim2.fromOffset(18, 48),
        {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 11 or 12,
            Color = App.Colors.Text,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1013,
        }
    )

    local contentRow = App:CreateEqualThreeColumnRow(
        root,
        310,
        380,
        "GamesSelectedContent"
    )

    local _, overviewBody = createInfoPanel(
        App,
        contentRow,
        "ROUND OVERVIEW",
        accent,
        1
    )
    local _, featureBody = createInfoPanel(
        App,
        contentRow,
        "STABLE FEATURES",
        App.Colors.Success,
        2
    )
    local _, statusBody = createInfoPanel(
        App,
        contentRow,
        "INTEGRATION STATUS",
        App.Colors.Warning,
        3
    )

    local buttonRefs = {}
    local selectedIndex = 1

    local function renderSelection(index)
        selectedIndex = index
        local definition = GAME_DEFINITIONS[index]

        selectedTitle.Text = definition.Name
        selectedDescription.Text = definition.Description

        overviewBody.Text =
            "Selected round:\n\n"
            .. definition.Name
            .. "\n\nThis workspace keeps each game's controls separate so "
            .. "features can be tested without affecting other rounds."

        featureBody.Text =
            "0 linked features\n\nOnly stable features that pass runtime "
            .. "testing will appear here. No placeholder toggles are shown."

        statusBody.Text =
            "READY FOR INTEGRATION\n\n"
            .. "The category, scrolling behavior, and content workspace are "
            .. "connected. Feature work can now begin for this round."

        if App.Session then
            App.Session.SelectedGameCategory = definition.Name
        end

        for buttonIndex, refs in ipairs(buttonRefs) do
            local selected = buttonIndex == selectedIndex
            refs.Button.BackgroundColor3 = selected
                and accent
                or App.Colors.CardAlt
            refs.Button.BackgroundTransparency = selected and 0.08 or 0.28
            refs.Stroke.Color = selected and accent or App.Colors.BorderSoft
            refs.Stroke.Transparency = selected and 0.02 or 0.55
            refs.Stroke.Thickness = selected and 2 or 1
            refs.Title.TextColor3 = selected
                and Color3.fromRGB(255, 255, 255)
                or App.Colors.Text
            refs.Code.TextColor3 = selected and Color3.fromRGB(
                255,
                255,
                255
            ) or accent
        end
    end

    for index, definition in ipairs(GAME_DEFINITIONS) do
        local width = math.clamp(
            130 + (#definition.Name * 4),
            170,
            270
        )

        local button = Instance.new("TextButton")
        button.Name = "Game_" .. tostring(index)
        button.Size = UDim2.fromOffset(width, 66)
        button.BackgroundColor3 = App.Colors.CardAlt
        button.BackgroundTransparency = 0.28
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = ""
        button.LayoutOrder = index
        button.ZIndex = 1013
        button.Parent = scroller
        makeCorner(button, 12)

        local outline = makeStroke(
            button,
            App.Colors.BorderSoft,
            1,
            0.55
        )

        local code = App:CreateText(
            button,
            definition.Short,
            UDim2.fromOffset(64, 18),
            UDim2.fromOffset(12, 9),
            {
                Font = Enum.Font.GothamBlack,
                TextSize = 10,
                Color = accent,
                ZIndex = 1014,
            }
        )

        local title = App:CreateText(
            button,
            definition.Name,
            UDim2.new(1, -24, 0, 28),
            UDim2.fromOffset(12, 28),
            {
                Font = Enum.Font.GothamBold,
                TextSize = App:IsMobile() and 11 or 12,
                Color = App.Colors.Text,
                Wrapped = true,
                ZIndex = 1014,
            }
        )

        App:BindButtonFeedback(button, accent)

        button.Activated:Connect(function()
            renderSelection(index)
        end)

        buttonRefs[index] = {
            Button = button,
            Stroke = outline,
            Title = title,
            Code = code,
        }
    end

    local saved = App.Session and App.Session.SelectedGameCategory
    if type(saved) == "string" then
        for index, definition in ipairs(GAME_DEFINITIONS) do
            if definition.Name == saved then
                selectedIndex = index
                break
            end
        end
    end

    renderSelection(selectedIndex)
end

return GamesPage
