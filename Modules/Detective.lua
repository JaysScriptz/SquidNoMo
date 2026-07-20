local DetectivePage = {}

local STEPS = {
    {Name = "LOCATE ISLAND", Detail = "Confirm the island route and landing point."},
    {Name = "SEARCH EVIDENCE", Detail = "Search the island and record useful evidence."},
    {Name = "SECURE EVIDENCE", Detail = "Carry collected evidence safely to extraction."},
    {Name = "DEPOSIT AT BOAT", Detail = "Deposit the evidence in the boat to finish the run."},
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

local function actionButton(App, parent, text, accent, position, size, callback)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = accent
    button.BackgroundTransparency = 0.12
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBlack
    button.TextSize = App:IsMobile() and 11 or 12
    button.ZIndex = 1014
    button.Parent = parent
    makeCorner(button, 11)
    makeStroke(button, accent, 1, 0.05)
    App:BindButtonFeedback(button, accent)
    button.Activated:Connect(callback)
    return button
end

function DetectivePage:Create(Page, App)
    Page:ClearAllChildren()

    local accent = App:GetPageAccent("Detective")
    local padding = App.Profile.ContentPadding
    local session = App.Session or {}
    local stage = math.clamp(tonumber(session.DetectiveStage) or 1, 1, 4)
    local evidence = math.clamp(tonumber(session.DetectiveEvidenceCount) or 0, 0, 9)
    local deposited = math.clamp(tonumber(session.DetectiveDepositedCount) or 0, 0, 99)

    local root = Instance.new("Frame")
    root.Position = UDim2.fromOffset(padding, padding)
    root.Size = UDim2.new(1, -(padding * 2), 0, 690)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = Page

    local header = App:CreateCard(root, UDim2.new(1, 0, 0, 78), {
        Color = Color3.fromRGB(14, 10, 21),
        BorderColor = accent,
        BorderTransparency = 0.08,
        Radius = App:IsMobile() and 14 or 17,
    })

    App:CreateText(header, "DETECTIVE INVESTIGATION", UDim2.new(1, -36, 0, 28), UDim2.fromOffset(18, 12), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 19 or 22,
        Color = accent,
        ZIndex = 1013,
    })

    App:CreateText(header, "Manual mission tracker for locating the island, collecting evidence, and returning it to the boat.", UDim2.new(1, -36, 0, 26), UDim2.fromOffset(18, 43), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Text,
        Wrapped = true,
        ZIndex = 1013,
    })

    local route = App:CreateCard(root, UDim2.new(1, 0, 0, 132), {
        Color = Color3.fromRGB(12, 9, 18),
        BorderColor = App.Colors.Border,
        BorderTransparency = 0.18,
        Radius = App:IsMobile() and 14 or 17,
    })
    route.Position = UDim2.fromOffset(0, 90)

    local stepRefs = {}
    for index, step in ipairs(STEPS) do
        local xScale = (index - 1) / 4
        local frame = Instance.new("Frame")
        frame.Position = UDim2.new(xScale, 8, 0, 18)
        frame.Size = UDim2.new(0.25, -16, 1, -36)
        frame.BackgroundColor3 = App.Colors.CardAlt
        frame.BackgroundTransparency = 0.22
        frame.BorderSizePixel = 0
        frame.ZIndex = 1012
        frame.Parent = route
        makeCorner(frame, 12)
        local outline = makeStroke(frame, App.Colors.BorderSoft, 1, 0.5)

        local number = App:CreateText(frame, tostring(index), UDim2.fromOffset(30, 30), UDim2.fromOffset(10, 10), {
            Font = Enum.Font.GothamBlack,
            TextSize = 15,
            Color = accent,
            XAlignment = Enum.TextXAlignment.Center,
            YAlignment = Enum.TextYAlignment.Center,
            ZIndex = 1013,
        })

        local title = App:CreateText(frame, step.Name, UDim2.new(1, -54, 0, 26), UDim2.fromOffset(48, 10), {
            Font = Enum.Font.GothamBlack,
            TextSize = App:IsMobile() and 10 or 11,
            Color = App.Colors.Text,
            ZIndex = 1013,
        })

        local detail = App:CreateText(frame, step.Detail, UDim2.new(1, -20, 0, 46), UDim2.fromOffset(10, 48), {
            Font = Enum.Font.GothamMedium,
            TextSize = App:IsMobile() and 9 or 10,
            Color = App.Colors.Muted,
            Wrapped = true,
            YAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1013,
        })

        stepRefs[index] = {
            Frame = frame,
            Stroke = outline,
            Number = number,
            Title = title,
            Detail = detail,
        }
    end

    local dashboard = App:CreateEqualThreeColumnRow(root, 234, 360, "DetectiveDashboard")

    local statusCard = App:CreateCard(dashboard, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(14, 10, 21),
        BorderColor = accent,
        BorderTransparency = 0.12,
        Radius = 16,
    })
    statusCard.LayoutOrder = 1

    local evidenceCard = App:CreateCard(dashboard, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(14, 10, 21),
        BorderColor = App.Colors.Success,
        BorderTransparency = 0.12,
        Radius = 16,
    })
    evidenceCard.LayoutOrder = 2

    local boatCard = App:CreateCard(dashboard, UDim2.new(0.333333, -8, 1, 0), {
        Color = Color3.fromRGB(14, 10, 21),
        BorderColor = App.Colors.Warning,
        BorderTransparency = 0.12,
        Radius = 16,
    })
    boatCard.LayoutOrder = 3

    local statusTitle = App:CreateText(statusCard, "CURRENT OBJECTIVE", UDim2.new(1, -28, 0, 26), UDim2.fromOffset(14, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 14 or 16,
        Color = accent,
        ZIndex = 1013,
    })

    local statusValue = App:CreateText(statusCard, "", UDim2.new(1, -28, 0, 42), UDim2.fromOffset(14, 58), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 18 or 21,
        Color = App.Colors.Text,
        Wrapped = true,
        ZIndex = 1013,
    })

    local statusDetail = App:CreateText(statusCard, "", UDim2.new(1, -28, 0, 74), UDim2.fromOffset(14, 112), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    App:CreateText(evidenceCard, "EVIDENCE BAG", UDim2.new(1, -28, 0, 26), UDim2.fromOffset(14, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 14 or 16,
        Color = App.Colors.Success,
        ZIndex = 1013,
    })

    local evidenceValue = App:CreateText(evidenceCard, "", UDim2.new(1, -28, 0, 58), UDim2.fromOffset(14, 62), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 28 or 34,
        Color = App.Colors.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1013,
    })

    App:CreateText(evidenceCard, "Use the tracker whenever you find or lose a piece of evidence.", UDim2.new(1, -28, 0, 52), UDim2.fromOffset(14, 128), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    App:CreateText(boatCard, "BOAT DEPOSIT", UDim2.new(1, -28, 0, 26), UDim2.fromOffset(14, 14), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 14 or 16,
        Color = App.Colors.Warning,
        ZIndex = 1013,
    })

    local depositedValue = App:CreateText(boatCard, "", UDim2.new(1, -28, 0, 58), UDim2.fromOffset(14, 62), {
        Font = Enum.Font.GothamBlack,
        TextSize = App:IsMobile() and 28 or 34,
        Color = App.Colors.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1013,
    })

    App:CreateText(boatCard, "Depositing clears the evidence bag and records the completed delivery.", UDim2.new(1, -28, 0, 52), UDim2.fromOffset(14, 128), {
        Font = Enum.Font.GothamMedium,
        TextSize = App:IsMobile() and 10 or 11,
        Color = App.Colors.Muted,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1013,
    })

    local nextButton
    local addButton
    local removeButton
    local depositButton
    local resetButton

    local function save()
        if App.Session then
            App.Session.DetectiveStage = stage
            App.Session.DetectiveEvidenceCount = evidence
            App.Session.DetectiveDepositedCount = deposited
        end
        if type(App.QueueSettingsSave) == "function" then
            App:QueueSettingsSave()
        end
    end

    local function render()
        local current = STEPS[stage]
        statusValue.Text = current.Name
        statusDetail.Text = current.Detail
        evidenceValue.Text = tostring(evidence) .. " HELD"
        depositedValue.Text = tostring(deposited) .. " STORED"

        for index, ref in ipairs(stepRefs) do
            local completed = index < stage
            local active = index == stage
            ref.Frame.BackgroundColor3 = active and accent or App.Colors.CardAlt
            ref.Frame.BackgroundTransparency = active and 0.12 or 0.24
            ref.Stroke.Color = completed and App.Colors.Success or (active and accent or App.Colors.BorderSoft)
            ref.Stroke.Transparency = (completed or active) and 0.04 or 0.55
            ref.Stroke.Thickness = active and 2 or 1
            ref.Number.TextColor3 = completed and App.Colors.Success or (active and Color3.fromRGB(255, 255, 255) or accent)
            ref.Title.TextColor3 = active and Color3.fromRGB(255, 255, 255) or App.Colors.Text
            ref.Detail.TextColor3 = active and Color3.fromRGB(245, 245, 250) or App.Colors.Muted
        end

        nextButton.Text = stage < 4 and "COMPLETE STEP" or "ROUTE READY"
        nextButton.BackgroundTransparency = stage < 4 and 0.12 or 0.45
        depositButton.BackgroundTransparency = evidence > 0 and 0.12 or 0.5
        save()
    end

    nextButton = actionButton(App, statusCard, "COMPLETE STEP", accent, UDim2.new(0, 14, 1, -102), UDim2.new(1, -28, 0, 42), function()
        if stage < 4 then
            stage = stage + 1
            render()
        end
    end)

    resetButton = actionButton(App, statusCard, "RESET ROUTE", App.Colors.Error, UDim2.new(0, 14, 1, -52), UDim2.new(1, -28, 0, 38), function()
        stage = 1
        evidence = 0
        render()
    end)

    addButton = actionButton(App, evidenceCard, "ADD EVIDENCE", App.Colors.Success, UDim2.new(0, 14, 1, -102), UDim2.new(1, -28, 0, 42), function()
        evidence = math.min(9, evidence + 1)
        if stage < 3 then
            stage = 3
        end
        render()
    end)

    removeButton = actionButton(App, evidenceCard, "REMOVE ONE", App.Colors.Error, UDim2.new(0, 14, 1, -52), UDim2.new(1, -28, 0, 38), function()
        evidence = math.max(0, evidence - 1)
        render()
    end)

    depositButton = actionButton(App, boatCard, "DEPOSIT AT BOAT", App.Colors.Warning, UDim2.new(0, 14, 1, -102), UDim2.new(1, -28, 0, 42), function()
        if evidence > 0 then
            deposited = deposited + evidence
            evidence = 0
            stage = 4
            render()
        end
    end)

    actionButton(App, boatCard, "NEW INVESTIGATION", accent, UDim2.new(0, 14, 1, -52), UDim2.new(1, -28, 0, 38), function()
        stage = 1
        evidence = 0
        render()
    end)

    render()
end

return DetectivePage
