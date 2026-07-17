print("TEST 1")
warn("TEST 2")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "SquidNoMo",
		Text = "Test Successful",
		Duration = 10
	})
end)

return true
