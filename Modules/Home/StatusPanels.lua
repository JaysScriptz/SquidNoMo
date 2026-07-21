--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Modules/Home/StatusPanels.lua
--//========================================================--

local UserInputService = game:GetService("UserInputService")

local StatusPanels = {}

local function createRow(App, card, iconName, labelText, valueText, y)
    local Theme = App.Theme

    local row = App:CreateFrame(card, UDim2.new(1, -32, 0, 29), UDim2.fromOffset(16, y), Theme.Row, {
        Radius = 7,
        StrokeColor = Theme.BorderSoft,
        StrokeTransparency = 0.50,
        ZIndex = 31,
    })

    local iconRoot = App:CreateFrame(row, UDim2.fromOffset(22, 22), UDim2.fromOffset(8, 3), Theme.Accent, {
        Transparency = 1,
        ZIndex = 33,
    })
    App.Icons:Create(iconRoot, iconName, 20, Theme.Text, 34)

    App:CreateText(row, labelText, UDim2.new(0.55, -38, 1, 0), UDim2.fromOffset(38, 0), {
        Font = Theme.FontMedium,
        TextSize = 13,
        Color = Theme.Text,
        ZIndex = 34,
    })

    local value = App:CreateText(row, valueText, UDim2.new(0.45, -12, 1, 0), UDim2.new(0.55, 0, 0, 0), {
        Font = Theme.FontMedium,
        TextSize = 13,
        Color = Theme.Accent,
        XAlignment = Enum.TextXAlignment.Right,
        ZIndex = 34,
    })

    return value
end

local function createTitle(App, card, iconName, title)
    local Theme = App.Theme

    local iconRoot = App:CreateFrame(card, UDim2.fromOffset(30, 30), UDim2.fromOffset(18, 10), Theme.Accent, {
        Transparency = 1,
        ZIndex = 33,
    })
    App.Icons:Create(iconRoot, iconName, 28, Theme.Accent, 34)

    App:CreateText(card, title, UDim2.new(1, -66, 0, 34), UDim2.fromOffset(54, 8), {
        Font = Theme.FontBlack,
        TextSize = 21,
        Color = Theme.Text,
        ZIndex = 34,
    })
end

function StatusPanels:Create(parent, App)
    local Theme = App.Theme

    local row = App:CreateFrame(parent, UDim2.new(1, 0, 0, 282), UDim2.fromOffset(0, 0), Theme.Background, {
        Transparency = 1,
        ZIndex = 20,
    })
    row.Name = "StatusPanels"

    local server = App:CreateCard(row, UDim2.new(0.5, -6, 1, 0), {
        Position = UDim2.fromOffset(0, 0),
        Color = Color3.fromRGB(8, 14, 11),
        StrokeColor = Theme.AccentDark,
        StrokeTransparency = 0.04,
        Radius = 15,
        ZIndex = 21,
    })

    local nomo = App:CreateCard(row, UDim2.new(0.5, -6, 1, 0), {
        Position = UDim2.new(0.5, 6, 0, 0),
        Color = Color3.fromRGB(8, 14, 11),
        StrokeColor = Theme.AccentDark,
        StrokeTransparency = 0.04,
        Radius = 15,
        ZIndex = 21,
    })

    createTitle(App, server, "Server", "SERVER STATS")
    createTitle(App, nomo, "Logo", "NOMO STATS")

    local serverValues = {}
    serverValues.Client = createRow(App, server, "UI", "Client", "--", 47)
    serverValues.FPS = createRow(App, server, "Stats", "FPS", "--", 79)
    serverValues.Ping = createRow(App, server, "Detective", "Ping", "--", 111)
    serverValues.ServerAge = createRow(App, server, "Calendar", "Server Age", "--", 143)
    serverValues.Uptime = createRow(App, server, "Calendar", "Uptime", "--", 175)
    serverValues.Connected = createRow(App, server, "Check", "Connected", "--", 207)
    serverValues.Players = createRow(App, server, "Players", "Players", "--", 239)

    local nomoValues = {}
    nomoValues.Status = createRow(App, nomo, "Check", "Status", "App Ready", 47)
    nomoValues.FeaturesLoaded = createRow(App, nomo, "Check", "Features Loaded", "0 / 0", 79)
    nomoValues.TouchSupport = createRow(App, nomo, "Touch", "Touch Support", UserInputService.TouchEnabled and "Enabled" or "Not Detected", 111)
    nomoValues.Errors = createRow(App, nomo, "Error", "Errors", "0", 143)
    nomoValues.LastUpdate = createRow(App, nomo, "Calendar", "Last Update", Theme.BuildDate, 175)
    nomoValues.BuildVersion = createRow(App, nomo, "Build", "Build Version", Theme.Version, 207)

    local function refresh()
        local snapshot = App.RuntimeStats:GetSnapshot()
        local summary = App.FeatureRegistry:GetSummary()

        serverValues.Client.Text = snapshot.Client
        serverValues.FPS.Text = snapshot.FPS
        serverValues.Ping.Text = snapshot.Ping
        serverValues.ServerAge.Text = snapshot.ServerAge
        serverValues.Uptime.Text = snapshot.Uptime
        serverValues.Connected.Text = snapshot.Connected
        serverValues.Players.Text = snapshot.Players

        nomoValues.Status.Text = "App Ready"
        nomoValues.FeaturesLoaded.Text = string.format("%d / %d", summary.loaded, summary.total)
        nomoValues.TouchSupport.Text = UserInputService.TouchEnabled and "Enabled" or "Not Detected"
        nomoValues.Errors.Text = tostring(App:GetErrorCount())
        nomoValues.LastUpdate.Text = Theme.BuildDate
        nomoValues.BuildVersion.Text = Theme.Version

        nomoValues.Errors.TextColor3 = App:GetErrorCount() > 0 and Theme.Warning or Theme.Accent
    end

    refresh()

    task.spawn(function()
        while row.Parent and App.Gui do
            task.wait(1.5)
            refresh()
        end
    end)

    return row
end

return StatusPanels
