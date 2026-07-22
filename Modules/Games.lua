local GamesPage = {}

function GamesPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Games") or {}
    local manager = App.FeatureManager
    local alive = true
    local lastDetected = nil

    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = "Games",
        HeaderHeight = App:IsMobile() and 100 or 106,
        ToolbarHeight = App:IsMobile() and 68 or 64,
    })

    local learning = App.Loader.LearningPanel:Create(shell.Toolbar, App, {
        GameName = categories[1] and categories[1].Name or "Red Light, Green Light",
    })

    local selector = App.Loader.CategoryStrip:Create(Page, App, {
        Parent = shell.Header,
        GestureOwner = Page,
        ClearParent = false,
        PageName = "Games",
        SessionKey = "SelectedGameCategory",
        DefaultName = categories[1] and categories[1].Name or "Red Light, Green Light",
        ScrollerName = "GameCategoryScroller",
        ButtonWidth = 190,
        Items = categories,
        OnSelected = function(item, _, userInitiated)
            if learning and learning.SetGame then learning.SetGame(item.Name) end
            if userInitiated and manager and type(manager.SetManualGameCategory) == "function" then
                manager:SetManualGameCategory(item.Name)
            end
            shell:ResetScroll()
            App.Loader.FeatureFolder:Render(shell.Content, App, {
                PageName = "Games",
                TopY = 0,
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
