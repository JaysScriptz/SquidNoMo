--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Modules/Home/FeatureStats.lua
--//========================================================--

local FeatureStats = {}

local function makeCorner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
    return item
end

local function makeStroke(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = parent
    return item
end

local function makeStatCard(App, parent, state, title, description, color, position)
    local Theme = App.Theme

    local card = App:CreateCard(parent, UDim2.fromOffset(355, 172), {
        Position = position,
        Color = state == "full"
            and Color3.fromRGB(5, 37, 22)
            or state == "partial"
                and Color3.fromRGB(37, 27, 5)
                or Color3.fromRGB(34, 10, 14),
        StrokeColor = color,
        StrokeTransparency = 0.12,
        Radius = 13,
        ZIndex = 30,
    })

    local iconHolder = App:CreateFrame(card, UDim2.fromOffset(60, 60), UDim2.fromOffset(18, 14), color, {
        Transparency = 1,
        ZIndex = 33,
    })

    if state == "partial" then
        App.Icons:CreateTriangleStatus(iconHolder, 58, color, 34)
        App:CreateText(iconHolder, "!", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 4), {
            Font = Theme.FontBlack,
            TextSize = 25,
            Color = color,
            XAlignment = Enum.TextXAlignment.Center,
            ZIndex = 36,
        })
    else
        App.Icons:CreateStatus(iconHolder, state, 58, Theme, 34)
    end

    App:CreateText(card, title, UDim2.new(1, -104, 0, 30), UDim2.fromOffset(92, 14), {
        Font = Theme.FontBlack,
        TextSize = 18,
        Color = Theme.Text,
        ZIndex = 34,
    })

    App:CreateText(card, description, UDim2.new(1, -104, 0, 48), UDim2.fromOffset(92, 46), {
        Font = Theme.FontMedium,
        TextSize = 13,
        Color = Theme.Text,
        Wrapped = true,
        YAlignment = Enum.TextYAlignment.Top,
        ZIndex = 34,
    })

    local count = App:CreateText(card, "0", UDim2.fromOffset(140, 54), UDim2.fromOffset(20, 96), {
        Font = Theme.FontBlack,
        TextSize = 43,
        Color = color,
        ZIndex = 34,
    })

    App:CreateText(card, "FEATURES", UDim2.fromOffset(170, 24), UDim2.fromOffset(20, 145), {
        Font = Theme.FontBlack,
        TextSize = 14,
        Color = color,
        ZIndex = 34,
    })

    local percent = App:CreateText(card, "0%", UDim2.fromOffset(92, 24), UDim2.new(1, -108, 1, -32), {
        Font = Theme.FontBlack,
        TextSize = 15,
        Color = color,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 34,
    })

    return {
        Card = card,
        Count = count,
        Percent = percent,
    }
end

function FeatureStats:Create(parent, App)
    local Theme = App.Theme

    local root = App:CreateCard(parent, UDim2.new(1, 0, 0, 354), {
        Color = Color3.fromRGB(8, 13, 11),
        StrokeColor = Theme.Border,
        StrokeTransparency = 0.05,
        Radius = 15,
        ZIndex = 20,
    })
    root.Name = "FeatureStats"

    local titleIcon = App:CreateFrame(root, UDim2.fromOffset(30, 30), UDim2.fromOffset(18, 12), Theme.Accent, {
        Transparency = 1,
        ZIndex = 31,
    })
    App.Icons:Create(titleIcon, "Stats", 28, Theme.Accent, 32)

    App:CreateText(root, "FEATURE STATS", UDim2.fromOffset(360, 34), UDim2.fromOffset(54, 10), {
        Font = Theme.FontBlack,
        TextSize = 23,
        Color = Theme.Text,
        ZIndex = 32,
    })

    local notice = App:CreateFrame(root, UDim2.new(1, -36, 0, 40), UDim2.fromOffset(18, 48), Color3.fromRGB(29, 22, 5), {
        Radius = 9,
        StrokeColor = Theme.Warning,
        StrokeTransparency = 0.15,
        ZIndex = 31,
    })

    local warningIcon = App:CreateText(notice, "!", UDim2.fromOffset(30, 30), UDim2.fromOffset(10, 5), {
        Font = Theme.FontBlack,
        TextSize = 19,
        Color = Theme.Black,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 34,
    })
    warningIcon.BackgroundTransparency = 0
    warningIcon.BackgroundColor3 = Theme.Warning
    makeCorner(warningIcon, 7)

    App:CreateText(notice, "To change any settings, please use the categories in the tabs on the left.", UDim2.new(1, -58, 1, 0), UDim2.fromOffset(50, 0), {
        Font = Theme.FontBold,
        TextSize = 14,
        Color = Theme.WarningBright,
        ZIndex = 34,
    })

    local full = makeStatCard(
        App,
        root,
        "full",
        "FULLY ON",
        "All features\nare enabled.",
        Theme.Accent,
        UDim2.fromOffset(18, 101)
    )

    local partial = makeStatCard(
        App,
        root,
        "partial",
        "PARTIALLY ON",
        "Some features\nare enabled.",
        Theme.Warning,
        UDim2.fromOffset(391, 101)
    )

    local off = makeStatCard(
        App,
        root,
        "off",
        "NOT ON",
        "No features\nare enabled.",
        Theme.Error,
        UDim2.fromOffset(764, 101)
    )

    local track = App:CreateFrame(root, UDim2.new(1, -36, 0, 34), UDim2.fromOffset(18, 286), Theme.Row, {
        Radius = 8,
        ClipsDescendants = true,
        ZIndex = 31,
    })

    local fullFill = App:CreateFrame(track, UDim2.new(0, 0, 1, 0), UDim2.fromOffset(0, 0), Theme.Accent, {
        ZIndex = 32,
    })
    local partialFill = App:CreateFrame(track, UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Warning, {
        ZIndex = 32,
    })
    local offFill = App:CreateFrame(track, UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Error, {
        ZIndex = 32,
    })

    local fullBarText = App:CreateText(track, "0%", UDim2.new(0, 0, 1, 0), UDim2.fromOffset(0, 0), {
        Font = Theme.FontBlack,
        TextSize = 14,
        Color = Theme.Black,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 35,
    })

    local partialBarText = App:CreateText(track, "0%", UDim2.new(0, 0, 1, 0), UDim2.fromOffset(0, 0), {
        Font = Theme.FontBlack,
        TextSize = 14,
        Color = Theme.Black,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 35,
    })

    local offBarText = App:CreateText(track, "0%", UDim2.new(0, 0, 1, 0), UDim2.fromOffset(0, 0), {
        Font = Theme.FontBlack,
        TextSize = 14,
        Color = Theme.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 35,
    })

    local totalLabel = App:CreateText(root, "0 / 0 FEATURES", UDim2.new(1, -36, 0, 24), UDim2.fromOffset(18, 324), {
        Font = Theme.FontBold,
        TextSize = 14,
        Color = Theme.Text,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 34,
    })

    local function refresh()
        local summary = App.FeatureRegistry:GetSummary()

        full.Count.Text = tostring(summary.full)
        full.Percent.Text = tostring(summary.fullPercent) .. "%"
        partial.Count.Text = tostring(summary.partial)
        partial.Percent.Text = tostring(summary.partialPercent) .. "%"
        off.Count.Text = tostring(summary.off)
        off.Percent.Text = tostring(summary.offPercent) .. "%"

        local fullScale = summary.fullPercent / 100
        local partialScale = summary.partialPercent / 100
        local offScale = summary.offPercent / 100

        fullFill.Size = UDim2.new(fullScale, 0, 1, 0)
        partialFill.Position = UDim2.new(fullScale, 0, 0, 0)
        partialFill.Size = UDim2.new(partialScale, 0, 1, 0)
        offFill.Position = UDim2.new(fullScale + partialScale, 0, 0, 0)
        offFill.Size = UDim2.new(offScale, 0, 1, 0)

        fullBarText.Position = UDim2.new(0, 0, 0, 0)
        fullBarText.Size = UDim2.new(fullScale, 0, 1, 0)
        fullBarText.Text = summary.fullPercent > 0 and (tostring(summary.fullPercent) .. "%") or ""

        partialBarText.Position = UDim2.new(fullScale, 0, 0, 0)
        partialBarText.Size = UDim2.new(partialScale, 0, 1, 0)
        partialBarText.Text = summary.partialPercent > 0 and (tostring(summary.partialPercent) .. "%") or ""

        offBarText.Position = UDim2.new(fullScale + partialScale, 0, 0, 0)
        offBarText.Size = UDim2.new(offScale, 0, 1, 0)
        offBarText.Text = summary.offPercent > 0 and (tostring(summary.offPercent) .. "%") or ""

        totalLabel.Text = string.format("%d / %d FEATURES", summary.loaded, summary.total)
    end

    refresh()

    task.spawn(function()
        while root.Parent and App.Gui do
            task.wait(0.5)
            refresh()
        end
    end)

    return root
end

return FeatureStats
