local DetectivePage = {}

local CATEGORIES = {
    {Name = "Find Island", Short = "ISLAND", Files = {"BoatDepositor"}},
    {Name = "Evidence", Short = "EVIDENCE", Files = {"EvidenceCollector", "EvidenceESP"}},
    {Name = "Extras", Short = "EXTRAS", Files = {"DisguiseManager"}},
}

local function displayName(name)
    return (name:gsub("(%l)(%u)", "%1 %2"))
end

local function featureList(item)
    local result = {}
    for _, file in ipairs(item.Files or {}) do
        table.insert(result, {
            Name = displayName(file),
            Path = "Features/Detective/" .. file .. ".lua",
        })
    end
    return result
end

function DetectivePage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Detective",
        SessionKey = "SelectedDetectiveCategory",
        DefaultName = "Find Island",
        ScrollerName = "DetectiveCategoryScroller",
        ButtonWidth = 260,
        Items = CATEGORIES,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Detective",
                Features = featureList(item),
            })
        end,
    })
end

return DetectivePage
