local GamesPage = {}

local CATEGORIES = {
    {Name = "Red Light, Green Light", Short = "RLGL"},
    {Name = "Honeycomb", Short = "HC"},
    {Name = "Pentathlon", Short = "PENTA"},
    {Name = "Hide & Seek (Keys & Knives)", Short = "H&S"},
    {Name = "Jump Rope", Short = "ROPE"},
    {Name = "Sky Squid", Short = "SKY"},
    {Name = "Mingle", Short = "MINGLE"},
    {Name = "Fight Nights", Short = "FIGHT"},
    {Name = "Rebellion", Short = "REBELLION"},
    {Name = "Tug of War", Short = "TUG"},
    {Name = "Marbles", Short = "MARBLES"},
    {Name = "Rock, Paper, Scissors Minus One", Short = "RPS-1"},
    {Name = "Glass Bridge", Short = "GLASS"},
    {Name = "Squid Game", Short = "SQUID"},
}

function GamesPage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Games",
        SessionKey = "SelectedGameCategory",
        DefaultName = "Red Light, Green Light",
        ScrollerName = "GameCategoryScroller",
        ButtonWidth = 190,
        Items = CATEGORIES,
    })
end

return GamesPage
