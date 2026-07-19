--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Core/Theme.lua
--// Canonical visual system for the approved neon dashboard.
--//========================================================--

local Theme = {}

Theme.Name = "SquidNoMo"
Theme.Version = "v0.5.0 Beta"
Theme.BuildDate = "Jul 18, 2026"

----------------------------------------------------------
-- Palette
----------------------------------------------------------

Theme.Background = Color3.fromRGB(5, 9, 8)
Theme.Backdrop = Theme.Background
Theme.Window = Color3.fromRGB(8, 13, 11)
Theme.Sidebar = Color3.fromRGB(10, 16, 14)
Theme.Header = Color3.fromRGB(8, 15, 12)
Theme.Card = Color3.fromRGB(12, 19, 16)
Theme.CardAlt = Color3.fromRGB(16, 24, 20)
Theme.CardHover = Color3.fromRGB(22, 34, 28)
Theme.CardPressed = Color3.fromRGB(26, 42, 34)

Theme.Accent = Color3.fromRGB(0, 238, 112)
Theme.AccentBright = Color3.fromRGB(0, 255, 130)
Theme.AccentHover = Color3.fromRGB(38, 255, 151)
Theme.AccentDark = Color3.fromRGB(0, 132, 68)
Theme.AccentDeep = Color3.fromRGB(0, 58, 34)
Theme.AccentGlow = Color3.fromRGB(0, 255, 123)

Theme.Pink = Color3.fromRGB(238, 24, 102)
Theme.PinkBright = Color3.fromRGB(255, 41, 123)
Theme.PinkDark = Color3.fromRGB(89, 14, 51)

Theme.Warning = Color3.fromRGB(255, 181, 0)
Theme.WarningBright = Color3.fromRGB(255, 196, 32)
Theme.WarningDark = Color3.fromRGB(74, 49, 0)

Theme.Error = Color3.fromRGB(239, 48, 70)
Theme.ErrorBright = Color3.fromRGB(255, 68, 88)
Theme.ErrorDark = Color3.fromRGB(72, 15, 24)

Theme.Success = Theme.Accent
Theme.Info = Color3.fromRGB(68, 166, 255)

Theme.Text = Color3.fromRGB(248, 250, 249)
Theme.SubText = Color3.fromRGB(188, 199, 193)
Theme.Muted = Color3.fromRGB(145, 159, 151)
Theme.DisabledText = Color3.fromRGB(92, 105, 98)
Theme.Dim = Color3.fromRGB(74, 87, 80)
Theme.Black = Color3.fromRGB(0, 0, 0)

Theme.Border = Color3.fromRGB(48, 80, 62)
Theme.BorderBright = Color3.fromRGB(0, 205, 99)
Theme.BorderDark = Color3.fromRGB(37, 50, 43)
Theme.BorderSoft = Color3.fromRGB(28, 42, 35)
Theme.Row = Color3.fromRGB(9, 15, 12)
Theme.RowAlt = Color3.fromRGB(12, 20, 16)

----------------------------------------------------------
-- Typography
----------------------------------------------------------

Theme.Font = Enum.Font.Gotham
Theme.FontMedium = Enum.Font.GothamMedium
Theme.FontBold = Enum.Font.GothamBold
Theme.FontBlack = Enum.Font.GothamBlack
Theme.FontCode = Enum.Font.Code

----------------------------------------------------------
-- Reference layout
----------------------------------------------------------

Theme.DesignWidth = 1500
Theme.DesignHeight = 840
Theme.SidebarWidth = 330
Theme.PagePadding = 14
Theme.PageGap = 12
Theme.CardRadius = 16
Theme.WindowRadius = 22
Theme.ButtonRadius = 10
Theme.TouchTarget = 52

Theme.MobileLandscapeMargins = {
    Left = 0.105,
    Right = 0.105,
    Top = 0.080,
    Bottom = 0.018,
}

Theme.MobilePortraitMargins = {
    Left = 0.025,
    Right = 0.025,
    Top = 0.065,
    Bottom = 0.050,
}

Theme.DesktopMargins = {
    Left = 0.018,
    Right = 0.018,
    Top = 0.025,
    Bottom = 0.025,
}

----------------------------------------------------------
-- Animation
----------------------------------------------------------

Theme.FastTween = TweenInfo.new(
    0.12,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

Theme.NormalTween = TweenInfo.new(
    0.20,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

Theme.SlowTween = TweenInfo.new(
    0.34,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

----------------------------------------------------------
-- Icon names
----------------------------------------------------------

Theme.Icons = {
    Home = "Home",
    Games = "Games",
    Players = "Players",
    Guards = "Guards",
    Detective = "Detective",
    Farming = "Farming",
    UI = "UI",
    Settings = "Settings",
    Warning = "Warning",
    Support = "Support",
    Check = "Check",
    Partial = "Partial",
    Off = "Off",
    Stats = "Stats",
}

Theme.Assets = {
    Shadow = "rbxassetid://1316045217",
}

function Theme:GetColor(name)
    return self[name]
end

function Theme:GetFont(name)
    return self[name]
end

return Theme
