--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Modules/Home.lua
--// Approved dashboard composition.
--//========================================================--

local Home = {}

function Home:Create(page, App)
    local root = App:CreateFrame(
        page,
        UDim2.fromScale(1, 1),
        UDim2.fromOffset(0, 0),
        App.Theme.Background,
        {
            Transparency = 1,
            ZIndex = 10,
        }
    )
    root.Name = "HomeDashboard"

    local heroHolder = App:CreateFrame(root, UDim2.new(1, -28, 0, 152), UDim2.fromOffset(14, 14), App.Theme.Background, {
        Transparency = 1,
        ZIndex = 11,
    })
    App.Loader.HomeHero:Create(heroHolder, App)

    local featureHolder = App:CreateFrame(root, UDim2.new(1, -28, 0, 354), UDim2.fromOffset(14, 178), App.Theme.Background, {
        Transparency = 1,
        ZIndex = 11,
    })
    App.Loader.HomeFeatureStats:Create(featureHolder, App)

    local statusHolder = App:CreateFrame(root, UDim2.new(1, -28, 0, 282), UDim2.fromOffset(14, 544), App.Theme.Background, {
        Transparency = 1,
        ZIndex = 11,
    })
    App.Loader.HomeStatusPanels:Create(statusHolder, App)
end

return Home
