print("LOADER STARTED")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "SquidNoMo",
		Text = "Loader Started",
		Duration = 5
	})
end)

return {
	Theme = {},
	Components = {},
	Navigation = {},
	Notifications = {},
	Utilities = {},
	Home = {
		Load = function()
			print("HOME FUNCTION")
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "SquidNoMo",
					Text = "Home Function",
					Duration = 5
				})
			end)
		end
	}
}
