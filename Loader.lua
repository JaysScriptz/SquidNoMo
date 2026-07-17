print("Loader started")

return {
    Theme = {},
    Components = {},
    Navigation = {},
    Notifications = {},
    Utilities = {},
    Home = {
        Load = function(App)
            print("HOME LOADED")
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title="SquidNoMo",
                    Text="Home Loaded",
                    Duration=10
                })
            end)
        end
    }
}
