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
                    Description = "Detects stalled movement and helps the character recover during the round.",
                    Path = "Features/Games/RLGL/AntiStuck.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.automove",
                    Name = "Auto Move",
                    Description = "Moves on green light and stops automatically when the doll changes to red.",
                    Path = "Features/Games/RLGL/AutoMove.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.dollesp",
                    Name = "Doll ESP",
                    Description = "Highlights the doll so its position stays visible from anywhere on the field.",
                    Path = "Features/Games/RLGL/DollESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.safezoneesp",
                    Name = "Safe Zone ESP",
                    Description = "Marks safe areas and the finish zone to make the route easier to read.",
                    Path = "Features/Games/RLGL/SafeZoneESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.red_light_green_light.stateesp",
                    Name = "State ESP",
                    Description = "Shows the current red-light or green-light state directly on screen.",
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
                    Description = "Automates the cookie carving interaction to help complete the selected shape.",
                    Path = "Features/Games/Dalgona/AutoCut.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.autolighter",
                    Name = "Auto Lighter",
                    Description = "Finds, equips, and repeatedly activates the lighter while enabled.",
                    Path = "Features/Games/Dalgona/AutoLighter.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.highlightesp",
                    Name = "Shape Highlight",
                    Description = "Outlines the cookie shape so the tracing boundary is easier to see.",
                    Path = "Features/Games/Dalgona/HighlightESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.dalgona.tacehelper",
                    Name = "Trace Helper",
                    Description = "Adds a visual tracing guide that follows the cursor over the cookie shape.",
                    Path = "Features/Games/Dalgona/TaceHelper.lua",
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
                    Description = "Automates the timing and interaction used for the Biseokchigi event.",
                    Path = "Features/Games/Pentathlon/Biseokchigi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.ddakji",
                    Name = "Ddakji Assist",
                    Description = "Helps perform the Ddakji action with consistent timing.",
                    Path = "Features/Games/Pentathlon/Ddakji.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.gonggi",
                    Name = "Gonggi Assist",
                    Description = "Automates the repeated inputs needed for the Gonggi event.",
                    Path = "Features/Games/Pentathlon/Gonggi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.jegichagi",
                    Name = "Jegichagi Assist",
                    Description = "Keeps the Jegichagi sequence going with automatic timed inputs.",
                    Path = "Features/Games/Pentathlon/Jegichagi.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.pentathlon.paengi",
                    Name = "Paengi Assist",
                    Description = "Automates the spin interaction for the Paengi event.",
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
                    Description = "Finds the nearest key and moves close enough to collect it.",
                    Path = "Features/Games/HideSeek/AutoGrabKey.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autograbknife",
                    Name = "Auto Grab Knife",
                    Description = "Finds the nearest knife and moves close enough to collect it.",
                    Path = "Features/Games/HideSeek/AutoGrabKnife.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autopathtoexit",
                    Name = "Auto Path to Exit",
                    Description = "Uses pathfinding to walk toward the nearest detected exit.",
                    Path = "Features/Games/HideSeek/AutoPathToExit.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.autoswing",
                    Name = "Auto Swing",
                    Description = "Automatically activates the equipped melee tool while enabled.",
                    Path = "Features/Games/HideSeek/AutoSwing.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.enemyesp",
                    Name = "Enemy ESP",
                    Description = "Highlights opposing players so nearby threats are easier to track.",
                    Path = "Features/Games/HideSeek/EnemyESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.exitesp",
                    Name = "Exit ESP",
                    Description = "Marks detected exits and escape points in the map.",
                    Path = "Features/Games/HideSeek/ExitESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.huntertracker",
                    Name = "Hunter Tracker",
                    Description = "Tracks hunters and keeps their location visible during the round.",
                    Path = "Features/Games/HideSeek/HunterTracker.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.hide_seek.mapradar",
                    Name = "Map Radar",
                    Description = "Shows nearby players and important map objects in a compact radar view.",
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
                    Description = "Coordinates movement and jumps to progress across the rope course.",
                    Path = "Features/Games/JumpRope/AutoComplete.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.autojump",
                    Name = "Auto Jump",
                    Description = "Triggers jumps automatically as the rope approaches.",
                    Path = "Features/Games/JumpRope/AutoJump.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.autoposition",
                    Name = "Auto Position",
                    Description = "Keeps the character aligned with the preferred jumping position.",
                    Path = "Features/Games/JumpRope/AutoPosition.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.jumpboost",
                    Name = "Jump Boost",
                    Description = "Temporarily increases jump strength for the rope sequence.",
                    Path = "Features/Games/JumpRope/JumpBoost.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.jump_rope.ropebypass",
                    Name = "Rope Bypass",
                    Description = "Reduces local rope interference to make crossing more forgiving.",
                    Path = "Features/Games/JumpRope/RopeBypass.lua",
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
                    Description = "Automatically moves toward a room that matches the current player count.",
                    Path = "Features/Games/Mingle/AutoRoom.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.mingle.roomesp",
                    Name = "Room ESP",
                    Description = "Highlights available rooms and displays useful room information.",
                    Path = "Features/Games/Mingle/RoomESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.mingle.smartroom",
                    Name = "Smart Room",
                    Description = "Chooses a suitable room based on occupancy and nearby players.",
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
                    Description = "Repeats the pull input automatically throughout Tug of War.",
                    Path = "Features/Games/TugOfWar/AutoPull.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.tug_of_war.perfect_timing",
                    Name = "Perfect Timing",
                    Description = "Times pull inputs around the strongest part of the tug sequence.",
                    Path = "Features/Games/TugOfWar/Perfect timing.lua",
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
                    Description = "Adds aiming assistance for more consistent marble throws.",
                    Path = "Features/Games/Marbles/MarbleAimer.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.marblesesp",
                    Name = "Marbles ESP",
                    Description = "Highlights marbles, targets, and useful round objects.",
                    Path = "Features/Games/Marbles/MarblesESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.recoveryassist",
                    Name = "Recovery Assist",
                    Description = "Helps recover the aiming position after a missed marble throw.",
                    Path = "Features/Games/Marbles/RecoveryAssist.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.marbles.ringshooter",
                    Name = "Ring Shooter",
                    Description = "Assists with lining up and firing marbles toward ring targets.",
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
                    Description = "Stores a recent safe bridge position and recovers after a fall.",
                    Path = "Features/Games/GlassBridge/AntiFall.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.autocomplete",
                    Name = "Auto Complete",
                    Description = "Moves toward detected safe glass tiles in sequence.",
                    Path = "Features/Games/GlassBridge/AutoComplete.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.autoreset",
                    Name = "Auto Reset",
                    Description = "Returns the character to a recovery point after falling below the bridge.",
                    Path = "Features/Games/GlassBridge/AutoReset.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.glass_bridge.glassesp",
                    Name = "Glass ESP",
                    Description = "Highlights detected safe and unsafe glass panels.",
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
                    Description = "Automatically selects and submits choices for each RPS Minus One round.",
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
                    Description = "Highlights nearby opponents during night-fight rounds.",
                    Path = "Features/Games/NightBrawls/BrawlESP.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.fight_nights.brawlevasion",
                    Name = "Brawl Evasion",
                    Description = "Keeps distance from nearby attackers and dangerous positions.",
                    Path = "Features/Games/NightBrawls/BrawlEvasion.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.fight_nights.combataura",
                    Name = "Combat Aura",
                    Description = "Automatically uses the equipped combat tool on nearby valid targets.",
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
                    Description = "Guides the character toward the detected Frontman objective.",
                    Path = "Features/Games/Rebellion/FrontmanNavigator.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.rebellion.guardcombat",
                    Name = "Guard Combat",
                    Description = "Automatically engages nearby guard targets with the equipped tool.",
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
                    Description = "Attempts to recover the character before a fall eliminates them.",
                    Path = "Features/Games/SkySquid/AntiFall.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.autofight",
                    Name = "Auto Fight",
                    Description = "Automatically attacks nearby valid opponents with the equipped tool.",
                    Path = "Features/Games/SkySquid/AutoFight.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.autopush",
                    Name = "Auto Push",
                    Description = "Uses the push action when an opponent enters range.",
                    Path = "Features/Games/SkySquid/AutoPush.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.sky_squid.instantgrab",
                    Name = "Instant Grab",
                    Description = "Quickly collects nearby weapons, poles, and usable tools.",
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
                    Description = "Helps keep the character inside the active Squid Game court.",
                    Path = "Features/Games/Squid game/CourtBoundaryKeeper.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.games.squid_game.squidgamepush",
                    Name = "Squid Game Push",
                    Description = "Automatically uses the push tool against nearby opponents.",
                    Path = "Features/Games/Squid game/SquidGamePush.lua",
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
                    Description = "Walks toward the detected extraction boat or finish point.",
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
                    Path = "Features/Guard/Player Moderation/GuardLocalCleanup.lua",
                    Category = "Experimental",
                },
                {
                    Id = "mapped.guards.game_moderation.guardlocalmoderator",
                    Name = "Guard Local Moderator",
                    Description = "Assists with nearby guard moderation targets while avoiding unsupported rounds.",
                    Path = "Features/Guard/Player Moderation/GuardLocalModerator.lua",
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
