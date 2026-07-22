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

    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = "Farming",
        HeaderHeight = 0,
        Gap = 0,
    })
    shell.Header.Visible = false

    App.Loader.FeatureFolder:Render(shell.Content, App, {
        PageName = "Farming",
        TopY = 0,
        Features = features,
    })
end

return FarmingPage
