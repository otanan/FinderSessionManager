--- === settings.lua ===
--- Author: Jonathan Delgado
---
--- Creates new and loads custom settings.
---
-- Module object
local settings = {}
-- Imports ----------
local helper = require(fsmPackagePath .. 'helper')


-- Generate a new settings file from a template
function settings.new()
    print('Generating a settings file.')
    local defaultSettingsPath = fsmPackagePath .. 'defaultSettings.json'
    local newSettingsPath = fsmPackagePath .. 'settings.json'
    helper.file.copy(defaultSettingsPath, newSettingsPath)
    return settings.load()
end


-- Load the settings, should only need to be done once.
function settings.load()
    -- Settings defines projects and their pinned folders
    local settingsData = helper.json.load('settings')
    -- New to make a new settings file
    if settingsData == nil then settingsData = settings.new() end
    return settingsData
end


-- Update the settings file
function settings.update(settingsData, readable)
    readable = readable ~= nil
    -- Update the actual file
    helper.json.dump(settingsData, 'settings', readable)
    print('Settings updated.')
end


-- Exit -------------------------------------------------
return settings