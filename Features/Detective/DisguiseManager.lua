local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local DisguiseManager = { Enabled = false, DetectionRange = 30 }

function DisguiseManager:Toggle(state)
    self.Enabled = state
    task.spawn(function()
        while self.Enabled do
            local char = Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Team and player.Team.Name == "Guards" and player.Character then
                        local guardHrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if guardHrp and (guardHrp.Position - hrp.Position).Magnitude < self.DetectionRange then
                            -- Auto-Equip Disguise
                            local disguise = Players.LocalPlayer.Backpack:FindFirstChild("Disguise") 
                                          or Players.LocalPlayer.Character:FindFirstChild("Disguise")
                            if disguise and disguise:IsA("Tool") then
                                disguise.Parent = char
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

return DisguiseManager
