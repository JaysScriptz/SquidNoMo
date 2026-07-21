local EvidenceESP = require(script.Parent.EvidenceESP)
local EvidenceCollector = require(script.Parent.EvidenceCollector)
local BoatDepositor = require(script.Parent.BoatDepositor)
local DisguiseManager = require(script.Parent.DisguiseManager)

local DetectiveMasterController = { Enabled = false }

function DetectiveMasterController:Toggle(state)
    self.Enabled = state
    
    -- Turn on the full detective loop stack
    EvidenceESP:Toggle(state)
    EvidenceCollector:Toggle(state)
    BoatDepositor:Toggle(state)
    DisguiseManager:Toggle(state)
    
    if state then
        print("[SquidNoMo]: Detective Master Auto-Farm Fully Started. Pathfinding and evidence retrieval active.")
    else
        print("[SquidNoMo]: Detective Master Auto-Farm Stopped.")
    end
end

return DetectiveMasterController
