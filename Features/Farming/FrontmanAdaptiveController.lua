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

local MODE_PATHS = {
    Player = "Features/Farming/PlayerMinigameBot.lua",
    Guard = "Features/Farming/GuardMasterController.lua",
}

local Controller = FarmingRuntime:CreateController({
    Id = "mapped.farming.frontman_adaptive_controller",
    Name = "Frontman Adaptive Farming",
    Description = "Detects whether Frontman selected Player or Guard mode, then runs the matching farming controller.",
    Interval = 0.85,
    IdleInterval = 1.45,
    Select = function(self, helper)
        local detectedMode, detectionDetail, confidence = helper:DetectFrontmanMode()
        local now = os.clock()

        if detectedMode then
            if detectedMode == self.ActiveMode then
                self.PendingMode = nil
                self.PendingCount = 0
                self.LastModeEvidence = now
            else
                if self.PendingMode == detectedMode then
                    self.PendingCount = (self.PendingCount or 0) + 1
                else
                    self.PendingMode = detectedMode
                    self.PendingCount = 1
                end

                -- Strong explicit attributes, a selected GUI state, or a guard
                -- duty tool can switch immediately. Weaker outfit/tool evidence
                -- must agree twice so the controller does not flap between modes.
                local confirmed = (tonumber(confidence) or 0) >= 14
                    or self.PendingCount >= 2
                if confirmed then
                    self.ActiveMode = detectedMode
                    Environment.__SquidNoMoFrontmanFarmingMode = detectedMode
                    self.PendingMode = nil
                    self.PendingCount = 0
                    self.LastModeEvidence = now
                elseif self.ActiveMode then
                    return {
                        MODE_PATHS[self.ActiveMode],
                    }, string.format(
                        "Frontman %s mode active; confirming switch to %s",
                        self.ActiveMode,
                        detectedMode
                    )
                else
                    return {}, "Confirming Frontman " .. detectedMode .. " mode"
                end
            end
        elseif self.ActiveMode then
            -- Mode labels often disappear immediately after the selection menu
            -- closes. Keep the last confirmed selection until clear evidence
            -- identifies the other mode.
            return {
                MODE_PATHS[self.ActiveMode],
            }, "Frontman " .. self.ActiveMode .. " mode active; using the last confirmed selection"
        else
            self.ActiveMode = nil
            self.PendingMode = nil
            self.PendingCount = 0
            return {}, detectionDetail or "Waiting for Frontman mode selection"
        end

        local mode = self.ActiveMode
        local path = mode and MODE_PATHS[mode]
        if not path then
            return {}, detectionDetail or "Waiting for Frontman mode selection"
        end

        return {
            path,
        }, string.format(
            "Frontman %s mode: %s",
            mode,
            detectionDetail or "running matching farming tasks"
        )
    end,
})


local savedMode = Environment.__SquidNoMoFrontmanFarmingMode
if savedMode == "Player" or savedMode == "Guard" then
    Controller.ActiveMode = savedMode
    Controller.LastModeEvidence = os.clock()
end

return Controller
