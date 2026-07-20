local GamesPage = {}

local CATEGORIES = {
    {Name = "Red Light, Green Light", Short = "RLGL", Folder = "RLGL", Files = {"AntiStuck", "AutoMove", "DollESP", "SafeZoneESP", "StateESP"}},
    {Name = "Honeycomb", Short = "HC", Folder = "Dalgona", Files = {"AutoCut", "AutoLighter", "HighlightESP", "TaceHelper"}},
    {Name = "Pentathlon", Short = "PENTA", Folder = "Pentathlon", Files = {"Biseokchigi", "Ddakji", "Gonggi", "Jegichagi", "Paengi"}},
    {Name = "Hide & Seek (Keys & Knives)", Short = "H&S", Folder = "HideSeek", Files = {"AutoGrabKey", "AutoGrabKnife", "AutoPathToExit", "AutoSwing", "EnemyESP", "ExitESP", "HunterTracker", "MapRadar"}},
    {Name = "Jump Rope", Short = "ROPE", Folder = "JumpRope", Files = {"AutoComplete", "AutoJump", "AutoPosition", "JumpBoost", "RopeBypass"}},
    {Name = "Sky Squid", Short = "SKY", Folder = "SkySquid", Files = {"AntiFall", "AutoFight", "AutoPush", "InstantGrab"}},
    {Name = "Mingle", Short = "MINGLE", Folder = "Mingle", Files = {"AutoRoom", "RoomESP", "SmartRoom"}},
    {Name = "Fight Nights", Short = "FIGHT", Folder = "NightBrawls", Files = {"BrawlESP", "BrawlEvasion", "CombatAura"}},
    {Name = "Rebellion", Short = "REBELLION", Folder = "Rebellion", Files = {"FrontmanNavigator", "GuardCombat"}},
    {Name = "Tug of War", Short = "TUG", Folder = "TugOfWar", Files = {"AutoPull", "Perfect timing"}},
    {Name = "Marbles", Short = "MARBLES", Folder = "Marbles", Files = {"MarbleAimer", "MarblesESP", "RecoveryAssist", "RingShooter"}},
    {Name = "Rock, Paper, Scissors Minus One", Short = "RPS-1", Folder = "RockPaperScissors", Files = {"AutoPlay"}},
    {Name = "Glass Bridge", Short = "GLASS", Folder = "GlassBridge", Files = {"AntiFall", "AutoComplete", "AutoReset", "GlassESP"}},
    {Name = "Squid Game", Short = "SQUID", Folder = "Squid game", Files = {"CourtBoundaryKeeper", "SquidGamePush"}},
}

local function displayName(name)
    return (name:gsub("(%l)(%u)", "%1 %2"))
end

local function featureList(item)
    local result = {}
    for _, file in ipairs(item.Files or {}) do
        table.insert(result, {
            Name = displayName(file),
            Path = "Features/Games/" .. item.Folder .. "/" .. file .. ".lua",
        })
    end
    return result
end

function GamesPage:Create(Page, App)
    App.Loader.CategoryStrip:Create(Page, App, {
        PageName = "Games",
        SessionKey = "SelectedGameCategory",
        DefaultName = "Red Light, Green Light",
        ScrollerName = "GameCategoryScroller",
        ButtonWidth = 190,
        Items = CATEGORIES,
        OnSelected = function(item)
            App.Loader.FeatureFolder:Render(Page, App, {
                PageName = "Games",
                Features = featureList(item),
            })
        end,
    })
end

return GamesPage
