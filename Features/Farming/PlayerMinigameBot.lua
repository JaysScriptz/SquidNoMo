local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local FarmingRuntime = Environment.__SquidNoMoFarmingRuntime
if type(FarmingRuntime) ~= "table" or FarmingRuntime.Revision ~= "1.1b1-farming-r1" then
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Features/Farming/FarmingRuntime.lua"
            .. "?squidnomo_revision=1_1b1_farming_r1"
    )
    FarmingRuntime = loadstring(source)()
end
if type(FarmingRuntime) ~= "table" or FarmingRuntime.Revision ~= "1.1b1-farming-r1" then
    error("SquidNoMo farming runtime revision mismatch")
end

local profiles = {
    ["Red Light, Green Light"] = {
        "Features/Games/RLGL/AutoMove.lua",
    },
    ["Dalgona"] = {
        "Features/Games/Dalgona/AutoCut.lua",
    },
    ["Pentathlon"] = {
        "Features/Games/Pentathlon/Biseokchigi.lua",
        "Features/Games/Pentathlon/Ddakji.lua",
        "Features/Games/Pentathlon/Gonggi.lua",
        "Features/Games/Pentathlon/Jegichagi.lua",
        "Features/Games/Pentathlon/Paengi.lua",
    },
    ["Jump Rope"] = {
        "Features/Games/JumpRope/AutoComplete.lua",
    },
    ["Marbles"] = {
        "Features/Games/Marbles/RingShooter.lua",
    },
    ["Mingle"] = {
        "Features/Games/Mingle/SmartRoom.lua",
    },
    ["Fight Nights"] = {
        "Features/Games/NightBrawls/CombatAura.lua",
    },
    ["Glass Bridge"] = {
        "Features/Games/GlassBridge/AutoComplete.lua",
    },
    ["Rebellion"] = {
        "Features/Games/Rebellion/GuardCombat.lua",
    },
    ["Rock, Paper, Scissors Minus One"] = {
        "Features/Games/RockPaperScissors/AutoPlay.lua",
    },
    ["Sky Squid"] = {
        "Features/Games/SkySquid/AutoPush.lua",
    },
    ["Squid Game"] = {
        "Features/Games/Squid game/SquidGamePush.lua",
    },
    ["Tug of War"] = {
        "Features/Games/TugOfWar/Perfect timing.lua",
    },
    ["Escape"] = {
        "Features/Games/Escape/IslandNav.lua",
    },
}

return FarmingRuntime:CreateController({
    Id = "mapped.farming.player_minigame_bot",
    Name = "Player Minigame Farming",
    Description = "Detects the active minigame and runs one conservative automation profile at a time.",
    Interval = 0.8,
    IdleInterval = 1.5,
    Select = function(self, helper, runtime)
        local category = runtime:DetectGameCategory()
        if not category then
            self.ActiveCategory = nil
            return {}, "Waiting to identify the active minigame"
        end

        if category == "Hide & Seek" then
            local hasKey = helper:FindTool({"key", "keycard"}) ~= nil
            if hasKey then
                return {
                    "Features/Games/HideSeek/AutoPathToExit.lua",
                }, "Hide & Seek: carrying a key, walking to the exit"
            end
            return {
                "Features/Games/HideSeek/AutoGrabKey.lua",
            }, "Hide & Seek: searching for a key"
        end

        local selected = profiles[category]
        if not selected then
            self.ActiveCategory = nil
            return {}, "No stable farming profile is available for " .. tostring(category)
        end

        self.ActiveCategory = category
        return selected, "Auto farming " .. tostring(category)
    end,
})
