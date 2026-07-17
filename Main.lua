print("MAIN STARTED")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SquidNoMo",
        Text = "Main.lua Started",
        Duration = 10
    })
end)

return true
