local FeatureFolder = {}

local cache = {}

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
end

local function loadFeature(App, path)
    if cache[path] then
        return cache[path]
    end

    local loader = App.Loader
    local feature
    if loader and type(loader.LoadRemote) == "function" then
        feature = loader:LoadRemote(path)
    else
        feature = loadstring(game:HttpGet(App.Config.Repository .. path))()
    end

    cache[path] = feature
    return feature
end

local function enabledState(feature)
    if type(feature) ~= "table" then
        return false
    end
    if type(feature.IsEnabled) == "function" then
        local ok, value = pcall(feature.IsEnabled, feature)
        if ok then return value == true end
    end
    return feature.Enabled == true or feature.Active == true
end

function FeatureFolder:Render(Page, App, options)
    options = options or {}
    local pageName = options.PageName or "Games"
    local topY = options.TopY or 128
    local accent = App:GetPageAccent(pageName)
    local padding = App:GetUIStyleValue(pageName, "PagePadding", "MainPage") or 18

    local old = Page:FindFirstChild(pageName .. "FeatureContent")
    if old then old:Destroy() end

    local content = Instance.new("Frame")
    content.Name = pageName .. "FeatureContent"
    content:SetAttribute("SquidNoMoSubpage", true)
    content.Position = UDim2.fromOffset(padding, topY)
    content.Size = UDim2.new(1, -(padding * 2), 0, 10)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Parent = Page

    local grid = Instance.new("UIGridLayout")
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    -- Feature subpages always use two columns, including phones. This keeps
    -- controls compact instead of stretching every button across the page.
    local cellGap = App:IsMobile() and 8 or 12
    local cardHeight = App:IsMobile() and 158 or 142
    grid.CellPadding = UDim2.fromOffset(cellGap, cellGap)
    grid.CellSize = UDim2.new(0.5, -(cellGap / 2), 0, cardHeight)
    grid.Parent = content

    local features = options.Features or {}
    for index, info in ipairs(features) do
        local card = App:CreateCard(content, UDim2.new(1, 0, 0, cardHeight), {
            Color = App.Colors.CardAlt,
            BorderColor = accent,
            BorderTransparency = 0.18,
            Radius = 14,
        })
        card.LayoutOrder = index

        App:CreateText(card, info.Name, UDim2.new(1, -28, 0, 44), UDim2.fromOffset(14, 12), {
            Font = Enum.Font.GothamBold,
            TextSize = App:IsMobile() and 14 or 15,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            Color = App.Colors.Text,
            ZIndex = 1014,
        })

        App:CreateText(card, info.Description or ("Loads " .. info.Path), UDim2.new(1, -28, 0, App:IsMobile() and 58 or 48), UDim2.fromOffset(14, 58), {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 12 or 12,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1014,
        })

        local button = Instance.new("TextButton")
        button.AnchorPoint = Vector2.new(0.5, 1)
        button.Position = UDim2.new(0.5, 0, 1, -12)
        local toggleWidth = App:IsMobile() and 68 or 62
        local toggleHeight = App:IsMobile() and 38 or 34
        button.Size = UDim2.fromOffset(toggleWidth, toggleHeight)
        button.BackgroundColor3 = Color3.fromRGB(70, 66, 80)
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = ""
        button.ZIndex = 1015
        button.Parent = card
        makeCorner(button, 999)

        local knob = Instance.new("Frame")
        local knobSize = toggleHeight - 6
        knob.Size = UDim2.fromOffset(knobSize, knobSize)
        knob.Position = UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = Color3.fromRGB(242, 239, 247)
        knob.BorderSizePixel = 0
        knob.ZIndex = 1016
        knob.Parent = button
        makeCorner(knob, 999)

        local feature
        local function render()
            local on = enabledState(feature)
            button.BackgroundColor3 = on and accent or Color3.fromRGB(70, 66, 80)
            local travel = toggleWidth - knobSize - 3
            knob.Position = UDim2.fromOffset(on and travel or 3, 3)
        end

        button.Activated:Connect(function()
            if not feature then
                local ok, result = pcall(loadFeature, App, info.Path)
                if not ok then
                    warn("[SquidNoMo] Failed to load " .. info.Path .. ": " .. tostring(result))
                    return
                end
                feature = result
            end

            if type(feature) ~= "table" or type(feature.Toggle) ~= "function" then
                warn("[SquidNoMo] " .. info.Path .. " does not expose Toggle(state)")
                return
            end

            local nextState = not enabledState(feature)
            local ok, err = pcall(feature.Toggle, feature, nextState)
            if not ok then
                warn("[SquidNoMo] Toggle failed for " .. info.Path .. ": " .. tostring(err))
            end
            render()
        end)

        App:BindButtonFeedback(button, accent)
        render()
    end

    task.defer(function()
        local rows = math.max(1, math.ceil(#features / 2))
        Page.AutomaticCanvasSize = Enum.AutomaticSize.None
        Page.CanvasSize = UDim2.fromOffset(
            0,
            topY + rows * (cardHeight + cellGap) + 36
        )
    end)

    return content
end

return FeatureFolder
