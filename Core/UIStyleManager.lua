local UIStyleManager = {}

UIStyleManager.PageNames = {
    'Home',
    'Games',
    'Players',
    'Guards',
    'Detective',
    'Farming',
    'UI',
    'Settings',
}

UIStyleManager.Scopes = {
    'Current Page',
    'Main Pages',
    'Subpages',
    'Entire App',
}

UIStyleManager.Defaults = {
    ThemePreset = 'SquidNoMo',
    WindowWidth = 1225,
    WindowHeight = 690,
    AppScale = 1.0,
    SidebarWidth = 232,
    TopbarHeight = 56,
    FooterHeight = 34,
    PagePadding = 8,
    ColumnGap = 12,
    SectionSpacing = 10,
    CategoryBubbleWidth = 190,
    CategoryBubbleHeight = 72,
    CategoryBarHeight = 116,
    CategoryGap = 10,
    TextScale = 1.08,
    CardRadius = 14,
    BorderThickness = 1,
    ScrollbarThickness = 5,
    ButtonHeight = 46,
    ButtonRadius = 10,
    ButtonStyle = 'Soft Glow',
    ToggleWidth = 54,
    ToggleHeight = 30,
    ToggleSpacing = 8,
    ToggleStyle = 'Switch',
    SliderTrack = 8,
    SliderKnob = 18,
    GlowIntensity = 70,
    AnimationSpeed = 100,
    PressScale = 97,
    QuickAdjust = true,
    AccentHue = 328,
    AccentSaturation = 77,
    AccentBrightness = 100,
    BackgroundBrightness = 6,
    CardBrightness = 10,
    TextBrightness = 96,
    UniformPageAccents = false,
}

UIStyleManager.Themes = {
    SquidNoMo = {
        AccentHue = 328,
        AccentSaturation = 77,
        AccentBrightness = 100,
        BackgroundBrightness = 6,
        CardBrightness = 10,
        TextBrightness = 96,
    },
    ['Neon Pink'] = {
        AccentHue = 328,
        AccentSaturation = 90,
        AccentBrightness = 100,
        BackgroundBrightness = 5,
        CardBrightness = 10,
        TextBrightness = 100,
    },
    ['Cyber Purple'] = {
        AccentHue = 275,
        AccentSaturation = 76,
        AccentBrightness = 100,
        BackgroundBrightness = 5,
        CardBrightness = 11,
        TextBrightness = 98,
    },
    ['Ocean Blue'] = {
        AccentHue = 195,
        AccentSaturation = 90,
        AccentBrightness = 100,
        BackgroundBrightness = 5,
        CardBrightness = 10,
        TextBrightness = 98,
    },
    Emerald = {
        AccentHue = 148,
        AccentSaturation = 82,
        AccentBrightness = 92,
        BackgroundBrightness = 5,
        CardBrightness = 10,
        TextBrightness = 98,
    },
    Crimson = {
        AccentHue = 350,
        AccentSaturation = 86,
        AccentBrightness = 100,
        BackgroundBrightness = 5,
        CardBrightness = 10,
        TextBrightness = 98,
    },
    Amber = {
        AccentHue = 42,
        AccentSaturation = 88,
        AccentBrightness = 100,
        BackgroundBrightness = 5,
        CardBrightness = 10,
        TextBrightness = 98,
    },
    Monochrome = {
        AccentHue = 0,
        AccentSaturation = 0,
        AccentBrightness = 92,
        BackgroundBrightness = 5,
        CardBrightness = 11,
        TextBrightness = 98,
    },
    ['High Contrast'] = {
        AccentHue = 55,
        AccentSaturation = 100,
        AccentBrightness = 100,
        BackgroundBrightness = 2,
        CardBrightness = 5,
        TextBrightness = 100,
    },
}

local limits = {
    WindowWidth = {900, 1600},
    WindowHeight = {540, 900},
    AppScale = {0.75, 1.15},
    SidebarWidth = {170, 340},
    TopbarHeight = {44, 92},
    FooterHeight = {24, 64},
    PagePadding = {6, 24},
    ColumnGap = {8, 22},
    SectionSpacing = {8, 24},
    CategoryBubbleWidth = {145, 300},
    CategoryBubbleHeight = {54, 76},
    CategoryBarHeight = {92, 126},
    CategoryGap = {2, 28},
    TextScale = {0.90, 1.18},
    CardRadius = {2, 32},
    BorderThickness = {0, 4},
    ScrollbarThickness = {2, 14},
    ButtonHeight = {34, 54},
    ButtonRadius = {2, 32},
    ToggleWidth = {46, 68},
    ToggleHeight = {24, 38},
    ToggleSpacing = {2, 24},
    SliderTrack = {4, 18},
    SliderKnob = {14, 34},
    GlowIntensity = {0, 100},
    AnimationSpeed = {50, 200},
    PressScale = {90, 100},
    AccentHue = {0, 360},
    AccentSaturation = {0, 100},
    AccentBrightness = {40, 100},
    BackgroundBrightness = {1, 20},
    CardBrightness = {4, 32},
    TextBrightness = {65, 100},
    PageAccentHue = {0, 360},
}

local function copyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do
        if type(value) == 'table' then
            result[key] = copyTable(value)
        else
            result[key] = value
        end
    end
    return result
end

local function clampValue(key, value)
    local boundary = limits[key]
    if boundary and type(value) == 'number' then
        return math.clamp(value, boundary[1], boundary[2])
    end
    return value
end

function UIStyleManager:Clone(source)
    return copyTable(source)
end

function UIStyleManager:CreateColorPreservingProfile(source)
    local fresh = self:CreateDefaultProfile()
    local normalized = self:Normalize(
        self:Clone(source)
    )

    local keys = {
        "ThemePreset",
        "AccentHue",
        "AccentSaturation",
        "AccentBrightness",
        "BackgroundBrightness",
        "CardBrightness",
        "TextBrightness",
        "UniformPageAccents",
        "PageAccentHue",
    }

    for _, key in ipairs(keys) do
        if normalized.Global[key] ~= nil then
            fresh.Global[key] = normalized.Global[key]
        end
    end

    for pageName, values in pairs(
        normalized.Pages or {}
    ) do
        if type(values) == "table"
            and values.PageAccentHue ~= nil
        then
            fresh.Pages[pageName] = {
                PageAccentHue =
                    values.PageAccentHue,
            }
        end
    end

    return self:Normalize(fresh)
end

function UIStyleManager:CreateDefaultProfile()
    return {
        Global = copyTable(self.Defaults),
        MainPages = {},
        Subpages = {},
        Pages = {},
    }
end

function UIStyleManager:Normalize(profile)
    if type(profile) ~= 'table' then
        return self:CreateDefaultProfile()
    end

    profile.Global = type(profile.Global) == 'table'
        and profile.Global
        or {}
    profile.MainPages = type(profile.MainPages) == 'table'
        and profile.MainPages
        or {}
    profile.Subpages = type(profile.Subpages) == 'table'
        and profile.Subpages
        or {}
    profile.Pages = type(profile.Pages) == 'table'
        and profile.Pages
        or {}

    for key, defaultValue in pairs(self.Defaults) do
        if profile.Global[key] == nil then
            profile.Global[key] = defaultValue
        else
            profile.Global[key] = clampValue(
                key,
                profile.Global[key]
            )
        end
    end

    for _, scopeTable in ipairs({
        profile.MainPages,
        profile.Subpages,
    }) do
        for key, value in pairs(scopeTable) do
            scopeTable[key] = clampValue(key, value)
        end
    end

    for _, pageValues in pairs(profile.Pages) do
        if type(pageValues) == 'table' then
            for key, value in pairs(pageValues) do
                pageValues[key] = clampValue(key, value)
            end
        end
    end

    return profile
end

function UIStyleManager:GetValue(
    profile,
    pageName,
    key,
    context
)
    profile = self:Normalize(profile)

    local pageValues = pageName
        and profile.Pages[pageName]
        or nil
    if type(pageValues) == 'table'
        and pageValues[key] ~= nil
    then
        return pageValues[key]
    end

    if context == 'Subpage'
        and profile.Subpages[key] ~= nil
    then
        return profile.Subpages[key]
    end

    if context == 'MainPage'
        and profile.MainPages[key] ~= nil
    then
        return profile.MainPages[key]
    end

    if profile.Global[key] ~= nil then
        return profile.Global[key]
    end

    return self.Defaults[key]
end

function UIStyleManager:GetEditableValue(
    profile,
    scope,
    pageName,
    key
)
    if scope == 'Current Page' then
        return self:GetValue(
            profile,
            pageName,
            key,
            'MainPage'
        )
    elseif scope == 'Main Pages' then
        return self:GetValue(
            profile,
            nil,
            key,
            'MainPage'
        )
    elseif scope == 'Subpages' then
        return self:GetValue(
            profile,
            nil,
            key,
            'Subpage'
        )
    end

    return self:GetValue(profile, nil, key, 'Global')
end

function UIStyleManager:SetValue(
    profile,
    scope,
    pageName,
    key,
    value
)
    profile = self:Normalize(profile)
    value = clampValue(key, value)

    local destination = profile.Global
    if scope == 'Current Page' then
        pageName = pageName or 'Home'
        profile.Pages[pageName] =
            profile.Pages[pageName] or {}
        destination = profile.Pages[pageName]
    elseif scope == 'Main Pages' then
        destination = profile.MainPages
    elseif scope == 'Subpages' then
        destination = profile.Subpages
    end

    destination[key] = value
    return value
end

function UIStyleManager:ResetScope(
    profile,
    scope,
    pageName
)
    profile = self:Normalize(profile)

    if scope == 'Current Page' then
        profile.Pages[pageName or 'Home'] = nil
    elseif scope == 'Main Pages' then
        profile.MainPages = {}
    elseif scope == 'Subpages' then
        profile.Subpages = {}
    else
        profile.Global = copyTable(self.Defaults)
    end

    return profile
end

function UIStyleManager:ApplyTheme(profile, themeName)
    profile = self:Normalize(profile)
    local theme = self.Themes[themeName]
    if type(theme) ~= 'table' then
        return false
    end

    profile.Global.ThemePreset = themeName
    for key, value in pairs(theme) do
        profile.Global[key] = value
    end
    return true
end

function UIStyleManager:ApplyProfileMetrics(
    deviceProfile,
    profile
)
    local global = self:Normalize(profile).Global
    deviceProfile.DesignWidth = global.WindowWidth
    deviceProfile.DesignHeight = global.WindowHeight
    deviceProfile.SidebarWidth = global.SidebarWidth
    deviceProfile.TopbarHeight = global.TopbarHeight
    deviceProfile.StatusbarHeight = global.FooterHeight
    deviceProfile.WindowRadius = global.CardRadius
    deviceProfile.ContentPadding = global.PagePadding
    deviceProfile.NavigationButtonHeight = math.clamp(
        global.ButtonHeight,
        32,
        58
    )
    deviceProfile.NavigationPadding = math.clamp(
        math.floor(global.SectionSpacing * 0.45),
        2,
        12
    )
    return deviceProfile
end

local defaultPageHues = {
    Home = 328,
    Games = 190,
    Players = 270,
    Guards = 350,
    Detective = 215,
    Farming = 145,
    UI = 300,
    Settings = 45,
}

function UIStyleManager:BuildPalette(profile)
    profile = self:Normalize(profile)
    local global = profile.Global

    local hue = (tonumber(global.AccentHue) or 328) / 360
    local saturation =
        (tonumber(global.AccentSaturation) or 77) / 100
    local brightness =
        (tonumber(global.AccentBrightness) or 100) / 100
    local backgroundBrightness =
        (tonumber(global.BackgroundBrightness) or 6) / 100
    local cardBrightness =
        (tonumber(global.CardBrightness) or 10) / 100
    local textBrightness =
        (tonumber(global.TextBrightness) or 96) / 100

    local accent = Color3.fromHSV(
        hue,
        math.clamp(saturation, 0, 1),
        math.clamp(brightness, 0.4, 1)
    )
    local backdrop = Color3.fromHSV(
        hue,
        0.28,
        math.clamp(backgroundBrightness, 0.01, 0.20)
    )
    local card = Color3.fromHSV(
        hue,
        0.25,
        math.clamp(cardBrightness, 0.04, 0.32)
    )
    local text = Color3.new(
        textBrightness,
        textBrightness,
        textBrightness
    )

    local colors = {
        Backdrop = backdrop,
        Window = Color3.fromHSV(
            hue,
            0.25,
            math.clamp(backgroundBrightness + 0.025, 0.02, 0.25)
        ),
        Sidebar = Color3.fromHSV(
            hue,
            0.26,
            math.clamp(backgroundBrightness + 0.035, 0.02, 0.27)
        ),
        Topbar = Color3.fromHSV(
            hue,
            0.28,
            math.clamp(backgroundBrightness + 0.045, 0.03, 0.28)
        ),
        Card = card,
        CardAlt = Color3.fromHSV(
            hue,
            0.28,
            math.clamp(cardBrightness + 0.045, 0.06, 0.38)
        ),
        CardHover = Color3.fromHSV(
            hue,
            0.32,
            math.clamp(cardBrightness + 0.09, 0.08, 0.46)
        ),
        Border = accent,
        BorderSoft = accent:Lerp(backdrop, 0.68),
        Accent = accent,
        AccentDark = accent:Lerp(Color3.new(0, 0, 0), 0.30),
        AccentSoft = accent:Lerp(backdrop, 0.48),
        Pink = accent,
        PinkDark = accent:Lerp(Color3.new(0, 0, 0), 0.34),
        Warning = Color3.fromRGB(255, 196, 64),
        Error = Color3.fromRGB(255, 63, 86),
        Success = Color3.fromRGB(45, 232, 98),
        Info = Color3.fromRGB(0, 170, 255),
        Minimize = Color3.fromRGB(106, 78, 176),
        Maximize = Color3.fromRGB(0, 139, 214),
        Close = Color3.fromRGB(211, 42, 68),
        CashApp = Color3.fromRGB(0, 224, 106),
        PayPal = Color3.fromRGB(0, 99, 214),
        Text = text,
        Muted = text:Lerp(backdrop, 0.34),
        Dim = text:Lerp(backdrop, 0.58),
        Black = Color3.fromRGB(0, 0, 0),
    }

    local pageAccents = {}
    for pageName, defaultHue in pairs(defaultPageHues) do
        local customHue = self:GetValue(
            profile,
            pageName,
            'PageAccentHue',
            'MainPage'
        )
        local resolvedHue = tonumber(customHue) or defaultHue
        if global.UniformPageAccents then
            resolvedHue = tonumber(global.AccentHue) or 328
        end

        pageAccents[pageName] = Color3.fromHSV(
            (resolvedHue % 360) / 360,
            math.clamp(saturation, 0.55, 1),
            math.clamp(brightness, 0.72, 1)
        )
    end

    pageAccents.Home = global.UniformPageAccents
        and accent
        or pageAccents.Home

    return colors, pageAccents
end

return UIStyleManager
