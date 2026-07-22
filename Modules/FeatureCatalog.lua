local FeatureCatalog = {}

local function slug(value)
    value = tostring(value or ""):lower()
    value = value:gsub("[^%w]+", "_")
    return value:gsub("^_+", ""):gsub("_+$", "")
end

local function humanize(value)
    value = tostring(value or "Feature")
    value = value:gsub("(%l)(%u)", "%1 %2")
    value = value:gsub("_", " ")
    return value
end

local function fallbackDescription(name)
    local readable = humanize(name)
    local lower = readable:lower()
    if lower:find("esp", 1, true) then
        return "Highlights the relevant targets so they are easier to locate during play."
    elseif lower:find("auto", 1, true) then
        return "Automates the related game action while this feature is enabled."
    elseif lower:find("navigator", 1, true) or lower:find("path", 1, true) then
        return "Guides the character toward the related objective using movement assistance."
    elseif lower:find("anti", 1, true) then
        return "Helps prevent the related failure condition during the current round."
    end
    return "Provides focused assistance for " .. readable .. "."
end

FeatureCatalog.Pages = {
    Games = {
        {
            Name = "Red Light, Green Light",
            Short = "RLGL",
            Folder = "RLGL",
            Features = {
                {
                    Id = "mapped.games.red_light_green_light.antistuck",
                    Name = "Anti Stuck",
                    Description = "Checks real movement progress and applies one jump recovery only during confirmed green light.",
                    Path = "Features/Games/RLGL/AntiStuck.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.automove",
                    Name = "Auto Move",
                    Description = "Moves toward the verified finish only during confirmed green light and stops on red or uncertain signals.",
                    Path = "Features/Games/RLGL/AutoMove.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.dollesp",
                    Name = "Doll ESP",
                    Description = "Highlights the active Younghee or robot doll model in the RLGL field.",
                    Path = "Features/Games/RLGL/DollESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.safezoneesp",
                    Name = "Safe Zone ESP",
                    Description = "Highlights the detected finish, goal, or safe zone and excludes start and spawn markers.",
                    Path = "Features/Games/RLGL/SafeZoneESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.stateesp",
                    Name = "State ESP",
                    Description = "Displays a clear local red, green, or uncertain signal without changing movement settings.",
                    Path = "Features/Games/RLGL/StateESP.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Dalgona",
            Short = "DALGONA",
            Folder = "Dalgona",
            Features = {
                {
                    Id = "mapped.games.dalgona.autocut",
                    Name = "Auto Cut",
                    Description = "Uses only client-visible trace nodes or exposed cut controls; it pauses instead of guessing when the interface hides the path.",
                    Path = "Features/Games/Dalgona/AutoCut.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.autolighter",
                    Name = "Auto Lighter",
                    Description = "Equips and activates a visible lighter or flame tool while the Dalgona round is confirmed.",
                    Path = "Features/Games/Dalgona/AutoLighter.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.highlightesp",
                    Name = "Shape Highlight",
                    Description = "Outlines the visible cookie shape or cutting area without sending game actions.",
                    Path = "Features/Games/Dalgona/HighlightESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.tracehelper",
                    Name = "Trace Helper",
                    Description = "Highlights the visible trace path, needle, or cursor so the cutting route is easier to follow.",
                    Path = "Features/Games/Dalgona/TraceHelper.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Pentathlon",
            Short = "PENTA",
            Folder = "Pentathlon",
            Features = {
                {
                    Id = "mapped.games.pentathlon.biseokchigi",
                    Name = "Biseokchigi Assist",
                    Description = "Acts only on the visible Biseokchigi timing control when its target zone is ready.",
                    Path = "Features/Games/Pentathlon/Biseokchigi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.ddakji",
                    Name = "Ddakji Assist",
                    Description = "Acts only on the visible Ddakji timing control when its target zone is ready.",
                    Path = "Features/Games/Pentathlon/Ddakji.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.gonggi",
                    Name = "Gonggi Assist",
                    Description = "Presses only visible Gonggi catch, throw, or next controls and ignores unrelated interface buttons.",
                    Path = "Features/Games/Pentathlon/Gonggi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.jegichagi",
                    Name = "Jegichagi Assist",
                    Description = "Triggers the visible kick control only during the ready timing zone.",
                    Path = "Features/Games/Pentathlon/Jegichagi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.paengi",
                    Name = "Paengi Assist",
                    Description = "Triggers the visible spin or pull control only during the ready timing zone.",
                    Path = "Features/Games/Pentathlon/Paengi.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Hide & Seek",
            Short = "H&S",
            Folder = "HideSeek",
            Features = {
                {
                    Id = "mapped.games.hide_seek.autograbkey",
                    Name = "Auto Grab Key",
                    Description = "For Hiders, finds the best interactive key target, walks to it, and uses the available prompt, click, or touch interaction.",
                    Path = "Features/Games/HideSeek/AutoGrabKey.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autograbknife",
                    Name = "Auto Grab Knife",
                    Description = "For Seekers, finds the best interactive knife target, walks to it, and collects it through the supported interaction.",
                    Path = "Features/Games/HideSeek/AutoGrabKnife.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autopathtoexit",
                    Name = "Auto Path to Exit",
                    Description = "For Hiders carrying a key, pathfinds to a detected exit and uses its visible interaction.",
                    Path = "Features/Games/HideSeek/AutoPathToExit.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autoswing",
                    Name = "Auto Swing",
                    Description = "For Seekers, faces a nearby opponent and activates an equipped melee tool at a controlled rate.",
                    Path = "Features/Games/HideSeek/AutoSwing.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.enemyesp",
                    Name = "Enemy ESP",
                    Description = "Highlights living opposing players using the confirmed local Hide & Seek role.",
                    Path = "Features/Games/HideSeek/EnemyESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.exitesp",
                    Name = "Exit ESP",
                    Description = "Highlights detected exits, gates, and escape doors in the active maze.",
                    Path = "Features/Games/HideSeek/ExitESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.huntertracker",
                    Name = "Hunter Tracker",
                    Description = "Highlights living players whose team, role, or character cues identify them as a Hunter or Seeker.",
                    Path = "Features/Games/HideSeek/HunterTracker.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.mapradar",
                    Name = "Map Radar",
                    Description = "Shows nearby players, exits, keys, knives, and doors in a lightweight local radar.",
                    Path = "Features/Games/HideSeek/MapRadar.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Jump Rope",
            Short = "ROPE",
            Folder = "JumpRope",
            Features = {
                {
                    Id = "mapped.games.jump_rope.autocomplete",
                    Name = "Auto Complete",
                    Description = "Advances toward the finish only when the moving rope is outside the danger window and jumps detected gaps.",
                    Path = "Features/Games/JumpRope/AutoComplete.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.autojump",
                    Name = "Auto Jump",
                    Description = "Tracks the moving rope and jumps only when it is approaching within the verified trigger window.",
                    Path = "Features/Games/JumpRope/AutoJump.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.autoposition",
                    Name = "Auto Position",
                    Description = "Keeps the character near the lane established when the feature is enabled while allowing forward progress.",
                    Path = "Features/Games/JumpRope/AutoPosition.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.jumpboost",
                    Name = "Jump Boost",
                    Description = "Temporarily raises jump strength during the confirmed Jump Rope round and restores the original value when disabled.",
                    Path = "Features/Games/JumpRope/JumpBoost.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Mingle",
            Short = "MINGLE",
            Folder = "Mingle",
            Features = {
                {
                    Id = "mapped.games.mingle.autoroom",
                    Name = "Auto Room",
                    Description = "Reads the visible required count, chooses a nearby room with available capacity, and enters it during the room phase.",
                    Path = "Features/Games/Mingle/AutoRoom.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.mingle.roomesp",
                    Name = "Room ESP",
                    Description = "Highlights active room and door targets during the confirmed Mingle round.",
                    Path = "Features/Games/Mingle/RoomESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.mingle.smartroom",
                    Name = "Smart Room",
                    Description = "Scores nearby rooms by distance and occupancy, rejects full rooms, and moves toward the best verified option.",
                    Path = "Features/Games/Mingle/SmartRoom.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Tug of War",
            Short = "TUG",
            Folder = "TugOfWar",
            Features = {
                {
                    Id = "mapped.games.tug_of_war.autopull",
                    Name = "Auto Pull",
                    Description = "Presses the visible Tug of War pull control at a throttled rate and ignores unrelated interface buttons.",
                    Path = "Features/Games/TugOfWar/AutoPull.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.tug_of_war.perfect_timing",
                    Name = "Perfect Timing",
                    Description = "Presses the visible pull control only when the timing meter exposes a ready or green zone.",
                    Path = "Features/Games/TugOfWar/PerfectTiming.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Marbles",
            Short = "MARBLES",
            Folder = "Marbles",
            Features = {
                {
                    Id = "mapped.games.marbles.marbleaimer",
                    Name = "Marble Aimer",
                    Description = "Aims the camera toward the best visible marble target and activates the equipped marble tool at a controlled rate.",
                    Path = "Features/Games/Marbles/MarbleAimer.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.marblesesp",
                    Name = "Marbles ESP",
                    Description = "Highlights visible marbles, rings, holes, and round targets.",
                    Path = "Features/Games/Marbles/MarblesESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.recoveryassist",
                    Name = "Recovery Assist",
                    Description = "Keeps the player near the position where the feature was enabled so missed throws do not pull them away from the aiming area.",
                    Path = "Features/Games/Marbles/RecoveryAssist.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.ringshooter",
                    Name = "Ring Shooter",
                    Description = "Aims at the nearest visible ring or hole and activates the marble tool without inventing hidden target data.",
                    Path = "Features/Games/Marbles/RingShooter.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Glass Bridge",
            Short = "GLASS",
            Folder = "GlassBridge",
            Features = {
                {
                    Id = "mapped.games.glass_bridge.antifall",
                    Name = "Anti Fall",
                    Description = "Keeps the latest grounded bridge position and attempts a non-teleport recovery when a fall begins.",
                    Path = "Features/Games/GlassBridge/AntiFall.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.autocomplete",
                    Name = "Auto Complete",
                    Description = "Walks only to glass panels verified safe by exposed state or by another living player standing on them; it never guesses.",
                    Path = "Features/Games/GlassBridge/AutoComplete.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.autoreset",
                    Name = "Auto Reset",
                    Description = "Attempts to steer the character back toward the last grounded bridge point without teleporting.",
                    Path = "Features/Games/GlassBridge/AutoReset.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.glassesp",
                    Name = "Glass ESP",
                    Description = "Labels known safe, known unsafe, and unknown bridge panels; unknown panels remain clearly marked instead of being guessed.",
                    Path = "Features/Games/GlassBridge/GlassESP.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Rock, Paper, Scissors Minus One",
            Short = "RPS-1",
            Folder = "RockPaperScissors",
            Features = {
                {
                    Id = "mapped.games.rock_paper_scissors_minus_one.autoplay",
                    Name = "Auto Play",
                    Description = "Reads visible opponent choice text when available, chooses a counter, and submits through the visible RPS controls.",
                    Path = "Features/Games/RockPaperScissors/AutoPlay.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Fight Nights",
            Short = "FIGHT",
            Folder = "NightBrawls",
            Features = {
                {
                    Id = "mapped.games.fight_nights.brawlesp",
                    Name = "Brawl ESP",
                    Description = "Highlights living nearby opponents during confirmed Fight Nights or Lights Out rounds.",
                    Path = "Features/Games/NightBrawls/BrawlESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.fight_nights.brawlevasion",
                    Name = "Brawl Evasion",
                    Description = "Moves away from the nearest living opponent while preserving shared movement ownership.",
                    Path = "Features/Games/NightBrawls/BrawlEvasion.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.fight_nights.combataura",
                    Name = "Combat Aura",
                    Description = "Faces the nearest living opponent and activates an equipped combat tool at a throttled rate.",
                    Path = "Features/Games/NightBrawls/CombatAura.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Rebellion",
            Short = "REBELLION",
            Folder = "Rebellion",
            Features = {
                {
                    Id = "mapped.games.rebellion.frontmannavigator",
                    Name = "Frontman Navigator",
                    Description = "Pathfinds toward the confirmed Frontman, command room, control room, or final Rebellion objective.",
                    Path = "Features/Games/Rebellion/FrontmanNavigator.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.rebellion.guardcombat",
                    Name = "Guard Combat",
                    Description = "Targets confirmed guard or soldier characters and activates an equipped combat tool at a controlled rate.",
                    Path = "Features/Games/Rebellion/GuardCombat.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Sky Squid",
            Short = "SKY",
            Folder = "SkySquid",
            Features = {
                {
                    Id = "mapped.games.sky_squid.antifall",
                    Name = "Anti Fall",
                    Description = "Keeps the latest grounded platform position and attempts a non-teleport recovery when a fall begins.",
                    Path = "Features/Games/SkySquid/AntiFall.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.autofight",
                    Name = "Auto Fight",
                    Description = "Faces the nearest living opponent and activates an equipped combat tool at a controlled rate.",
                    Path = "Features/Games/SkySquid/AutoFight.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.autopush",
                    Name = "Auto Push",
                    Description = "Uses an equipped push or shove tool only when a living opponent is within range.",
                    Path = "Features/Games/SkySquid/AutoPush.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.instantgrab",
                    Name = "Instant Grab",
                    Description = "Finds the best nearby interactive weapon or pole and uses a supported prompt, click, or touch interaction.",
                    Path = "Features/Games/SkySquid/InstantGrab.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Squid Game",
            Short = "SQUID",
            Folder = "Squid game",
            Features = {
                {
                    Id = "mapped.games.squid_game.courtboundarykeeper",
                    Name = "Court Boundary Keeper",
                    Description = "Detects the active Squid Game court and moves inward only after the character crosses the configured boundary.",
                    Path = "Features/Games/SquidGame/CourtBoundaryKeeper.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.squid_game.squidgamepush",
                    Name = "Squid Game Push",
                    Description = "Uses an equipped push or shove tool only when a living opponent is within range.",
                    Path = "Features/Games/SquidGame/SquidGamePush.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Escape",
            Short = "ESCAPE",
            Folder = "Escape",
            Features = {
                {
                    Id = "mapped.games.escape.islandnav",
                    Name = "Island Extraction Route",
                    Description = "Uses pathfinding to walk toward a confirmed extraction boat, dock, or escape finish and interacts when close.",
                    Path = "Features/Games/Escape/IslandNav.lua",
                    Category = "Experimental",
                },
            },
        },
    },
    Guards = {
        {
            Name = "Game Moderation",
            Short = "MOD",
            Folder = "Player Moderation",
            Features = {
                {
                    Id = "mapped.guards.game_moderation.guardlocalcleanup",
                    Name = "Guard Local Cleanup",
                    Description = "Locally clears nearby eliminated bodies and cleanup targets during guard duty.",
                    Path = "Features/Guard/PlayerModeration/GuardLocalCleanup.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.guards.game_moderation.guardlocalmoderator",
                    Name = "Guard Local Moderator",
                    Description = "Assists with nearby guard moderation targets while avoiding unsupported rounds.",
                    Path = "Features/Guard/PlayerModeration/GuardLocalModerator.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Kitchen Staff",
            Short = "KITCHEN",
            Folder = "Kitchen",
            Features = {
                {
                    Id = "mapped.guards.kitchen_staff.autocooker",
                    Name = "Auto Cooker",
                    Description = "Finds raw supplies, equips them, and assists with nearby cooking stations.",
                    Path = "Features/Guard/Kitchen/AutoCooker.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.guards.kitchen_staff.autostorage",
                    Name = "Auto Storage",
                    Description = "Moves cooked food into detected storage or delivery stations.",
                    Path = "Features/Guard/Kitchen/AutoStorage.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.guards.kitchen_staff.autosupply",
                    Name = "Auto Supply",
                    Description = "Collects nearby kitchen supplies when inventory space is available.",
                    Path = "Features/Guard/Kitchen/AutoSupply.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Morgue Staff",
            Short = "MORGUE",
            Folder = "Coffin",
            Features = {
                {
                    Id = "mapped.guards.morgue_staff.coffindisposal",
                    Name = "Coffin Disposal",
                    Description = "Carries detected coffin or body tools toward the disposal area.",
                    Path = "Features/Guard/Coffin/CoffinDisposal.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.guards.morgue_staff.coffingrabber",
                    Name = "Coffin Grabber",
                    Description = "Finds and collects the nearest available coffin or body target.",
                    Path = "Features/Guard/Coffin/CoffinGrabber.lua",
                    Category = "Experimental",
                },
            },
        },
    },
    Detective = {
        {
            Name = "Island Navigation",
            Short = "WALK",
            Features = {
                {
                    Id = "mapped.detective.island_navigation.islandnavigator",
                    Name = "Island Navigator",
                    Description = "Auto-walks from the boat or starting area to the nearest evidence using pathfinding; it does not teleport.",
                    Path = "Features/Detective/IslandNavigator.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Evidence",
            Short = "EVIDENCE",
            Features = {
                {
                    Id = "mapped.detective.evidence.evidencecollector",
                    Name = "Evidence Collector",
                    Description = "Walks to nearby evidence and activates supported collection prompts.",
                    Path = "Features/Detective/EvidenceCollector.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.detective.evidence.evidenceesp",
                    Name = "Evidence ESP",
                    Description = "Highlights evidence, clues, files, and keycards in the world.",
                    Path = "Features/Detective/EvidenceESP.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Boat Operations",
            Short = "BOAT",
            Features = {
                {
                    Id = "mapped.detective.boat_operations.boatdepositor",
                    Name = "Boat Depositor",
                    Description = "Walks evidence back to the boat and deposits supported evidence tools.",
                    Path = "Features/Detective/BoatDepositor.lua",
                    Category = "Experimental",
                },
            },
        },
        {
            Name = "Disguise",
            Short = "DISGUISE",
            Features = {
                {
                    Id = "mapped.detective.disguise.disguisemanager",
                    Name = "Disguise Manager",
                    Description = "Equips an available disguise when a nearby guard is detected.",
                    Path = "Features/Detective/DisguiseManager.lua",
                    Category = "Experimental",
                },
            },
        },
    },
    Farming = {
        {
            Name = "Automation Controllers",
            Short = "AUTO",
            Features = {
                {
                    Id = "mapped.farming.player_minigame_bot",
                    Name = "Player Minigame Farming",
                    Description = "Detects the active minigame and runs one conservative automation profile at a time.",
                    Path = "Features/Farming/PlayerMinigameBot.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.farming.guard_master_controller",
                    Name = "Guard Staff Farming",
                    Description = "Selects one compatible guard duty at a time for kitchen, morgue, or moderation work.",
                    Path = "Features/Farming/GuardMasterController.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.farming.frontman_adaptive_controller",
                    Name = "Frontman Adaptive Farming",
                    Description = "Detects whether Frontman selected Player or Guard mode, then runs the matching farming controller.",
                    Path = "Features/Farming/FrontmanAdaptiveController.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.farming.detective_master_controller",
                    Name = "Detective Evidence Farming",
                    Description = "Runs a stable evidence loop: walk to clues, collect them, and return them to the boat.",
                    Path = "Features/Farming/DetectiveMasterController.lua",
                    Category = "Experimental",
                },
            },
        },
    },
}

local function finalize()
    for pageName, categories in pairs(FeatureCatalog.Pages) do
        for _, category in ipairs(categories) do
            for _, feature in ipairs(category.Features or {}) do
                feature.PageName = pageName
                feature.CategoryName = category.Name
                feature.Name = feature.Name or humanize(feature.Path:match("([^/]+)%.lua$") or "Feature")
                feature.Description = feature.Description or fallbackDescription(feature.Name)
                feature.Id = feature.Id or ("mapped." .. slug(pageName) .. "." .. slug(category.Name) .. "." .. slug(feature.Name))
                feature.Category = feature.Category or "Experimental"
            end
        end
    end
end

finalize()

function FeatureCatalog:GetCategories(pageName)
    return self.Pages[pageName] or {}
end

function FeatureCatalog:GetAllFeatures()
    local result = {}
    for _, categories in pairs(self.Pages) do
        for _, category in ipairs(categories) do
            for _, feature in ipairs(category.Features or {}) do
                table.insert(result, feature)
            end
        end
    end
    return result
end

function FeatureCatalog:GetTotalCount()
    return #self:GetAllFeatures()
end

function FeatureCatalog:Describe(feature)
    if type(feature) == "table" then
        return feature.Description or fallbackDescription(feature.Name)
    end
    return fallbackDescription(feature)
end

return FeatureCatalog
