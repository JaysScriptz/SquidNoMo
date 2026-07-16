-- modules/Sidebar.lua
local Sidebar = {}

function Sidebar:Init(UI)
    local sidebarFrame = Instance.new("Frame", UI.Main)
    sidebarFrame.Size = UDim2.new(0, 150, 1, 0)
    sidebarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", sidebarFrame)

    local tabs = {"Player", "Combat", "Settings"}
    for i, name in pairs(tabs) do
        local btn = Instance.new("TextButton", sidebarFrame)
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = UDim2.new(0.1, 0, 0, (i-1) * 50 + 10)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            UI.ContentContainer:ClearAllChildren()
            print("Switched to: " .. name)
        end)
    end
end

return Sidebar
