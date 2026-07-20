local UI = {}

function UI:Initialize(Loader)
    local function Load(name)
        local path = "Features/UI/" .. name .. ".lua"
        if type(Loader.LoadRemote) == "function" then
            return Loader:LoadRemote(path)
        end
        return loadstring(game:HttpGet(
            Loader.Config.Repository .. path
        ))()
    end

    local CoreGuiToggle = Load("CoreGuiToggle")

    local function CreateCoreToggle(enumName)
        local ok, enumItem = pcall(function()
            return Enum.CoreGuiType[enumName]
        end)
        if ok and enumItem then
            return CoreGuiToggle.new(enumItem)
        end

        local unavailable = {Enabled = false}
        function unavailable:Enable() self.Enabled = false end
        function unavailable:Disable() self.Enabled = false end
        function unavailable:IsEnabled() return false end
        function unavailable:GetState() return "off" end
        return unavailable
    end

    self.Crosshair = Load("Crosshair")
    self.PerformanceHUD = Load("PerformanceHUD")
    self.RoleLegend = Load("RoleLegend")
    self.SessionHUD = Load("SessionHUD")
    self.CoordinatesHUD = Load("CoordinatesHUD")
    self.SpeedHUD = Load("SpeedHUD")
    self.CompassHUD = Load("CompassHUD")
    self.ServerHUD = Load("ServerHUD")
    self.ClockHUD = Load("ClockHUD")

    self.HideChat = CreateCoreToggle("Chat")
    self.HidePlayerList = CreateCoreToggle("PlayerList")
    self.HideBackpack = CreateCoreToggle("Backpack")
    self.HideHealth = CreateCoreToggle("Health")
    self.HideEmotes = CreateCoreToggle("EmotesMenu")

    self.RemoveBlur = Load("RemoveBlur")
    self.Fullbright = Load("Fullbright")
    self.ScreenEffects = Load("ScreenEffects")
    self.RemoveAtmosphere = Load("RemoveAtmosphere")
    self.RemoveFog = Load("RemoveFog")
    self.DisableShadows = Load("DisableShadows")
    self.DisableParticles = Load("DisableParticles")
    self.CameraFOV = Load("CameraFOV")
    self.HighContrast = Load("HighContrast")

    local manager = Loader.FeatureManager
    if manager and type(manager.RegisterFeature) == "function" then
        manager:RegisterFeature("ui.crosshair", self.Crosshair, {Name = "Crosshair", Category = "Safe", DefaultColor = Color3.fromRGB(255, 58, 145)})
        manager:RegisterFeature("ui.performance_hud", self.PerformanceHUD, {Name = "Performance HUD", Category = "Safe"})
        manager:RegisterFeature("ui.role_legend", self.RoleLegend, {Name = "Role Legend", Category = "Safe"})
        manager:RegisterFeature("ui.session_hud", self.SessionHUD, {Name = "Session Timer HUD", Category = "Safe"})
        manager:RegisterFeature("ui.coordinates_hud", self.CoordinatesHUD, {Name = "Coordinates HUD", Category = "Safe"})
        manager:RegisterFeature("ui.speed_hud", self.SpeedHUD, {Name = "Speed HUD", Category = "Safe"})
        manager:RegisterFeature("ui.compass_hud", self.CompassHUD, {Name = "Compass HUD", Category = "Safe"})
        manager:RegisterFeature("ui.server_hud", self.ServerHUD, {Name = "Server Info HUD", Category = "Safe"})
        manager:RegisterFeature("ui.clock_hud", self.ClockHUD, {Name = "Clock HUD", Category = "Safe"})

        manager:RegisterFeature("ui.hide_chat", self.HideChat, {Name = "Hide Chat", Category = "Safe"})
        manager:RegisterFeature("ui.hide_player_list", self.HidePlayerList, {Name = "Hide Player List", Category = "Safe"})
        manager:RegisterFeature("ui.hide_backpack", self.HideBackpack, {Name = "Hide Backpack", Category = "Safe"})
        manager:RegisterFeature("ui.hide_health", self.HideHealth, {Name = "Hide Health UI", Category = "Safe"})
        manager:RegisterFeature("ui.hide_emotes", self.HideEmotes, {Name = "Hide Emotes UI", Category = "Safe"})

        manager:RegisterFeature("ui.remove_blur", self.RemoveBlur, {Name = "Remove Blur", Category = "Safe"})
        manager:RegisterFeature("ui.fullbright", self.Fullbright, {Name = "Fullbright", Category = "SemiSafe"})
        manager:RegisterFeature("ui.screen_effects", self.ScreenEffects, {Name = "Disable Screen Effects", Category = "SemiSafe"})
        manager:RegisterFeature("ui.remove_atmosphere", self.RemoveAtmosphere, {Name = "Remove Atmosphere", Category = "Safe"})
        manager:RegisterFeature("ui.remove_fog", self.RemoveFog, {Name = "Remove Fog", Category = "Safe"})
        manager:RegisterFeature("ui.disable_shadows", self.DisableShadows, {Name = "Disable Shadows", Category = "Safe"})
        manager:RegisterFeature("ui.disable_particles", self.DisableParticles, {Name = "Disable Particles", Category = "Safe"})
        manager:RegisterFeature("ui.camera_fov", self.CameraFOV, {Name = "Camera FOV", Category = "Safe", DefaultValue = 70})
        manager:RegisterFeature("ui.high_contrast", self.HighContrast, {Name = "High Contrast", Category = "Safe"})
    end

    return self
end

return UI
