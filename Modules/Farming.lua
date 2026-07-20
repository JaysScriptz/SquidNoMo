local FarmingPage = {}

local CATEGORIES = {
    {Name = "Player Farming", Short = "PLAYER"},
    {Name = "Guard Farming", Short = "GUARD"},
    {Name = "Frontman Farming", Short = "FRONTMAN"},
    {Name = "Detective Farming", Short = "DETECTIVE"},
}

function FarmingPage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Farming",
        SessionKey = "SelectedFarmingCategory",
        DefaultName = "Player Farming",
        ScrollerName = "FarmingCategoryScroller",
        ButtonWidth = 220,
        Items = CATEGORIES,
    })
end

return FarmingPage
