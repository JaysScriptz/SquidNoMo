local FeatureFolder = {}

local cache = {}

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
end

local function loadFeature(App, info)
    local path = info.Path
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

    if type(feature) ~= "table" then
        error(
            "module did not return a feature table: "
            .. tostring(path)
        )
    end
    if type(feature.Toggle) ~= "function"
        and not (
            type(feature.Enable) == "function"
            and type(feature.Disable) == "function"
        )
    then
        error(
            "module has no Toggle or Enable/Disable API: "
            .. tostring(path)
        )
    end

    cache[path] = feature

    local manager = App.FeatureManager
    if manager and type(manager.AttachCatalogFeature) == "function" and info.Id then
        manager:AttachCatalogFeature(info.Id, feature)
    end

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
    if type(feature.GetState) == "function" then
        local ok, value = pcall(feature.GetState, feature)
        if ok then
            value = tostring(value or ""):lower()
            return value == "on" or value == "enabled" or value == "full"
        end
    end
    return feature.Enabled == true or feature.Active == true
end

local function desiredState(manager, info, feature)
    if manager and manager.AutoApplyPerGameEnabled
        and type(manager.GetEntry) == "function"
        and info and info.Id
    then
        local entry = manager:GetEntry(info.Id)
        if entry and entry.PageName == "Games" then
            return entry.DesiredEnabled == true
        end
    end
    return enabledState(feature)
end

local function isAutoManagedGame(manager, info)
    if not manager or not manager.AutoApplyPerGameEnabled or not info or not info.Id then return false end
    local entry = type(manager.GetEntry) == "function" and manager:GetEntry(info.Id) or nil
    return entry and entry.PageName == "Games"
end

local function setEnabled(feature, state)
    if type(feature) ~= "table" then
        return false, "module did not return a feature table"
    end

    local function invoke(method)
        local ok, result, detail = pcall(
            method,
            feature,
            state
        )
        if not ok then
            return false, tostring(result)
        end
        if result == false then
            return false, tostring(
                detail
                or "feature rejected the requested state"
            )
        end
        return true, result
    end

    if type(feature.Toggle) == "function" then
        return invoke(feature.Toggle)
    end

    local method = state
        and feature.Enable
        or feature.Disable
    if type(method) == "function" then
        local ok, result, detail = pcall(
            method,
            feature
        )
        if not ok then
            return false, tostring(result)
        end
        if result == false then
            return false, tostring(
                detail
                or "feature rejected the requested state"
            )
        end
        return true, result
    end

    return false, "module does not expose Toggle(state) or Enable/Disable"
end

local function descriptionFor(App, info)
    if type(info.Description) == "string" and info.Description ~= "" then
        return info.Description
    end

    local catalog = App.Loader and App.Loader.FeatureCatalog
    if catalog and type(catalog.Describe) == "function" then
        return catalog:Describe(info)
    end

    return "Provides focused assistance for " .. tostring(info.Name or "this feature") .. "."
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
    local cellGap = App:IsMobile() and 8 or 12
    local cardHeight = App:IsMobile() and 184 or 166
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

        App:CreateText(card, descriptionFor(App, info), UDim2.new(1, -28, 0, App:IsMobile() and 66 or 56), UDim2.fromOffset(14, 56), {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 13 or 12,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1014,
        })

        local statusLabel = App:CreateText(
            card,
            "READY • Tap to load",
            UDim2.new(1, -104, 0, 28),
            UDim2.new(0, 14, 1, -42),
            {
                Font = Enum.Font.GothamBold,
                TextSize = App:IsMobile() and 12 or 11,
                Color = App.Colors.Muted,
                Wrapped = false,
                XAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1014,
            }
        )
        statusLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local button = Instance.new("TextButton")
        button.AnchorPoint = Vector2.new(1, 1)
        button.Position = UDim2.new(1, -14, 1, -12)
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

        local manager = App.FeatureManager
        local feature = manager
            and type(manager.GetFeature) == "function"
            and manager:GetFeature(info.Id)
            or cache[info.Path]
        local busy = false
        local statusConnection = nil

        local function renderStatus()
            local armed = desiredState(manager, info, feature)
            local running = enabledState(feature)
            if isAutoManagedGame(manager, info) and armed and not running and type(feature) ~= "table" then
                local entry = manager:GetEntry(info.Id)
                statusLabel.Text = "ARMED • Waiting for " .. tostring(entry and entry.CategoryName or "matching game")
                statusLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
                return
            end
            if type(feature) ~= "table" then
                statusLabel.Text = armed and "ARMED • Loads when detected" or "READY • Tap to load"
                statusLabel.TextColor3 = armed and Color3.fromRGB(255, 210, 80) or App.Colors.Muted
                return
            end

            local state = running and "ACTIVE" or "OFF"
            local detail = enabledState(feature) and "Enabled" or "Disabled"
            if type(feature.GetStatus) == "function" then
                local ok, nextState, nextDetail = pcall(
                    feature.GetStatus,
                    feature
                )
                if ok then
                    state = string.upper(tostring(nextState or state))
                    detail = tostring(nextDetail or detail)
                end
            end

            statusLabel.Text = state .. " • " .. detail
            if state == "ERROR" then
                statusLabel.TextColor3 = Color3.fromRGB(255, 105, 115)
            elseif state == "WAITING" or state == "STARTING" then
                statusLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
            elseif state == "ACTIVE" or state == "COMPLETE" then
                statusLabel.TextColor3 = Color3.fromRGB(80, 255, 145)
            else
                statusLabel.TextColor3 = App.Colors.Muted
            end
        end

        local function subscribeStatus()
            if statusConnection then
                pcall(function() statusConnection:Disconnect() end)
                statusConnection = nil
            end
            if type(feature) == "table"
                and type(feature.SubscribeStatus) == "function"
            then
                local ok, connection = pcall(
                    feature.SubscribeStatus,
                    feature,
                    function()
                        renderStatus()
                    end
                )
                if ok then statusConnection = connection end
            end
            renderStatus()
        end

        local function render()
            local on = desiredState(manager, info, feature)
            button.BackgroundColor3 = on and accent or Color3.fromRGB(70, 66, 80)
            local travel = toggleWidth - knobSize - 3
            knob.Position = UDim2.fromOffset(on and travel or 3, 3)
            renderStatus()
        end

        button.Activated:Connect(function()
            if Page:GetAttribute("SquidNoMoTouchDragging") then return end
            if busy then return end
            busy = true

            -- Capture the user's intended state before a lazy module is loaded.
            -- This prevents a restored pending state from flipping the first click.
            local nextState = not desiredState(manager, info, feature)

            if not feature then
                local ok, result = pcall(loadFeature, App, info)
                if not ok then
                    local message = tostring(result)
                    warn("[SquidNoMo] Failed to load " .. tostring(info.Name) .. ": " .. message)
                    statusLabel.Text = "ERROR • " .. message
                    statusLabel.TextColor3 = Color3.fromRGB(255, 105, 115)
                    if App.Notifications
                        and type(App.Notifications.Error) == "function"
                    then
                        App.Notifications:Error(
                            tostring(info.Name),
                            message,
                            5
                        )
                    end
                    busy = false
                    return
                end
                feature = result
                subscribeStatus()
            end

            local ok, err = setEnabled(feature, nextState)
            if ok and manager then
                if type(manager.SetFeatureState) == "function" and info.Id then
                    -- Manual means the tap must take effect now. Auto Apply still
                    -- remembers the selection and handles later game transitions.
                    ok = manager:SetFeatureState(
                        info.Id,
                        nextState and "on" or "off",
                        {Manual = true}
                    )
                    if not ok then err = "feature state could not be saved" end
                elseif type(manager.Notify) == "function" then
                    manager:Notify()
                end
            end
            if not ok then
                local message = tostring(err)
                warn("[SquidNoMo] Toggle failed for " .. tostring(info.Name) .. ": " .. message)
                if App.Notifications and type(App.Notifications.Error) == "function" then
                    App.Notifications:Error(tostring(info.Name), message, 5)
                end
            end

            render()
            if type(App.QueueSettingsSave) == "function" then App:QueueSettingsSave() end
            busy = false
        end)

        card.Destroying:Connect(function()
            if statusConnection then
                pcall(function()
                    statusConnection:Disconnect()
                end)
                statusConnection = nil
            end
        end)

        App:BindButtonFeedback(button, accent)
        subscribeStatus()
        render()
    end

    local function updateCanvas()
        local height = math.max(cardHeight, grid.AbsoluteContentSize.Y)
        content.AutomaticSize = Enum.AutomaticSize.None
        content.Size = UDim2.new(1, -(padding * 2), 0, height)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.None
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.ScrollingEnabled = true
        local viewport = math.max(Page.AbsoluteWindowSize.Y, Page.AbsoluteSize.Y)
        Page.CanvasSize = UDim2.fromOffset(
            0,
            math.max(topY + height + (App:IsMobile() and 92 or 44), viewport + 2)
        )
    end
    local gridConnection = grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    local pageConnection = Page:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
    content.Destroying:Connect(function()
        pcall(function() gridConnection:Disconnect() end)
        pcall(function() pageConnection:Disconnect() end)
    end)
    task.defer(updateCanvas)
    task.delay(0.12, updateCanvas)
    task.delay(0.45, updateCanvas)

    return content
end

return FeatureFolder
