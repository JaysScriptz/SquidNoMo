local LearningPanel = {}

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 12)
    value.Parent = parent
end

local function button(parent, text, color, order)
    local value = Instance.new("TextButton")
    value.LayoutOrder = order
    value.Size = UDim2.fromOffset(104, 42)
    value.BackgroundColor3 = color
    value.BorderSizePixel = 0
    value.AutoButtonColor = false
    value.Text = text
    value.TextColor3 = Color3.new(1, 1, 1)
    value.Font = Enum.Font.GothamBold
    value.TextSize = 13
    value.Parent = parent
    corner(value, 10)
    return value
end

function LearningPanel:Create(Parent, App, options)
    options = options or {}
    local recorder = App.Loader and App.Loader.LearningRecorder
    local accent = App:GetPageAccent("Games")
    local selectedGame = options.GameName or "Red Light, Green Light"

    local card = App:CreateCard(Parent, UDim2.fromScale(1, 1), {
        Color = App.Colors.Card,
        BorderColor = accent,
        BorderTransparency = 0.18,
        Radius = 13,
    })
    card.ClipsDescendants = true

    local title = App:CreateText(card, "ONE-ROUND LEARNING", UDim2.fromOffset(190, 18), UDim2.fromOffset(14, 8), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 12 or 11,
        Color = accent,
        ZIndex = 1014,
    })

    local gameLabel = App:CreateText(card, selectedGame, UDim2.new(0.30, -20, 0, 22), UDim2.fromOffset(14, 27), {
        Font = Enum.Font.GothamBold,
        TextSize = App:IsMobile() and 14 or 13,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })
    gameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local status = App:CreateText(card, "Play one round manually, then mark success.", UDim2.new(0.30, -16, 0, 36), UDim2.new(0.30, 0, 0, 13), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 12 or 11,
        Color = App.Colors.Muted,
        Wrapped = true,
        ZIndex = 1014,
    })

    local actions = Instance.new("Frame")
    actions.AnchorPoint = Vector2.new(1, 0.5)
    actions.Position = UDim2.new(1, -12, 0.5, 0)
    actions.Size = UDim2.new(0.40, 0, 0, 44)
    actions.BackgroundTransparency = 1
    actions.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = actions

    local learn = button(actions, "LEARN", accent, 1)
    local success = button(actions, "SUCCESS", Color3.fromRGB(48, 190, 105), 2)
    local stop = button(actions, "STOP", Color3.fromRGB(185, 66, 76), 3)

    local function render(nextStatus)
        nextStatus = nextStatus or (recorder and recorder:GetStatus()) or {}
        local active = nextStatus.Active == true
        gameLabel.Text = active and tostring(nextStatus.Game or selectedGame) or selectedGame
        status.Text = tostring(nextStatus.Message or "Play one round manually, then mark success.")
        status.TextColor3 = active and Color3.fromRGB(255, 214, 84) or App.Colors.Muted
        learn.Visible = not active
        success.Visible = active
        stop.Visible = active
    end

    learn.Activated:Connect(function()
        if not recorder then return end
        local ok, detail = recorder:Start(selectedGame)
        if not ok and App.Notifications and type(App.Notifications.Error) == "function" then
            App.Notifications:Error("Learning", tostring(detail), 5)
        end
        render()
    end)

    success.Activated:Connect(function()
        if not recorder then return end
        local ok, detail = recorder:MarkSuccess()
        if App.Notifications then
            local method = ok and App.Notifications.Success or App.Notifications.Error
            if type(method) == "function" then
                method(App.Notifications, "Learning", tostring(detail), 6)
            end
        end
        render()
    end)

    stop.Activated:Connect(function()
        if not recorder then return end
        recorder:Stop(false)
        render()
    end)

    App:BindButtonFeedback(learn, accent)
    App:BindButtonFeedback(success, Color3.fromRGB(48, 190, 105))
    App:BindButtonFeedback(stop, Color3.fromRGB(185, 66, 76))

    local connection = recorder and recorder:Subscribe(render) or nil
    card.Destroying:Connect(function()
        if connection then pcall(function() connection:Disconnect() end) end
    end)

    render()
    return {
        Root = card,
        SetGame = function(name)
            selectedGame = tostring(name or selectedGame)
            if not recorder or not recorder.Active then gameLabel.Text = selectedGame end
        end,
    }
end

return LearningPanel
