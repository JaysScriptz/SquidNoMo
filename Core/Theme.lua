--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Theme.lua
--//========================================================--

local Theme = {}

----------------------------------------------------------
-- Application
----------------------------------------------------------

Theme.Name = "SquidNoMo"

Theme.Version = "Beta 4.0"

----------------------------------------------------------
-- Colors
----------------------------------------------------------

Theme.Background = Color3.fromRGB(18,18,18)

Theme.Sidebar = Color3.fromRGB(23,23,23)

Theme.Header = Color3.fromRGB(22,22,22)

Theme.Card = Color3.fromRGB(31,31,31)

Theme.CardHover = Color3.fromRGB(38,38,38)

Theme.CardPressed = Color3.fromRGB(42,42,42)

----------------------------------------------------------
-- Accent
----------------------------------------------------------

Theme.Accent = Color3.fromRGB(0,255,140)

Theme.AccentHover = Color3.fromRGB(45,255,170)

Theme.AccentDark = Color3.fromRGB(0,190,110)

----------------------------------------------------------
-- Text
----------------------------------------------------------

Theme.Text = Color3.fromRGB(255,255,255)

Theme.SubText = Color3.fromRGB(180,180,180)

Theme.DisabledText = Color3.fromRGB(120,120,120)

----------------------------------------------------------
-- Status Colors
----------------------------------------------------------

Theme.Success = Color3.fromRGB(0,255,120)

Theme.Warning = Color3.fromRGB(255,185,35)

Theme.Error = Color3.fromRGB(255,70,70)

Theme.Info = Color3.fromRGB(0,170,255)

----------------------------------------------------------
-- Borders
----------------------------------------------------------

Theme.Border = Color3.fromRGB(55,255,175)

Theme.BorderDark = Color3.fromRGB(60,60,60)

----------------------------------------------------------
-- Fonts
----------------------------------------------------------

Theme.Font = Enum.Font.Gotham

Theme.FontMedium = Enum.Font.GothamMedium

Theme.FontBold = Enum.Font.GothamBold

Theme.FontBlack = Enum.Font.GothamBlack

----------------------------------------------------------
-- Sizes
----------------------------------------------------------

Theme.WindowWidth = 1225

Theme.WindowHeight = 730

Theme.SidebarWidth = 245

Theme.HeaderHeight = 72

Theme.PagePadding = 18

Theme.CardRadius = 16

Theme.ButtonRadius = 10

----------------------------------------------------------
-- Animation
----------------------------------------------------------

Theme.FastTween = TweenInfo.new(
    0.15,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

Theme.NormalTween = TweenInfo.new(
    0.25,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

Theme.SlowTween = TweenInfo.new(
    0.4,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

----------------------------------------------------------
-- Icons
----------------------------------------------------------

Theme.Icons = {

    Home = "",

    Players = "",

    Guards = "",

    Detective = "",

    Farming = "",

    VIP = "",

    Games = "",

    Settings = "",

    Support = "",

    Warning = "",

    AI = ""

}

----------------------------------------------------------
-- Assets
----------------------------------------------------------

Theme.Assets = {

    Logo = "",

    HeroImage = "",

    SquidGameArtwork = "",

    Shadow = "rbxassetid://1316045217"

}

----------------------------------------------------------
-- Utility
----------------------------------------------------------

function Theme:GetColor(Name)

    return self[Name]

end

function Theme:GetFont(Name)

    return self[Name]

end

return Theme
