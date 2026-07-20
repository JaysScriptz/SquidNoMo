local StarterGui = game:GetService("StarterGui")

local CoreGuiToggle = {}
CoreGuiToggle.__index = CoreGuiToggle

function CoreGuiToggle.new(coreGuiType)
    return setmetatable({CoreGuiType = coreGuiType, Enabled = false}, CoreGuiToggle)
end

function CoreGuiToggle:Enable()
    if self.Enabled then return end
    local ok = pcall(function()
        StarterGui:SetCoreGuiEnabled(self.CoreGuiType, false)
    end)
    self.Enabled = ok
end

function CoreGuiToggle:Disable()
    if not self.Enabled then return end
    local ok = pcall(function()
        StarterGui:SetCoreGuiEnabled(self.CoreGuiType, true)
    end)
    if ok then
        self.Enabled = false
    end
end

function CoreGuiToggle:IsEnabled()
    return self.Enabled
end

function CoreGuiToggle:GetState()
    return self.Enabled and "on" or "off"
end

return CoreGuiToggle
