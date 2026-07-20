local HighlightShape = { Enabled = false }

function HighlightShape:Toggle(state)
    self.Enabled = state
    local gui = game.Players.LocalPlayer.PlayerGui
    
    -- Find the shape container
    local shape = gui:FindFirstChild("ShapeContainer", true) or gui:FindFirstChild("Cookie", true)
    
    if shape and state then
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Name = "AutoSolveStroke"
        uiStroke.Color = Color3.fromRGB(0, 255, 0)
        uiStroke.Thickness = 5
        uiStroke.Parent = shape
    elseif shape then
        local existing = shape:FindFirstChild("AutoSolveStroke")
        if existing then existing:Destroy() end
    end
end

return HighlightShape
