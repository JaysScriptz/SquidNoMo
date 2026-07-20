local CategoryStrip = {}

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 13)
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

function CategoryStrip:Create(Page, App, options)
    Page:ClearAllChildren()
    options = options or {}

    local items = options.Items or {}
    local pageName = options.PageName or "Games"
    local sessionKey = options.SessionKey or "SelectedCategory"
    local defaultName = options.DefaultName or (items[1] and items[1].Name)
    local buttonWidth = options.ButtonWidth or 190
    local accent = App:GetPageAccent(pageName)
    local padding = App.Profile.ContentPadding

    local root = Instance.new("Frame")
    root.Name = pageName .. "CategoryRoot"
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 112)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local card = App:CreateCard(root, UDim2.new(1, 0, 0, 108), {
        Color = Color3.fromRGB(13, 10, 18),
        BorderColor = accent,
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 13 or 16,
    })
    card.Position = UDim2.fromOffset(0, 0)
    card.ClipsDescendants = true

    local scroller = Instance.new("ScrollingFrame")
    scroller.Name = options.ScrollerName or (pageName .. "CategoryScroller")
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
    scroller.Parent = card

    local paddingObject = Instance.new("UIPadding")
    paddingObject.PaddingLeft = UDim.new(0, 2)
    paddingObject.PaddingRight = UDim.new(0, 2)
    paddingObject.PaddingTop = UDim.new(0, 5)
    paddingObject.PaddingBottom = UDim.new(0, 10)
    paddingObject.Parent = scroller

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroller

    local refs = {}
    local selectedIndex = 1

    local function renderSelection(index)
        selectedIndex = index
        local item = items[index]
        if not item then
            return
        end

        if App.Session then
            App.Session[sessionKey] = item.Name
        end

        if type(App.QueueSettingsSave) == "function" then
            App:QueueSettingsSave()
        end

        for refIndex, ref in ipairs(refs) do
            local selected = refIndex == selectedIndex
            ref.Button.BackgroundColor3 = selected and accent or App.Colors.CardAlt
            ref.Button.BackgroundTransparency = selected and 0.08 or 0.28
            ref.Stroke.Color = selected and accent or App.Colors.BorderSoft
            ref.Stroke.Transparency = selected and 0.02 or 0.55
            ref.Stroke.Thickness = selected and 2 or 1
            ref.Title.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or App.Colors.Text
            ref.Code.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or accent
        end
    end

    for index, item in ipairs(items) do
        local button = Instance.new("TextButton")
        button.Name = pageName .. "Category_" .. tostring(index)
        button.Size = UDim2.fromOffset(buttonWidth, 66)
        button.BackgroundColor3 = App.Colors.CardAlt
        button.BackgroundTransparency = 0.28
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = ""
        button.LayoutOrder = index
        button.ZIndex = 1013
        button.Parent = scroller
        makeCorner(button, 12)

        local outline = makeStroke(button, App.Colors.BorderSoft, 1, 0.55)

        local code = App:CreateText(button, item.Short or tostring(index), UDim2.fromOffset(82, 18), UDim2.fromOffset(12, 8), {
            Font = Enum.Font.GothamBlack,
            TextSize = 10,
            Color = accent,
            ZIndex = 1014,
        })

        local title = App:CreateText(button, item.Name, UDim2.new(1, -24, 0, 32), UDim2.fromOffset(12, 27), {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 11 or 12,
            Color = App.Colors.Text,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Center,
            ZIndex = 1014,
        })

        App:BindButtonFeedback(button, accent)
        button.Activated:Connect(function()
            renderSelection(index)
        end)

        refs[index] = {
            Button = button,
            Stroke = outline,
            Title = title,
            Code = code,
        }
    end

    local saved = App.Session and App.Session[sessionKey]
    local target = type(saved) == "string" and saved or defaultName

    if type(target) == "string" then
        for index, item in ipairs(items) do
            if item.Name == target then
                selectedIndex = index
                break
            end
        end
    end

    renderSelection(selectedIndex)
end

return CategoryStrip
