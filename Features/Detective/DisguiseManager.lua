local Players = game:GetService("Players")

local DisguiseManager = { Enabled = false, DetectionRange = 30, Worker = nil }

function DisguiseManager:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state
    if self.Worker then task.cancel(self.Worker); self.Worker = nil end
    if not state then return end

    self.Worker = task.spawn(function()
        while self.Enabled do
            local localPlayer = Players.LocalPlayer
            local character = localPlayer and localPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, player in ipairs(Players:GetPlayers()) do
                    local guardCharacter = player ~= localPlayer and player.Character
                    local guardRoot = guardCharacter and guardCharacter:FindFirstChild("HumanoidRootPart")
                    local teamName = player.Team and player.Team.Name:lower() or ""
                    if guardRoot and teamName:find("guard", 1, true)
                        and (guardRoot.Position - root.Position).Magnitude < self.DetectionRange then
                        local backpack = localPlayer:FindFirstChildOfClass("Backpack")
                        local disguise = (backpack and backpack:FindFirstChild("Disguise"))
                            or character:FindFirstChild("Disguise")
                        if disguise and disguise:IsA("Tool") then disguise.Parent = character end
                        break
                    end
                end
            end
            task.wait(0.5)
        end
        self.Worker = nil
    end)
end

function DisguiseManager:IsEnabled()
    return self.Enabled
end

return DisguiseManager
