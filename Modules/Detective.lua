local DetectivePage = {}

function DetectivePage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Detective") or {}

    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Detective",
        SessionKey = "SelectedDetectiveCategory",
        DefaultName = categories[1] and categories[1].Name or "Island Navigation",
        ScrollerName = "DetectiveCategoryScroller",
        ButtonWidth = 240,
        Items = categories,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Detective",
                Features = item.Features or {},
            })
        end,
    })
end

return DetectivePage
