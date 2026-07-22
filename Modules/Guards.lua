local GuardsPage = {}

function GuardsPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Guards") or {}
    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = "Guards",
        HeaderHeight = App:IsMobile() and 100 or 106,
    })

    App.Loader.CategoryStrip:Create(Page, App, {
        Parent = shell.Header,
        GestureOwner = Page,
        ClearParent = false,
        PageName = "Guards",
        SessionKey = "SelectedGuardCategory",
        DefaultName = categories[1] and categories[1].Name or "Game Moderation",
        ScrollerName = "GuardCategoryScroller",
        ButtonWidth = 220,
        Items = categories,
        OnSelected = function(item)
            shell:ResetScroll()
            App.Loader.FeatureFolder:Render(shell.Content, App, {
                PageName = "Guards",
                TopY = 0,
                Features = item.Features or {},
            })
        end,
    })
end

return GuardsPage
