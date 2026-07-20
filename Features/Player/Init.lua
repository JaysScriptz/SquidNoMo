local Player = {}

function Player:Initialize(Loader)
    local function Load(name)
        local path = "Features/Player/" .. name .. ".lua"
        if type(Loader.LoadRemote) == "function" then
            return Loader:LoadRemote(path)
        end
        return loadstring(game:HttpGet(
            Loader.Config.Repository .. path
        ))()
    end

    self.WalkSpeed = Load("WalkSpeed")
    self.JumpPower = Load("JumpPower")
    self.Gravity = Load("Gravity")
    self.InfiniteJump = Load("InfiniteJump")
    self.AutoJump = Load("AutoJump")
    self.Noclip = Load("NoClip")
    self.ForceThirdPerson = Load("ForceThirdPerson")
    self.UnlockZoom = Load("UnlockZoom")
    self.AutoStand = Load("AutoStand")

    self.PlayerESP = Load("PlayerESP")
    self.GuardESP = Load("GuardESP")
    self.DetectiveESP = Load("DetectiveESP")
    self.FrontmanESP = Load("FrontmanESP")
    self.DistanceESP = Load("DistanceESP")
    self.HealthESP = Load("HealthESP")

    self.AntiAFK = Load("AntiAFK")
    self.AntiLag = Load("AntiLag")
    self.HideOthers = Load("HideOthers")
    self.HideSelf = Load("HideSelf")
    self.MuteCharacterSounds = Load("MuteCharacterSounds")
    self.Reset = Load("Reset")
    self.Rejoin = Load("Rejoin")

    for _, feature in ipairs({
        self.PlayerESP,
        self.GuardESP,
        self.DetectiveESP,
        self.FrontmanESP,
    }) do
        if type(feature.Initialize) == "function" then
            feature:Initialize(Loader)
        end
    end

    local manager = Loader.FeatureManager
    if manager and type(manager.RegisterFeature) == "function" then
        manager:RegisterFeature("player.walk_speed", self.WalkSpeed, {Name = "Walk Speed", Category = "SemiSafe", DefaultValue = 16})
        manager:RegisterFeature("player.jump_power", self.JumpPower, {Name = "Jump Power", Category = "SemiSafe", DefaultValue = 50})
        manager:RegisterFeature("player.gravity", self.Gravity, {Name = "Gravity", Category = "SemiSafe", DefaultValue = 196.2})
        manager:RegisterFeature("player.infinite_jump", self.InfiniteJump, {Name = "Infinite Jump", Category = "SemiSafe"})
        manager:RegisterFeature("player.auto_jump", self.AutoJump, {Name = "Auto Jump", Category = "SemiSafe"})
        manager:RegisterFeature("player.noclip", self.Noclip, {Name = "Noclip", Category = "Experimental"})
        manager:RegisterFeature("player.force_third_person", self.ForceThirdPerson, {Name = "Force Third Person", Category = "Safe"})
        manager:RegisterFeature("player.unlock_zoom", self.UnlockZoom, {Name = "Unlock Camera Zoom", Category = "Safe"})
        manager:RegisterFeature("player.auto_stand", self.AutoStand, {Name = "Auto Stand", Category = "Safe"})

        manager:RegisterFeature("player.player_esp", self.PlayerESP, {Name = "Player ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 170, 255)})
        manager:RegisterFeature("player.guard_esp", self.GuardESP, {Name = "Guard ESP", Category = "Safe", DefaultColor = Color3.fromRGB(235, 55, 70)})
        manager:RegisterFeature("player.detective_esp", self.DetectiveESP, {Name = "Detective ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 230, 150)})
        manager:RegisterFeature("player.frontman_esp", self.FrontmanESP, {Name = "Frontman ESP", Category = "Safe", DefaultColor = Color3.fromRGB(172, 76, 255)})
        manager:RegisterFeature("player.distance_esp", self.DistanceESP, {Name = "Distance ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 205, 255)})
        manager:RegisterFeature("player.health_esp", self.HealthESP, {Name = "Health ESP", Category = "Safe"})

        manager:RegisterFeature("player.anti_afk", self.AntiAFK, {Name = "Anti AFK", Category = "Safe"})
        manager:RegisterFeature("player.anti_lag", self.AntiLag, {Name = "Anti Lag", Category = "Safe"})
        manager:RegisterFeature("player.hide_others", self.HideOthers, {Name = "Hide Other Players", Category = "Safe"})
        manager:RegisterFeature("player.hide_self", self.HideSelf, {Name = "Hide Local Character", Category = "Safe"})
        manager:RegisterFeature("player.mute_character_sounds", self.MuteCharacterSounds, {Name = "Mute Character Sounds", Category = "Safe"})
    end

    return self
end

return Player
