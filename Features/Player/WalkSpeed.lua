local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoPlayerRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-player-ultralight-r3" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/PlayerRuntime.lua?squidnomo_revision=1_1b1_player_ultralight_r3")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-player-ultralight-r3" then
    error("SquidNoMo player runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "player.walk_speed",
    Name = "Walk Speed",
    Description = "Continuously applies the selected walking speed to the local humanoid and reapplies it after respawn.",
    Kind = "HumanoidValue",
    Property = "WalkSpeed",
    EnabledValue = 32,
    DefaultValue = 16,
    Min = 8,
    Max = 120,
    Interval = 0.1,
})
