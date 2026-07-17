print("CONFIG FILE EXECUTED")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "SquidNoMo",
		Text = "Config Executed",
		Duration = 5
	})
end)

return {
	Debug = true,
	Repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
}
