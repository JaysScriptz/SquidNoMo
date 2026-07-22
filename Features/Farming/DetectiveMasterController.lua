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
