--- === res.lua ===
--- Author: Jonathan Delgado
---
--- Resource manager, such as for images, icons etc. Any external files
--- with specific IO conventions (paths etc.)
---
-- Module object
local res = {}
local helper = require(workingDir .. 'helper')


-- Settings -------------------------------------------------
res.settings = {}

-- Generate a new settings file from a template
function res.settings.new()
    print('Generating a settings file.')
    local defaultSettingsPath = workingDir .. 'defaultSettings.json'
    local newSettingsPath = workingDir .. 'settings.json'
    helper.file.copy(defaultSettingsPath, newSettingsPath)
    return res.settings.load()
end


-- Load the settings, should only need to be done once.
function res.settings.load()
    -- Settings defines projects and their pinned folders
    local settings = helper.json.load('settings')
    -- New to make a new settings file
    if settings == nil then settings = res.settings.new() end
    return settings
end



-- Images -------------------------------------------------
res.images = {}

-- Opens a file explorer to get an image and returns the path to the image
function res.images.chooseFromFileSystem()
    local paths = hs.dialog.chooseFileOrFolder(
        'Choose an image', '~/Pictures', true, false, false,
        { 'jpg', 'jpeg', 'png' }, true
    )

    if paths == nil then return nil end
    return paths['1']
end


-- Returns the path to the saved image
function res.images.getSavedPath(name) return workingDir .. 'icons/' .. name end


-- Copies the image to an images folder and returns the new path to the image
function res.images.save(path)
    local name = helper.file.name(path)
    -- Copy the file to the new folder
    helper.file.copy(path, res.images.getSavedPath(name))
    return name
end


-- Load image from saved images path by name
function res.images.load(name)
    return hs.image.imageFromPath(res.images.getSavedPath(name))
end


-- Exit -------------------------------------------------
return res