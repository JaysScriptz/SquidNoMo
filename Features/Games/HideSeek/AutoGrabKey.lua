local AutoGrabKey = {
    Enabled = false,
    TweenSpeed = 45,
}

function AutoGrabKey:Toggle(state)
    local localPlayer = game.Players.LocalPlayer
    local TweenService = game:GetService("TweenService")
    
    self.Enabled = state
    
    if state then
        task.spawn(function()
            while self.Enabled do
                task.wait(0.5)
                
                if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                
                local hasKey = localPlayer.Character:FindFirstChild("Key") or localPlayer.Backpack:FindFirstChild("Key")
                if hasKey then continue end 
                
                local key = workspace:FindFirstChild("Key", true) or workspace:FindFirstChild("DroppedKey", true)
                if key and key:IsA("Tool") and key:FindFirstChild("Handle") then
                    
                    local hrp = localPlayer.Character.HumanoidRootPart
                    local targetCFrame = key.Handle.CFrame
                    
                    -- Calculate safe travel time
                    local distance = (hrp.Position - targetCFrame.Position).Magnitude
                    local tweenTime = distance / self.TweenSpeed
                    
                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                    
                    tween:Play()
                    tween.Completed:Wait() 
                    
                    if self.Enabled then
                        local prompt = key:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Auto-Grab Key (Safe) Enabled.")
    else
        print("[SquidNoMo]: Auto-Grab Key Disabled.")
    end
end

return AutoGrabKey
