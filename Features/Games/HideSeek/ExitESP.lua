local ExitESP = {
    Highlights = {},
}

function ExitESP:Toggle(state, mapFolder)
    if state then
        if not mapFolder then 
            warn("[SquidNoMo]: Map folder not provided for Exit ESP.")
            return 
        end
        
        for _, part in ipairs(mapFolder:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():match("exit") or part.Name:lower():match("door")) then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ExitESP"
                highlight.Adornee = part
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Bright Green
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = part
                
                table.insert(self.Highlights, highlight)
            end
        end
        print("[SquidNoMo]: Exit ESP Enabled.")
    else
        for _, hl in ipairs(self.Highlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        self.Highlights = {}
        print("[SquidNoMo]: Exit ESP Disabled.")
    end
end

return ExitESP
