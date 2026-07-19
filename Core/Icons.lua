--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Core/Icons.lua
--// Dependency-free vector-style GUI icons.
--//========================================================--

local Icons = {}

local function corner(parent, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius)
    uiCorner.Parent = parent
    return uiCorner
end

local function stroke(parent, color, thickness, transparency)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = color
    uiStroke.Thickness = thickness or 1
    uiStroke.Transparency = transparency or 0
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = parent
    return uiStroke
end

local function frame(parent, size, position, color, zIndex)
    local item = Instance.new("Frame")
    item.Size = size
    item.Position = position or UDim2.fromOffset(0, 0)
    item.BackgroundColor3 = color
    item.BorderSizePixel = 0
    item.ZIndex = zIndex or 1
    item.Parent = parent
    return item
end

local function label(parent, text, size, position, color, font, textSize, zIndex)
    local item = Instance.new("TextLabel")
    item.Size = size
    item.Position = position or UDim2.fromOffset(0, 0)
    item.BackgroundTransparency = 1
    item.BorderSizePixel = 0
    item.Font = font or Enum.Font.GothamBold
    item.Text = text
    item.TextSize = textSize or 18
    item.TextColor3 = color
    item.TextXAlignment = Enum.TextXAlignment.Center
    item.TextYAlignment = Enum.TextYAlignment.Center
    item.ZIndex = zIndex or 1
    item.Parent = parent
    return item
end

local function roundedLine(parent, size, position, rotation, color, zIndex)
    local line = frame(parent, size, position, color, zIndex)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Rotation = rotation or 0
    corner(line, 99)
    return line
end

local function createTriangle(parent, color, zIndex)
    local holder = frame(parent, UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), color, zIndex)
    holder.BackgroundTransparency = 1

    roundedLine(holder, UDim2.new(0.055, 0, 0.58, 0), UDim2.new(0.36, 0, 0.48, 0), -30, color, zIndex)
    roundedLine(holder, UDim2.new(0.055, 0, 0.58, 0), UDim2.new(0.64, 0, 0.48, 0), 30, color, zIndex)
    roundedLine(holder, UDim2.new(0.56, 0, 0.055, 0), UDim2.new(0.50, 0, 0.73, 0), 0, color, zIndex)

    return holder
end

function Icons:CreateLogo(parent, size, options)
    options = options or {}

    local accent = options.Color or Color3.fromRGB(0, 238, 112)
    local background = options.BackgroundColor or Color3.fromRGB(5, 15, 10)
    local zIndex = options.ZIndex or 1

    local holder = frame(parent, UDim2.fromOffset(size, size), options.Position or UDim2.fromOffset(0, 0), background, zIndex)
    holder.Name = options.Name or "SquidNoMoLogo"
    holder.BackgroundTransparency = options.BackgroundTransparency or 0.08
    corner(holder, math.floor(size / 2))
    stroke(holder, accent, math.max(1, size * 0.025), 0.05)

    if options.Glow ~= false then
        local glowOuter = frame(holder, UDim2.new(1, 12, 1, 12), UDim2.fromOffset(-6, -6), accent, zIndex - 1)
        glowOuter.BackgroundTransparency = 0.90
        corner(glowOuter, math.floor((size + 12) / 2))

        local glowInner = frame(holder, UDim2.new(1, -10, 1, -10), UDim2.fromOffset(5, 5), accent, zIndex)
        glowInner.BackgroundTransparency = 0.88
        corner(glowInner, math.floor((size - 10) / 2))
    end

    local inner = frame(holder, UDim2.new(1, -12, 1, -12), UDim2.fromOffset(6, 6), background, zIndex + 1)
    inner.BackgroundTransparency = 0.18
    corner(inner, math.floor((size - 12) / 2))
    stroke(inner, accent, math.max(1, size * 0.016), 0.32)

    local triangle = createTriangle(inner, accent, zIndex + 2)
    triangle.Size = UDim2.new(0.58, 0, 0.58, 0)
    triangle.Position = UDim2.new(0.21, 0, 0.20, 0)

    return holder
end

local glyphs = {
    Home = "⌂",
    Games = "▣",
    Players = "●",
    Guards = "⬟",
    Detective = "⌕",
    Farming = "⌁",
    UI = "▱",
    Settings = "⚙",
    Warning = "!",
    Support = "♥",
    Stats = "▥",
    Server = "▤",
    Touch = "✋",
    Error = "!",
    Calendar = "▪",
    Build = "◆",
    Check = "✓",
    Partial = "!",
    Off = "×",
}

function Icons:Create(parent, name, size, color, zIndex)
    if name == "Logo" then
        return self:CreateLogo(parent, size, {
            Color = color,
            ZIndex = zIndex,
            Glow = false,
        })
    end

    local holder = frame(parent, UDim2.fromOffset(size, size), UDim2.fromOffset(0, 0), color, zIndex)
    holder.BackgroundTransparency = 1

    local text = glyphs[name] or string.sub(tostring(name or "?"), 1, 1)
    local icon = label(holder, text, UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), color, Enum.Font.GothamBold, math.floor(size * 0.68), (zIndex or 1) + 1)

    if name == "Players" then
        icon.Text = "●"
        icon.TextSize = math.floor(size * 0.40)
        icon.Position = UDim2.new(0, 0, -0.18, 0)
        local shoulders = frame(holder, UDim2.new(0.74, 0, 0.36, 0), UDim2.new(0.13, 0, 0.56, 0), color, (zIndex or 1) + 1)
        corner(shoulders, math.floor(size * 0.18))
    elseif name == "UI" then
        local monitor = frame(holder, UDim2.new(0.78, 0, 0.56, 0), UDim2.new(0.11, 0, 0.12, 0), color, (zIndex or 1) + 1)
        monitor.BackgroundTransparency = 1
        corner(monitor, 3)
        stroke(monitor, color, math.max(1, size * 0.07), 0)
        roundedLine(holder, UDim2.new(0.08, 0, 0.24, 0), UDim2.new(0.50, 0, 0.77, 0), 0, color, (zIndex or 1) + 1)
        roundedLine(holder, UDim2.new(0.42, 0, 0.07, 0), UDim2.new(0.50, 0, 0.91, 0), 0, color, (zIndex or 1) + 1)
        icon.Visible = false
    elseif name == "Games" then
        local body = frame(holder, UDim2.new(0.86, 0, 0.58, 0), UDim2.new(0.07, 0, 0.23, 0), color, (zIndex or 1) + 1)
        body.BackgroundTransparency = 1
        corner(body, math.floor(size * 0.20))
        stroke(body, color, math.max(1, size * 0.08), 0)

        local dpadH = roundedLine(body, UDim2.new(0.25, 0, 0.08, 0), UDim2.new(0.28, 0, 0.48, 0), 0, color, (zIndex or 1) + 2)
        local dpadV = roundedLine(body, UDim2.new(0.08, 0, 0.25, 0), UDim2.new(0.28, 0, 0.48, 0), 0, color, (zIndex or 1) + 2)
        local b1 = frame(body, UDim2.new(0.10, 0, 0.16, 0), UDim2.new(0.67, 0, 0.35, 0), color, (zIndex or 1) + 2)
        local b2 = frame(body, UDim2.new(0.10, 0, 0.16, 0), UDim2.new(0.78, 0, 0.54, 0), color, (zIndex or 1) + 2)
        corner(b1, 99)
        corner(b2, 99)
        icon.Visible = false
    end

    return holder
end

function Icons:CreateStatus(parent, state, size, theme, zIndex)
    local color = theme.Accent
    local glyph = "✓"

    if state == "partial" then
        color = theme.Warning
        glyph = "!"
    elseif state == "off" then
        color = theme.Error
        glyph = "×"
    end

    local holder = frame(parent, UDim2.fromOffset(size, size), UDim2.fromOffset(0, 0), color, zIndex)
    holder.BackgroundTransparency = 0.88
    corner(holder, math.floor(size / 2))
    stroke(holder, color, math.max(1, size * 0.05), 0)

    label(holder, glyph, UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), color, Enum.Font.GothamBlack, math.floor(size * 0.55), (zIndex or 1) + 1)
    return holder
end

function Icons:CreateTriangleStatus(parent, size, color, zIndex)
    local holder = frame(parent, UDim2.fromOffset(size, size), UDim2.fromOffset(0, 0), color, zIndex)
    holder.BackgroundTransparency = 1
    createTriangle(holder, color, (zIndex or 1) + 1)
    return holder
end

return Icons
