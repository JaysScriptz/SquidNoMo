local DetectivePage = {}

local CATEGORIES = {
    {Name = 'Find Island', Short = 'ISLAND'},
    {Name = 'Evidence', Short = 'EVIDENCE'},
    {Name = 'Extras', Short = 'EXTRAS'},
}

function DetectivePage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = 'Detective',
        SessionKey = 'SelectedDetectiveCategory',
        DefaultName = 'Find Island',
        ScrollerName = 'DetectiveCategoryScroller',
        ButtonWidth = 260,
        Items = CATEGORIES,
    })
end

return DetectivePage
