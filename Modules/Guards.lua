local Guards = {}

function Guards:Create(Page, App)
    App:BuildComingSoonPage(
        Page,
        "Guards",
        "Guard-related settings will be organized here after the dashboard shell is finalized."
    )
end

return Guards
