local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest or {}
local FarmingRuntime = Environment.__SquidNoMoFarmingRuntime
if type(FarmingRuntime) ~= "table"
    or FarmingRuntime.Revision ~= tostring(Manifest.FarmingRuntimeRevision or "")
    or tonumber(FarmingRuntime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    local bundle = Environment.__SquidNoMoSourceBundle
    local source = type(bundle) == "table" and bundle["Features/Farming/FarmingRuntime.lua"] or nil
    if type(source) ~= "string" then
        error("SquidNoMo verified farming runtime is unavailable")
    end
    FarmingRuntime = loadstring(source)()
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
        "Features/Games/SquidGame/SquidGamePush.lua",
    },
    ["Tug of War"] = {
        "Features/Games/TugOfWar/PerfectTiming.lua",
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
        local category = Environment.__SquidNoMoDetectedGame
        if not category then category = runtime:DetectGameCategory() end
        if not category then
            self.ActiveCategory = nil
            return {}, "Waiting to identify the active minigame"
        end

        self.ActiveCategory = category
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
