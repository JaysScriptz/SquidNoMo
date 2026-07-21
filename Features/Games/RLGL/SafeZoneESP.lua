local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.games.red_light_green_light.safezoneesp",
    Name = "Safe Zone ESP",
    Description = "Marks safe areas and the finish zone to make the route easier to read.",
    Kind = "Highlight",
    TargetTokens = {"safe zone", "finish", "end zone", "goal"},
    ExcludeTokens = {"start", "spawn"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(60, 255, 126),
    WaitingMessage = "Waiting for the finish or safe zone",
})
