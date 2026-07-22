local DetectivePage = {}

function DetectivePage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Detective") or {}
    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = "Detective",
        HeaderHeight = App:IsMobile() and 100 or 106,
    })

    App.Loader.CategoryStrip:Create(Page, App, {
        Parent = shell.Header,
        GestureOwner = Page,
        ClearParent = false,
        PageName = "Detective",
        SessionKey = "SelectedDetectiveCategory",
        DefaultName = categories[1] and categories[1].Name or "Island Navigation",
        ScrollerName = "DetectiveCategoryScroller",
        ButtonWidth = 240,
        Items = categories,
        OnSelected = function(item)
            shell:ResetScroll()
            App.Loader.FeatureFolder:Render(shell.Content, App, {
                PageName = "Detective",
                TopY = 0,
                Features = item.Features or {},
            })
        end,
    })
end

return DetectivePage
