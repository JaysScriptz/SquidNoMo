local Games = {}

function Games:Create(Page, App)
    App:BuildComingSoonPage(
        Page,
        "Games",
        "Game-specific categories will live here. This is the primary feature area and remains first in navigation."
    )
end

return Games
