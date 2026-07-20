local GuardsPage = {}

-- Guard has exactly three role-based subpages, each backed by a real feature folder.
local CATEGORIES = {
    {Name = "Game Moderation", Short = "MOD", Folder = "Player Moderation", Files = {"GuardLocalCleanup", "GuardLocalModerator"}},
    {Name = "Kitchen Staff", Short = "KITCHEN", Folder = "Kitchen", Files = {"AutoCooker", "AutoStorage", "AutoSupply"}},
    {Name = "Morgue Staff", Short = "MORGUE", Folder = "Coffin", Files = {"CoffinDisposal", "CoffinGrabber"}},
}

local function displayName(name)
    return (name:gsub("(%l)(%u)", "%1 %2"))
end

local function featureList(item)
    local result = {}
    for _, file in ipairs(item.Files or {}) do
        table.insert(result, {
            Name = displayName(file),
            Path = "Features/Guard/" .. item.Folder .. "/" .. file .. ".lua",
        })
    end
    return result
end

function GuardsPage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Guards",
        SessionKey = "SelectedGuardCategory",
        DefaultName = CATEGORIES[1].Name,
        ScrollerName = "GuardCategoryScroller",
        ButtonWidth = 220,
        Items = CATEGORIES,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Guards",
                Features = featureList(item),
            })
        end,
    })
end

return GuardsPage
