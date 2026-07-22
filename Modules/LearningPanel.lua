local LearningPanel = {}

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 12)
    value.Parent = parent
end

local function makeButton(parent, text, color, order)
    local value = Instance.new("TextButton")
    value.Name = string.gsub(text, "[^%w]", "") .. "Button"
    value.LayoutOrder = order
    value.Size = UDim2.new(1 / 3, -6, 1, 0)
    value.BackgroundColor3 = color
    value.BackgroundTransparency = 0.04
    value.BorderSizePixel = 0
    value.AutoButtonColor = false
    value.Text = text
    value.TextColor3 = Color3.new(1, 1, 1)
    value.Font = Enum.Font.GothamBold
    value.TextSize = 12
    value.TextWrapped = true
    value.Parent = parent
    corner(value, 10)
    return value
end

local function setButtonEnabled(button, enabled)
    button.Active = enabled == true
    button.Selectable = enabled == true
    button.BackgroundTransparency = enabled and 0.04 or 0.55
    button.TextTransparency = enabled and 0 or 0.35
end

function LearningPanel:Create(parent, App, options)
    options = options or {}
    local recorder = App.Loader and App.Loader.LearningRecorder
    local accent = App:GetPageAccent("Games")
    local selectedGame = options.GameName or "Red Light, Green Light"
    local mobile = App:IsMobile()

    local card = App:CreateCard(parent, UDim2.fromScale(1, 1), {
        Color = App.Colors.Card,
        BorderColor = accent,
        BorderTransparency = 0.10,
        Radius = 13,
    })
    card.Name = "OneRoundLearningPanel"
    card.ClipsDescendants = true

    local heading = Instance.new("Frame")
    heading.Name = "LearningHeading"
    heading.Position = UDim2.fromOffset(14, 8)
    heading.Size = UDim2.new(1, -28, 0, mobile and 42 or 38)
    heading.BackgroundTransparency = 1
    heading.Parent = card

    local title = App:CreateText(heading, "● ONE-ROUND RECORDER", UDim2.new(0.38, -8, 0, 18), UDim2.fromOffset(0, 0), {
        Font = Enum.Font.GothamBlack,
        TextSize = mobile and 12 or 11,
        Color = accent,
        ZIndex = 1014,
    })

    local gameLabel = App:CreateText(heading, selectedGame, UDim2.new(0.38, -8, 0, 20), UDim2.fromOffset(0, 19), {
        Font = Enum.Font.GothamBold,
        TextSize = mobile and 13 or 12,
        Color = App.Colors.Text,
        ZIndex = 1014,
    })
    gameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local status = App:CreateText(heading, "Tap START RECORDING before you play the round.", UDim2.new(0.62, 0, 1, 0), UDim2.new(0.38, 0, 0, 0), {
        Font = Enum.Font.GothamMedium,
        TextSize = mobile and 11 or 10,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Center,
        ZIndex = 1014,
    })

    local actions = Instance.new("Frame")
    actions.Name = "LearningActions"
    actions.Position = UDim2.fromOffset(12, mobile and 55 or 50)
    actions.Size = UDim2.new(1, -24, 0, mobile and 46 or 42)
    actions.BackgroundTransparency = 1
    actions.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = actions

    local startButton = makeButton(actions, "START RECORDING", accent, 1)
    local finishButton = makeButton(actions, "FINISH & SAVE", Color3.fromRGB(48, 190, 105), 2)
    local cancelButton = makeButton(actions, "CANCEL", Color3.fromRGB(185, 66, 76), 3)

    local function notify(kind, message)
        if not App.Notifications then return end
        local method = App.Notifications[kind]
        if type(method) == "function" then
            method(App.Notifications, "Round recorder", tostring(message), 6)
        end
    end

    local function render(nextStatus)
        nextStatus = nextStatus or (recorder and recorder:GetStatus()) or {}
        local active = nextStatus.Active == true
        local available = recorder ~= nil
        gameLabel.Text = active and tostring(nextStatus.Game or selectedGame) or selectedGame

        if not available then
            status.Text = "Recorder unavailable. Upload the complete matching build."
            status.TextColor3 = Color3.fromRGB(255, 106, 122)
        elseif active then
            local samples = tonumber(nextStatus.Samples) or 0
            local events = tonumber(nextStatus.Events) or 0
            status.Text = string.format("RECORDING • %d samples • %d events", samples, events)
            status.TextColor3 = Color3.fromRGB(255, 214, 84)
        else
            status.Text = tostring(nextStatus.Message or "Tap START RECORDING before you play the round.")
            status.TextColor3 = nextStatus.SavedPath and Color3.fromRGB(72, 232, 124) or App.Colors.Muted
        end

        title.Text = active and "● RECORDING ROUND" or "● ONE-ROUND RECORDER"
        title.TextColor3 = active and Color3.fromRGB(255, 95, 115) or accent
        setButtonEnabled(startButton, available and not active)
        setButtonEnabled(finishButton, available and active)
        setButtonEnabled(cancelButton, available and active)
    end

    startButton.Activated:Connect(function()
        if not recorder or recorder.Active then return end
        local ok, detail = recorder:Start(selectedGame)
        if not ok then notify("Error", detail) else notify("Success", "Recording started. Play the round manually.") end
        render()
    end)

    finishButton.Activated:Connect(function()
        if not recorder or not recorder.Active then return end
        local ok, detail = recorder:MarkSuccess()
        if ok then
            notify("Success", "Successful round saved to " .. tostring(detail))
        else
            notify("Error", detail)
        end
        render()
    end)

    cancelButton.Activated:Connect(function()
        if not recorder or not recorder.Active then return end
        local ok, detail = recorder:Stop(false)
        if ok then notify("Warning", "Recording stopped and saved to " .. tostring(detail)) else notify("Error", detail) end
        render()
    end)

    App:BindButtonFeedback(startButton, accent)
    App:BindButtonFeedback(finishButton, Color3.fromRGB(48, 190, 105))
    App:BindButtonFeedback(cancelButton, Color3.fromRGB(185, 66, 76))

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
