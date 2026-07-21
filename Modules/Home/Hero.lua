--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Modules/Home/Hero.lua
--//========================================================--

local Hero = {}

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

function Hero:Create(parent, App)
    local Theme = App.Theme

    local hero = App:CreateCard(parent, UDim2.new(1, 0, 0, 152), {
        Color = Color3.fromRGB(5, 20, 13),
        StrokeColor = Theme.AccentDark,
        StrokeTransparency = 0.03,
        Radius = 17,
        ClipsDescendants = true,
        ZIndex = 20,
    })
    hero.Name = "HeroBanner"

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 13, 10)),
        ColorSequenceKeypoint.new(0.42, Color3.fromRGB(4, 19, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 37, 18)),
    })
    gradient.Rotation = 0
    gradient.Parent = hero

    -- Radar rings reproduce the approved banner without external image assets.
    for index = 1, 6 do
        local ringSize = 96 + ((index - 1) * 42)
        local ring = App:CreateFrame(
            hero,
            UDim2.fromOffset(ringSize, ringSize),
            UDim2.new(0.79, -(ringSize / 2), 0.50, -(ringSize / 2)),
            Theme.Accent,
            {
                Transparency = 1,
                Radius = math.floor(ringSize / 2),
                StrokeColor = Theme.Accent,
                StrokeThickness = index == 1 and 2 or 1,
                StrokeTransparency = 0.34 + (index * 0.07),
                ZIndex = 22,
            }
        )
        ring.Name = "RadarRing" .. tostring(index)
    end

    for index = 1, 18 do
        local x = 0.48 + (((index * 37) % 48) / 100)
        local y = 0.12 + (((index * 53) % 76) / 100)
        local dotSize = (index % 4 == 0) and 6 or 3

        local dot = App:CreateFrame(
            hero,
            UDim2.fromOffset(dotSize, dotSize),
            UDim2.new(x, 0, y, 0),
            Theme.Accent,
            {
                Transparency = (index % 4 == 0) and 0.15 or 0.55,
                Radius = 99,
                ZIndex = 23,
            }
        )
        dot.Name = "RadarDot" .. tostring(index)
    end

    App:CreateText(hero, "SQUIDNOMO", UDim2.fromOffset(560, 58), UDim2.fromOffset(34, 16), {
        Font = Theme.FontBlack,
        TextSize = 50,
        Color = Theme.Text,
        ZIndex = 28,
    })

    App:CreateText(hero, "DASHBOARD", UDim2.fromOffset(420, 42), UDim2.fromOffset(35, 67), {
        Font = Theme.FontBlack,
        TextSize = 32,
        Color = Theme.Accent,
        ZIndex = 28,
    })

    App:CreateText(hero, "Optimized. Feature-Rich. Built for Squid Game X.", UDim2.fromOffset(650, 28), UDim2.fromOffset(36, 111), {
        Font = Theme.FontMedium,
        TextSize = 15,
        Color = Theme.Text,
        ZIndex = 28,
    })

    local logo = App.Icons:CreateLogo(hero, 118, {
        Position = UDim2.new(0.79, -59, 0.50, -59),
        Color = Theme.Accent,
        BackgroundColor = Color3.fromRGB(3, 14, 8),
        Glow = true,
        ZIndex = 29,
    })
    logo.Name = "BannerLogo"

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.AnchorPoint = Vector2.new(1, 0)
    minimizeButton.Position = UDim2.new(1, -14, 0, 13)
    minimizeButton.Size = UDim2.fromOffset(58, 58)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.BorderSizePixel = 0
    minimizeButton.AutoButtonColor = false
    minimizeButton.Text = ""
    minimizeButton.ZIndex = 40
    minimizeButton.Parent = hero

    App.Icons:CreateLogo(minimizeButton, 58, {
        Color = Theme.Accent,
        BackgroundColor = Theme.Window,
        Glow = false,
        ZIndex = 41,
    })

    local tooltip = App:CreateCard(hero, UDim2.fromOffset(142, 48), {
        Position = UDim2.new(1, -156, 0, 78),
        Color = Color3.fromRGB(8, 15, 12),
        StrokeColor = Theme.Accent,
        StrokeTransparency = 0.08,
        Radius = 8,
        ZIndex = 44,
    })
    tooltip.Visible = false

    App:CreateText(tooltip, "Click to minimize\nthe app", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4), {
        Font = Theme.FontMedium,
        TextSize = 12,
        Color = Theme.Text,
        Wrapped = true,
        XAlignment = Enum.TextXAlignment.Center,
        ZIndex = 45,
    })

    App:Track(minimizeButton.MouseEnter:Connect(function()
        tooltip.Visible = true
    end))

    App:Track(minimizeButton.MouseLeave:Connect(function()
        tooltip.Visible = false
    end))

    App:Track(minimizeButton.MouseButton1Click:Connect(function()
        App:SetMinimized(true)
    end))

    local dragHandle = App:CreateFrame(
        hero,
        UDim2.new(0.70, 0, 1, 0),
        UDim2.fromOffset(0, 0),
        Theme.Window,
        {
            Transparency = 1,
            Active = true,
            ZIndex = 39,
        }
    )
    dragHandle.Name = "HeroDragHandle"
    App:EnableDragging(dragHandle)

    return hero
end

return Hero
