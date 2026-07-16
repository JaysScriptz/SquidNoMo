-- Modules/Player.lua
local Player = {}
function Player:Init(UI)
    UI:AddButton("Speed 50", function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end)
    UI:AddButton("Jump 100", function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
    end)
end
return Player
