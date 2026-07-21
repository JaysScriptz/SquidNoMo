local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoPlayerRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/PlayerRuntime.lua?squidnomo_revision=1_1b1_player_recode_r1")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "player.jump_power",
    Name = "Jump Power",
    Description = "Continuously applies the selected jump power and switches the humanoid to JumpPower mode when required.",
    Kind = "HumanoidValue",
    Property = "JumpPower",
    EnabledValue = 80,
    DefaultValue = 50,
    Min = 20,
    Max = 220,
    Interval = 0.1,
})
