local KitchenSupplyGrabber = require(script.Parent.Kitchen.KitchenSupplyGrabber)
local KitchenPotCooker = require(script.Parent.Kitchen.KitchenPotCooker)
local KitchenCookedHandler = require(script.Parent.Kitchen.KitchenCookedHandler)
local CoffinCollector = require(script.Parent.Furnace.CoffinCollector)
local CoffinDisposer = require(script.Parent.Furnace.CoffinDisposer)
local GameDependentAutoKill = require(script.Parent.Moderation.GameDependentAutoKill)

local GuardMasterController = { Enabled = false }

function GuardMasterController:Toggle(state)
    self.Enabled = state
    
    -- Toggles all Guard sub-features simultaneously for a complete walk-away loop
    KitchenSupplyGrabber:Toggle(state)
    KitchenPotCooker:Toggle(state)
    KitchenCookedHandler:Toggle(state)
    CoffinCollector:Toggle(state)
    CoffinDisposer:Toggle(state)
    GameDependentAutoKill:Toggle(state)
    
    if state then
        print("[SquidNoMo]: Guard Master Auto-Farm Fully Started. Walk away safely.")
    else
        print("[SquidNoMo]: Guard Master Auto-Farm Stopped.")
    end
end

return GuardMasterController
