local HighContrast = {}
local Lighting = game:GetService("Lighting")

local Enabled = false
local Effect = nil

local function build()
    if Effect and Effect.Parent then return end
    Effect = Lighting:FindFirstChild("SquidNoMo_HighContrast")
    if not Effect then
        Effect = Instance.new("ColorCorrectionEffect")
        Effect.Name = "SquidNoMo_HighContrast"
        Effect.Brightness = 0.03
        Effect.Contrast = 0.28
        Effect.Saturation = 0.08
        Effect.TintColor = Color3.fromRGB(255, 250, 255)
        Effect.Parent = Lighting
    end
end

function HighContrast:Enable()
    if Enabled then return end
    Enabled = true
    build()
    Effect.Enabled = true
end

function HighContrast:Disable()
    Enabled = false
    if Effect then
        Effect:Destroy()
        Effect = nil
    end
end

function HighContrast:IsEnabled() return Enabled end
function HighContrast:GetState() return Enabled and "on" or "off" end

return HighContrast
