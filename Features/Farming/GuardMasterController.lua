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

local function nearby(helper, root, tokens, maxDistance)
    if not root then return nil, math.huge end
    local target, distance = helper:FindNearest({
        Scope = "Workspace",
        TargetTokens = tokens,
        TargetClasses = {"Model", "BasePart", "Tool", "ProximityPrompt"},
        MaxTargets = 140,
    }, root.Position)
    if target and distance <= (maxDistance or 70) then
        return target, distance
    end
    return nil, math.huge
end

return FarmingRuntime:CreateController({
    Id = "mapped.farming.guard_master_controller",
    Name = "Guard Staff Farming",
    Description = "Selects one compatible guard duty at a time for kitchen, morgue, or moderation work.",
    Interval = 0.9,
    IdleInterval = 1.7,
    Select = function(self, helper)
        local _, _, _, root = helper:GetCharacter()
        if not root then return {}, "Waiting for the local character" end

        if helper:FindTool({"cooked", "meal", "tray"}) then
            return {
                "Features/Guard/Kitchen/AutoStorage.lua",
            }, "Kitchen Staff: delivering cooked food"
        end
        if helper:FindTool({"raw", "ingredient", "meat", "uncooked"}) then
            return {
                "Features/Guard/Kitchen/AutoCooker.lua",
            }, "Kitchen Staff: cooking collected supplies"
        end
        if helper:FindTool({"coffin", "body", "corpse"}) then
            return {
                "Features/Guard/Coffin/CoffinDisposal.lua",
            }, "Morgue Staff: carrying a coffin to disposal"
        end

        local kitchen, kitchenDistance = nearby(
            helper,
            root,
            {"kitchen", "cook", "stove", "oven", "ingredient", "supply", "food crate"},
            70
        )
        local morgue, morgueDistance = nearby(
            helper,
            root,
            {"morgue", "coffin", "corpse", "incinerator", "furnace", "disposal"},
            70
        )
        local cleanup, cleanupDistance = nearby(
            helper,
            root,
            {"eliminated", "dead body", "cleanup target"},
            55
        )

        if kitchen and kitchenDistance <= morgueDistance and kitchenDistance <= cleanupDistance then
            return {
                "Features/Guard/Kitchen/AutoSupply.lua",
            }, "Kitchen Staff: collecting supplies"
        end
        if morgue and morgueDistance <= cleanupDistance then
            return {
                "Features/Guard/Coffin/CoffinGrabber.lua",
            }, "Morgue Staff: collecting a coffin or body"
        end
        if cleanup then
            return {
                "Features/Guard/PlayerModeration/GuardLocalCleanup.lua",
            }, "Game Moderation: cleaning an eliminated target"
        end

        if helper:FindTool({"taser", "stun", "baton", "guard weapon"}) then
            return {
                "Features/Guard/PlayerModeration/GuardLocalModerator.lua",
            }, "Game Moderation: monitoring nearby player targets"
        end

        return {}, "Waiting to identify a nearby guard duty station"
    end,
})
