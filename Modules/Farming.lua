local FarmingPage = {}

function FarmingPage:Create(Page, App)
    local catalog = App.Loader and App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Farming") or {}
    local features = {}

    for _, category in ipairs(categories) do
        for _, feature in ipairs(category.Features or {}) do
            table.insert(features, feature)
        end
    end

    -- Farming intentionally uses one continuous toggle page. There is no
    -- category strip because each controller already selects its own task.
    App.Loader.FeatureFolder:Render(Page, App, {
        PageName = "Farming",
        TopY = App:IsMobile() and 18 or 22,
        Features = features,
    })
end

return FarmingPage
