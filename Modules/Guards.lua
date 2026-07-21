local GuardsPage = {}

function GuardsPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Guards") or {}

    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Guards",
        SessionKey = "SelectedGuardCategory",
        DefaultName = categories[1] and categories[1].Name or "Game Moderation",
        ScrollerName = "GuardCategoryScroller",
        ButtonWidth = 220,
        Items = categories,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Guards",
                Features = item.Features or {},
            })
        end,
    })
end

return GuardsPage
