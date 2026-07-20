local GuardsPage = {}

local CATEGORIES = {
    {Name = "Moderation", Short = "MOD"},
    {Name = "Kitchen", Short = "KITCHEN"},
    {Name = "Morgue", Short = "MORGUE"},
    {Name = "Surveillance", Short = "CCTV"},
}

function GuardsPage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Guards",
        SessionKey = "SelectedGuardCategory",
        DefaultName = "Moderation",
        ScrollerName = "GuardCategoryScroller",
        ButtonWidth = 220,
        Items = CATEGORIES,
    })
end

return GuardsPage
