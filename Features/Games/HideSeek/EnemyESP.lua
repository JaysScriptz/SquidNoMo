local EnemyESP = {
    Highlights = {},
    AddedConnections = {},
}

function EnemyESP:Toggle(state)
    local localPlayer = game.Players.LocalPlayer

    local function applyEnemyESP(character)
        if not character:FindFirstChild("EnemyESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EnemyESP"
            highlight.Adornee = character
            -- Set to a distinct orange color so it differs from standard player ESP
            highlight.FillColor = Color3.fromRGB(255, 128, 0) 
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            table.insert(self.Highlights, highlight)
        end
    end

    if state then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                applyEnemyESP(player.Character)
            end
            
            if player ~= localPlayer then
                self.AddedConnections[player.Name] = player.CharacterAdded:Connect(function(char)
                    task.wait(0.5) 
                    applyEnemyESP(char)
                end)
            end
        end
        print("[SquidNoMo]: Enemy ESP Enabled.")
    else
        for _, hl in ipairs(self.Highlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        self.Highlights = {}
        
        for _, conn in pairs(self.AddedConnections) do
            conn:Disconnect()
        end
        self.AddedConnections = {}
        print("[SquidNoMo]: Enemy ESP Disabled.")
    end
end

return EnemyESP
