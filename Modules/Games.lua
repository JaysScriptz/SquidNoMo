local GamesPage = {}

function GamesPage:Create(Page, App)
    local catalog = App.Loader.FeatureCatalog
    local categories = catalog and catalog:GetCategories("Games") or {}
    local manager = App.FeatureManager
    local alive = true
    local lastDetected = nil
    local mobile = App:IsMobile()
    local categoryHeight = mobile and 102 or 106

    -- The learning recorder is a separate executable (Recorder.lua). Keeping the
    -- Games page focused on navigation prevents recorder controls from being
    -- clipped by subpage headers or affected by page scrolling.
    local shell = App.Loader.SubpageShell:Create(Page, App, {
        PageName = "Games",
        HeaderHeight = categoryHeight,
        ToolbarHeight = 0,
    })

    local categoryHost = Instance.new("Frame")
    categoryHost.Name = "GameCategoryHost"
    categoryHost.Position = UDim2.fromOffset(0, 0)
    categoryHost.Size = UDim2.new(1, 0, 0, categoryHeight)
    categoryHost.BackgroundTransparency = 1
    categoryHost.ClipsDescendants = true
    categoryHost.Parent = shell.Header

    local selector = App.Loader.CategoryStrip:Create(Page, App, {
        Parent = categoryHost,
        GestureOwner = Page,
        ClearParent = false,
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
