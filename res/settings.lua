--- === settings.lua ===
--- Author: Jonathan Delgado
---
--- Creates new and loads custom settings.
---
-- Module object
local settings = {}
-- Imports ----------
local helper = require(workingDir .. 'helper')


-- Generate a new settings file from a template
function settings.new()
    print('Generating a settings file.')
    local defaultSettingsPath = workingDir .. 'defaultSettings.json'
    local newSettingsPath = workingDir .. 'settings.json'
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


-- Exit -------------------------------------------------
return settings