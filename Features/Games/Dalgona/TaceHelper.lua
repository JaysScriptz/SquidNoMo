local TraceHelper = { Enabled = false, Adorner = nil }

function TraceHelper:Toggle(state)
    self.Enabled = state
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui

    if state then
        -- Find the Shape UI (adjust name based on your game)
        local cookieFrame = gui:FindFirstChild("Shape", true) or gui:FindFirstChild("Cookie", true)
        
        if cookieFrame then
            -- Create a visual guide path
            self.Adorner = Instance.new("Frame")
            self.Adorner.Name = "TraceGuide"
            self.Adorner.Size = UDim2.new(0.1, 0, 0.1, 0)
            self.Adorner.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            self.Adorner.BorderSizePixel = 0
            self.Adorner.Parent = cookieFrame
            
            -- Logic: Follow the mouse or highlight the target path
            task.spawn(function()
                while self.Enabled do
                    local mouse = player:GetMouse()
                    -- Snap the visual guide to the mouse for better precision
                    self.Adorner.Position = UDim2.new(0, mouse.X - cookieFrame.AbsolutePosition.X, 0, mouse.Y - cookieFrame.AbsolutePosition.Y)
                    task.wait()
                end
            end)
        end
    else
        if self.Adorner then self.Adorner:Destroy() end
    end
end

return TraceHelper
