--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Theme.lua
--//========================================================--

local Theme = {}

----------------------------------------------------------
-- Application
----------------------------------------------------------

Theme.Name = "SquidNoMo"

Theme.Version = "1.1 beta 1"

----------------------------------------------------------
-- Colors
----------------------------------------------------------

Theme.Background = Color3.fromRGB(8,6,12)

Theme.Sidebar = Color3.fromRGB(12,10,18)

Theme.Header = Color3.fromRGB(14,10,20)

Theme.Card = Color3.fromRGB(18,13,25)

Theme.CardHover = Color3.fromRGB(28,20,37)

Theme.CardPressed = Color3.fromRGB(34,24,44)

----------------------------------------------------------
-- Accent
----------------------------------------------------------

Theme.Accent = Color3.fromRGB(255,58,145)

Theme.AccentHover = Color3.fromRGB(255,95,169)

Theme.AccentDark = Color3.fromRGB(194,30,109)

----------------------------------------------------------
-- Text
----------------------------------------------------------

Theme.Text = Color3.fromRGB(255,255,255)

Theme.SubText = Color3.fromRGB(177,163,184)

Theme.DisabledText = Color3.fromRGB(116,102,126)

----------------------------------------------------------
-- Status Colors
----------------------------------------------------------

Theme.Success = Color3.fromRGB(45,232,98)

Theme.Warning = Color3.fromRGB(255,196,64)

Theme.Error = Color3.fromRGB(255,63,86)

Theme.Info = Color3.fromRGB(0,170,255)

----------------------------------------------------------
-- Borders
----------------------------------------------------------

Theme.Border = Color3.fromRGB(255,58,145)

Theme.BorderDark = Color3.fromRGB(92,47,77)

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

Theme.SidebarWidth = 248

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

    Logo = "Images/SquidNoMoLogo.png",

    HeroImage = "Images/BannerGuards.png",

    SquidGameArtwork = "Images/BannerGuards.png",

    TabIcons = {
        Home = "Images/TabIcons/Home.png",
        Games = "Images/TabIcons/Games.png",
        Players = "Images/TabIcons/Players.png",
        Guards = "Images/TabIcons/Guards.png",
        Detective = "Images/TabIcons/Detective.png",
        Farming = "Images/TabIcons/Farming.png",
        UI = "Images/TabIcons/UI.png",
        Settings = "Images/TabIcons/Settings.png",
    },

    CashAppQR = "Images/CashAppQR.png",

    PayPalQR = "Images/PayPalQR.png",

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
