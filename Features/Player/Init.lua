local Player = {}

function Player:Initialize(Loader)
    local function Load(moduleName)
        return loadstring(game:HttpGet(
            Loader.Config.Repository .. "Features/Player/" .. moduleName .. ".lua"
        ))()
    end

    self.WalkSpeed = Load("WalkSpeed")
    self.JumpPower = Load("JumpPower")
    self.InfiniteJump = Load("InfiniteJump")
    self.Noclip = Load("Noclip")

    self.PlayerESP = Load("PlayerESP")
    self.GuardESP = Load("GuardESP")
    self.DetectiveESP = Load("DetectiveESP")
    self.FrontmanESP = Load("FrontmanESP")

    self.AntiAFK = Load("AntiAFK")
    self.AntiLag = Load("AntiLag")
    self.Reset = Load("Reset")
    self.Rejoin = Load("Rejoin")

    for _, feature in ipairs({self.PlayerESP, self.GuardESP, self.DetectiveESP, self.FrontmanESP}) do
        if type(feature.Initialize) == "function" then
            feature:Initialize(Loader)
        end
    end

    local manager = Loader.FeatureManager
    if manager and type(manager.RegisterFeature) == "function" then
        manager:RegisterFeature("player.walk_speed", self.WalkSpeed, {Name = "Walk Speed", Category = "SemiSafe"})
        manager:RegisterFeature("player.jump_power", self.JumpPower, {Name = "Jump Power", Category = "SemiSafe"})
        manager:RegisterFeature("player.infinite_jump", self.InfiniteJump, {Name = "Infinite Jump", Category = "SemiSafe"})
        manager:RegisterFeature("player.noclip", self.Noclip, {Name = "Noclip", Category = "Experimental"})

        manager:RegisterFeature("player.player_esp", self.PlayerESP, {Name = "Player ESP", Category = "Safe"})
        manager:RegisterFeature("player.guard_esp", self.GuardESP, {Name = "Guard ESP", Category = "Safe"})
        manager:RegisterFeature("player.detective_esp", self.DetectiveESP, {Name = "Detective ESP", Category = "Safe"})
        manager:RegisterFeature("player.frontman_esp", self.FrontmanESP, {Name = "Frontman ESP", Category = "Safe"})

        manager:RegisterFeature("player.anti_afk", self.AntiAFK, {Name = "Anti AFK", Category = "Safe"})
        manager:RegisterFeature("player.anti_lag", self.AntiLag, {Name = "Anti Lag", Category = "Safe"})
    end

    return self
end

return Player
