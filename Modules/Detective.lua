local DetectivePage = {}

-- Detective subpages are grouped around the actual investigation workflow.
local CATEGORIES = {
    {
        Name = "Island Navigation",
        Short = "WALK",
        Features = {
            {
                Name = "Island Navigator",
                Description = "Auto-walks from the boat/start area to the nearest evidence using pathfinding. No teleports.",
                Path = "Features/Detective/IslandNavigator.lua",
            },
        },
    },
    {
        Name = "Evidence",
        Short = "EVIDENCE",
        Features = {
            {Name = "Evidence Collector", Path = "Features/Detective/EvidenceCollector.lua"},
            {Name = "Evidence ESP", Path = "Features/Detective/EvidenceESP.lua"},
        },
    },
    {
        Name = "Boat Operations",
        Short = "BOAT",
        Features = {
            {Name = "Boat Depositor", Path = "Features/Detective/BoatDepositor.lua"},
        },
    },
    {
        Name = "Disguise",
        Short = "DISGUISE",
        Features = {
            {Name = "Disguise Manager", Path = "Features/Detective/DisguiseManager.lua"},
        },
    },
}

function DetectivePage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Detective",
        SessionKey = "SelectedDetectiveCategory",
        DefaultName = CATEGORIES[1].Name,
        ScrollerName = "DetectiveCategoryScroller",
        ButtonWidth = 240,
        Items = CATEGORIES,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Detective",
                Features = item.Features or {},
            })
        end,
    })
end

return DetectivePage
