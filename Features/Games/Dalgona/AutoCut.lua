local AutoSolve = { Enabled = false }

function AutoSolve:Toggle(state)
    self.Enabled = state
    
    if state then
        -- We intercept the "Carve" RemoteEvent
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- FIND YOUR GAME'S EVENT: Look in Remotes or Network folder
        local carveEvent = ReplicatedStorage:FindFirstChild("Carve", true) or 
                           ReplicatedStorage:FindFirstChild("Trace", true)

        if carveEvent then
            -- Hook the firing mechanism
            self.Hook = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                if self == carveEvent and method == "FireServer" and AutoSolve.Enabled then
                    -- Force the server to think we traced the perfect coordinates
                    -- Most games use Vector2 or UDim2 for shape points
                    return self.FireServer(self, "Perfect", 100) 
                end
                return self.Hook(self, ...)
            end)
        end
    else
        -- Logic to revert the hook
        self.Hook = nil
    end
end

return AutoSolve
