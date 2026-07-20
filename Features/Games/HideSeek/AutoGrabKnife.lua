local AutoGrabKnife = {
    Enabled = false,
    TweenSpeed = 45, -- Studs per second. Adjust if anti-cheat still flags it.
}

function AutoGrabKnife:Toggle(state)
    local localPlayer = game.Players.LocalPlayer
    local TweenService = game:GetService("TweenService")
    
    self.Enabled = state
    
    if state then
        task.spawn(function()
            while self.Enabled do
                task.wait(0.5) -- Check for the knife every 0.5 seconds
                
                if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                
                local hasKnife = localPlayer.Character:FindFirstChild("Knife") or localPlayer.Backpack:FindFirstChild("Knife")
                if hasKnife then continue end 
                
                local knife = workspace:FindFirstChild("Knife", true) or workspace:FindFirstChild("Weapon", true)
                if knife and knife:IsA("Tool") and knife:FindFirstChild("Handle") then
                    
                    local hrp = localPlayer.Character.HumanoidRootPart
                    local targetCFrame = knife.Handle.CFrame
                    
                    -- Calculate safe travel time based on distance
                    local distance = (hrp.Position - targetCFrame.Position).Magnitude
                    local tweenTime = distance / self.TweenSpeed
                    
                    -- Create and play the tween
                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                    
                    tween:Play()
                    tween.Completed:Wait() -- Yield script until movement is finished
                    
                    -- Fire prompt once we arrive
                    if self.Enabled then
                        local prompt = knife:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Auto-Grab Knife (Safe) Enabled.")
    else
        print("[SquidNoMo]: Auto-Grab Knife Disabled.")
    end
end

return AutoGrabKnife
