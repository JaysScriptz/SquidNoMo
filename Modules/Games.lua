local GamesPage = {}

function GamesPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Games") or {}
    local manager = App.FeatureManager
    local lastDetected = nil

    local selector = App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Games",
        SessionKey = "SelectedGameCategory",
        DefaultName = categories[1] and categories[1].Name or "Red Light, Green Light",
        ScrollerName = "GameCategoryScroller",
        ButtonWidth = 190,
        Items = categories,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Games",
                Features = item.Features or {},
            })
        end,
    })

    local function followDetectedGame()
        if not manager or type(manager.GetDetectedGameCategory) ~= "function" then return end
        local detected = manager:GetDetectedGameCategory()
        if detected and detected ~= lastDetected then
            lastDetected = detected
            selector.SelectByName(detected)
        end
    end

    followDetectedGame()
    if manager and type(manager.Subscribe) == "function" then
        local connection = manager:Subscribe(function()
            followDetectedGame()
        end)
        Page.Destroying:Connect(function()
            pcall(function() connection:Disconnect() end)
        end)
    end
end

return GamesPage
