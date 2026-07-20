local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RPSMinusOne = { Enabled = false, HasSelected = false }

local function isRPSActive()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local gui = playerGui:FindFirstChild("MinusOneGui", true) or playerGui:FindFirstChild("RPSGui", true) or playerGui:FindFirstChild("RockPaperScissorsGui", true)
    return gui and gui.Enabled
end

function RPSMinusOne:Toggle(state)
    self.Enabled = state
    
    if state then
        self.HasSelected = false
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled or self.HasSelected then return end
            if not isRPSActive() then return end
            
            self.HasSelected = true
            local choices = {"Rock", "Paper", "Scissors"}
            local chosenMove = choices[math.random(1, #choices)]
            
            local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
            if eventsFolder then
                for _, remote in ipairs(eventsFolder:GetChildren()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():match("rps") or remote.Name:lower():match("minus") or remote.Name:lower():match("choice") or remote.Name:lower():match("hand")) then
                        pcall(function()
                            remote:FireServer(chosenMove)
                        end)
                    end
                end
            end
        end)
        print("[SquidNoMo]: RPSMinusOne Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: RPSMinusOne Disabled.")
    end
end

return RPSMinusOne
