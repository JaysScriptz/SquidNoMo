local Settings = {}

function Settings:Create(Page, App)
    App:BuildComingSoonPage(
        Page,
        "Settings",
        "General app settings, persistence, and diagnostics will be organized here."
    )
end

return Settings
