local AutoJump = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Enabled = false
local Connection = nil
local LastJumpAt = 0
local JumpCooldown = 0.24

local function getCharacterParts()
    local player = Players.LocalPlayer
    local character = player and player.Character
    if not character then
        return nil, nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    return character, humanoid, root
end

local function isGrounded(character, humanoid, root)
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        return true
    end

    if not root then
        return false
    end

    local parameters = RaycastParams.new()
    parameters.FilterType = Enum.RaycastFilterType.Exclude
    parameters.FilterDescendantsInstances = {character}
    parameters.IgnoreWater = false

    local distance = math.max(4, (humanoid.HipHeight or 2) + 2.5)
    local result = Workspace:Raycast(
        root.Position,
        Vector3.new(0, -distance, 0),
        parameters
    )

    return result ~= nil
end

local function canJump(humanoid)
    if humanoid.Health <= 0 or humanoid.Sit then
        return false
    end

    local state = humanoid:GetState()
    return state ~= Enum.HumanoidStateType.Dead
        and state ~= Enum.HumanoidStateType.Seated
        and state ~= Enum.HumanoidStateType.Swimming
        and state ~= Enum.HumanoidStateType.Climbing
end

local function requestJump(humanoid)
    humanoid.Jump = true

    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)

    task.defer(function()
        if humanoid and humanoid.Parent then
            humanoid.Jump = false
        end
    end)
end

function AutoJump:Enable()
    if Enabled then
        return true
    end

    Enabled = true
    LastJumpAt = 0

    Connection = RunService.Stepped:Connect(function()
        if not Enabled then
            return
        end

        local character, humanoid, root = getCharacterParts()
        if not character or not humanoid or not canJump(humanoid) then
            return
        end

        if humanoid.MoveDirection.Magnitude <= 0.05 then
            return
        end

        if not isGrounded(character, humanoid, root) then
            return
        end

        local now = os.clock()
        if now - LastJumpAt < JumpCooldown then
            return
        end

        LastJumpAt = now
        requestJump(humanoid)
    end)

    return true
end

function AutoJump:Disable()
    Enabled = false
    LastJumpAt = 0

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    return true
end

function AutoJump:IsEnabled()
    return Enabled
end

function AutoJump:GetState()
    return Enabled and "on" or "off"
end

return AutoJump
