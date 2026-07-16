-- modules/Sidebar.lua
local Sidebar = {}

function Sidebar:Init(UI)
    -- Create the container for tab buttons
    local sidebarFrame = Instance.new("Frame", UI.Main)
    sidebarFrame.Size = UDim2.new(0, 120, 1, 0)
    sidebarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", sidebarFrame)

    -- Define your tabs
    local tabs = {"Player", "Games", "Settings"}
    
    for i, name in pairs(tabs) do
        local btn = Instance.new("TextButton", sidebarFrame)
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 50 + 10)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            print("Switched to tab: " .. name)
            -- Here you will trigger your Tab.lua logic to update the screen
        end)
    end
end

return Sidebar
