local SettingsStore = {}

local HttpService = game:GetService("HttpService")

SettingsStore.FileName = "SquidNoMo-settings-v1.json"
SettingsStore.MemoryKey = "__SquidNoMoSavedSettings"
SettingsStore.SchemaVersion = 1

local function environment()
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then
            return value
        end
    end
    return _G
end

function SettingsStore:GetStorageMode()
    if type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
    then
        return "FILE"
    end
    return "SESSION"
end

function SettingsStore:Load()
    local env = environment()

    if type(isfile) == "function"
        and type(readfile) == "function"
    then
        local exists = false
        pcall(function()
            exists = isfile(self.FileName)
        end)

        if exists then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(self.FileName))
            end)
            if ok and type(data) == "table" then
                env[self.MemoryKey] = data
                return data
            end
        end
    end

    local cached = env[self.MemoryKey]
    return type(cached) == "table" and cached or nil
end

function SettingsStore:Save(data)
    if type(data) ~= "table" then
        return false, "INVALID"
    end

    data.SchemaVersion = self.SchemaVersion
    environment()[self.MemoryKey] = data

    if type(writefile) ~= "function" then
        return true, "SESSION"
    end

    local ok, message = pcall(function()
        writefile(self.FileName, HttpService:JSONEncode(data))
    end)

    if not ok then
        return false, tostring(message)
    end

    return true, "FILE"
end

function SettingsStore:Clear()
    environment()[self.MemoryKey] = nil

    if type(delfile) == "function"
        and type(isfile) == "function"
    then
        pcall(function()
            if isfile(self.FileName) then
                delfile(self.FileName)
            end
        end)
    end

    return true
end

return SettingsStore
