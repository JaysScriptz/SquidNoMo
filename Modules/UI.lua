local UIPage = {}

function UIPage:Create(Page, App)
    App:BuildComingSoonPage(
        Page,
        "UI",
        "Interface, scaling, layout, and visual customization settings will be organized here."
    )
end

return UIPage
