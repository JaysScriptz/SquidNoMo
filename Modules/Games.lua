local GamesPage = {}

function GamesPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Games") or {}
    local manager = App.FeatureManager
    local alive = true
    local lastDetected = nil

    local selector = App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Games",
        SessionKey = "SelectedGameCategory",
        DefaultName = categories[1] and categories[1].Name or "Red Light, Green Light",
        ScrollerName = "GameCategoryScroller",
        ButtonWidth = 190,
        Items = categories,
        OnSelected = function(item, _, userInitiated)
            if userInitiated and manager and type(manager.SetManualGameCategory) == "function" then
                manager:SetManualGameCategory(item.Name)
            end
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
            if App.Session then App.Session.SelectedGameCategory = detected end
        end
    end

    followDetectedGame()
    local connection
    if manager and type(manager.Subscribe) == "function" then
        connection = manager:Subscribe(followDetectedGame)
    end

    -- Do not depend solely on registry notifications. The mode detector runs while
    -- the page is open and immediately changes the visible subpage after a round
    -- transition, even when no feature state changed.
    task.spawn(function()
        while alive and Page.Parent do
            followDetectedGame()
            task.wait(Page.Visible and 0.35 or 0.9)
        end
    end)

    Page.Destroying:Connect(function()
        alive = false
        if connection then pcall(function() connection:Disconnect() end) end
    end)
end

return GamesPage
