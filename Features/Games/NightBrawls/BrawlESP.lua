local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BrawlESP = { Enabled = false, Highlights = {} }

function BrawlESP:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    local char = player.Character
                    if not char:FindFirstChild("BrawlHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "BrawlHL"
                        hl.Adornee = char
                        hl.FillColor = Color3.fromRGB(255, 100, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = char
                        table.insert(self.Highlights, hl)
                    end
                end
            end
        end)
        print("[SquidNoMo]: BrawlESP Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        for _, hl in ipairs(self.Highlights) do if hl then hl:Destroy() end end
        self.Highlights = {}
        print("[SquidNoMo]: BrawlESP Disabled.")
    end
end

return BrawlESP
