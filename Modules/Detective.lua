local Detective = {}

function Detective:Create(Page, App)
    App:BuildComingSoonPage(
        Page,
        "Detective",
        "Detective-related settings will be organized here after the dashboard shell is finalized."
    )
end

return Detective
