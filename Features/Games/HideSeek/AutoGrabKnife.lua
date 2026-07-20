local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local AutoGrabKnife = { Enabled = false, TweenSpeed = 45, Worker = nil, ActiveTween = nil }

function AutoGrabKnife:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state
    if self.ActiveTween then self.ActiveTween:Cancel(); self.ActiveTween = nil end
    if self.Worker then task.cancel(self.Worker); self.Worker = nil end
    if not state then return end

    self.Worker = task.spawn(function()
        while self.Enabled do
            local player = Players.LocalPlayer
            local character = player and player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local backpack = player and player:FindFirstChildOfClass("Backpack")
            local hasKnife = character and character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
            if root and not hasKnife then
                local knife = Workspace:FindFirstChild("Knife", true) or Workspace:FindFirstChild("Weapon", true)
                local handle = knife and knife:IsA("Tool") and knife:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local distance = (root.Position - handle.Position).Magnitude
                    local tween = TweenService:Create(root, TweenInfo.new(math.max(0.05, distance / self.TweenSpeed), Enum.EasingStyle.Linear), {CFrame = handle.CFrame})
                    self.ActiveTween = tween
                    tween:Play()
                    tween.Completed:Wait()
                    self.ActiveTween = nil
                    if self.Enabled then
                        local prompt = knife:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and type(fireproximityprompt) == "function" then pcall(fireproximityprompt, prompt) end
                    end
                end
            end
            task.wait(0.5)
        end
        self.Worker = nil
    end)
end

function AutoGrabKnife:IsEnabled() return self.Enabled end
return AutoGrabKnife
