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

local DISGUISE = "Features/Detective/DisguiseManager.lua"

return FarmingRuntime:CreateController({
    Id = "mapped.farming.detective_master_controller",
    Name = "Detective Evidence Farming",
    Description = "Runs a stable evidence loop: walk to clues, collect them, and return them to the boat.",
    Interval = 0.85,
    IdleInterval = 1.6,
    Select = function(self, helper)
        local _, _, _, root = helper:GetCharacter()
        if not root then return {}, "Waiting for the local character" end

        if helper:FindTool({"evidence", "clue", "file", "document", "keycard", "fingerprint"}) then
            return {
                DISGUISE,
                "Features/Detective/BoatDepositor.lua",
            }, "Carrying evidence back to the boat"
        end

        local evidence, distance = helper:FindNearest({
            Scope = "Workspace",
            TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint"},
            ExcludeTokens = {"submitted", "deposit"},
            TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt", "ClickDetector"},
            MaxTargets = 160,
        }, root.Position)

        if evidence and distance <= 80 then
            return {
                DISGUISE,
                "Features/Detective/EvidenceCollector.lua",
            }, "Collecting the nearest evidence"
        end

        return {
            DISGUISE,
            "Features/Detective/IslandNavigator.lua",
        }, "Walking from the boat toward island evidence"
    end,
})
