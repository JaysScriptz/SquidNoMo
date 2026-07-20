local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local GuardLocalModerator = { Enabled = false, MaxRange = 60 } -- 60 studs limit prevents cross-map targeting

local function getActiveGameType()
    for _, child in ipairs(Workspace:GetChildren()) do
        local name = child.Name:lower()
        if name:match("rlgl") or name:match("glass") or name:match("dalgona") or name:match("hide") or name:match("marbles") then
            return name
        end
    end
    return "unknown"
end

function GuardLocalModerator:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local currentGame = getActiveGameType()
            if currentGame:match("rebellion") or currentGame:match("frontman") then return end
            
            local localPlayer = Players.LocalPlayer
            local character = localPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local nearestTarget = nil
            local shortestDist = self.MaxRange
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetChar = player.Character
                    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    
                    if humanoid and humanoid.Health > 0 then
                        local dist = (targetChar.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                        
                        -- Only target if they are within local range and breaking a rule (e.g., moving in RLGL)
                        if dist < shortestDist then
                            if currentGame:match("rlgl") and humanoid.MoveDirection.Magnitude > 0.05 then
                                shortestDist = dist
                                nearestTarget = targetChar:FindFirstChild("Head") or targetChar.HumanoidRootPart
                            elseif not currentGame:match("rlgl") then
                                shortestDist = dist
                                nearestTarget = targetChar:FindFirstChild("Head") or targetChar.HumanoidRootPart
                            end
                        end
                    end
                end
            end
            
            -- Aim and shoot only if a target is legally within range
            if nearestTarget then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearestTarget.Position)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
        end)
        print("[SquidNoMo]: GuardLocalModerator Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: GuardLocalModerator Disabled.")
    end
end

return GuardLocalModerator
